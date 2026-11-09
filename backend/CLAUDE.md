# Entourage Backend — Architecture & Implementation Guide

## Stack
TypeScript · Express · Zod · bcrypt · dotenv · Redis · Docker · PostgreSQL · Prisma ORM 5

## Rules (always in effect)
- Never commit secrets. All env vars through `.env` only.
- Every endpoint wrapped in the standard response envelope (see API Contract).
- Auth token in every protected route — header `Authorization: Bearer <token>` OR query/body `auth_token`.
- All validation through Zod schemas defined alongside the route. Reject early, never trust raw input.
- All DB access through Prisma only. No raw SQL except for the haversine distance query.
- Redis for: auth-token lookup cache (5 min TTL), rate limiting, swipe-deck pagination cursor.
- Push notifications go through Firebase Admin SDK (server-side), not through the iOS client's cloud function path.
- File uploads stored on S3 (or local `/uploads` in dev). Three sizes generated per photo: original, medium (640px), thumb (200px).

---

## Project Structure

```
backend/
├── prisma/
│   ├── schema.prisma          ← single source of truth for DB schema
│   └── migrations/
├── src/
│   ├── index.ts               ← app entry, starts server
│   ├── app.ts                 ← express setup, middleware, router mount
│   ├── config/
│   │   ├── env.ts             ← Zod-validated env vars (process.env checked at boot)
│   │   ├── redis.ts           ← Redis client singleton
│   │   ├── firebase.ts        ← Firebase Admin SDK init
│   │   └── s3.ts              ← S3 / storage client
│   ├── middleware/
│   │   ├── auth.ts            ← requireAuth — validates auth_token, attaches req.user
│   │   ├── validate.ts        ← validateBody / validateQuery — Zod wrapper
│   │   ├── upload.ts          ← multer config for photo endpoints
│   │   └── rateLimiter.ts     ← Redis-backed rate limiter
│   ├── routes/
│   │   ├── users.ts
│   │   ├── photos.ts
│   │   ├── groups.ts
│   │   ├── matches.ts
│   │   ├── friendships.ts
│   │   ├── notifications.ts
│   │   └── devices.ts
│   ├── services/
│   │   ├── authService.ts     ← token generation/validation
│   │   ├── photoService.ts    ← resize + upload to S3
│   │   ├── matchService.ts    ← like/match logic
│   │   ├── notificationService.ts ← FCM push via Firebase Admin
│   │   └── locationService.ts ← haversine distance calc
│   ├── lib/
│   │   ├── prisma.ts          ← Prisma client singleton
│   │   ├── respond.ts         ← ok() / fail() response helpers
│   │   └── pagination.ts      ← paginate() helper
│   └── types/
│       └── express.d.ts       ← augment req.user type
├── docker-compose.yml
├── Dockerfile
├── .env.example
└── package.json
```

---

## API Response Contract

**Every endpoint** returns this envelope. No exceptions.

```json
{ "meta": { "code": 200, "message": "Success" }, "data": { ... } }
{ "meta": { "code": 200, "message": "Success" }, "data": [ ... ] }
{ "meta": { "code": 422, "message": "Validation failed" }, "data": null }
{ "meta": { "code": 401, "message": "Unauthorized" }, "data": null }
{ "meta": { "code": 404, "message": "Not found" }, "data": null }
```

HTTP status code always matches `meta.code`.

```typescript
// src/lib/respond.ts
export const ok   = (res, data, message = "Success") =>
  res.status(200).json({ meta: { code: 200, message }, data });

export const fail = (res, code: number, message: string) =>
  res.status(code).json({ meta: { code, message }, data: null });
```

Pagination fields go inside `meta`:
```json
{ "meta": { "code": 200, "message": "Success", "current_page": 1, "total_pages": 5, "per_page": 20, "total_count": 94 }, "data": [...] }
```

---

## Prisma Schema

