import { fileURLToPath } from "node:url";
import createJiti from "jiti";
const jiti = createJiti(fileURLToPath(import.meta.url));

// Import env here to validate during build. Using jiti@^1 we can import .ts files :)
jiti("./src/lib/env");

/** @type {import('next').NextConfig} */
export default {
  distDir: process.env.NODE_ENV === "development" ? ".next/dev" : ".next/build",
  allowedDevOrigins: ["localhost:3000", "localhost:80"],
  /** ... */
};
