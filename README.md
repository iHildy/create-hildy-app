# 🚀 create-hildy-app

An opinionated comprehensive Next.js 15 monorepo starter template designed for rapid development with best practices, type safety, and developer experience in mind. Built for teams who want to move fast without breaking things.

[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Next.js](https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white)](https://nextjs.org/)
[![Drizzle](https://img.shields.io/badge/Drizzle-C5F74F?style=for-the-badge&logo=drizzle&logoColor=black)](https://orm.drizzle.team/)
[![tRPC](https://img.shields.io/badge/tRPC-398CCB?style=for-the-badge&logo=trpc&logoColor=white)](https://trpc.io/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)](https://cloudflare.com/)

## ✨ Features

### 🏗️ Core Stack

- **[Next.js 15](https://nextjs.org/)** with App Router and Turbopack for blazing fast development
- **[TypeScript](https://www.typescriptlang.org/)** with strict type checking and best practices
- **[Drizzle ORM](https://orm.drizzle.team/)** for type-safe database access with Cloudflare D1
- **[tRPC](https://trpc.io/)** for end-to-end type safety between frontend and backend
- **[React Query](https://tanstack.com/query)** for powerful server state management
- **[Zod](https://zod.dev/)** for runtime type validation and schema definition
- **Monorepo Architecture** with pnpm workspaces for scalable code organization

### 🔐 Authentication

- **[BetterAuth](https://better-auth.com/)** for secure, modern authentication
- Email/password authentication out of the box
- Session management with secure tokens

### ☁️ Cloudflare Infrastructure

- **[Cloudflare Workers](https://workers.cloudflare.com/)** for edge compute
- **[Cloudflare D1](https://developers.cloudflare.com/d1/)** for SQLite at the edge
- **[Cloudflare R2](https://developers.cloudflare.com/r2/)** for S3-compatible object storage
- **[OpenNext](https://opennext.js.org/)** for deploying Next.js to Cloudflare

### 🎨 UI & Styling

- **[Tailwind CSS v4](https://tailwindcss.com/)** for utility-first styling
- **[shadcn/ui](https://ui.shadcn.com/)** for beautiful, accessible components
- **[Radix UI](https://www.radix-ui.com/)** primitives for robust component foundations
- **[Lucide React](https://lucide.dev/)** for consistent iconography

### 🛠️ Developer Experience

- **[ESLint](https://eslint.org/)** with Next.js and React Query configurations
- **[Prettier](https://prettier.io/)** for consistent code formatting
- **[Vitest](https://vitest.dev/)** for fast unit testing
- **[Husky](https://typicode.github.io/husky/)** for Git hooks and pre-commit checks
- **[lint-staged](https://github.com/lint-staged/lint-staged)** for running linters on staged files
- **[Wrangler](https://developers.cloudflare.com/workers/wrangler/)** for Cloudflare development and deployment

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- pnpm (recommended package manager)
- Cloudflare account (for D1 and R2)
- jq (`brew install jq` on macOS)

### Installation

```bash
# Use this template on GitHub, then clone your new repo
git clone https://github.com/YOUR_USERNAME/your-app-name.git
cd your-app-name

# Run the interactive setup script
./scripts/setup.sh
```

The setup script will:
1. ✅ Detect your app name from the folder
2. ✅ Log you into Cloudflare (if needed)
3. ✅ Create a D1 database
4. ✅ Create an R2 bucket
5. ✅ Generate a secure BetterAuth secret
6. ✅ Update all configuration files
7. ✅ Create your `.env` file

After setup, add your [D1 API token](https://dash.cloudflare.com/profile/api-tokens) to `apps/website/.env`, then:

```bash
pnpm db:push  # Push schema to D1
pnpm dev      # Start development server
```

Open [http://localhost:3000](http://localhost:3000) to see your application.

## 📁 Project Structure

```
├── apps/
│   └── website/                  # Next.js web application
│       ├── src/
│       │   ├── app/              # Next.js App Router pages
│       │   │   ├── api/auth/     # BetterAuth API routes
│       │   │   └── providers/    # React context providers
│       │   ├── components/       # Reusable UI components
│       │   ├── lib/              # Utility functions
│       │   └── server/           # tRPC configuration
│       └── next.config.ts
├── packages/
│   ├── auth/                     # BetterAuth configuration
│   │   └── src/
│   │       ├── index.ts          # Server-side auth
│   │       └── client.ts         # React client hooks
│   ├── db/                       # Drizzle ORM & D1
│   │   ├── src/
│   │   │   ├── schema.ts         # Database schema
│   │   │   └── client.ts         # DB client factory
│   │   └── drizzle.config.ts     # Migration config
│   └── storage/                  # R2 storage utilities
│       └── src/index.ts          # Upload/download helpers
├── wrangler.toml                 # Cloudflare Workers config
├── open-next.config.ts           # OpenNext adapter config
└── pnpm-workspace.yaml
```

## 📦 Workspaces

### Apps (`apps/`)

- **`@repo/website`** - The main Next.js web application

### Packages (`packages/`)

- **`@repo/db`** - Drizzle ORM schema and D1 client
- **`@repo/auth`** - BetterAuth configuration and React hooks
- **`@repo/storage`** - Cloudflare R2 storage utilities

## 🛠️ Available Scripts

```bash
# Development
pnpm dev                         # Start Next.js dev server with Turbopack
pnpm build                       # Build for production
pnpm start                       # Start production server
pnpm clean                       # Clean and reinstall dependencies

# Database (Drizzle + D1)
pnpm db:generate                 # Generate migrations
pnpm db:migrate                  # Run migrations
pnpm db:push                     # Push schema to D1
pnpm db:studio                   # Open Drizzle Studio

# Cloudflare
pnpm cf:dev                      # Run with Wrangler dev server
pnpm cf:deploy                   # Deploy to Cloudflare Workers
pnpm cf:tail                     # Tail production logs
pnpm d1:create                   # Create D1 database
pnpm r2:create                   # Create R2 bucket

# Code Quality
pnpm lint                        # Run ESLint
pnpm format                      # Format with Prettier
pnpm test                        # Run tests
```

## 🔐 Authentication

BetterAuth is pre-configured with email/password authentication:

```typescript
// Sign up
import { signUp } from "@repo/auth/client";
await signUp.email({ email, password, name });

// Sign in
import { signIn } from "@repo/auth/client";
await signIn.email({ email, password });

// Get session
import { useSession } from "@repo/auth/client";
const { data: session } = useSession();

// Sign out
import { signOut } from "@repo/auth/client";
await signOut();
```

## 📚 Learning Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Drizzle ORM Documentation](https://orm.drizzle.team/docs/overview)
- [tRPC Documentation](https://trpc.io/docs)
- [BetterAuth Documentation](https://better-auth.com/docs)
- [Cloudflare D1 Documentation](https://developers.cloudflare.com/d1/)
- [OpenNext for Cloudflare](https://opennext.js.org/cloudflare)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💡 Why create-hildy-app?

- **⚡ Edge-First** - Built for Cloudflare's global edge network
- **🛡️ Type Safety** - End-to-end types with TypeScript, Zod, Drizzle, and tRPC
- **📦 Monorepo Ready** - Scalable architecture with pnpm workspaces
- **🔐 Auth Included** - BetterAuth for secure, modern authentication
- **☁️ Cloud Native** - D1, R2, and Workers out of the box
- **🎨 Beautiful by Default** - Tailwind and shadcn/ui

Built with ❤️ for developers who want to deploy to the edge.