```prisma
// prisma/schema.prisma
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "linux-musl-openssl-3.0.x"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id                   Int       @id @default(autoincrement())
  phone_number         String    @unique
  authentication_token String    @unique @default(cuid())
  first_name           String?
  last_name            String?
  user_name            String?   @unique
  bio                  String?
  gender               String?   // "male" | "female"
  dob                  Int?      // unix timestamp (seconds)
  age                  Int?
  latitude             String?
  longitude            String?
  city                 String?
  state                String?
  is_blocked           Boolean   @default(false)
  is_banned            Boolean   @default(false)
  created_at           DateTime  @default(now())
  updated_at           DateTime  @updatedAt

  photos               Photo[]
  setting              Setting?
  devices              Device[]
  groupMemberships     GroupMember[]
  createdGroups        Group[]       @relation("GroupCreator")
  sentLikes            GroupLike[]   @relation("LikerUser")
  sentFriendRequests   Friendship[]  @relation("FriendRequester")
  receivedFriendRequests Friendship[] @relation("FriendAddressee")
  reportsMade          Report[]      @relation("Reporter")
  reportsReceived      Report[]      @relation("Reported")
  deletionLog          DeletionLog?
}

model Photo {
  id         Int      @id @default(autoincrement())
  user_id    Int
  original   String
  medium     String
  thumb      String
  is_primary Boolean  @default(false)
  order      Int      @default(0)
  created_at DateTime @default(now())

  user       User     @relation(fields: [user_id], references: [id], onDelete: Cascade)
}

model Setting {
  id                 Int     @id @default(autoincrement())
  user_id            Int     @unique
  everyone           Boolean @default(true)
  male_only          Boolean @default(false)
  female_only        Boolean @default(false)
  min_age            Int     @default(18)
  max_age            Int     @default(42)
  max_distace        Int     @default(50)   // keep legacy spelling to match iOS
  group_member_count Int     @default(3)
  block_member_count Int     @default(0)
  general            Boolean @default(true)
  friendship         Boolean @default(true)
  match              Boolean @default(true)
  group              Boolean @default(true)
  chat               Boolean @default(true)

  user               User    @relation(fields: [user_id], references: [id], onDelete: Cascade)
}

model Group {
  id         Int       @id @default(autoincrement())
  name       String?
  status     String    @default("in_active")  // "active" | "in_active"
  city       String?
  state      String?
  creator_id Int
  created_at DateTime  @default(now())
  updated_at DateTime  @updatedAt

  creator    User        @relation("GroupCreator", fields: [creator_id], references: [id])
  members    GroupMember[]
  likesGiven GroupLike[] @relation("LikerGroup")
  likesReceived GroupLike[] @relation("LikedGroup")
  matchesAsA Match[]     @relation("MatchGroupA")
  matchesAsB Match[]     @relation("MatchGroupB")
}

model GroupMember {
  id         Int      @id @default(autoincrement())
  group_id   Int
  user_id    Int
  joined_at  DateTime @default(now())

  group      Group    @relation(fields: [group_id], references: [id], onDelete: Cascade)
  user       User     @relation(fields: [user_id], references: [id], onDelete: Cascade)

  @@unique([group_id, user_id])
}

model GroupLike {
  id              Int      @id @default(autoincrement())
  liker_group_id  Int
  liked_group_id  Int
  liker_user_id   Int      // the user who tapped like
  created_at      DateTime @default(now())

  likerGroup      Group    @relation("LikerGroup", fields: [liker_group_id], references: [id], onDelete: Cascade)
  likedGroup      Group    @relation("LikedGroup", fields: [liked_group_id], references: [id], onDelete: Cascade)
  likerUser       User     @relation("LikerUser", fields: [liker_user_id], references: [id])

  @@unique([liker_group_id, liked_group_id])
}

model Match {
  id          Int      @id @default(autoincrement())
  group_a_id  Int
  group_b_id  Int
  status      String   @default("active")  // "active" | "unmatched"
  distance    Float?
  created_at  DateTime @default(now())

  groupA      Group    @relation("MatchGroupA", fields: [group_a_id], references: [id])
  groupB      Group    @relation("MatchGroupB", fields: [group_b_id], references: [id])

  @@unique([group_a_id, group_b_id])
}

model Friendship {
  id           Int      @id @default(autoincrement())
  requester_id Int
  addressee_id Int
  status       String   @default("pending")  // "pending" | "accepted" | "blocked"
  created_at   DateTime @default(now())
  updated_at   DateTime @updatedAt

  requester    User     @relation("FriendRequester", fields: [requester_id], references: [id], onDelete: Cascade)
  addressee    User     @relation("FriendAddressee", fields: [addressee_id], references: [id], onDelete: Cascade)

  @@unique([requester_id, addressee_id])
}

model Device {
  id               Int      @id @default(autoincrement())
  user_id          Int
  physical_address String   // device UUID
  fcm_token        String
  device_type      String   @default("iphone")
  updated_at       DateTime @updatedAt

  user             User     @relation(fields: [user_id], references: [id], onDelete: Cascade)

  @@unique([user_id, physical_address])
}

model Report {
  id          Int      @id @default(autoincrement())
  reporter_id Int
  reported_id Int
  reason      String
  image_url   String?
  created_at  DateTime @default(now())

  reporter    User     @relation("Reporter", fields: [reporter_id], references: [id])
  reported    User     @relation("Reported", fields: [reported_id], references: [id])
}

model DeletionLog {
  id         Int      @id @default(autoincrement())
  user_id    Int      @unique
  reason     String?
  deleted_at DateTime @default(now())

  user       User     @relation(fields: [user_id], references: [id])
}

model AppVersion {
  id              Int    @id @default(autoincrement())
  platform        String @default("ios")
  min_version     String
  current_version String?
}
```

