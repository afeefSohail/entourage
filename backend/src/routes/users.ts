import { Router } from "express";
import { z } from "zod";
import { formBool, formInt } from "../lib/formFields";
import { requireAuth } from "../middleware/auth";
import { validateBody, validateQuery } from "../middleware/validate";
import { upload } from "../middleware/upload";
import {
  checkIosVersion,
  userSignup,
  userByAuthToken,
  userByPhoneNumber,
  editProfile,
  userNameAvailable,
  deleteAccount,
  updateCoordinates,
  searchByUserName,
  reportUser,
  sendMessageInvite,
  mySetting,
  editSetting,
} from "../controllers/usersController";

export const usersRouter = Router();

usersRouter.get(
  "/check_ios_version",
  validateQuery(z.object({ ios_version: z.string().min(1) })),
  checkIosVersion
);

usersRouter.post(
  "/user_signup",
  validateBody(z.object({ phone_number: z.string().min(1) })),
  userSignup
);

usersRouter.get("/user_by_auth_token", requireAuth, userByAuthToken);

usersRouter.get(
  "/user_by_phone_number",
  validateQuery(z.object({ phone_number: z.string().min(1) })),
  userByPhoneNumber
);

usersRouter.post(
  "/edit_profile",
  requireAuth,
  validateBody(
    z.object({
      gender: z.enum(["male", "female"]).optional(),
      first_name: z.string().optional(),
      last_name: z.string().optional(),
      user_name: z.string().optional(),
      bio: z.string().optional(),
      dob: formInt().optional(),
    })
  ),
  editProfile
);

usersRouter.get(
  "/user_name_available",
  validateQuery(z.object({ user_name: z.string().min(1) })),
  userNameAvailable
);

usersRouter.delete(
  "/delete_account",
  requireAuth,
  validateBody(z.object({ reason: z.string().optional() })),
  deleteAccount
);

usersRouter.post(
  "/update_coordinates",
  requireAuth,
  validateBody(
    z.object({
      latitude: z.string().min(1),
      longitude: z.string().min(1),
      city: z.string().optional(),
      state: z.string().optional(),
    })
  ),
  updateCoordinates
);

usersRouter.get(
  "/search_by_user_name",
  requireAuth,
  validateQuery(z.object({ user_name: z.string().min(1) })),
  searchByUserName
);

usersRouter.post("/report", requireAuth, upload.single("image"), reportUser);

usersRouter.post(
  "/send_message_invite",
  requireAuth,
  validateBody(z.object({ phone_number: z.string().min(1) })),
  sendMessageInvite
);

usersRouter.get("/my_setting", requireAuth, mySetting);

usersRouter.post(
  "/edit_setting",
  requireAuth,
  validateBody(
    z.object({
      everyone: formBool().optional(),
      male_only: formBool().optional(),
      female_only: formBool().optional(),
      min_age: formInt().min(18).optional(),
      max_age: formInt().max(100).optional(),
      max_distace: formInt().min(1).optional(),
      general: formBool().optional(),
      friendship: formBool().optional(),
      match: formBool().optional(),
      group: formBool().optional(),
      chat: formBool().optional(),
    })
  ),
  editSetting
);
