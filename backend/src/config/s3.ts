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

export function s3Url(key: string): string {
  if (env.S3_ENDPOINT) {
    // Cloudflare R2 public URL format
    return `${env.S3_ENDPOINT}/${S3_BUCKET}/${key}`;
  }
  return `https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com/${key}`;
}
