# 🚀 create-hildy-app

An opinionated comprehensive Next.js 15 starter template designed for rapid development with best practices, type safety, and developer experience in mind. Built for teams who want to move fast without breaking things.

[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Next.js](https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white)](https://nextjs.org/)
[![Prisma](https://img.shields.io/badge/Prisma-5A67D8?style=for-the-badge&logo=Prisma&logoColor=white)](https://prisma.io/)
[![tRPC](https://img.shields.io/badge/tRPC-398CCB?style=for-the-badge&logo=trpc&logoColor=white)](https://trpc.io/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)

## ✨ Features

### 🏗️ Core Stack

- **[Next.js 15](https://nextjs.org/)** with App Router and Turbopack for blazing fast development
- **[TypeScript](https://www.typescriptlang.org/)** with strict type checking and best practices
- **[Prisma](https://prisma.io/)** for type-safe database access with PostgreSQL
- **[tRPC](https://trpc.io/)** for end-to-end type safety between frontend and backend
- **[React Query](https://tanstack.com/query)** for powerful server state management
- **[Zod](https://zod.dev/)** for runtime type validation and schema definition

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
- **[T3 Env](https://env.t3.gg/)** for type-safe environment variables

### 🏛️ Infrastructure Ready

- **[Supabase](https://supabase.com/)** configuration for PostgreSQL and authentication
- **[Redis](https://redis.io/)** integration patterns and best practices
- **[Vercel](https://vercel.com/)** deployment configuration
- **[Ngrok](https://ngrok.com/)** tunnel setup for local development

### 🎯 Cursor AI Integration

- **16 Comprehensive Cursor Rules** covering all aspects of development
- **Review Gate V2** for interactive AI code reviews
- **Best Practice Enforcement** for TypeScript, React, Prisma, and more
- **MCP Integration** for enhanced AI development workflows

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- pnpm (recommended package manager)
- PostgreSQL database (Supabase recommended)

### Installation

```bash
# Clone the repository
git clone https://github.com/ihildy/create-hildy-app.git my-app-name
cd my-app-name

# Install dependencies
pnpm install

# Set up environment variables
cp .env.example .env
# Edit .env.local with your database URL and other secrets

# Generate Prisma client and run migrations
pnpm prisma:generate
pnpm prisma:migrate

# Start development server with Turbopack
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) to see your application.

## 📁 Project Structure

```
├── .cursor/                  # Cursor AI rules and configurations
│   └── rules/               # 16 comprehensive development rules
├── prisma/                  # Database schema and migrations
│   ├── migrations/          # Database migration files
│   └── schema.prisma        # Prisma schema definition
├── public/                  # Static assets
├── src/
│   ├── app/                 # Next.js App Router pages
│   │   ├── api/trpc/        # tRPC API routes
│   │   ├── providers/       # React context providers
│   │   ├── globals.css      # Global styles
│   │   ├── layout.tsx       # Root layout component
│   │   └── page.tsx         # Home page
│   ├── components/          # Reusable UI components
│   │   └── ui/              # shadcn/ui components
│   ├── lib/                 # Utility functions and configurations
│   │   ├── env.ts           # Environment variable validation
│   │   └── utils.ts         # Common utilities
│   ├── server/              # Backend logic
│   │   ├── db.ts            # Database connection
│   │   ├── index.ts         # tRPC router exports
│   │   └── trpc.ts          # tRPC configuration
│   └── types/               # TypeScript type definitions
├── supabase/                # Supabase configuration
└── package.json             # Dependencies and scripts
```

## 🛠️ Available Scripts

```bash
# Development
pnpm dev                     # Start development server with Turbopack
pnpm build                   # Build for production
pnpm start                   # Start production server
pnpm clean                   # Clean build artifacts and reinstall dependencies

# Database
pnpm prisma:generate         # Generate Prisma client
pnpm prisma:migrate          # Run database migrations
pnpm deploy                  # Production deployment with migrations

# Code Quality
pnpm lint                    # Run ESLint
pnpm format                  # Format code with Prettier
pnpm test                    # Run tests with Vitest
pnpm test:watch              # Run tests in watch mode

# Infrastructure
pnpm supabase:start          # Start local Supabase
pnpm supabase:stop           # Stop local Supabase
pnpm ngrok:start             # Start ngrok tunnel for localhost:3000
```

## 🎯 Cursor AI Rules

This template includes 16 comprehensive Cursor rules for AI-assisted development:

- **TypeScript Standards** - Best practices for type-safe development
- **React Query & tRPC** - Optimal patterns for data fetching and state management
- **Prisma** - Database best practices and security guidelines
- **Zod** - Runtime validation and schema design patterns
- **Supabase** - Authentication and database integration
- **Redis** - Caching and session management
- **Vitest** - Testing strategies and patterns
- **Review Gate V2** - Interactive AI code review workflows
- **Turbopack** - Build optimization and performance
- **Web Expert** - Modern web development best practices

## 📚 Learning Resources

- [Next.js Documentation](https://nextjs.org/docs) - Learn Next.js features and API
- [tRPC Documentation](https://trpc.io/docs) - End-to-end type safety
- [Prisma Documentation](https://www.prisma.io/docs) - Database toolkit
- [Tailwind CSS](https://tailwindcss.com/docs) - Utility-first CSS framework
- [shadcn/ui](https://ui.shadcn.com/) - Component library
- [React Query](https://tanstack.com/query/latest) - Server state management

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💡 Why create-hildy-app?

This starter template was created to address the common pain points of setting up a modern Next.js application:

- **⚡ Zero Configuration** - Everything is pre-configured and ready to use
- **🛡️ Type Safety First** - End-to-end type safety with TypeScript, Zod, and tRPC
- **🎨 Beautiful by Default** - Professional UI components with Tailwind and shadcn/ui
- **🧪 Testing Ready** - Vitest setup with testing utilities and examples
- **🤖 AI-Optimized** - Comprehensive Cursor rules for AI-assisted development
- **📈 Production Ready** - Optimized builds, error handling, and deployment configs
- **🔄 Best Practices** - Industry-standard patterns and code organization

Built with ❤️ for developers who want to focus on building features, not configuring tools.
