import { FlatCompat } from "@eslint/eslintrc";
import pluginQuery from "@tanstack/eslint-plugin-query";
import eslintPluginPrettierRecommended from "eslint-plugin-prettier/recommended";
import { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

const eslintConfig = [
  {
    ignores: [
      "next.config.js",
      "eslint.config.js",
      ".lintstagedrc.js",
      ".vercel",
    ],
  },
  ...compat.extends("next/core-web-vitals", "next/typescript", "prettier"),
  ...pluginQuery.configs["flat/recommended"],
  eslintPluginPrettierRecommended,
];

export default eslintConfig;
