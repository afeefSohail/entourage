import { RequestHandler } from "express";
import { ok, fail } from "../lib/respond";
import { notifySelf } from "../services/notificationService";

export const sendNotification: RequestHandler = async (req, res) => {
  try {
    const { message } = req.body as { message: string };
    await notifySelf(req.user.id, message);
    ok(res, null);
  } catch {
    fail(res, 500, "Internal server error");
  }
};
