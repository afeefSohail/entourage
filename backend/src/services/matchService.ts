import { prisma } from "../lib/prisma";
import { haversineDistance } from "./locationService";

export async function checkAndCreateMatch(
  myGroupId: number,
  targetGroupId: number
): Promise<number | null> {
  const mutualLike = await prisma.groupLike.findUnique({
    where: {
      liker_group_id_liked_group_id: {
        liker_group_id: targetGroupId,
        liked_group_id: myGroupId,
      },
    },
  });

  if (!mutualLike) return null;

  const [a, b] = [myGroupId, targetGroupId].sort((x, y) => x - y);

  const existing = await prisma.match.findUnique({
    where: { group_a_id_group_b_id: { group_a_id: a, group_b_id: b } },
  });
  if (existing) return existing.id;

  const [groupA, groupB] = await Promise.all([
    prisma.group.findUnique({
      where: { id: a },
      include: { creator: true },
    }),
    prisma.group.findUnique({
      where: { id: b },
      include: { creator: true },
    }),
  ]);

  let distance: number | null = null;
  const aLat = groupA?.creator.latitude;
  const aLng = groupA?.creator.longitude;
  const bLat = groupB?.creator.latitude;
  const bLng = groupB?.creator.longitude;

  if (aLat && aLng && bLat && bLng) {
    distance = haversineDistance(
      parseFloat(aLat),
      parseFloat(aLng),
      parseFloat(bLat),
      parseFloat(bLng)
    );
  }

  const match = await prisma.match.create({
    data: { group_a_id: a, group_b_id: b, distance },
  });

  return match.id;
}
