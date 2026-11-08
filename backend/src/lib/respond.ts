import { Response } from "express";

export function ok(res: Response, data: unknown, message = "Success"): void {
  res.status(200).json({ meta: { code: 200, message }, data });
}

export function okPaginated(
  res: Response,
  data: unknown,
  pagination: {
    current_page: number;
    total_pages: number;
    per_page: number;
    total_count: number;
  },
  message = "Success"
): void {
  res.status(200).json({ meta: { code: 200, message, ...pagination }, data });
}

export function fail(res: Response, code: number, message: string): void {
  res.status(code).json({ meta: { code, message }, data: null });
}
