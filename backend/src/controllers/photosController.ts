import { RequestHandler } from "express";
import { GetObjectCommand } from "@aws-sdk/client-s3";
import { Readable } from "stream";
import { prisma } from "../lib/prisma";
import { ok, fail } from "../lib/respond";
import { uploadPhoto, deletePhotoFromS3 } from "../services/photoService";
import { reEvaluateGroupStatus, findUserGroup } from "../services/groupService";
import { serializeOwnUser } from "../lib/serializers";
import { s3, S3_BUCKET } from "../config/s3";

const PHOTO_KEY_PATTERN = /^photos\/\d+\/[\w.-]+\.(jpg|png)$/;

export const getPhotoFile: RequestHandler = async (req, res) => {
  const key = (req.params as Record<string, string>)[0];
  if (!PHOTO_KEY_PATTERN.test(key)) {
    fail(res, 404, "Not found");
    return;
  }
  try {
    const obj = await s3.send(new GetObjectCommand({ Bucket: S3_BUCKET, Key: key }));
    res.setHeader("Content-Type", obj.ContentType ?? "image/jpeg");
    if (obj.ContentLength !== undefined) res.setHeader("Content-Length", obj.ContentLength);
    res.setHeader("Cache-Control", "public, max-age=31536000, immutable");
    (obj.Body as Readable).pipe(res);
  } catch (err) {
    if ((err as { name?: string }).name === "NoSuchKey") {
      fail(res, 404, "Not found");
    } else {
      console.error("Photo fetch error:", err);
      fail(res, 502, "Could not load photo");
    }
  }
};

export const uploadPhotoHandler: RequestHandler = async (req, res) => {
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
};

export const deletePhoto: RequestHandler = async (req, res) => {
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
};

export const setPhotoOrder: RequestHandler = async (req, res) => {
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
};
