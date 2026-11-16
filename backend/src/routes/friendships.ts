import { Router } from "express";
import { z } from "zod";
import { requireAuth } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import { upload } from "../middleware/upload";
import {
  directFriendship,
  getFriends,
  allFriendsAndRequests,
  receivedRequests,
  noRelation,
  friendsAndNoRelation,
  friendshipRequest,
  acceptFriendship,
  rejectFriendship,
  blockUser,
  unfriend,
  getBlocked,
  unblock,
  friendshipStatus,
} from "../controllers/friendshipsController";

export const friendshipsRouter = Router();

friendshipsRouter.post(
  "/direct_friendship",
  requireAuth,
  validateBody(z.object({ phone_number: z.string().min(1) })),
  directFriendship
);

friendshipsRouter.get("/friendes", requireAuth, getFriends);

friendshipsRouter.post("/all_friends_and_requests", requireAuth, allFriendsAndRequests);

friendshipsRouter.post("/received_requests", requireAuth, receivedRequests);

friendshipsRouter.post(
  "/no_relation",
  requireAuth,
  validateBody(z.object({ contacts: z.string().optional() })),
  noRelation
);

friendshipsRouter.post(
  "/friends_and_no_relation",
  requireAuth,
  validateBody(z.object({ contacts: z.string().optional() })),
  friendsAndNoRelation
);

friendshipsRouter.post(
  "/request",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  friendshipRequest
);

friendshipsRouter.post(
  "/accept",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  acceptFriendship
);

friendshipsRouter.post(
  "/reject",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  rejectFriendship
);

friendshipsRouter.post("/block", requireAuth, upload.single("image"), blockUser);

friendshipsRouter.post(
  "/unfriend",
  requireAuth,
  validateBody(z.object({ friend_id: z.number().int() })),
  unfriend
);

friendshipsRouter.get("/blocked", requireAuth, getBlocked);

friendshipsRouter.post(
  "/unblock",
  requireAuth,
  validateBody(z.object({ block_users: z.string() })),
  unblock
);

friendshipsRouter.get(
  "/status",
  requireAuth,
  validateQuery(z.object({ friend_id: z.coerce.number().int() })),
  friendshipStatus
);
