import { Request, Response, NextFunction } from "express";
import { prisma } from "../lib/prisma";
import { redis } from "../config/redis";
import { fail } from "../lib/respond";

const CACHE_TTL = 5 * 60; // 5 minutes

function extractToken(req: Request): string | null {
  const authHeader = req.headers.authorization;
  if (authHeader?.startsWith("Bearer ")) {
    return authHeader.slice(7);
  }
  const token =
    (req.query.auth_token as string) ||
    (req.body?.auth_token as string);
  return token || null;
}

export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const token = extractToken(req);
  if (!token) {
    fail(res, 401, "Unauthorized");
    return;
  }

  try {
    const cacheKey = `user:token:${token}`;
    const cached = await redis.get(cacheKey);
    if (cached) {
      req.user = JSON.parse(cached);
      next();
      return;
    }

    const user = await prisma.user.findUnique({
      where: { authentication_token: token },
      include: { photos: true, devices: true },
    });

    if (!user || user.is_blocked || user.is_banned) {
      fail(res, 401, "Unauthorized");
      return;
    }

    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(user));
    req.user = user;
    next();
  } catch (err) {
    console.error("Auth middleware error:", err);
    fail(res, 500, "Internal server error");
  }
}

export async function invalidateUserCache(token: string): Promise<void> {
  await redis.del(`user:token:${token}`);
}
