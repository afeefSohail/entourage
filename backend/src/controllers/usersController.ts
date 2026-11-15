import { RequestHandler } from "express";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";
import { requireAuth, invalidateUserCache } from "../middleware/auth";
import { generateToken } from "../services/authService";
import { deletePhotoFromS3, uploadPhoto } from "../services/photoService";
import { reEvaluateGroupStatus, findUserGroup } from "../services/groupService";
import { serializeOwnUser } from "../lib/serializers";
import semver from "semver";
import { env } from "../config/env";

export const checkIosVersion: RequestHandler = async (req, res) => {
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
};

export const userSignup: RequestHandler = async (req, res) => {
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
};

export const userByAuthToken: RequestHandler = (req, res) => {
  ok(res, serializeOwnUser(req.user));
};

export const userByPhoneNumber: RequestHandler = async (req, res) => {
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
};

export const editProfile: RequestHandler = async (req, res) => {
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
};

export const userNameAvailable: RequestHandler = async (req, res) => {
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
};

export const deleteAccount: RequestHandler = async (req, res) => {
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
};

export const updateCoordinates: RequestHandler = async (req, res) => {
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
};

export const searchByUserName: RequestHandler = async (req, res) => {
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
};

export const reportUser: RequestHandler = async (req, res) => {
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
};

export const sendMessageInvite: RequestHandler = (req, res) => {
  ok(res, { invite_url: `https://entourage.app/invite?ref=${req.user.id}` });
};

export const mySetting: RequestHandler = async (req, res) => {
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
};

export const editSetting: RequestHandler = async (req, res) => {
  try {
    const data = req.body as Record<string, unknown>;

    const current = await prisma.setting.findUnique({
      where: { user_id: req.user.id },
    });

    const merged: Record<string, unknown> = { ...current, ...data };

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
};
