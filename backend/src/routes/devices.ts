import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validate";

export const devicesRouter = Router();

// POST /update_device_token
devicesRouter.post(
  "/update_device_token",
  requireAuth,
  validateBody(
    z.object({
      physical_address: z.string().min(1),
      fcm_token: z.string().min(1),
      device_type: z.string().min(1),
    })
  ),
  async (req, res) => {
    try {
      const { physical_address, fcm_token, device_type } = req.body as {
        physical_address: string;
        fcm_token: string;
        device_type: string;
      };

      await prisma.device.upsert({
        where: {
          user_id_physical_address: {
            user_id: req.user.id,
            physical_address,
          },
        },
        update: { fcm_token, device_type, updated_at: new Date() },
        create: {
          user_id: req.user.id,
          physical_address,
          fcm_token,
          device_type,
          updated_at: new Date(),
        },
      });

      ok(res, null);
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);
