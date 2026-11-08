import { messaging } from "../config/firebase";
import { prisma } from "../lib/prisma";

async function getTokens(userId: number): Promise<string[]> {
  const devices = await prisma.device.findMany({
    where: { user_id: userId },
    select: { fcm_token: true },
  });
  return devices.map((d) => d.fcm_token).filter(Boolean);
}

async function sendToUser(
  userId: number,
  notification: { title: string; body: string },
  data: Record<string, string>
): Promise<void> {
  const tokens = await getTokens(userId);
  if (tokens.length === 0) return;

  await Promise.allSettled(
    tokens.map((token) =>
      messaging.send({
        token,
        notification,
        data,
      })
    )
  );
}

export async function notifyFriendRequest(
  toUserId: number,
  fromUser: { first_name: string | null; user_name: string | null },
  fromUserId: number
): Promise<void> {
  const setting = await prisma.setting.findUnique({ where: { user_id: toUserId } });
  if (!setting?.friendship) return;

  const name = fromUser.first_name ?? fromUser.user_name ?? "Someone";
  await sendToUser(
    toUserId,
    { title: "Entourage", body: `${name} sent you a friend request` },
    { notifiable_type: "FriendshipRequest", notifiable_id: String(fromUserId) }
  );
}

export async function notifyFriendAccepted(
  toUserId: number,
  accepter: { first_name: string | null; user_name: string | null },
  accepterId: number
): Promise<void> {
  const setting = await prisma.setting.findUnique({ where: { user_id: toUserId } });
  if (!setting?.friendship) return;

  const name = accepter.first_name ?? accepter.user_name ?? "Someone";
  await sendToUser(
    toUserId,
    { title: "Entourage", body: `${name} accepted your friend request` },
    { notifiable_type: "FriendshipAccepted", notifiable_id: String(accepterId) }
  );
}

export async function notifyMatch(
  groupACreatorId: number,
  groupBCreatorId: number,
  matchId: number
): Promise<void> {
  const [settingA, settingB] = await Promise.all([
    prisma.setting.findUnique({ where: { user_id: groupACreatorId } }),
    prisma.setting.findUnique({ where: { user_id: groupBCreatorId } }),
  ]);

  const payload = {
    notification: { title: "Entourage", body: "🎉 You have a new match!" },
    data: { notifiable_type: "MatchCreated", match_id: String(matchId) },
  };

  const sends: Promise<void>[] = [];
  if (settingA?.match) sends.push(sendToUser(groupACreatorId, payload.notification, payload.data));
  if (settingB?.match) sends.push(sendToUser(groupBCreatorId, payload.notification, payload.data));
  await Promise.allSettled(sends);
}

export async function notifyGroupMemberAdded(
  addedUserId: number,
  groupId: number
): Promise<void> {
  const setting = await prisma.setting.findUnique({ where: { user_id: addedUserId } });
  if (!setting?.group) return;

  await sendToUser(
    addedUserId,
    { title: "Entourage", body: "You were added to a group!" },
    { notifiable_type: "GroupMemberAdded", group_id: String(groupId) }
  );
}

export async function notifySelf(userId: number, message: string): Promise<void> {
  await sendToUser(
    userId,
    { title: "Entourage", body: message },
    { notifiable_type: "SelfNotification" }
  );
}
