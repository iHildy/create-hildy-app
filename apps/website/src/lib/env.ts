import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const env = createEnv({
  server: {
    // BetterAuth secret (required for production)
    BETTER_AUTH_SECRET: z.string().min(32).optional(),
    BETTER_AUTH_URL: z.string().url().optional(),
    // Environment
    ENVIRONMENT: z.enum(["development", "production", "preview"]).optional(),
  },
  client: {
    // Add client-side env vars here
    // NEXT_PUBLIC_APP_URL: z.string().url(),
  },
  runtimeEnv: {
    // Server
    BETTER_AUTH_SECRET: process.env.BETTER_AUTH_SECRET,
    BETTER_AUTH_URL: process.env.BETTER_AUTH_URL,
    ENVIRONMENT: process.env.ENVIRONMENT,
    // Client
  },
});
