import {
  User,
  Photo,
  Device,
  Group,
  GroupMember,
} from "@prisma/client";

type UserWithRelations = User & {
  photos: Photo[];
  devices?: Device[];
};

type GroupMemberWithUser = GroupMember & {
  user: UserWithRelations;
};

type GroupWithMembers = Group & {
  members: GroupMemberWithUser[];
};

export function serializeOwnUser(user: UserWithRelations): Record<string, unknown> {
  return {
    id: user.id,
    phone_number: user.phone_number,
    authentication_token: user.authentication_token,
    first_name: user.first_name,
    last_name: user.last_name,
    user_name: user.user_name,
    bio: user.bio,
    gender: user.gender,
    dob: user.dob,
    age: user.age,
    latitude: user.latitude,
    longitude: user.longitude,
    city: user.city,
    state: user.state,
    is_blocked: user.is_blocked,
    is_banned: user.is_banned,
    photos: user.photos,
    fcm_tokens: user.devices?.map((d) => d.fcm_token) ?? [],
    status: null,
    created_at: user.created_at,
    updated_at: user.updated_at,
  };
}

export function serializeOtherUser(
  user: UserWithRelations,
  status: string | null = null
): Record<string, unknown> {
  return {
    id: user.id,
    phone_number: null,
    authentication_token: null,
    first_name: user.first_name,
    last_name: user.last_name,
    user_name: user.user_name,
    bio: user.bio,
    gender: user.gender,
    dob: user.dob,
    age: user.age,
    latitude: null,
    longitude: null,
    city: user.city,
    state: user.state,
    is_blocked: user.is_blocked,
    is_banned: user.is_banned,
    photos: user.photos,
    fcm_tokens: [],
    status,
    created_at: user.created_at,
    updated_at: user.updated_at,
  };
}

export function serializeGroup(
  group: GroupWithMembers,
  distance?: number | null
): Record<string, unknown> {
  return {
    id: group.id,
    status: group.status,
    name: group.name,
    city: group.city,
    state: group.state,
    distance: distance != null ? String(parseFloat(distance.toFixed(1))) : null,
    users: group.members.map((m) => serializeOtherUser(m.user)),
  };
}

export const GROUP_MEMBER_INCLUDE = {
  members: {
    include: {
      user: {
        include: {
          photos: true,
        },
      },
    },
  },
} as const;