---

## Auth Middleware

```typescript
// src/middleware/auth.ts
// Accepts auth_token from: Authorization header, query string, or request body.
// Caches user in Redis for 5 min to avoid a DB hit on every request.
```

Token strategy: `cuid()` on signup, stored in `users.authentication_token`. Never hashed — it is a session token, not a password. Rotate on explicit logout if needed.

---

## Environment Variables

```ini
# .env.example
DATABASE_URL=postgresql://entourage:secret@localhost:5432/entourage
REDIS_URL=redis://localhost:6379
S3_BUCKET=entourage-photos
S3_REGION=auto
S3_ENDPOINT=https://<accountid>.r2.cloudflarestorage.com
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
MIN_IOS_VERSION=2.0.0
PORT=3000
NODE_ENV=development
```

Validate all of these at startup with Zod in `src/config/env.ts`. If any required var is missing, throw and crash — never start with invalid config.

---

## Docker Setup

```yaml
# docker-compose.yml
services:
  api:
    build: .
    ports: ["3001:3000"]
    env_file: .env
    environment:
      DATABASE_URL: postgresql://entourage:secret@postgres:5432/entourage
      REDIS_URL: redis://redis:6379
    depends_on: [postgres, redis]
    command: sh -c "npx prisma migrate deploy && node dist/index.js"

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: entourage
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: entourage
    volumes: [pgdata:/var/lib/postgresql/data]
    ports: ["5432:5432"]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

volumes:
  pgdata:
```

