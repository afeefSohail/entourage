import { Router } from "express";
import { z } from "zod";
import { formBool, formInt } from "../lib/formFields";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validate";
import { upload } from "../middleware/upload";
import {
  getPhotoFile,
  uploadPhotoHandler,
  deletePhoto,
  setPhotoOrder,
} from "../controllers/photosController";

export const photosRouter = Router();

// Public: image views can't attach auth headers; keys are immutable (timestamped)
photosRouter.get("/file/*", getPhotoFile);

photosRouter.post("/upload_photo", requireAuth, upload.single("image"), uploadPhotoHandler);

photosRouter.delete(
  "/delete_photo",
  requireAuth,
  validateBody(z.object({ id: formInt() })),
  deletePhoto
);

photosRouter.post(
  "/set_order",
  requireAuth,
  validateBody(
    z.object({
      id: formInt(),
      order: formInt(),
      is_primary: formBool().optional(),
    })
  ),
  setPhotoOrder
);
