import { createId } from "@paralleldrive/cuid2";
import { redis } from "../config/redis";

export function generateToken(): string {
  return createId();
}

export async function invalidateToken(token: string): Promise<void> {
  await redis.del(`user:token:${token}`);
}