```dockerfile
# Dockerfile
FROM node:20-alpine
RUN apk add --no-cache openssl
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

---

## Route Structure

Mount all routes under `/api/v1`:

```typescript
// src/app.ts
app.use("/api/v1/users",         usersRouter);
app.use("/api/v1/photos",        photosRouter);
app.use("/api/v1/groups",        groupsRouter);
app.use("/api/v1/matches",       matchesRouter);
app.use("/api/v1/friendships",   friendshipsRouter);
app.use("/api/v1/notifications", notificationsRouter);
app.use("/api/v1/devices",       devicesRouter);
```

---

## Endpoints — Full Specification

### Users

#### `GET /api/v1/users/check_ios_version`
No auth required.
- Query: `ios_version: string`
- Logic: compare against `AppVersion.min_version`; if below minimum → `is_valid: false`
- Response: `data: { is_valid: boolean }`

#### `POST /api/v1/users/user_signup`
No auth required.
- Body: `{ phone_number: string }` (E.164 format, e.g. `+14155551234`)
- Logic: upsert User by `phone_number`. On create, also create a default `Setting` row. Generate a fresh `authentication_token`. **Never store a password** — Firebase phone auth owns OTP verification; this endpoint only provisions the backend account.
- Response: `data: User` — full user object including `authentication_token` and `photos: []`

#### `GET /api/v1/users/user_by_auth_token`
Protected.
- Logic: return the authenticated user (from middleware)
- Response: `data: User` with photos included

#### `GET /api/v1/users/user_by_phone_number`
No auth required.
- Query: `phone_number: string`
- Logic: find user by phone, return with photos
- Response: `data: User`

#### `POST /api/v1/users/edit_profile`
Protected.
- Body: `{ gender?, first_name?, last_name?, user_name?, bio?, dob? }` — all optional, patch semantics
- Validation: if `dob` present → derive `age` from it; must be ≥ 18 (`422` if under age)
- Logic: update user fields. Set group status to `active` once profile is complete (has gender + photos + username).
- Response: `data: User`

#### `GET /api/v1/users/user_name_available`
No auth required.
- Query: `user_name: string`
- Logic: lowercase the name, check uniqueness
- Response on available: `meta.code: 200, meta.message: "Available", data: null`
- Response on taken: `meta.code: 422, meta.message: "Username taken", data: null`

#### `DELETE /api/v1/users/delete_account`
Protected.
- Body: `{ reason?: string }`
- Logic: soft-delete via `DeletionLog`. Anonymise PII: null out `phone_number`, `first_name`, `last_name`, `user_name`, set `is_blocked: true`. Delete all photos from S3. Leave group (remove from GroupMember). Remove all active Friendships.
- Response: `data: null`

#### `POST /api/v1/users/update_coordinates`
Protected.
- Body: `{ latitude: string, longitude: string }`
- Logic: update user lat/lng; also re-evaluate Group `status` to `active` if the group has ≥ 2 members and user has photos
- Response: `data: User`

#### `GET /api/v1/users/search_by_user_name`
Protected.
- Query: `user_name: string`
- Logic: `WHERE user_name ILIKE %query%`. Exclude the requesting user. For each result, inject `status` field from Friendship table (see Friendship Status enum below).
- Response: `data: { friendships: [User], users: [User] }` — `friendships` = already friends, `users` = others (backend returns a container object with these two keys)

#### `POST /api/v1/users/report`
Protected. Multipart form data.
- Fields: `user_id: int, reason: string, image?: file`
- Logic: create Report row. Upload image to S3 if present. If this user has 3+ reports from different reporters → auto-set `is_banned: true`.
- Response: `data: null`

#### `POST /api/v1/users/send_message_invite`
Protected.
- Body: `{ phone_number: string }`
- Logic: returns a deep link the iOS app shares natively via `UIActivityViewController`. No SMS/Twilio.
- Response: `data: { invite_url: "https://entourage.app/invite?ref=<user_id>" }`

#### `GET /api/v1/users/my_setting`
Protected.
- Logic: return the user's Setting row (auto-create with defaults if missing)
- Response: `data: Setting`

#### `POST /api/v1/users/edit_setting`
Protected.
- Body: `{ everyone?, male_only?, female_only?, min_age?, max_age?, max_distace?, general?, friendship?, match?, group?, chat? }`
- Validation: `min_age` < `max_age`. Exactly one of `everyone | male_only | female_only` must be true.
- Response: `data: Setting`

---

### Photos

#### `POST /api/v1/photos/upload_photo`
Protected. Multipart (`image: file`).
- Body fields: `order: int, is_primary?: bool`
- Logic:
  1. Resize to 3 sizes via sharp: `original` (max 1200px), `medium` (640px), `thumb` (200px)
  2. Upload all 3 to S3
  3. Create Photo row
  4. If `is_primary: true`, unset all other `is_primary` for this user first
  5. After upload, re-evaluate group `status`
- Response: `data: User` — full user with updated photos array

#### `DELETE /api/v1/photos/delete_photo`
Protected.
- Body: `{ id: int }`
- Logic: verify photo belongs to requesting user. Delete from S3 (all 3 sizes). Delete DB row. If deleted photo was primary, promote next photo by order.
- Response: `data: User` — full user with updated photos

#### `POST /api/v1/photos/set_order`
Protected.
- Body: `{ id: int, order: int, is_primary?: bool }`
- Logic: update Photo row. If `is_primary: true`, unset other primaries first.
- Response: `data: User` — full user with updated photos

---

### Groups

#### `POST /api/v1/groups/create`
Protected.
- Body: `{ friend_ids: string }` — comma-separated user IDs (e.g. `"12,34,56"`)
- Logic:
  1. User must not already be in an active group → `422` if they are
  2. Create Group with `status: "in_active"` initially
  3. Add requesting user as first GroupMember
  4. Parse `friend_ids`, verify each is a friend (accepted Friendship exists) → add each as GroupMember
  5. If group has ≥ 2 members AND creator has photos → set `status: "active"`
- Response: `data: Group` — group with nested `users` array (full User objects)

#### `POST /api/v1/groups/add_member`
Protected. Creator only.
- Body: `{ group_id: int, friend_id: int }`
- Logic:
  1. Verify requesting user is the group creator
  2. Verify `friend_id` is an accepted friend of the creator
  3. Verify friend is not already in the group
  4. Add GroupMember row — user is immediately in the group, no approval step (Phase 5 direct-add model)
  5. Re-evaluate group `status`
- Response: `data: Group` — updated group with users

#### `GET /api/v1/groups/my_group`
Protected.
- Logic: find the group where the requesting user is a GroupMember. Return `null` in `data` if none.
- Response: `data: Group | null`

#### `DELETE /api/v1/groups/leave_group`
Protected.
- Logic:
  1. Remove user from GroupMember
  2. If user was the creator AND other members remain → transfer creator to oldest remaining member
  3. If group now has 0 or 1 member → set `status: "in_active"` (can't swipe as solo)
- Response: `data: null`

#### `GET /api/v1/groups/group_by_id`
Protected.
- Query: `group_id: int`
- Response: `data: Group` — group with nested users

---

## Group Shape in Responses

The iOS `Group` Codable class has these fields. Always return exactly this shape:

```json
{
  "id": 42,
  "status": "active",
  "name": null,
  "city": "Los Angeles",
  "state": "CA",
  "distance": "2.3",
  "users": [
    {
      "id": 7,
      "phone_number": null,
      "authentication_token": null,
      "user_name": "alexj98",
      "bio": null,
      "first_name": "Alex",
      "last_name": "Johnson",
      "latitude": null,
      "longitude": null,
      "dob": 883008000,
      "gender": "male",
      "city": "Los Angeles",
      "state": "CA",
      "age": 27,
      "photos": [...],
      "fcm_tokens": [],
      "is_blocked": false,
      "status": null
    }
  ]
}
```

**Never** return `authentication_token` or `phone_number` for other users — only for the authenticated user themselves. Null these out in Prisma `select` for group member queries.

---

### Matches

#### `GET /api/v1/matches/find_groups`
Protected.
- Query: `page: int` (1-indexed, 20 per page)
- Logic (this is the swipe deck — most complex query):
  1. Find requesting user's group → `422` if none or status is `in_active`
  2. Exclude groups already swiped (liked or passed) by my group
  3. Exclude groups already matched with my group
  4. Exclude my own group
  5. Exclude groups containing anyone who has blocked me (or I've blocked)
  6. Apply gender filter from my Setting (`everyone` / `male_only` / `female_only`): filter by majority gender of the group's members
  7. Apply age filter (`min_age` / `max_age`): filter groups where average member age is in range
  8. Apply distance filter (`max_distace` in miles): use haversine formula against creator's coordinates
  9. Only return groups with `status: "active"` and at least 2 members
  10. Order by distance ascending (closest first)
  11. Paginate
- Response: `data: [Group]` with pagination in `meta`

```sql
-- Haversine raw query (wrap in Prisma.$queryRaw)
SELECT g.id,
  3959 * acos(
    cos(radians($userLat)) * cos(radians(u.latitude::float))
    * cos(radians(u.longitude::float) - radians($userLng))
    + sin(radians($userLat)) * sin(radians(u.latitude::float))
  ) AS distance_miles
