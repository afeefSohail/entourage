import { Router } from "express";
import { z } from "zod";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validate";
import { updateDeviceToken } from "../controllers/devicesController";

export const devicesRouter = Router();

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
  updateDeviceToken
);
