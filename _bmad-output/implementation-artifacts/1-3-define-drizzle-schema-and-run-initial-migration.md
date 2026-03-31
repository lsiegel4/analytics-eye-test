# Story 1.3: Define Drizzle Schema and Run Initial Migration

Status: review

## Story

As a developer,
I want the PostgreSQL schema defined in `web/src/db/schema.ts` and a migration applied to Neon,
So that the database is ready to receive writes from the pipeline and reads from the web app.

## Acceptance Criteria

1. **Given** Neon PostgreSQL is provisioned and `DATABASE_URL` is set, **When** the schema is defined and migration is run, **Then** `web/src/db/schema.ts` defines all four tables: `players`, `player_stats`, `player_clips`, `pipeline_runs`
2. **Given** the schema is defined, **Then** the `players` table has columns: `id` (serial PK), `slug` (text, unique, not null), `name` (text), `school` (text), `position` (text), `big_board_rank` (integer), `is_active` (boolean, default true)
3. **Given** the schema is defined, **Then** the `player_stats` table has columns: `id`, `player_id` (FK -> players), `stat_key` (text), `stat_value` (numeric), `percentile` (numeric), `updated_at` (timestamptz)
4. **Given** the schema is defined, **Then** the `player_clips` table has columns: `id`, `player_id` (FK -> players), `skill_category` (text), `video_id` (text, nullable), `is_playable` (boolean), `verified_at` (timestamptz)
5. **Given** the schema is defined, **Then** the `pipeline_runs` table has columns: `id`, `started_at` (timestamptz), `completed_at` (timestamptz, nullable), `status` (text -- `'success'` | `'partial'` | `'failed'`), `players_updated` (integer), `errors_json` (jsonb, nullable)
6. **Given** the schema is defined, **Then** all columns use `snake_case` naming
7. **Given** the schema is defined, **Then** `drizzle-kit generate` produces a migration file in `web/drizzle/migrations/`
8. **Given** the migration is generated, **Then** `drizzle-kit migrate` applies the migration to the Neon database without errors
9. **Given** the schema is defined, **Then** `web/drizzle.config.ts` exists and references `DATABASE_URL`

## Tasks / Subtasks

