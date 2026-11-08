import { Router } from "express";
import { z } from "zod";
import { ok, fail } from "../lib/respond";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validate";
import { notifySelf } from "../services/notificationService";

export const notificationsRouter = Router();

// POST /send_notification
notificationsRouter.post(
  "/send_notification",
  requireAuth,
  validateBody(z.object({ message: z.string().min(1) })),
  async (req, res) => {
    try {
      const { message } = req.body as { message: string };
      await notifySelf(req.user.id, message);
      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);