FROM groups g
JOIN group_members gm ON gm.group_id = g.id
JOIN users u ON u.id = gm.user_id
WHERE g.status = 'active'
ORDER BY distance_miles ASC
```

#### `POST /api/v1/matches/like_group`
Protected.
- Body: `{ group_id: string }` — target group ID
- Logic:
  1. Find my group → `422` if none
  2. Create GroupLike (my group → target group)
  3. Check if target group has already liked my group → if yes, **create a Match**
  4. Match creation: insert Match row. The `id` of the Match IS the `chat_id` used by iOS to form the Firebase room key `"Match_\(matchId)"`
  5. If match created: return Match object; otherwise return `null`
- Response: `data: Match | null` — the new Match when mutual like; `null` when no match yet. Match includes `matcher` (the other group), `distance`, `chat_id`

#### `POST /api/v1/matches/unlike_group`
Protected.
- Body: `{ group_id: string }`
- Logic: delete GroupLike row (my group → target group). If a Match exists, do NOT delete it here — unlike ≠ unmatch.
- Response: `data: null`

#### `GET /api/v1/matches/my_matches`
Protected.
- Logic:
  1. Find my group
  2. Find all active Matches where my group is `group_a` or `group_b`
  3. For each match, resolve the **other** group and compute current distance
  4. Order by most recent match first
- Response: `data: [Match]`

Match shape:
```json
{
  "id": 15,
  "status": "active",
  "distance": 2.3,
  "chat_id": 15,
  "matcher": { /* full Group object — the OTHER group */ }
}
```

Note: `chat_id` is the same as `id`. iOS forms the Firebase chat room as `"Match_\(match.chat_id)"`.

#### `DELETE /api/v1/matches/unmatch_group`
Protected.
- Body: `{ group_id: string }` — the OTHER group's ID
- Logic: set Match `status: "unmatched"`. Do NOT hard-delete (audit trail). Remove the GroupLike rows in both directions.
- Response: `data: null`

---

### Friendships

**Friendship Status Enum** (injected as `status` field on User in relevant endpoints):
- `"friends"` — accepted Friendship between the two users
- `"pending"` — I sent a request, waiting for them
- `"received"` — they sent me a request, I haven't answered
- `"blocked"` — either party has blocked the other
- `"no_relation"` — no record exists

#### `POST /api/v1/friendships/direct_friendship`
Protected.
- Body: `{ phone_number: string }`
- Logic: find user by phone.
  - If found and no existing friendship → create accepted Friendship. Return `{ user: User, invite_url: null }`.
  - If no account exists for that phone number → return `{ user: null, invite_url: "https://entourage.app/invite?ref=<current_user_id>" }`. **Fire-and-forget — do NOT create a pending record, do NOT send an SMS.**
- Response: `data: DirectFriendshipResult`
  ```json
  { "user": User | null, "invite_url": "https://..." | null }
  ```
- The iOS app shows a native share sheet (`UIActivityViewController`) with `invite_url` when it is non-null. No Twilio, no cost.

#### `GET /api/v1/friendships/friendes`
Protected.
- Logic: return all users who have an accepted Friendship with me (either direction)
- Response: `data: [User]` — each User has `status: "friends"`

#### `POST /api/v1/friendships/all_friends_and_requests`
Protected.
- Body: none (auth_token only)
- Logic: return all accepted friends + all received pending requests in one call. Each user has `status` injected.
- Response: `data: [User]` — mixed, differentiated by `status` field

#### `POST /api/v1/friendships/received_requests`
Protected.
- Logic: return users who sent me a pending request
- Response: `data: [User]` — each with `status: "received"`

#### `POST /api/v1/friendships/no_relation`
Protected.
- Body: `{ contacts: string }` — comma-separated phone numbers
- Logic: from the given phone numbers, find users with no existing friendship with me.
- Response: `data: [User]` — each with `status: "no_relation"`

#### `POST /api/v1/friendships/friends_and_no_relation`
Protected.
- Body: `{ contacts: string }` — comma-separated phone numbers
- Logic: for each phone number in contacts, find the user (if exists in app) and classify as `friends` or `no_relation`. Used for contact list with add/added state.
- Response: `data: { friendships: [User], non_existing: [String] }` — container object; `non_existing` is phone numbers not in the app

#### `POST /api/v1/friendships/request`
Protected.
- Body: `{ friend_id: int }`
- Logic: create Friendship with `status: "pending"`. Check no existing row. Send push notification to target user (if `friendship` notifications enabled in their Setting).
- Response: `data: null`

#### `POST /api/v1/friendships/accept`
Protected.
- Body: `{ friend_id: int }`
- Logic: find Friendship where `requester_id = friend_id AND addressee_id = me AND status = "pending"`. Set `status: "accepted"`. Send push notification to requester.
- Response: `data: null`

#### `POST /api/v1/friendships/reject`
Protected.
- Body: `{ friend_id: int }`
- Logic: find Friendship where `requester_id = friend_id AND addressee_id = me AND status = "pending"`. Delete the row.
- Response: `data: null`

#### `POST /api/v1/friendships/block`
Protected. Multipart (optional image for abuse reporting).
- Fields: `friend_id: int, reason?: string, image?: file`
- Logic:
  1. Upsert Friendship to `status: "blocked"` with `requester_id = me` (I'm the blocker)
  2. If they're in my group, remove them from the group
  3. If image present, upload to S3 and create a Report row
- Response: `data: null`

#### `POST /api/v1/friendships/unfriend`
Protected.
- Body: `{ friend_id: int }`
- Logic: delete the accepted Friendship row (either direction). If the unfriended user is in my group, remove them from the group.
- Response: `data: null`

#### `GET /api/v1/friendships/blocked`
Protected.
- Logic: return users I have blocked (`requester_id = me AND status = "blocked"`)
- Response: `data: [User]`

#### `POST /api/v1/friendships/unblock`
Protected.
- Body: `{ block_users: string }` — comma-separated user IDs
- Logic: delete blocked Friendship rows where I am the blocker
- Response: `data: null`

#### `GET /api/v1/friendships/status`
Protected.
- Query: `friend_id: int`
- Logic: resolve the status enum between me and that user
- Response: `data: { status: "friends" | "pending" | "received" | "blocked" | "no_relation" }`

---

### Notifications

#### `POST /api/v1/notifications/send_notification`
Protected.
- Body: `{ message: string }`
- Logic: generic push to the requesting user's own FCM tokens (self-notification, used for testing)
- Response: `data: null`

---

### Devices

#### `POST /api/v1/devices/update_device_token`
Protected.
- Body: `{ physical_address: string, fcm_token: string, device_type: string }`
- Logic: upsert Device row by `(user_id, physical_address)`. Update `fcm_token`.
- Response: `data: null`

---

## Push Notification Shapes

All push via Firebase Admin SDK (`firebase-admin`). Collect FCM tokens from `Device` rows for the target user(s).

### Friend request received
```json
{
  "notification": { "title": "Entourage", "body": "Alex sent you a friend request" },
  "data": { "notifiable_type": "FriendshipRequest", "notifiable_id": "<requester_user_id>" }
}
```

### Friend request accepted
```json
{
  "notification": { "title": "Entourage", "body": "Alex accepted your friend request" },
  "data": { "notifiable_type": "FriendshipAccepted", "notifiable_id": "<accepter_user_id>" }
}
```

### New match
```json
{
  "notification": { "title": "Entourage", "body": "🎉 You have a new match!" },
  "data": { "notifiable_type": "MatchCreated", "match_id": "<match_id>" }
}
```

### Added to group
```json
{
  "notification": { "title": "Entourage", "body": "You were added to a group!" },
  "data": { "notifiable_type": "GroupMemberAdded", "group_id": "<group_id>" }
}
```
Send when `add_member` succeeds. Only send if the added user has `group` notifications enabled in their Setting. Do NOT send if the creator is adding themselves.

### New message (Firebase Cloud Function — NOT this backend)
The iOS app calls the Firebase Cloud Function at `https://us-east1-<project>.cloudfunctions.net/sendNotificationToUsers` directly. The backend does NOT handle this. Never implement it server-side.

