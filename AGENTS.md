# AGENTS RULES OVERVIEW

This document condenses the most critical rules for agents working on this repository. Note that YOU don't have access to environmental variables and cannot run commands like `pnpm build` because of this, instead use `pnpm lint`

---

## Project Overview

Please read the README.md file for a detailed overview of the project.

## 0. General Rules

Always run `pnpm lint` at the end of your response after making your changes. Use ALL warnings and errors as a feedback loop and continue your same response by fixing ALL warnings and errors in an enterprise expert SWE + non-lazy way. Loop the `pnpm lint` until there are ZERO errors or warnings with the files you have edited.

Don't be lazy; always investigate thoroughly and address ROOT causes rather than merely treating symptoms.

---

## 1. Project Tech Stack

• **Core Stack**: Next.js 15 (App Router) · TypeScript + ESLint · Zod + Drizzle + tRPC + React Query · Cloudflare D1 + R2 · BetterAuth · ShadCN + TailwindCSS v4 · pnpm.
• Use `pnpm` (never `npm`) and `pnpm dlx` (never `npx`).
• After code changes run `pnpm lint`.
• Default to **React Server Components**; mark client components with `"use client"` only when browser APIs or state are required.
• All new packages must support **ES modules**; add via `pnpm add -w` to keep lockfile consistent.

---

## 2. TypeScript Standards

• Put **all** type/interface definitions in `app/types/` – never inline duplicates.
• Re-use or extend existing types before making new ones; prefer interfaces, avoid enums and `any`.
• Enable `strict` compiler options: no implicit `any`, explicit return types, strict-null checks.
• File names **kebab-case**; PascalCase for interfaces/types.
• Export from `app/types/index.ts` to create a single import path.

---

## 3. Web Expert (Frontend/UI)

• Use Tailwind for styling, ShadCN + Radix primitives.
• Keep `use client` components minimal; favour RSC, Suspense, dynamic imports.
• Mobile-first, responsive design; optimize Web Vitals (LCP/CLS/FID).
• Component/dir names in `kebab-case`; export components by name.
• Adhere to **WCAG 2.1 AA** accessibility: semantic HTML, ARIA only when needed.
• Use `clsx` or `tailwind-merge` to compose classNames.

---

## 4. React Query Best Practices

• Encapsulate data access in custom hooks (`useXQuery`, `useYMutation`).
• Separate query & mutation files; prefetch likely routes; invalidate on writes.
• Handle errors & retries centrally; implement optimistic updates where it helps UX.
• **Stable query keys** must be arrays (`['campaign', id]`) not interpolated strings.

---

## 5. tRPC Best Practices

• Keep routers separate from business logic; compose routers hierarchically.
• Validate **every** input with Zod; generate & export types from schemas.
• Use middleware for auth, RBAC, logging; throw `TRPCError` for failures.
• Never access DB directly in routers—use service / repository layers.
• Store current user & drizzle client on the **context** object; type it globally.

---

## 6. Zod Guidelines

• Organize schemas per domain (`schemas/`); compose & reuse via `extend`, `intersection`, `union`.
• Use `.safeParse` & typed guards for runtime validation.
• Provide defaults, custom refinements, informative error messages.
• Keep schemas immutable; export both `schema` and `type Schema = z.infer<typeof schema>`.

---

## 7. Drizzle ORM Best Practices

• **Schema in `packages/db/src/schema.ts`**: Define all tables using `sqliteTable`.
• Use D1-compatible types: `text`, `integer` (with `mode: "timestamp"` for dates).
• **Migrations**: Use `pnpm db:generate` then `pnpm db:push` for D1.
• **Client factory**: Always use `createDb(binding)` - D1 binding comes from request context.
• Use `select()` to limit returned fields; avoid N+1 with proper joins.

Example pattern:

```typescript
import { createDb } from "@repo/db";

// In tRPC context or route handler
const db = createDb(env.DB);
const users = await db.select().from(user).where(eq(user.id, id));
```

---

## 8. BetterAuth Best Practices

• **Server config** in `packages/auth/src/index.ts` - uses Drizzle adapter.
• **Client hooks** from `@repo/auth/client`: `signIn`, `signUp`, `signOut`, `useSession`.
• Auth tables (user, session, account, verification) defined in `packages/db/src/schema.ts`.
• API route at `app/api/auth/[...all]/route.ts` handles all auth endpoints.
• Always validate session in protected routes/procedures.

---

## 9. Cloudflare Workers Best Practices

• **Bindings** (D1, R2, KV) are accessed per-request, not globally.
• Use `wrangler.toml` for binding configuration.
• Set `compatibility_date` to `2024-09-23` or later for Node.js compatibility.
• Use `@cloudflare/workers-types` for type definitions.
• Test locally with `pnpm cf:dev` (wrangler dev).

---

## 10. R2 Storage Best Practices

• Use `@repo/storage` utilities: `upload`, `download`, `remove`, `list`, `exists`.
• Create storage client: `createStorage(env.BUCKET)`.
• For large files, use streaming uploads.
• Set appropriate content types via options.

---

## 11. Vitest Testing Standards

• Place test files beside source (`*.spec.ts`/`*.test.ts`).
• Follow AAA (Arrange-Act-Assert) structure & descriptive names.
• Mock only external deps; clean up in `afterEach`; run tests in parallel.

---

### Global Conventions

• Concise, functional, declarative TypeScript.
• Descriptive variables (`isLoading`, `hasError`).
• Prefer iteration & modularization over duplication.

> Adhering to these condensed rules keeps the codebase safe, maintainable, and fast-moving.
