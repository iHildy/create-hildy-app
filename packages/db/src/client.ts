import { drizzle } from "drizzle-orm/d1";
import * as schema from "./schema";

export type Database = ReturnType<typeof createDb>;

/**
 * Create a Drizzle database instance for Cloudflare D1
 * @param d1 - The D1 database binding from Cloudflare Workers
 * @returns Drizzle ORM instance with schema
 */
export function createDb(d1: D1Database) {
  return drizzle(d1, { schema });
}

/**
 * Type helper for database operations
 */
export type DbClient = ReturnType<typeof createDb>;