---

## Redis Usage

| Key pattern | TTL | Purpose |
|---|---|---|
| `user:token:<auth_token>` | 5 min | Cached user object (avoid DB hit per request) |
| `rate:<ip>:<endpoint>` | 1 min | Rate limiting (max 60 req/min per IP) |
| `swipe:cursor:<group_id>:<page>` | 10 min | Swipe deck page offset (avoid re-serving same groups on retry) |

Invalidate `user:token:<auth_token>` on any profile update or logout.

---

## Business Logic Rules

1. **One group per user.** A user can only be in one group at a time. `POST /groups/create` must check for existing membership.
2. **Group active status.** A group is `active` only when: at least 2 members AND creator has at least 1 photo. Re-evaluate on: photo upload, member join, member leave.
3. **Mutual like → match.** When group A likes group B: check if group B already has a GroupLike pointing to group A. If yes, create Match immediately.
4. **Match `chat_id` = match `id`.** The iOS app forms the Firebase chat room as `"Match_\(match.chat_id)"`. `chat_id` and `id` are the same field. Return `chat_id: match.id` in every Match response.
5. **No pending invites.** `add_member` adds the user directly to the group. There is no accept/reject for group invitations (Phase 5 direct-add model).
6. **Distance in `find_groups`.** Uses miles. Store user coordinates as `String` to match the iOS model, but cast to `float` for the haversine query.
7. **Swipe deck filtering.** Server-side only. Remove groups with `status: "in_active"` or fewer than 2 members before paginating.
8. **Username is case-insensitive.** Store lowercased. `user_name_available` lowercases before checking.
9. **`phone_number` and `authentication_token` are hidden in group member responses.** Only return them when the user is fetching their own profile.
10. **Notification settings.** Check `setting.friendship` before sending friend request/accept push. Check `setting.match` before sending match push. Check `setting.chat` before sending message push.
11. **Personal group chat room ID.** For non-match group chat, the Firebase room key is `"\(group.id)"` (just the group's integer ID as a string). Match chat room key is `"Match_\(matchId)"`.

---

## Implementation Order

Build in this order. Each step is independently testable.

1. **Scaffolding** — project setup, Docker Compose up, Prisma migrate, env validation (`dotenv/config` must be imported first in `env.ts`), `respond.ts` helpers. Seed one `AppVersion` row: `INSERT INTO "AppVersion" (platform, min_version) VALUES ('ios', '2.0.0');`
2. **Auth layer** — `user_signup`, `user_by_auth_token`, `update_device_token`, auth middleware
3. **Profile** — `edit_profile`, `my_setting`, `edit_setting`, `update_coordinates`, `user_name_available`
4. **Photos** — `upload_photo`, `delete_photo`, `set_order` (sharp + S3)
5. **Groups** — `create`, `my_group`, `add_member`, `leave_group`, `group_by_id`
6. **Swipe** — `find_groups` (haversine + all filters), `like_group`, `unlike_group`
7. **Matches** — `my_matches`, `unmatch_group`
8. **Friendships** — all 11 friendship endpoints
9. **Notifications** — `send_notification`, FCM push on friend/match events
10. **Remaining** — `check_ios_version`, `delete_account`, `report`, `send_message_invite`, `search_by_user_name`

After each step: write integration tests with a real Postgres + Redis (use Docker in test mode), verify the exact JSON shape the iOS client expects.
