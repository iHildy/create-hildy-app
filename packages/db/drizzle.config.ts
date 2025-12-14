import type { Config } from "drizzle-kit";
import { env } from "./env";

export default {
  schema: "./src/schema.ts",
  out: "./migrations",
  dialect: "sqlite",
  driver: "d1-http",
  dbCredentials: {
    accountId: env.CLOUDFLARE_ACCOUNT_ID,
    databaseId: env.CLOUDFLARE_D1_DATABASE_ID,
    token: env.CLOUDFLARE_D1_TOKEN,
  },
} satisfies Config;
