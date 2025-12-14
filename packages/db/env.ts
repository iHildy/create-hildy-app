import { z } from "zod";
import { config } from "dotenv";

// Load .env from apps/website if it exists, as that's where setup.sh puts it
config({ path: "../../apps/website/.env" });
// Also try local .env
config();

const envSchema = z.object({
  CLOUDFLARE_ACCOUNT_ID: z.string().min(1, "CLOUDFLARE_ACCOUNT_ID is required"),
  CLOUDFLARE_D1_DATABASE_ID: z.string().min(1, "CLOUDFLARE_D1_DATABASE_ID is required"),
  CLOUDFLARE_D1_TOKEN: z.string().min(1, "CLOUDFLARE_D1_TOKEN is required"),
});

export const env = envSchema.parse(process.env);
