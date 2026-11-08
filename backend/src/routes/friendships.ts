import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";
import { requireAuth } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import { upload } from "../middleware/upload";
import { uploadPhoto } from "../services/photoService";
import { serializeOtherUser } from "../lib/serializers";
import {
  notifyFriendRequest,
  notifyFriendAccepted,
} from "../services/notificationService";

export const friendshipsRouter = Router();

type FriendshipStatus = "friends" | "pending" | "received" | "blocked" | "no_relation";

async function resolveFriendshipStatus(
  myId: number,
  otherId: number
): Promise<FriendshipStatus> {
  const fs = await prisma.friendship.findFirst({
    where: {
      OR: [
        { requester_id: myId, addressee_id: otherId },
        { requester_id: otherId, addressee_id: myId },
      ],
    },
  });

  if (!fs) return "no_relation";
  if (fs.status === "accepted") return "friends";
  if (fs.status === "blocked") return "blocked";
  if (fs.status === "pending") {
    return fs.requester_id === myId ? "pending" : "received";
  }
  return "no_relation";
}

// POST /direct_friendship
friendshipsRouter.post(
  "/direct_friendship",
  requireAuth,
  validateBody(z.object({ phone_number: z.string().min(1) })),
  async (req, res) => {
    try {
      const { phone_number } = req.body as { phone_number: string };
      const myId = req.user.id;

      const other = await prisma.user.findUnique({
        where: { phone_number },
        include: { photos: true, devices: true },
      });

      if (!other || other.id === myId) {
        ok(res, null);
        return;
      }

      const existing = await prisma.friendship.findFirst({
        where: {
          OR: [
            { requester_id: myId, addressee_id: other.id },
            { requester_id: other.id, addressee_id: myId },
          ],
        },
      });

      if (!existing) {
        await prisma.friendship.create({
          data: {
            requester_id: myId,
            addressee_id: other.id,
            status: "accepted",
          },
        });
      }

      ok(res, serializeOtherUser(other, "friends"));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /friendes (intentional legacy spelling)
friendshipsRouter.get("/friendes", requireAuth, async (req, res) => {
  try {
    const myId = req.user.id;

    const friendships = await prisma.friendship.findMany({
      where: {
        status: "accepted",
        OR: [{ requester_id: myId }, { addressee_id: myId }],
      },
    });

    const friendIds = friendships.map((f) =>
      f.requester_id === myId ? f.addressee_id : f.requester_id
    );

    const users = await prisma.user.findMany({
      where: { id: { in: friendIds } },
      include: { photos: true, devices: true },
    });

    ok(res, users.map((u) => serializeOtherUser(u, "friends")));
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// POST /all_friends_and_requests
friendshipsRouter.post("/all_friends_and_requests", requireAuth, async (req, res) => {
  try {
    const myId = req.user.id;

    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [
          { requester_id: myId, status: "accepted" },
          { addressee_id: myId, status: { in: ["accepted", "pending"] } },
        ],
      },
    });

    const userIds = new Set<number>();
    const statusMap = new Map<number, FriendshipStatus>();

    for (const f of friendships) {
      const otherId = f.requester_id === myId ? f.addressee_id : f.requester_id;
      userIds.add(otherId);
      if (f.status === "accepted") statusMap.set(otherId, "friends");
      else if (f.status === "pending" && f.addressee_id === myId)
        statusMap.set(otherId, "received");
    }

    const users = await prisma.user.findMany({
      where: { id: { in: Array.from(userIds) } },
      include: { photos: true, devices: true },
    });

    ok(
      res,
      users.map((u) => serializeOtherUser(u, statusMap.get(u.id) ?? "no_relation"))
    );
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// POST /received_requests
friendshipsRouter.post("/received_requests", requireAuth, async (req, res) => {
  try {
    const myId = req.user.id;

    const friendships = await prisma.friendship.findMany({
      where: { addressee_id: myId, status: "pending" },
    });

    const requesterIds = friendships.map((f) => f.requester_id);
    const users = await prisma.user.findMany({
      where: { id: { in: requesterIds } },
      include: { photos: true, devices: true },
    });

    ok(res, users.map((u) => serializeOtherUser(u, "received")));
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// POST /no_relation
friendshipsRouter.post(
  "/no_relation",
  requireAuth,
  validateBody(z.object({ contacts: z.string() })),
  async (req, res) => {
    try {
      const { contacts } = req.body as { contacts: string };
      const myId = req.user.id;
      const phones = contacts.split(",").map((p) => p.trim()).filter(Boolean);

      const matchedUsers = await prisma.user.findMany({
        where: {
          phone_number: { in: phones },
          id: { not: myId },
        },
        include: { photos: true, devices: true },
      });

      const friendships = await prisma.friendship.findMany({
        where: {
          OR: [
            { requester_id: myId, addressee_id: { in: matchedUsers.map((u) => u.id) } },
            { addressee_id: myId, requester_id: { in: matchedUsers.map((u) => u.id) } },
          ],
        },
      });

      const relatedIds = new Set(
        friendships.flatMap((f) => [f.requester_id, f.addressee_id])
      );

      const noRelation = matchedUsers.filter((u) => !relatedIds.has(u.id));
      ok(res, noRelation.map((u) => serializeOtherUser(u, "no_relation")));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /friends_and_no_relation
friendshipsRouter.post(
  "/friends_and_no_relation",
  requireAuth,
  validateBody(z.object({ contacts: z.string() })),
  async (req, res) => {
    try {
      const { contacts } = req.body as { contacts: string };
      const myId = req.user.id;
      const phones = contacts.split(",").map((p) => p.trim()).filter(Boolean);

      const matchedUsers = await prisma.user.findMany({
        where: {
          phone_number: { in: phones },
          id: { not: myId },
        },
        include: { photos: true, devices: true },
      });

      const matchedPhones = new Set(matchedUsers.map((u) => u.phone_number));
      const nonExisting = phones.filter((p) => !matchedPhones.has(p));

      const friendships = await prisma.friendship.findMany({
        where: {
          status: "accepted",
          OR: [
            { requester_id: myId, addressee_id: { in: matchedUsers.map((u) => u.id) } },
            { addressee_id: myId, requester_id: { in: matchedUsers.map((u) => u.id) } },
          ],
        },
      });

      const friendIds = new Set(
        friendships.flatMap((f) => [f.requester_id, f.addressee_id]).filter((id) => id !== myId)
      );

      const friendList = matchedUsers
        .filter((u) => friendIds.has(u.id))
        .map((u) => serializeOtherUser(u, "friends"));

      const otherList = matchedUsers
        .filter((u) => !friendIds.has(u.id))
        .map((u) => serializeOtherUser(u, "no_relation"));

      ok(res, {
        friendships: [...friendList, ...otherList],
        non_existing: nonExisting,
      });
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /request
friendshipsRouter.post(
  "/request",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  async (req, res) => {
    try {
      const { friend_id } = req.body as { friend_id: number };
      const myId = req.user.id;

      const existing = await prisma.friendship.findFirst({
        where: {
          OR: [
            { requester_id: myId, addressee_id: friend_id },
            { requester_id: friend_id, addressee_id: myId },
          ],
        },
      });

      if (existing) {
        fail(res, 422, "Friendship already exists");
        return;
      }

      await prisma.friendship.create({
        data: { requester_id: myId, addressee_id: friend_id, status: "pending" },
      });

      notifyFriendRequest(friend_id, req.user, myId).catch(() => null);

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /accept
friendshipsRouter.post(
  "/accept",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  async (req, res) => {
    try {
      const { friend_id } = req.body as { friend_id: number };
      const myId = req.user.id;

      const fs = await prisma.friendship.findFirst({
        where: { requester_id: friend_id, addressee_id: myId, status: "pending" },
      });

      if (!fs) {
        fail(res, 404, "Pending request not found");
        return;
      }

      await prisma.friendship.update({
        where: { id: fs.id },
        data: { status: "accepted" },
      });

      notifyFriendAccepted(friend_id, req.user, myId).catch(() => null);

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /reject
friendshipsRouter.post(
  "/reject",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  async (req, res) => {
    try {
      const { friend_id } = req.body as { friend_id: number };
      const myId = req.user.id;

      await prisma.friendship.deleteMany({
        where: { requester_id: friend_id, addressee_id: myId, status: "pending" },
      });

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /block
friendshipsRouter.post(
  "/block",
  requireAuth,
  upload.single("image"),
  async (req, res) => {
    try {
      const friend_id = parseInt(req.body.friend_id as string, 10);
      const reason = req.body.reason as string | undefined;

      if (!friend_id) {
        fail(res, 422, "friend_id is required");
        return;
      }

      const myId = req.user.id;

      const existing = await prisma.friendship.findFirst({
        where: {
          OR: [
            { requester_id: myId, addressee_id: friend_id },
            { requester_id: friend_id, addressee_id: myId },
          ],
        },
      });

      if (existing) {
        await prisma.friendship.update({
          where: { id: existing.id },
          data: { requester_id: myId, addressee_id: friend_id, status: "blocked" },
        });
      } else {
        await prisma.friendship.create({
          data: { requester_id: myId, addressee_id: friend_id, status: "blocked" },
        });
      }

      // Remove from my group if present
      const myMembership = await prisma.groupMember.findFirst({
        where: { user_id: myId },
        select: { group_id: true },
      });
      if (myMembership) {
        await prisma.groupMember.deleteMany({
          where: { group_id: myMembership.group_id, user_id: friend_id },
        });
      }

      if (req.file && reason) {
        const urls = await uploadPhoto(req.file.buffer, myId, req.file.mimetype);
        await prisma.report.create({
          data: {
            reporter_id: myId,
            reported_id: friend_id,
            reason,
            image_url: urls.original,
          },
        });
      }

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /unfriend
friendshipsRouter.post(
  "/unfriend",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  async (req, res) => {
    try {
      const { friend_id } = req.body as { friend_id: number };
      const myId = req.user.id;

      await prisma.friendship.deleteMany({
        where: {
          status: "accepted",
          OR: [
            { requester_id: myId, addressee_id: friend_id },
            { requester_id: friend_id, addressee_id: myId },
          ],
        },
      });

      // Remove friend from my group if present
      const myMembership = await prisma.groupMember.findFirst({
        where: { user_id: myId },
        select: { group_id: true },
      });
      if (myMembership) {
        await prisma.groupMember.deleteMany({
          where: { group_id: myMembership.group_id, user_id: friend_id },
        });
      }

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /blocked
friendshipsRouter.get("/blocked", requireAuth, async (req, res) => {
  try {
    const myId = req.user.id;

    const rows = await prisma.friendship.findMany({
      where: { requester_id: myId, status: "blocked" },
      select: { addressee_id: true },
    });

    const ids = rows.map((r) => r.addressee_id);
    const users = await prisma.user.findMany({
      where: { id: { in: ids } },
      include: { photos: true, devices: true },
    });

    ok(res, users.map((u) => serializeOtherUser(u, "blocked")));
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// POST /unblock
friendshipsRouter.post(
  "/unblock",
  requireAuth,
  validateBody(z.object({ block_users: z.string() })),
  async (req, res) => {
    try {
      const { block_users } = req.body as { block_users: string };
      const myId = req.user.id;
      const ids = block_users
        .split(",")
        .map((s) => parseInt(s.trim(), 10))
        .filter((n) => !isNaN(n));

      await prisma.friendship.deleteMany({
        where: {
          requester_id: myId,
          addressee_id: { in: ids },
          status: "blocked",
        },
      });

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /status
friendshipsRouter.get(
  "/status",
  requireAuth,
  validateQuery(z.object({ friend_id: z.coerce.number().int() })),
  async (req, res) => {
    try {
      const { friend_id } = req.query as unknown as { friend_id: number };
      const status = await resolveFriendshipStatus(req.user.id, friend_id);
      ok(res, { status });
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);
