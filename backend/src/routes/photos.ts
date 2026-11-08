import { Router } from "express";
import { z } from "zod";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";
import { requireAuth } from "../middleware/auth";
import { validateBody } from "../middleware/validate";
import { upload } from "../middleware/upload";
import { uploadPhoto, deletePhotoFromS3 } from "../services/photoService";
import { reEvaluateGroupStatus, findUserGroup } from "../services/groupService";
import { serializeOwnUser } from "../lib/serializers";

export const photosRouter = Router();

// POST /upload_photo
photosRouter.post(
  "/upload_photo",
  requireAuth,
  upload.single("image"),
  async (req, res) => {
    try {
      if (!req.file) {
        fail(res, 422, "image is required");
        return;
      }

      const order = parseInt(req.body.order as string, 10) || 0;
      const isPrimary = req.body.is_primary === "true" || req.body.is_primary === true;

      const urls = await uploadPhoto(req.file.buffer, req.user.id, req.file.mimetype);

      if (isPrimary) {
        await prisma.photo.updateMany({
          where: { user_id: req.user.id },
          data: { is_primary: false },
        });
      }

      await prisma.photo.create({
        data: {
          user_id: req.user.id,
          original: urls.original,
          medium: urls.medium,
          thumb: urls.thumb,
          order,
          is_primary: isPrimary,
        },
      });

      const group = await findUserGroup(req.user.id);
      if (group) {
        await reEvaluateGroupStatus(group.id);
      }

      const user = await prisma.user.findUniqueOrThrow({
        where: { id: req.user.id },
        include: { photos: true, devices: true },
      });

      ok(res, serializeOwnUser(user));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// DELETE /delete_photo
photosRouter.delete(
  "/delete_photo",
  requireAuth,
  validateBody(z.object({ id: z.number().int() })),
  async (req, res) => {
    try {
      const { id } = req.body as { id: number };

      const photo = await prisma.photo.findUnique({ where: { id } });
      if (!photo || photo.user_id !== req.user.id) {
        fail(res, 404, "Not found");
        return;
      }

      await deletePhotoFromS3({
        original: photo.original,
        medium: photo.medium,
        thumb: photo.thumb,
      });

      await prisma.photo.delete({ where: { id } });

      if (photo.is_primary) {
        const next = await prisma.photo.findFirst({
          where: { user_id: req.user.id },
          orderBy: { order: "asc" },
        });
        if (next) {
          await prisma.photo.update({
            where: { id: next.id },
            data: { is_primary: true },
          });
        }
      }

      const group = await findUserGroup(req.user.id);
      if (group) {
        await reEvaluateGroupStatus(group.id);
      }

      const user = await prisma.user.findUniqueOrThrow({
        where: { id: req.user.id },
        include: { photos: true, devices: true },
      });

      ok(res, serializeOwnUser(user));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);

// POST /set_order
photosRouter.post(
  "/set_order",
  requireAuth,
  validateBody(
    z.object({
      id: z.number().int(),
      order: z.number().int(),
      is_primary: z.boolean().optional(),
    })
  ),
  async (req, res) => {
    try {
      const { id, order, is_primary } = req.body as {
        id: number;
        order: number;
        is_primary?: boolean;
      };

      const photo = await prisma.photo.findUnique({ where: { id } });
      if (!photo || photo.user_id !== req.user.id) {
        fail(res, 404, "Not found");
        return;
      }

      if (is_primary) {
        await prisma.photo.updateMany({
          where: { user_id: req.user.id },
          data: { is_primary: false },
        });
      }

      await prisma.photo.update({
        where: { id },
        data: { order, ...(is_primary != null ? { is_primary } : {}) },
      });

      const user = await prisma.user.findUniqueOrThrow({
        where: { id: req.user.id },
        include: { photos: true, devices: true },
      });

      ok(res, serializeOwnUser(user));
    } catch {
      fail(res, 500, "Internal server error");
    }
  }
);