- [x] Task 1: Create Drizzle schema file (AC: #1, #2, #3, #4, #5, #6)
  - [x] 1.1 Create `web/src/db/schema.ts` with all four table definitions using `pgTable` from `drizzle-orm/pg-core`
  - [x] 1.2 Define `players` table with all specified columns, types, and constraints
  - [x] 1.3 Define `player_stats` table with `player_id` FK referencing `players.id`
  - [x] 1.4 Define `player_clips` table with `player_id` FK referencing `players.id`, `video_id` explicitly nullable
  - [x] 1.5 Define `pipeline_runs` table with all specified columns
  - [x] 1.6 Verify all column names are `snake_case` in the database (Drizzle column name strings)
- [x] Task 2: Verify drizzle.config.ts (AC: #9)
  - [x] 2.1 Confirm `web/drizzle.config.ts` already exists from Story 1.2 and points to `./src/db/schema.ts` with `DATABASE_URL`
- [x] Task 3: Generate migration (AC: #7)
  - [x] 3.1 Run `npx drizzle-kit generate` from `/web` directory
  - [x] 3.2 Verify migration SQL file is created in `web/drizzle/migrations/`
  - [x] 3.3 Review generated SQL to confirm it matches the schema (4 CREATE TABLE statements, correct types, constraints)
- [x] Task 4: Apply migration to Neon (AC: #8)
  - [x] 4.1 Ensure `DATABASE_URL` is set in environment (check `web/.env.local` or env)
  - [x] 4.2 Run `npx drizzle-kit migrate` from `/web` directory
  - [x] 4.3 Verify migration applied without errors
- [x] Task 5: Verify build still passes
  - [x] 5.1 Run `npm run build` in `/web` to confirm schema file doesn't break the build
  - [x] 5.2 Verify the Drizzle client in `web/src/db/index.ts` can import from schema without errors

## Dev Notes

### Schema Implementation Guide

**File to create:** `web/src/db/schema.ts`

**Drizzle ORM version installed:** `drizzle-orm@^0.45.2` with `drizzle-kit@^0.31.10` and `pg@^8.20.0`

**Import pattern:**
```typescript
import { pgTable, serial, text, integer, boolean, numeric, timestamp, jsonb } from 'drizzle-orm/pg-core';
```

**Table definitions — exact column specs:**

```typescript
export const players = pgTable('players', {
  id: serial('id').primaryKey(),
  slug: text('slug').unique().notNull(),
  name: text('name'),
  school: text('school'),
  position: text('position'),
  bigBoardRank: integer('big_board_rank'),
  isActive: boolean('is_active').default(true),
});

export const playerStats = pgTable('player_stats', {
  id: serial('id').primaryKey(),
  playerId: integer('player_id').references(() => players.id).notNull(),
  statKey: text('stat_key').notNull(),
  statValue: numeric('stat_value'),
  percentile: numeric('percentile'),
  updatedAt: timestamp('updated_at', { withTimezone: true }),
});

export const playerClips = pgTable('player_clips', {
  id: serial('id').primaryKey(),
  playerId: integer('player_id').references(() => players.id).notNull(),
  skillCategory: text('skill_category').notNull(),
  videoId: text('video_id'),  // nullable — null means no verified clip
  isPlayable: boolean('is_playable'),
  verifiedAt: timestamp('verified_at', { withTimezone: true }),
});

export const pipelineRuns = pgTable('pipeline_runs', {
  id: serial('id').primaryKey(),
  startedAt: timestamp('started_at', { withTimezone: true }),
  completedAt: timestamp('completed_at', { withTimezone: true }),
  status: text('status'),  // 'success' | 'partial' | 'failed'
  playersUpdated: integer('players_updated'),
  errorsJson: jsonb('errors_json'),
});
```

**Critical naming seam:** TypeScript properties are `camelCase` (e.g., `bigBoardRank`), DB column name strings are `snake_case` (e.g., `'big_board_rank'`). Drizzle handles the mapping automatically. The Python pipeline will reference the `snake_case` DB column names directly in SQL.

### Architecture Constraints

- **ARCH2:** PostgreSQL on Neon; Drizzle ORM for web layer; psycopg3 for pipeline
- **ARCH3:** Database is the sole contract between pipeline and web app — schema must match what pipeline SQL will write
- **ARCH7:** All DB access through `db/queries/` functions — schema is the shared type source
- **ARCH8:** `null` video_id -> render `<StatUnavailable />` — video_id MUST be nullable, never use `""` sentinel

### Drizzle Kit Commands

Run all commands from the `web/` directory:

```bash
# Generate migration SQL from schema
npx drizzle-kit generate

# Apply migration to database
npx drizzle-kit migrate
```

The `drizzle.config.ts` already exists from Story 1.2 and is correctly configured:
- Schema path: `./src/db/schema.ts`
- Migration output: `./drizzle/migrations`
- Dialect: `postgresql`
- DB credentials: `process.env.DATABASE_URL`

### Pipeline SQL Alignment

The Python pipeline (Story 1.4+) will use `psycopg3` with raw SQL targeting these exact column names:
- `players`: `id`, `slug`, `name`, `school`, `position`, `big_board_rank`, `is_active`
- `player_stats`: `id`, `player_id`, `stat_key`, `stat_value`, `percentile`, `updated_at`
- `player_clips`: `id`, `player_id`, `skill_category`, `video_id`, `is_playable`, `verified_at`
- `pipeline_runs`: `id`, `started_at`, `completed_at`, `status`, `players_updated`, `errors_json`

Any column name change here requires a coordinated update in pipeline SQL later.

### Previous Story Intelligence (Story 1.2)

- Next.js 16.2.1 scaffolded with TypeScript, Tailwind v4, App Router, ESLint, Turbopack
- `web/src/db/index.ts` exists — exports Drizzle client using `pg` Pool with `DATABASE_URL`
- `web/drizzle.config.ts` exists — already points to `./src/db/schema.ts` (file doesn't exist yet — this story creates it)
- `web/.env.example` has `DATABASE_URL` placeholder
- Build passes cleanly; dev server runs without errors
- TypeScript strict mode enabled
- No issues encountered in Story 1.2

### What NOT To Do

- Do NOT modify `web/src/db/index.ts` — it's already correct from Story 1.2
- Do NOT modify `web/drizzle.config.ts` — it's already correct from Story 1.2
- Do NOT create any query functions in `db/queries/` — that comes in Epic 4
- Do NOT create any components, pages, or routes
- Do NOT install any new dependencies — all required packages (`drizzle-orm`, `drizzle-kit`, `pg`) are already installed
- Do NOT use `@neondatabase/serverless` driver — architecture specifies `pg`
- Do NOT use empty string `""` for nullable columns — always use `null`
- Do NOT add indexes or constraints beyond what's specified — keep it minimal for v1
- Do NOT use `integer().generatedAlwaysAsIdentity()` — use `serial()` to match the acceptance criteria

### Environment Prerequisite

`DATABASE_URL` must be set before running `drizzle-kit migrate`. Expected format:
```
postgresql://user:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require
```

If `DATABASE_URL` is not available in `.env.local`, the migration step will fail. The schema definition and generation steps can proceed without it.

### Project Structure After This Story

```
web/
├── src/
│   └── db/
│       ├── index.ts       # (unchanged from Story 1.2)
│       └── schema.ts      # NEW — all four table definitions
├── drizzle/
│   └── migrations/
│       └── 0000_*.sql     # NEW — generated migration file
├── drizzle.config.ts      # (unchanged from Story 1.2)
└── ...
```

### References

- [Source: _bmad-output/planning-artifacts/architecture.md — Data Architecture]
- [Source: _bmad-output/planning-artifacts/architecture.md — Naming Patterns]
- [Source: _bmad-output/planning-artifacts/architecture.md — Complete Project Directory Structure]
- [Source: _bmad-output/planning-artifacts/architecture.md — Architectural Boundaries]
- [Source: _bmad-output/planning-artifacts/epics-and-stories.md — Story 1.3]
- [Source: _bmad-output/implementation-artifacts/1-2-scaffold-nextjs-web-app.md — Dev Notes, Completion Notes]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

- TypeScript `tsc --noEmit` shows errors in drizzle-orm internal type declarations for gel/mysql drivers (unrelated to our schema) — resolved by `skipLibCheck` which Next.js build uses by default
- No issues with schema compilation or migration generation

### Completion Notes List

- Created `web/src/db/schema.ts` with all four tables: `players`, `player_stats`, `player_clips`, `pipeline_runs`
- All columns match acceptance criteria exactly — correct types, FKs, constraints, `snake_case` DB names with `camelCase` TS properties
- `video_id` on `player_clips` is nullable (no `.notNull()`) per ARCH8
- `drizzle-kit generate` produced migration `0000_workable_skaar.sql` with 4 CREATE TABLE statements + 2 FK ALTER TABLE statements
- `drizzle.config.ts` verified unchanged from Story 1.2 — correctly configured
- `npm run build` passes cleanly with schema file present
- Migration applied successfully to Neon via `drizzle-kit migrate` — all 4 tables created with FKs

### File List

- web/src/db/schema.ts (created)
- web/drizzle/migrations/0000_workable_skaar.sql (created — generated by drizzle-kit)
- web/drizzle/migrations/meta/0000_snapshot.json (created — generated by drizzle-kit)
- web/drizzle/migrations/meta/_journal.json (created — generated by drizzle-kit)

### Change Log

- 2026-03-30: Story 1.3 implemented — schema defined, migration generated and applied to Neon. All 4 tables live.
