import { Request, Response, NextFunction } from "express";
import { redis } from "../config/redis";
import { fail } from "../lib/respond";

const MAX_REQUESTS = 60;
const WINDOW_SECONDS = 60;

export async function rateLimiter(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const ip = req.ip ?? req.socket.remoteAddress ?? "unknown";
  const endpoint = req.path;
  const key = `rate:${ip}:${endpoint}`;

  try {
    const count = await redis.incr(key);
    if (count === 1) {
      await redis.expire(key, WINDOW_SECONDS);
    }
    if (count > MAX_REQUESTS) {
      fail(res, 429, "Too many requests");
      return;
    }
    next();
  } catch {
    next();
  }
}
