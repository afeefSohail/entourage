import "./config/env"; // validates env vars at boot — crashes if invalid
import { app } from "./app";
import { prisma } from "./lib/prisma";
import { redis } from "./config/redis";
import { env } from "./config/env";

const PORT = env.PORT;

async function main() {
  await redis.connect();
  await prisma.$connect();

  app.listen(PORT, () => {
    console.log(`Entourage API running on port ${PORT} (${env.NODE_ENV})`);
  });
}

main().catch((err) => {
  console.error("Failed to start server:", err);
  process.exit(1);
});
