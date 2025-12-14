import type { CloudflareBindings, CreateContextOptions } from "@/types";
import type { DbClient } from "@repo/db";
import { initTRPC } from "@trpc/server";
import { FetchCreateContextFnOptions } from "@trpc/server/adapters/fetch";
import superjson from "superjson";
import { ZodError } from "zod";
import { createDb } from "./db";

/**
 * 1. CONTEXT
 *
 * This section defines the "contexts" that are available in the backend API.
 *
 * These allow you to access things when processing a request, like the database, the session, etc.
 */

/**
 * This helper generates the "internals" for a tRPC context. If you need to use it, you can export
 * it from here.
 *
 * Examples of things you may need it for:
 * - testing, so we don't have to mock Next.js' req/res
 * - tRPC's `createSSGHelpers`, where we don't have req/res
 *
 * @see https://create.t3.gg/en/usage/trpc#-serverapitrpcts
 */
export const createInnerTRPCContext = (opts: CreateContextOptions) => {
  return {
    headers: opts.headers,
    db: opts.db,
  };
};

/**
 * Create tRPC context with Cloudflare bindings
 * In Cloudflare Workers, bindings are accessed per-request
 *
 * @param opts - Fetch request options
 * @param bindings - Cloudflare Worker bindings (DB, BUCKET, etc.)
 */
export const createTRPCContext = (
  opts: FetchCreateContextFnOptions,
  bindings: CloudflareBindings,
) => {
  const db = createDb(bindings.DB);
  return createInnerTRPCContext({
    headers: opts.req.headers,
    db,
  });
};

/**
 * For local development without Cloudflare bindings
 * Uses a mock or local D1 instance
 */
export const createTRPCContextLocal = (opts: FetchCreateContextFnOptions) => {
  // In local dev, the D1 binding comes from wrangler
  // This is a placeholder that will be replaced when running with wrangler dev
  return createInnerTRPCContext({
    headers: opts.req.headers,
    db: new Proxy({} as DbClient, {
      get: () => {
        throw new Error(
          "Database not initialized in local context. Ensure you are running with 'wrangler dev' or have properly mocked the DB.",
        );
      },
    }),
  });
};

/**
 * 2. INITIALIZATION
 *
 * This is where the tRPC API is initialized, connecting the context and transformer. We also parse
 * ZodErrors so that you get typesafety on the frontend if your procedure fails due to validation
 * errors on the backend.
 */
const t = initTRPC.context<ReturnType<typeof createInnerTRPCContext>>().create({
  transformer: superjson,
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError ? error.cause.flatten() : null,
      },
    };
  },
});

/**
 * 3. ROUTER & PROCEDURE HELPERS
 *
 * These are helper functions to create the base router and procedures for your tRPC API.
 */

/**
 * This is how you create new routers and sub-routers in your tRPC API.
 *
 * @see https://trpc.io/docs/router
 */
export const createTRPCRouter = t.router;

/**
 * Public (unauthenticated) procedure
 */
export const publicProcedure = t.procedure;
