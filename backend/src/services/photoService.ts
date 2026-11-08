import sharp from "sharp";
import { PutObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
import { s3, S3_BUCKET, s3Url } from "../config/s3";

type PhotoSizes = {
  original: string;
  medium: string;
  thumb: string;
};

type SizeConfig = {
  key: "original" | "medium" | "thumb";
  width: number;
};

const SIZES: SizeConfig[] = [
  { key: "original", width: 1200 },
  { key: "medium", width: 640 },
  { key: "thumb", width: 200 },
];

export async function uploadPhoto(
  buffer: Buffer,
  userId: number,
  mimeType: string
): Promise<PhotoSizes> {
  const timestamp = Date.now();
  const ext = mimeType.includes("png") ? "png" : "jpg";
  const urls: Partial<PhotoSizes> = {};

  await Promise.all(
    SIZES.map(async ({ key, width }) => {
      const resized = await sharp(buffer)
        .resize({ width, withoutEnlargement: true })
        .jpeg({ quality: 85 })
        .toBuffer();

      const s3Key = `photos/${userId}/${timestamp}_${key}.${ext}`;

      await s3.send(
        new PutObjectCommand({
          Bucket: S3_BUCKET,
          Key: s3Key,
          Body: resized,
          ContentType: "image/jpeg",
        })
      );

      urls[key] = s3Url(s3Key);
    })
  );

  return urls as PhotoSizes;
}

export async function deletePhotoFromS3(urls: {
  original: string;
  medium: string;
  thumb: string;
}): Promise<void> {
  const keys = [urls.original, urls.medium, urls.thumb].map((url) =>
    url.replace(
      /^https?:\/\/[^/]+\.s3\.[^/]+\.amazonaws\.com\//,
      ""
    )
  );

  await Promise.allSettled(
    keys.map((key) =>
      s3.send(new DeleteObjectCommand({ Bucket: S3_BUCKET, Key: key }))
    )
  );
}
