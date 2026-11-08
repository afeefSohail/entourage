import { User, Photo, Device } from "@prisma/client";

type AuthUser = User & {
  photos: Photo[];
  devices: Device[];
};

declare global {
  namespace Express {
    interface Request {
      user: AuthUser;
    }
  }
}
