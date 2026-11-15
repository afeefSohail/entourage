import { Router } from "express";
import { z } from "zod";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validate";
import { sendNotification } from "../controllers/notificationsController";

export const notificationsRouter = Router();

notificationsRouter.post(
  "/send_notification",
  requireAuth,
  validateBody(z.object({ message: z.string().min(1) })),
  sendNotification
);
