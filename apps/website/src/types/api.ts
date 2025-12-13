import type { Auth } from "@repo/auth";
import type { DbClient } from "@repo/db";
import type { StorageClient } from "@repo/storage";

/**
 * Cloudflare Worker bindings
 * These are available in the Cloudflare Workers environment
 */
export interface CloudflareBindings {
  DB: D1Database;
  BUCKET: R2Bucket;
  ENVIRONMENT: string;
}

/**
 * tRPC Context options
 */
export interface CreateContextOptions {
  headers: Headers;
  db: DbClient;
  auth?: Auth;
  storage?: StorageClient;
}
