import { S3Client } from "@aws-sdk/client-s3";
import { env } from "./env";

export const s3 = new S3Client({
  region: env.S3_REGION,
  credentials: {
    accessKeyId: env.AWS_ACCESS_KEY_ID,
    secretAccessKey: env.AWS_SECRET_ACCESS_KEY,
  },
  ...(env.S3_ENDPOINT ? { endpoint: env.S3_ENDPOINT } : {}),
});

export const S3_BUCKET = env.S3_BUCKET;
export const S3_REGION = env.S3_REGION;

export const PHOTO_KEY_PREFIX = "photos/";
export const PHOTO_FILE_ROUTE = "/api/v1/photos/file/";

// The R2 S3 endpoint only accepts signed requests, so without a public bucket URL
// photos are streamed through the API's file route.
export function s3Url(key: string): string {
  if (env.S3_PUBLIC_URL) {
    return `${env.S3_PUBLIC_URL.replace(/\/+$/, "")}/${key}`;
  }
  if (!env.S3_ENDPOINT) {
    return `https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com/${key}`;
  }
  return `${env.PUBLIC_API_URL.replace(/\/+$/, "")}${PHOTO_FILE_ROUTE}${key}`;
}

// Recovers the object key from any URL format stored over time (R2 path-style,
// AWS virtual-host, public base, or the API file route).
export function photoKeyFromUrl(url: string): string | null {
  let path: string;
  try {
    path = decodeURIComponent(new URL(url).pathname);
  } catch {
    return null;
  }
  const i = path.lastIndexOf(`/${PHOTO_KEY_PREFIX}`);
  return i === -1 ? null : path.slice(i + 1);
}

export function publicPhotoUrl(url: string): string {
  const key = photoKeyFromUrl(url);
  return key ? s3Url(key) : url;
}
