import { RequestHandler } from "express";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";

export const updateDeviceToken: RequestHandler = async (req, res) => {
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
};
