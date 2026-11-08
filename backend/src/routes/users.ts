import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";
import { requireAuth, invalidateUserCache } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import { upload } from "../middleware/upload";
import { generateToken } from "../services/authService";
import { deletePhotoFromS3, uploadPhoto } from "../services/photoService";
import { reEvaluateGroupStatus, findUserGroup } from "../services/groupService";
import { serializeOwnUser } from "../lib/serializers";
import semver from "semver";
import { env } from "../config/env";

export const usersRouter = Router();

// GET /check_ios_version
usersRouter.get(
  "/check_ios_version",
  validateQuery(z.object({ ios_version: z.string().min(1) })),
  async (req, res) => {
    try {
      const { ios_version } = req.query as { ios_version: string };
      const appVersion = await prisma.appVersion.findFirst({
        where: { platform: "ios" },
        orderBy: { id: "desc" },
      });

      const minVersion = appVersion?.min_version ?? env.MIN_IOS_VERSION;
      const isValid = semver.gte(
        semver.coerce(ios_version)?.version ?? "0.0.0",
        semver.coerce(minVersion)?.version ?? "0.0.0"
      );

      ok(res, { is_valid: isValid });
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /user_signup
usersRouter.post(
  "/user_signup",
  validateBody(z.object({ phone_number: z.string().min(1) })),
  async (req, res) => {
    try {
      const { phone_number } = req.body as { phone_number: string };
      const token = generateToken();

      const user = await prisma.user.upsert({
        where: { phone_number },
        update: { authentication_token: token },
        create: {
          phone_number,
          authentication_token: token,
          setting: { create: {} },
        },
        include: { photos: true, devices: true },
      });

      ok(res, serializeOwnUser(user));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /user_by_auth_token
usersRouter.get("/user_by_auth_token", requireAuth, (req, res) => {
  ok(res, serializeOwnUser(req.user));
});

// GET /user_by_phone_number
usersRouter.get(
  "/user_by_phone_number",
  validateQuery(z.object({ phone_number: z.string().min(1) })),
  async (req, res) => {
    try {
      const { phone_number } = req.query as { phone_number: string };
      const user = await prisma.user.findUnique({
        where: { phone_number },
        include: { photos: true, devices: true },
      });

      if (!user) {
        fail(res, 404, "Not found");
        return;
      }

      ok(res, serializeOwnUser(user));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /edit_profile
usersRouter.post(
  "/edit_profile",
  requireAuth,
  validateBody(
    z.object({
      gender: z.enum(["male", "female"]).optional(),
      first_name: z.string().optional(),
      last_name: z.string().optional(),
      user_name: z.string().optional(),
      bio: z.string().optional(),
      dob: z.number().int().optional(),
    })
  ),
  async (req, res) => {
    try {
      const updates = req.body as {
        gender?: string;
        first_name?: string;
        last_name?: string;
        user_name?: string;
        bio?: string;
        dob?: number;
      };

      let age: number | undefined;
      if (updates.dob != null) {
        const birthYear = new Date(updates.dob * 1000).getFullYear();
        age = new Date().getFullYear() - birthYear;
        if (age < 18) {
          fail(res, 422, "Must be at least 18 years old");
          return;
        }
      }

      if (updates.user_name) {
        updates.user_name = updates.user_name.toLowerCase();
      }

      const user = await prisma.user.update({
        where: { id: req.user.id },
        data: { ...updates, ...(age != null ? { age } : {}) },
        include: { photos: true, devices: true },
      });

      await invalidateUserCache(req.user.authentication_token);

      const group = await findUserGroup(user.id);
      if (group) {
        await reEvaluateGroupStatus(group.id);
      }

      ok(res, serializeOwnUser(user));
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "";
      if (msg.includes("Unique constraint") && msg.includes("user_name")) {
        fail(res, 422, "Username taken");
        return;
      }
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /user_name_available
usersRouter.get(
  "/user_name_available",
  validateQuery(z.object({ user_name: z.string().min(1) })),
  async (req, res) => {
    try {
      const { user_name } = req.query as { user_name: string };
      const existing = await prisma.user.findUnique({
        where: { user_name: user_name.toLowerCase() },
        select: { id: true },
      });

      if (existing) {
        fail(res, 422, "Username taken");
      } else {
        ok(res, null, "Available");
      }
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// DELETE /delete_account
usersRouter.delete(
  "/delete_account",
  requireAuth,
  validateBody(z.object({ reason: z.string().optional() })),
  async (req, res) => {
    try {
      const { reason } = req.body as { reason?: string };
      const userId = req.user.id;

      const photos = await prisma.photo.findMany({ where: { user_id: userId } });
      await Promise.allSettled(
        photos.map((p) =>
          deletePhotoFromS3({ original: p.original, medium: p.medium, thumb: p.thumb })
        )
      );

      await prisma.$transaction([
        prisma.groupMember.deleteMany({ where: { user_id: userId } }),
        prisma.friendship.deleteMany({
          where: {
            OR: [{ requester_id: userId }, { addressee_id: userId }],
            status: "accepted",
          },
        }),
        prisma.photo.deleteMany({ where: { user_id: userId } }),
        prisma.deletionLog.upsert({
          where: { user_id: userId },
          update: { reason },
          create: { user_id: userId, reason },
        }),
        prisma.user.update({
          where: { id: userId },
          data: {
            phone_number: `deleted_${userId}`,
            first_name: null,
            last_name: null,
            user_name: null,
            is_blocked: true,
          },
        }),
      ]);

      await invalidateUserCache(req.user.authentication_token);
      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /update_coordinates
usersRouter.post(
  "/update_coordinates",
  requireAuth,
  validateBody(
    z.object({
      latitude: z.string().min(1),
      longitude: z.string().min(1),
    })
  ),
  async (req, res) => {
    try {
      const { latitude, longitude } = req.body as {
        latitude: string;
        longitude: string;
      };

      const user = await prisma.user.update({
        where: { id: req.user.id },
        data: { latitude, longitude },
        include: { photos: true, devices: true },
      });

      await invalidateUserCache(req.user.authentication_token);

      const group = await findUserGroup(user.id);
      if (group) {
        await prisma.group.update({
          where: { id: group.id },
          data: { city: user.city, state: user.state },
        });
        await reEvaluateGroupStatus(group.id);
      }

      ok(res, serializeOwnUser(user));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /search_by_user_name
usersRouter.get(
  "/search_by_user_name",
  requireAuth,
  validateQuery(z.object({ user_name: z.string().min(1) })),
  async (req, res) => {
    try {
      const { user_name } = req.query as { user_name: string };
      const myId = req.user.id;

      const users = await prisma.user.findMany({
        where: {
          id: { not: myId },
          user_name: { contains: user_name.toLowerCase(), mode: "insensitive" },
          is_blocked: false,
          is_banned: false,
        },
        include: { photos: true, devices: true },
        take: 50,
      });

      const friendships = await prisma.friendship.findMany({
        where: {
          OR: [
            { requester_id: myId, addressee_id: { in: users.map((u) => u.id) } },
            { addressee_id: myId, requester_id: { in: users.map((u) => u.id) } },
          ],
        },
      });

      const friendList: ReturnType<typeof serializeOwnUser>[] = [];
      const otherList: ReturnType<typeof serializeOwnUser>[] = [];

      for (const user of users) {
        const fs = friendships.find(
          (f) =>
            (f.requester_id === myId && f.addressee_id === user.id) ||
            (f.addressee_id === myId && f.requester_id === user.id)
        );

        let status: string | null = null;
        if (fs?.status === "accepted") status = "friends";
        else if (fs?.status === "pending" && fs.requester_id === myId) status = "pending";
        else if (fs?.status === "pending" && fs.addressee_id === myId) status = "received";
        else if (fs?.status === "blocked") status = "blocked";

        const serialized = {
          ...serializeOwnUser(user),
          phone_number: null,
          authentication_token: null,
          latitude: null,
          longitude: null,
          fcm_tokens: [],
          status,
        };

        if (status === "friends") {
          friendList.push(serialized);
        } else {
          otherList.push(serialized);
        }
      }

      ok(res, { friendships: friendList, users: otherList });
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /report
usersRouter.post(
  "/report",
  requireAuth,
  upload.single("image"),
  async (req, res) => {
    try {
      const userId = parseInt(req.body.user_id as string, 10);
      const reason = req.body.reason as string;

      if (!userId || !reason) {
        fail(res, 422, "user_id and reason are required");
        return;
      }

      let imageUrl: string | null = null;
      if (req.file) {
        const urls = await uploadPhoto(req.file.buffer, req.user.id, req.file.mimetype);
        imageUrl = urls.original;
      }

      await prisma.report.create({
        data: {
          reporter_id: req.user.id,
          reported_id: userId,
          reason,
          image_url: imageUrl,
        },
      });

      const reportCount = await prisma.report.groupBy({
        by: ["reporter_id"],
        where: { reported_id: userId },
        _count: true,
      });

      if (reportCount.length >= 3) {
        await prisma.user.update({
          where: { id: userId },
          data: { is_banned: true },
        });
      }

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /send_message_invite
usersRouter.post(
  "/send_message_invite",
  requireAuth,
  validateBody(z.object({ phone_number: z.string().min(1) })),
  async (_req, res) => {
    // Twilio integration placeholder — returns success without actual send in dev
    ok(res, null);
  }
);

// GET /my_setting
usersRouter.get("/my_setting", requireAuth, async (req, res) => {
  try {
    const setting = await prisma.setting.upsert({
      where: { user_id: req.user.id },
      update: {},
      create: { user_id: req.user.id },
    });
    ok(res, setting);
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// POST /edit_setting
usersRouter.post(
  "/edit_setting",
  requireAuth,
  validateBody(
    z.object({
      everyone: z.boolean().optional(),
      male_only: z.boolean().optional(),
      female_only: z.boolean().optional(),
      min_age: z.number().int().min(18).optional(),
      max_age: z.number().int().max(100).optional(),
      max_distace: z.number().int().min(1).optional(),
      general: z.boolean().optional(),
      friendship: z.boolean().optional(),
      match: z.boolean().optional(),
      group: z.boolean().optional(),
      chat: z.boolean().optional(),
    })
  ),
  async (req, res) => {
    try {
      const data = req.body as Record<string, unknown>;

      const current = await prisma.setting.findUnique({
        where: { user_id: req.user.id },
      });

      const merged = { ...current, ...data };

      if (
        merged.min_age != null &&
        merged.max_age != null &&
        (merged.min_age as number) >= (merged.max_age as number)
      ) {
        fail(res, 422, "min_age must be less than max_age");
        return;
      }

      const genderFields = ["everyone", "male_only", "female_only"];
      const trueCounts = genderFields.filter((f) => merged[f] === true).length;
      if (trueCounts !== 1) {
        fail(res, 422, "Exactly one of everyone, male_only, female_only must be true");
        return;
      }

      const setting = await prisma.setting.upsert({
        where: { user_id: req.user.id },
        update: data,
        create: { user_id: req.user.id, ...data },
      });

      ok(res, setting);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);
