import express from "express";
import { usersRouter } from "./routes/users";
import { photosRouter } from "./routes/photos";
import { groupsRouter } from "./routes/groups";
import { matchesRouter } from "./routes/matches";
import { friendshipsRouter } from "./routes/friendships";
import { notificationsRouter } from "./routes/notifications";
import { devicesRouter } from "./routes/devices";
import { rateLimiter } from "./middleware/rateLimiter";
import { fail } from "./lib/respond";

export const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(rateLimiter);

app.use("/api/v1/users", usersRouter);
app.use("/api/v1/photos", photosRouter);
app.use("/api/v1/groups", groupsRouter);
app.use("/api/v1/matches", matchesRouter);
app.use("/api/v1/friendships", friendshipsRouter);
app.use("/api/v1/notifications", notificationsRouter);
app.use("/api/v1/devices", devicesRouter);

app.use((_req, res) => {
  fail(res, 404, "Not found");
});

app.use(
  (
    err: Error,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction
  ) => {
    console.error("Unhandled error:", err);
    fail(res, 500, "Internal server error");
  }
);
