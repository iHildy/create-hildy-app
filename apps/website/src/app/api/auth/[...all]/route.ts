import { createAuth } from "@repo/auth";
import { createDb } from "@repo/db";
import { toNextJsHandler } from "better-auth/next-js";

/**
 * BetterAuth API route handler for Next.js
 * Handles all auth endpoints: /api/auth/*
 *
 * Note: This is a simplified version. In production with OpenNext,
 * you would access D1 bindings from getRequestContext() or
 * process.env.DB when running with wrangler.
 */

// Placeholder D1 binding - will be replaced at runtime by Cloudflare Workers
const getD1Binding = (): D1Database => {
  // In development, this will throw - run with `wrangler dev` instead
  // In production, OpenNext provides the binding via process.env
  if (typeof process !== "undefined" && process.env.DB) {
    return process.env.DB as unknown as D1Database;
  }
  throw new Error("D1 binding not available - run with wrangler dev");
};

// Create auth instance factory for request handling
const createRequestAuth = () => {
  try {
    const db = createDb(getD1Binding());
    return createAuth({ db });
  } catch {
    // Fallback for build-time - will fail at runtime if D1 not configured
    return null;
  }
};

export const { GET, POST } = toNextJsHandler({
  handler: async (request: Request) => {
    const auth = createRequestAuth();
    if (!auth) {
      return new Response("Auth not configured", { status: 500 });
    }
    return auth.handler(request);
  },
});
