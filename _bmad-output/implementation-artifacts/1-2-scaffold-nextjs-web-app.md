# Story 1.2: Scaffold Next.js Web App

Status: done

## Story

As a developer,
I want the Next.js 15 app scaffolded with TypeScript, Tailwind CSS, App Router, and ESLint,
So that the web layer is ready for feature development with all tooling configured.

## Acceptance Criteria

1. **Given** the `/web` directory exists, **When** the scaffold is complete, **Then** `npx create-next-app@latest` has been run with `--typescript --tailwind --app --eslint` flags
2. **Given** the scaffold is complete, **Then** Drizzle ORM (`drizzle-orm`, `pg`) and `drizzle-kit`, `@types/pg` are installed
3. **Given** the scaffold is complete, **Then** `web/src/db/index.ts` exists and exports a Drizzle client configured from `DATABASE_URL` env var
4. **Given** the scaffold is complete, **Then** `npm run dev` starts the development server without errors
5. **Given** the scaffold is complete, **Then** `npm run build` completes without errors
6. **Given** the scaffold is complete, **Then** TypeScript strict mode is enabled in `tsconfig.json`
7. **Given** the scaffold is complete, **Then** the app has no user authentication — all routes are public by default (FR26)

## Tasks / Subtasks

- [x] Task 1: Scaffold Next.js app into `/web` (AC: #1)
  - [x] 1.1 Remove `web/.gitkeep` placeholder from Story 1.1
  - [x] 1.2 Run `npx create-next-app@latest web --typescript --tailwind --app --eslint --src-dir --turbopack` from the project root (scaffolds into existing `web/` directory)
  - [x] 1.3 Verify the `src/` directory structure exists (`web/src/app/`)
  - [x] 1.4 Verify TypeScript strict mode is enabled in `web/tsconfig.json` (AC: #6)
- [x] Task 2: Install Drizzle ORM and database dependencies (AC: #2)
  - [x] 2.1 Run `npm install drizzle-orm pg` in `/web`
  - [x] 2.2 Run `npm install -D drizzle-kit @types/pg` in `/web`
- [x] Task 3: Create Drizzle database client (AC: #3)
  - [x] 3.1 Create `web/src/db/index.ts` exporting a Drizzle client configured from `DATABASE_URL`
  - [x] 3.2 Create `web/.env.example` with `DATABASE_URL` placeholder
- [x] Task 4: Create drizzle.config.ts (AC: #2, supports Story 1.3)
  - [x] 4.1 Create `web/drizzle.config.ts` referencing `DATABASE_URL` for migrations
- [x] Task 5: Verify build and dev server (AC: #4, #5, #7)
  - [x] 5.1 Run `npm run dev` and confirm it starts without errors
  - [x] 5.2 Run `npm run build` and confirm it completes without errors
  - [x] 5.3 Verify no authentication middleware or login routes exist (FR26)

### Review Findings

- [x] [Review][Patch] `"lint": "eslint"` missing target path — fixed: changed to `next lint` [web/package.json]
- [x] [Review][Decision] Pool connection limits and serverless singleton pattern — resolved: applied globalThis singleton guard
- [x] [Review][Patch] DATABASE_URL undefined causes silent/wrong error in Pool constructor [web/src/db/index.ts] — fixed: throws early with clear message + singleton guard applied
- [x] [Review][Patch] .env.example doesn't clarify `.env.local` filename for Next.js [web/.env.example] — fixed: added clarifying comments
- [x] [Review][Defer] db/queries/ directory absent (ARCH7) [web/src/db/] — deferred, pre-existing; by design for Epic 4

## Dev Notes

### Architecture Requirements

- **ARCH1:** Web app lives in `/web` — this is the Vercel deployment root
- **ARCH10:** Vercel Git Integration deploys from `/web` directory on push to `main`
- **FR26:** All routes are public by default — no user authentication in v1
- Architecture specifies `src/` directory layout — `create-next-app` should be configured to use `src/`

### Scaffold Command Details

The architecture doc specifies this exact initialization:

```bash
npx create-next-app@latest web --typescript --tailwind --app --eslint --src-dir --turbopack
```

**Critical:** Run from the project root so it scaffolds INTO the existing `web/` directory. The `create-next-app` CLI will detect the existing directory and scaffold into it.

**Important flags:**
- `--src-dir` is required — the `src/` directory is NOT the default, but the architecture requires `web/src/` structure
- `--turbopack` enables Turbopack for the dev server (Next.js 15 default)

**Interactive prompt handling:** If `create-next-app` asks interactive questions despite flags, expected answers:
- Use `src/` directory? **Yes**
- Use Turbopack? **Yes**
- Customize import alias? **No** (use default `@/*`)

**Next.js 15 breaking changes to be aware of:**
- `cookies()`, `headers()`, `params`, `searchParams` are now **async** — must be `await`ed
- `fetch` requests are **no longer cached by default** (changed from Next.js 14)
- Default config file is `next.config.ts` (TypeScript)

### Drizzle Client Setup (`web/src/db/index.ts`)

```typescript
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export const db = drizzle(pool);
```

**Note:** Using `pg` (node-postgres) driver as specified in the architecture. The `@neondatabase/serverless` driver is an alternative for edge runtime, but the architecture chose `pg` for simplicity. Neon supports standard PostgreSQL connections with built-in pooling.

### drizzle.config.ts Setup

```typescript
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

**Note:** `schema.ts` doesn't exist yet — it will be created in Story 1.3. The config just needs to point to the correct path.

### .env.example Content

```
DATABASE_URL=postgresql://user:password@host:5432/dbname
```

Only `DATABASE_URL` for now. `ADMIN_USER`, `ADMIN_PASS` will be added in Story 6.1. `GITHUB_PAT`, `GITHUB_REPO` added in Story 6.4.

### Tailwind CSS Version Note

`create-next-app@latest` may install Tailwind v4 by default (which uses CSS-based configuration instead of `tailwind.config.ts`). Either version is acceptable — the architecture only requires Tailwind, not a specific major version. If Tailwind v4 is installed:
- Configuration is in CSS (`@theme` directives) instead of `tailwind.config.ts`
- No `postcss.config.js` needed
- Import syntax changes slightly

If the dev agent encounters Tailwind v4, proceed with it — do not downgrade.

### Project Structure After This Story

```
web/
├── package.json
├── next.config.ts          # (or next.config.mjs)
├── tsconfig.json            # TypeScript strict mode enabled
├── drizzle.config.ts        # Drizzle migration config
├── .env.example             # DATABASE_URL placeholder
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   └── db/
│       └── index.ts         # Drizzle client export
├── public/
└── node_modules/
```

### Previous Story Intelligence (Story 1.1)

- Git repo initialized on `main` branch
- `web/` directory exists with `.gitkeep` (remove before scaffolding)
- `.gitignore` at root already covers `node_modules/`, `.next/`, `.env.local`
- No issues encountered in Story 1.1
- Root `README.md` exists with project overview

### What NOT To Do

- Do NOT define the database schema — that's Story 1.3
- Do NOT run any migrations — that's Story 1.3
- Do NOT install Recharts or any chart libraries — those come in Epic 4
- Do NOT create any components, pages, or routes beyond what `create-next-app` generates
- Do NOT add any authentication middleware — that's Story 6.1
- Do NOT install `@neondatabase/serverless` — architecture specifies `pg` driver

### References

- [Source: _bmad-output/planning-artifacts/architecture.md — Starter Template Evaluation]
- [Source: _bmad-output/planning-artifacts/architecture.md — Web Project Organization]
- [Source: _bmad-output/planning-artifacts/architecture.md — Data Architecture]
- [Source: _bmad-output/planning-artifacts/epics-and-stories.md — Story 1.2]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

- No issues encountered during implementation

### Completion Notes List

- Scaffolded Next.js 16.2.1 app with TypeScript, Tailwind CSS v4, App Router, ESLint, src-dir, and Turbopack
- Installed Drizzle ORM (drizzle-orm, pg) and dev dependencies (drizzle-kit, @types/pg)
- Created Drizzle database client at `web/src/db/index.ts` using node-postgres Pool with DATABASE_URL
- Created `web/.env.example` with DATABASE_URL placeholder
- Created `web/drizzle.config.ts` pointing to future schema.ts location
- Verified dev server starts without errors (Next.js 16.2.1 with Turbopack)
- Verified production build completes successfully
- Verified TypeScript strict mode is enabled
- Verified no authentication middleware or login routes exist (FR26)
- Removed `web/.gitkeep` placeholder from Story 1.1

### File List

- web/.gitkeep (deleted)
- web/package.json (created - scaffolded by create-next-app, deps added)
- web/package-lock.json (created)
- web/tsconfig.json (created - strict mode enabled)
- web/next.config.ts (created)
- web/.env.example (created)
- web/drizzle.config.ts (created)
- web/src/app/layout.tsx (created)
- web/src/app/page.tsx (created)
- web/src/app/globals.css (created)
- web/src/db/index.ts (created)
- web/public/file.svg (created)
- web/public/globe.svg (created)
- web/public/next.svg (created)
- web/public/vercel.svg (created)
- web/public/window.svg (created)
- web/eslint.config.mjs (created)
- web/postcss.config.mjs (created)
- web/next-env.d.ts (created)
- web/AGENTS.md (created)
- web/CLAUDE.md (created)

### Change Log

- 2026-03-30: Story 1.2 implemented — scaffolded Next.js 16.2.1 app with all required tooling and Drizzle ORM setup
