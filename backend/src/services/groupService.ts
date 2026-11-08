import { prisma } from "../lib/prisma";
import { GROUP_MEMBER_INCLUDE } from "../lib/serializers";

export async function reEvaluateGroupStatus(groupId: number): Promise<void> {
  const group = await prisma.group.findUnique({
    where: { id: groupId },
    include: {
      members: {
        include: {
          user: { include: { photos: true } },
        },
      },
    },
  });

  if (!group) return;

  const memberCount = group.members.length;
  const creator = group.members.find((m) => m.user_id === group.creator_id);
  const creatorHasPhoto = (creator?.user.photos.length ?? 0) > 0;

  const shouldBeActive = memberCount >= 2 && creatorHasPhoto;
  const newStatus = shouldBeActive ? "active" : "in_active";

  if (group.status !== newStatus) {
    await prisma.group.update({
      where: { id: groupId },
      data: { status: newStatus },
    });
  }
}

export async function getGroupWithMembers(groupId: number) {
  return prisma.group.findUnique({
    where: { id: groupId },
    include: GROUP_MEMBER_INCLUDE,
  });
}

export async function findUserGroup(userId: number) {
  const membership = await prisma.groupMember.findFirst({
    where: { user_id: userId },
    include: {
      group: {
        include: GROUP_MEMBER_INCLUDE,
      },
    },
  });
  return membership?.group ?? null;
}
