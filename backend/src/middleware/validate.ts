import { Request, Response, NextFunction } from "express";
import { ZodSchema, ZodError } from "zod";
import { fail } from "../lib/respond";

export function validateBody<T>(schema: ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const message = formatZodError(result.error);
      fail(res, 422, message);
      return;
    }
    req.body = result.data;
    next();
  };
}

export function validateQuery<T>(schema: ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.query);
    if (!result.success) {
      const message = formatZodError(result.error);
      fail(res, 422, message);
      return;
    }
    req.query = result.data as typeof req.query;
    next();
  };
}

function formatZodError(error: ZodError): string {
  const first = error.errors[0];
  if (!first) return "Validation failed";
  const field = first.path.join(".");
  return field ? `${field}: ${first.message}` : first.message;
}
