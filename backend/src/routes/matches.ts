import { Router } from "express";
import { z } from "zod";
import { requireAuth } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import {
  findGroups,
  likeGroup,
  unlikeGroup,
  myMatches,
  unmatchGroup,
} from "../controllers/matchesController";

export const matchesRouter = Router();

matchesRouter.get(
  "/find_groups",
  requireAuth,
  validateQuery(z.object({ page: z.coerce.number().int().min(1).default(1) })),
  findGroups
);

matchesRouter.post(
  "/like_group",
  requireAuth,
  validateBody(z.object({ group_id: z.string().or(z.number()) })),
  likeGroup
);

matchesRouter.post(
  "/unlike_group",
  requireAuth,
  validateBody(z.object({ group_id: z.string().or(z.number()) })),
  unlikeGroup
);

matchesRouter.get("/my_matches", requireAuth, myMatches);

matchesRouter.delete(
  "/unmatch_group",
  requireAuth,
  validateBody(z.object({ group_id: z.string().or(z.number()) })),
  unmatchGroup
);
