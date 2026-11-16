import { Router } from "express";
import { z } from "zod";
import { formInt } from "../lib/formFields";
import { requireAuth } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import {
  createGroup,
  addMember,
  myGroup,
  leaveGroup,
  groupById,
} from "../controllers/groupsController";

export const groupsRouter = Router();

groupsRouter.post(
  "/create",
  requireAuth,
  validateBody(z.object({ friend_ids: z.string() })),
  createGroup
);

groupsRouter.post(
  "/add_member",
  requireAuth,
  validateBody(
    z.object({
      group_id: formInt(),
      friend_id: formInt(),
    })
  ),
  addMember
);

groupsRouter.get("/my_group", requireAuth, myGroup);

groupsRouter.delete("/leave_group", requireAuth, leaveGroup);

groupsRouter.get(
  "/group_by_id",
  requireAuth,
  validateQuery(z.object({ group_id: z.coerce.number().int() })),
  groupById
);
