import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";
import { requireAuth } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import { reEvaluateGroupStatus, findUserGroup, getGroupWithMembers } from "../services/groupService";
import { serializeGroup, GROUP_MEMBER_INCLUDE } from "../lib/serializers";
import { notifyGroupMemberAdded } from "../services/notificationService";

export const groupsRouter = Router();

// POST /create
groupsRouter.post(
  "/create",
  requireAuth,
  validateBody(
    z.object({
      friend_ids: z.string(),
    })
  ),
  async (req, res) => {
    try {
      const { friend_ids } = req.body as { friend_ids: string };
      const myId = req.user.id;

      const existing = await findUserGroup(myId);
      if (existing) {
        fail(res, 422, "You are already in a group");
        return;
      }

      const friendIdList = friend_ids
        .split(",")
        .map((s) => parseInt(s.trim(), 10))
        .filter((n) => !isNaN(n) && n !== myId);

      const accepted = await prisma.friendship.findMany({
        where: {
          status: "accepted",
          OR: friendIdList.flatMap((fid) => [
            { requester_id: myId, addressee_id: fid },
            { requester_id: fid, addressee_id: myId },
          ]),
        },
      });

      const friendSet = new Set<number>();
      for (const f of accepted) {
        const other = f.requester_id === myId ? f.addressee_id : f.requester_id;
        friendSet.add(other);
      }

      const verifiedFriendIds = friendIdList.filter((id) => friendSet.has(id));

      const group = await prisma.group.create({
        data: {
          creator_id: myId,
          status: "in_active",
          members: {
            create: [
              { user_id: myId },
              ...verifiedFriendIds.map((uid) => ({ user_id: uid })),
            ],
          },
        },
        include: GROUP_MEMBER_INCLUDE,
      });

      await reEvaluateGroupStatus(group.id);

      const updated = await getGroupWithMembers(group.id);
      ok(res, serializeGroup(updated!));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /add_member
groupsRouter.post(
  "/add_member",
  requireAuth,
  validateBody(
    z.object({
      group_id: z.number().int(),
      friend_id: z.number().int(),
    })
  ),
  async (req, res) => {
    try {
      const { group_id, friend_id } = req.body as {
        group_id: number;
        friend_id: number;
      };
      const myId = req.user.id;

      const group = await prisma.group.findUnique({
        where: { id: group_id },
        include: { members: true },
      });

      if (!group) {
        fail(res, 404, "Group not found");
        return;
      }

      if (group.creator_id !== myId) {
        fail(res, 403, "Only the group creator can add members");
        return;
      }

      const isFriend = await prisma.friendship.findFirst({
        where: {
          status: "accepted",
          OR: [
            { requester_id: myId, addressee_id: friend_id },
            { requester_id: friend_id, addressee_id: myId },
          ],
        },
      });

      if (!isFriend) {
        fail(res, 422, "User is not your friend");
        return;
      }

      const alreadyMember = group.members.some((m) => m.user_id === friend_id);
      if (alreadyMember) {
        fail(res, 422, "User is already in the group");
        return;
      }

      await prisma.groupMember.create({
        data: { group_id, user_id: friend_id },
      });

      await reEvaluateGroupStatus(group_id);

      if (friend_id !== myId) {
        notifyGroupMemberAdded(friend_id, group_id).catch(() => null);
      }

      const updated = await getGroupWithMembers(group_id);
      ok(res, serializeGroup(updated!));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /my_group
groupsRouter.get("/my_group", requireAuth, async (req, res) => {
  try {
    const group = await findUserGroup(req.user.id);
    ok(res, group ? serializeGroup(group) : null);
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// DELETE /leave_group
groupsRouter.delete("/leave_group", requireAuth, async (req, res) => {
  try {
    const myId = req.user.id;
    const group = await findUserGroup(myId);

    if (!group) {
      fail(res, 422, "You are not in a group");
      return;
    }

    await prisma.groupMember.deleteMany({
      where: { group_id: group.id, user_id: myId },
    });

    const remaining = await prisma.groupMember.findMany({
      where: { group_id: group.id },
      orderBy: { joined_at: "asc" },
    });

    if (group.creator_id === myId && remaining.length > 0) {
      await prisma.group.update({
        where: { id: group.id },
        data: { creator_id: remaining[0].user_id },
      });
    }

    await reEvaluateGroupStatus(group.id);

    ok(res, null);
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// GET /group_by_id
groupsRouter.get(
  "/group_by_id",
  requireAuth,
  validateQuery(z.object({ group_id: z.coerce.number().int() })),
  async (req, res) => {
    try {
      const { group_id } = req.query as unknown as { group_id: number };
      const group = await getGroupWithMembers(group_id);

      if (!group) {
        fail(res, 404, "Not found");
        return;
      }

      ok(res, serializeGroup(group));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);
