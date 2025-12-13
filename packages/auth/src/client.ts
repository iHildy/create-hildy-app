import { createAuthClient } from "better-auth/react";

/**
 * BetterAuth client for React applications
 * Configure the baseURL in your app's environment
 */
export const authClient = createAuthClient({
  baseURL: typeof window !== "undefined" ? window.location.origin : "",
});

/**
 * Auth hooks for React components
 */
export const { signIn, signUp, signOut, useSession } = authClient;

/**
 * Type exports for the auth client
 */
export type Session = typeof authClient.$Infer.Session;
