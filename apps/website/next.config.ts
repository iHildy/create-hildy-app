import createJiti from 'jiti';

const jiti = createJiti(new URL(import.meta.url).pathname);

// Import env here to validate during build. Using jiti we can import .ts files :)
jiti('./src/lib/env');

/** @type {import('next').NextConfig} */
const nextConfig = {
  distDir: process.env.NODE_ENV === "development" ? ".next/dev" : ".next/build",
  allowedDevOrigins: ["localhost:3000", "localhost:80", "*.ngrok.app", "*.ngrok-free.app"],
  transpilePackages: ["@repo/db"],
  compiler: {
    removeConsole: process.env.VERCEL_ENV === 'production' && {
      exclude: ['error'],
    },
  },
};

module.exports = nextConfig;

