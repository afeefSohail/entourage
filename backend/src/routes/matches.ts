import { Router } from "express";
import { z } from "zod";
import { Prisma } from "@prisma/client";
import { prisma } from "../lib/prisma";
import { ok, okPaginated, fail } from "../lib/respond";
import { requireAuth } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import { findUserGroup, getGroupWithMembers } from "../services/groupService";
import { checkAndCreateMatch } from "../services/matchService";
import { haversineDistance } from "../services/locationService";
import { serializeGroup, GROUP_MEMBER_INCLUDE } from "../lib/serializers";
import { redis } from "../config/redis";
import { notifyMatch } from "../services/notificationService";
import { paginationMeta, PER_PAGE } from "../lib/pagination";

export const matchesRouter = Router();

// GET /find_groups
matchesRouter.get(
  "/find_groups",
  requireAuth,
  validateQuery(z.object({ page: z.coerce.number().int().min(1).default(1) })),
  async (req, res) => {
    try {
      const page = (req.query as unknown as { page: number }).page;
      const myId = req.user.id;

      const myGroup = await findUserGroup(myId);
      if (!myGroup || myGroup.status !== "active") {
        fail(res, 422, "You need an active group to swipe");
        return;
      }

      const setting = await prisma.setting.findUnique({
        where: { user_id: myId },
      });

      const myUser = req.user;
      if (!myUser.latitude || !myUser.longitude) {
        fail(res, 422, "Location required to find groups");
        return;
      }

      const userLat = parseFloat(myUser.latitude);
      const userLng = parseFloat(myUser.longitude);
      const maxDistance = setting?.max_distace ?? 50;

      // Check Redis cursor cache
      const cursorKey = `swipe:cursor:${myGroup.id}:${page}`;
      const cached = await redis.get(cursorKey);

      let groupIds: number[];
      if (cached) {
        groupIds = JSON.parse(cached) as number[];
      } else {
        // Get exclusion sets via Prisma
        const [likedRows, matchedRowsA, matchedRowsB, blockedRows] = await Promise.all([
          prisma.groupLike.findMany({
            where: { liker_group_id: myGroup.id },
            select: { liked_group_id: true },
          }),
          prisma.match.findMany({
            where: { group_a_id: myGroup.id, status: "active" },
            select: { group_b_id: true },
          }),
          prisma.match.findMany({
            where: { group_b_id: myGroup.id, status: "active" },
            select: { group_a_id: true },
          }),
          prisma.friendship.findMany({
            where: {
              status: "blocked",
              OR: [{ requester_id: myId }, { addressee_id: myId }],
            },
            select: { requester_id: true, addressee_id: true },
          }),
        ]);

        const excludeGroupIds = new Set<number>([myGroup.id]);
        likedRows.forEach((r) => excludeGroupIds.add(r.liked_group_id));
        matchedRowsA.forEach((r) => excludeGroupIds.add(r.group_b_id));
        matchedRowsB.forEach((r) => excludeGroupIds.add(r.group_a_id));

        const blockedUserIds = new Set<number>();
        blockedRows.forEach((f) => {
          blockedUserIds.add(f.requester_id);
          blockedUserIds.add(f.addressee_id);
        });
        blockedUserIds.delete(myId);

        // Haversine raw query — only exception to Prisma-only rule
        type DistanceRow = { id: bigint; distance_miles: number };
        const distanceRows = await prisma.$queryRaw<DistanceRow[]>`
          SELECT DISTINCT ON (g.id) g.id,
            3959 * acos(
              GREATEST(-1, LEAST(1,
                cos(radians(${userLat}::float)) * cos(radians(creator.latitude::float))
                * cos(radians(creator.longitude::float) - radians(${userLng}::float))
                + sin(radians(${userLat}::float)) * sin(radians(creator.latitude::float))
              ))
            ) AS distance_miles
          FROM groups g
          JOIN users creator ON creator.id = g.creator_id
          WHERE g.status = 'active'
            AND creator.latitude IS NOT NULL
            AND creator.longitude IS NOT NULL
          ORDER BY g.id, distance_miles ASC
        `;

        // Build a distance map
        const distanceMap = new Map<number, number>();
        for (const row of distanceRows) {
          distanceMap.set(Number(row.id), row.distance_miles);
        }

        // Fetch candidate groups with member data
        const candidateGroups = await prisma.group.findMany({
          where: {
            status: "active",
            id: { notIn: Array.from(excludeGroupIds) },
          },
          include: {
            members: {
              include: { user: { include: { photos: true } } },
            },
          },
        });

        // Filter and sort
        const filtered = candidateGroups
          .filter((g) => {
            const dist = distanceMap.get(g.id) ?? Infinity;
            if (dist > maxDistance) return false;

            if (g.members.length < 2) return false;

            if (blockedUserIds.size > 0) {
              const hasBlocked = g.members.some((m) => blockedUserIds.has(m.user_id));
              if (hasBlocked) return false;
            }

            const members = g.members;
            const ages = members.map((m) => m.user.age).filter((a): a is number => a != null);
            if (ages.length > 0) {
              const avgAge = ages.reduce((s, a) => s + a, 0) / ages.length;
              if (avgAge < (setting?.min_age ?? 18) || avgAge > (setting?.max_age ?? 42)) {
                return false;
              }
            }

            if (setting && !setting.everyone) {
              const maleCount = members.filter((m) => m.user.gender === "male").length;
              const maleMajority = maleCount >= members.length / 2;
              if (setting.male_only && !maleMajority) return false;
              if (setting.female_only && maleMajority) return false;
            }

            return true;
          })
          .sort((a, b) => {
            const da = distanceMap.get(a.id) ?? Infinity;
            const db = distanceMap.get(b.id) ?? Infinity;
            return da - db;
          });

        groupIds = filtered.map((g) => g.id);
        await redis.setex(cursorKey, 10 * 60, JSON.stringify(groupIds));
      }

      const totalCount = groupIds.length;
      const pageIds = groupIds.slice((page - 1) * PER_PAGE, page * PER_PAGE);

      const groups = await prisma.group.findMany({
        where: { id: { in: pageIds } },
        include: GROUP_MEMBER_INCLUDE,
      });

      // Restore sort order from pageIds
      const groupMap = new Map(groups.map((g) => [g.id, g]));
      const ordered = pageIds.map((id) => groupMap.get(id)).filter(Boolean);

      // Re-calculate distance for each group
      const serialized = ordered.map((g) => {
        if (!g) return null;
        const creator = g.members.find((m) => m.user_id === g.creator_id);
        let dist: number | null = null;
        if (creator?.user.latitude && creator.user.longitude) {
          dist = haversineDistance(
            userLat,
            userLng,
            parseFloat(creator.user.latitude),
            parseFloat(creator.user.longitude)
          );
        }
        return serializeGroup(g, dist);
      }).filter(Boolean);

      okPaginated(
        res,
        serialized,
        paginationMeta(totalCount, page)
      );
    } catch (err) {
      console.error("find_groups error:", err);
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /like_group
matchesRouter.post(
  "/like_group",
  requireAuth,
  validateBody(z.object({ group_id: z.string().or(z.number()) })),
  async (req, res) => {
    try {
      const targetGroupId = parseInt(String(req.body.group_id), 10);
      const myId = req.user.id;

      const myGroup = await findUserGroup(myId);
      if (!myGroup) {
        fail(res, 422, "You need a group to like");
        return;
      }

      await prisma.groupLike.upsert({
        where: {
          liker_group_id_liked_group_id: {
            liker_group_id: myGroup.id,
            liked_group_id: targetGroupId,
          },
        },
        update: {},
        create: {
          liker_group_id: myGroup.id,
          liked_group_id: targetGroupId,
          liker_user_id: myId,
        },
      });

      const matchId = await checkAndCreateMatch(myGroup.id, targetGroupId);

      if (matchId == null) {
        ok(res, null);
        return;
      }

      const match = await prisma.match.findUniqueOrThrow({
        where: { id: matchId },
        include: {
          groupA: { include: GROUP_MEMBER_INCLUDE },
          groupB: { include: GROUP_MEMBER_INCLUDE },
        },
      });

      const isA = match.group_a_id === myGroup.id;
      const otherGroup = isA ? match.groupB : match.groupA;

      const otherCreatorId = otherGroup.creator_id;
      notifyMatch(myGroup.creator_id, otherCreatorId, matchId).catch(() => null);

      const dist = match.distance;
      ok(res, {
        id: match.id,
        status: match.status,
        distance: dist,
        chat_id: match.id,
        matcher: serializeGroup(otherGroup, dist ?? undefined),
      });
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /unlike_group
matchesRouter.post(
  "/unlike_group",
  requireAuth,
  validateBody(z.object({ group_id: z.string().or(z.number()) })),
  async (req, res) => {
    try {
      const targetGroupId = parseInt(String(req.body.group_id), 10);
      const myGroup = await findUserGroup(req.user.id);
      if (!myGroup) {
        fail(res, 422, "You need a group");
        return;
      }

      await prisma.groupLike.deleteMany({
        where: {
          liker_group_id: myGroup.id,
          liked_group_id: targetGroupId,
        },
      });

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// GET /my_matches
matchesRouter.get("/my_matches", requireAuth, async (req, res) => {
  try {
    const myGroup = await findUserGroup(req.user.id);
    if (!myGroup) {
      ok(res, []);
      return;
    }

    const matches = await prisma.match.findMany({
      where: {
        status: "active",
        OR: [{ group_a_id: myGroup.id }, { group_b_id: myGroup.id }],
      },
      include: {
        groupA: { include: GROUP_MEMBER_INCLUDE },
        groupB: { include: GROUP_MEMBER_INCLUDE },
      },
      orderBy: { created_at: "desc" },
    });

    const myUser = req.user;
    const myLat = myUser.latitude ? parseFloat(myUser.latitude) : null;
    const myLng = myUser.longitude ? parseFloat(myUser.longitude) : null;

    const serialized = matches.map((m) => {
      const isA = m.group_a_id === myGroup.id;
      const otherGroup = isA ? m.groupB : m.groupA;

      let dist: number | null = m.distance;
      if (myLat != null && myLng != null) {
        const otherCreator = otherGroup.members.find(
          (mem) => mem.user_id === otherGroup.creator_id
        );
        if (otherCreator?.user.latitude && otherCreator.user.longitude) {
          dist = haversineDistance(
            myLat,
            myLng,
            parseFloat(otherCreator.user.latitude),
            parseFloat(otherCreator.user.longitude)
          );
        }
      }

      return {
        id: m.id,
        status: m.status,
        distance: dist,
        chat_id: m.id,
        matcher: serializeGroup(otherGroup, dist ?? undefined),
      };
    });

    ok(res, serialized);
  } catch {
    fail(res, 500, "Internal server error");
  }
});

// DELETE /unmatch_group
matchesRouter.delete(
  "/unmatch_group",
  requireAuth,
  validateBody(z.object({ group_id: z.string().or(z.number()) })),
  async (req, res) => {
    try {
      const otherGroupId = parseInt(String(req.body.group_id), 10);
      const myGroup = await findUserGroup(req.user.id);
      if (!myGroup) {
        fail(res, 422, "You need a group");
        return;
      }

      const [a, b] = [myGroup.id, otherGroupId].sort((x, y) => x - y);

      await prisma.match.updateMany({
        where: { group_a_id: a, group_b_id: b },
        data: { status: "unmatched" },
      });

      await prisma.groupLike.deleteMany({
        where: {
          OR: [
            { liker_group_id: myGroup.id, liked_group_id: otherGroupId },
            { liker_group_id: otherGroupId, liked_group_id: myGroup.id },
          ],
        },
      });

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);
