import type { DbClient } from "@repo/db/client";
import * as schema from "@repo/db/schema";
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";

/**
 * BetterAuth configuration options
 */
export interface AuthOptions {
  db: DbClient;
  baseURL?: string;
  secret?: string;
}

/**
 * Create a BetterAuth instance configured for Cloudflare D1
 * @param options - Configuration options including the Drizzle DB client
 */
export function createAuth(options: AuthOptions) {
  return betterAuth({
    database: drizzleAdapter(options.db, {
      provider: "sqlite",
      schema: {
        user: schema.user,
        session: schema.session,
        account: schema.account,
        verification: schema.verification,
      },
    }),
    baseURL: options.baseURL,
    secret: options.secret ?? process.env.BETTER_AUTH_SECRET,
    emailAndPassword: {
      enabled: true,
      requireEmailVerification: false, // Set to true in production
    },
    session: {
      expiresIn: 60 * 60 * 24 * 7, // 7 days
      updateAge: 60 * 60 * 24, // 1 day
    },
  });
}

export type Auth = ReturnType<typeof createAuth>;
