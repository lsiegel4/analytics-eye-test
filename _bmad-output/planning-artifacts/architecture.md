---
stepsCompleted: ["step-01-init", "step-02-context", "step-03-starter", "step-04-decisions", "step-05-patterns", "step-06-structure", "step-07-validation", "step-08-complete"]
lastStep: 8
status: 'complete'
completedAt: '2026-03-29'
inputDocuments:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/product-brief-analytics-eye-test.md"
  - "_bmad-output/planning-artifacts/product-brief-analytics-eye-test-distillate.md"
workflowType: 'architecture'
project_name: 'analytics-eye-test'
user_name: 'Lucas'
date: '2026-03-29'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
26 FRs across 6 categories: Player Discovery & Navigation (FR1–3), Player Profile (FR4–8), Video Integration (FR9–13), Data Pipeline (FR14–17), Operator Tools (FR18–21), and Platform & Compliance (FR22–26). The profile and video integration FRs are the core product; the pipeline and operator FRs are the operational infrastructure that keeps it running.

**Non-Functional Requirements:**
- Performance: Profile pages render stats and visualizations without perceptible delay; clips load lazily and must not block above-the-fold content
- Security: All external API credentials server-side only; HTTPS required; no PII collected
- Accessibility: Soft WCAG 2.1 AA commitment; charts need accessible text alternatives; full audit deferred to post-v1
- Integration Reliability: Graceful degradation on any upstream failure; 7-day data staleness SLA during active season; YouTube embeds verified playable before serving
- Availability: No formal SLA, but must be reliably available during peak draft-season usage; pipeline and web app independently deployable

**Scale & Complexity:**
- Primary domain: Full-stack web (data pipeline + server-rendered MPA + operator tooling)
- Complexity level: Medium — driven by data pipeline complexity and YouTube reliability risk, not user scale
- Player scope: 30–50 players v1; ~150–200 at full season scale
- No real-time features, no multi-tenancy, no authentication in v1

### Technical Constraints & Dependencies

- **Tech stack: undecided** — no framework or language preferences stated; key architectural decision ahead
- **MPA architecture: explicit PRD requirement** — one URL per player profile, server-side rendering for SEO and shareability
- **YouTube Data API v3** — free tier, quota constraints; bulk re-fetch must be batched; clip availability non-guaranteed (Content-ID enforcement)
- **Open-source sports data stack** (cbbdata, hoopR, CBBpy, NCAA) — no SLAs; unofficial endpoints; attribution required; could break without notice
- **Pipeline–web app independence** — hard constraint from PRD; a pipeline failure must not take down the public-facing site
- **Solo developer** — simplicity and maintainability are first-order concerns alongside correctness

### Cross-Cutting Concerns Identified

- **Data freshness** — pipeline scheduling, profile rendering, operator staleness view, and UI timestamp indicator all touch this
- **Graceful degradation** — YouTube embed unavailability and data source outages must never produce broken page states; fallback logic is pervasive
- **Clip playability verification** — spans pipeline storage (when to verify), page serving (what to show), and operator tools (status visibility)
- **API credential security** — YouTube Data API key and any other third-party credentials must remain server-side; no client exposure
- **Independent deployability** — pipeline and web app must be deployable separately; shapes the storage layer and service boundaries throughout

## Starter Template Evaluation

### Primary Technology Domain

Full-stack web application: server-rendered MPA (Next.js on Vercel) + independent Python data pipeline, connected via shared PostgreSQL database.

### Technology Stack

- **Web Layer:** Next.js (Node.js)
- **Data Pipeline:** Python (independent deployment)
- **Database:** PostgreSQL
- **Deployment:** Vercel (web), separate scheduler (pipeline)

### Starter Options Considered

- `create-next-app@latest` + Drizzle ORM — minimal, composable, serverless-optimized
- `create-next-app@latest` + Prisma 7 — heavier but more abstraction
- T3 Stack — rejected; tRPC overhead not justified for a read-heavy MPA
- Full Python stack on Vercel — rejected; serverless limitations make SSR/MPA awkward; Next.js is Vercel's native framework

### Selected Starter: Vercel Postgres + Drizzle Next.js Starter

**Rationale:** Officially maintained by Vercel, zero-config PostgreSQL wiring, Drizzle is serverless-optimized and SQL-like (low learning curve), App Router Server Components provide native SSR/MPA pattern.

**Initialization Command:**

```bash
npx create-next-app@latest analytics-eye-test \
  --typescript \
  --tailwind \
  --app \
  --eslint
```

Then add Drizzle:

```bash
npm install drizzle-orm pg
npm install -D drizzle-kit @types/pg
```

**Note:** Project initialization using this command should be the first implementation story. The Python pipeline is initialized separately.

**Architectural Decisions Provided by Starter:**

**Language & Runtime:**
TypeScript (web layer); Python (pipeline). Two-language split is intentional — Python owns data ingestion, Node.js owns rendering.

**Styling Solution:**
Tailwind CSS — utility-first, no CSS-in-JS overhead, responsive design built-in.

**Build Tooling:**
Next.js 15 built-in (Turbopack dev server, Webpack production build).

**ORM & Database:**
Drizzle ORM + PostgreSQL. Schema-as-code, SQL-like query builder, minimal bundle. Connection pooling required for serverless (use Neon or Vercel Postgres which include pooling out of the box).

**Code Organization:**
Next.js App Router conventions: `app/` directory for routes, Server Components by default, `use client` only where interactivity is needed.

**Rendering Pattern:**
Server Components for all player profile pages and the index — no client-side data fetching for core content. Clip embeds use client-side YouTube IFrame API.

**Development Experience:**
TypeScript strict mode, ESLint, Tailwind IntelliSense, Drizzle Studio for database inspection.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- PostgreSQL hosting: Neon (serverless, Vercel-native, pooling built-in)
- Pipeline scheduler: GitHub Actions cron
- Monorepo structure: `/web` (Next.js) + `/pipeline` (Python)
- Database as the contract between pipeline and web app

**Important Decisions (Shape Architecture):**
- Operator tooling: HTTP Basic Auth via Next.js middleware on `/admin`
- Operator mutations: Next.js Server Actions (no API routes)
- Chart library: Recharts v1 (Nivo as fallback if shot chart complexity grows)
- YouTube embeds: direct `<iframe>` with pipeline-verified video IDs
- No client-side state library; local React state + URL params only

**Deferred Decisions (Post-v1):**
- Caching / ISR (add if page performance warrants it)
- Web-based pipeline trigger endpoint (add shared secret pattern when needed)
- Sentry or APM tooling (add if errors become hard to diagnose)
- Nivo upgrade for shot charts (revisit if Recharts hits limits)

### Data Architecture

**PostgreSQL Hosting: Neon**
Serverless Postgres with built-in connection pooling. Native Vercel integration (zero-config env vars). Python pipeline connects via standard `DATABASE_URL`. Rationale: serverless-friendly pooling, generous free tier, same underlying tech as Vercel Postgres without the abstraction layer.

**Python Pipeline Data Layer: psycopg3 + raw SQL**
Minimal abstraction for batch inserts and updates on a known schema. SQLAlchemy not warranted for a pipeline with straightforward write patterns.

**Caching Strategy: None in v1**
Profiles render from fresh DB reads per request. Player pool is small (30–50 v1), traffic is low, and the DB is co-located on Vercel infrastructure. Add Next.js `unstable_cache` or ISR if page load performance becomes a concern post-launch.

**Migration Strategy: Drizzle Kit**
Schema defined in TypeScript (`/web/src/db/schema.ts`), migrations generated and run via `drizzle-kit`. Python pipeline references the same column names directly in SQL — schema changes require coordinated updates in both.

### Authentication & Security

**Operator Tooling: HTTP Basic Auth via Next.js Middleware**
`/admin` route prefix protected by Next.js middleware checking Basic Auth headers. Credentials stored in environment variables. No user accounts, no sessions. Rationale: single operator (creator), zero overhead, credentials never in source.

**API Credentials: Environment Variables Only**
YouTube Data API key, `DATABASE_URL`, and all third-party credentials in `.env.local` (local) and Vercel/GitHub Actions environment variables (deployed). Never in source code, never in client bundles.

**Manual Pipeline Triggers: CLI-Only in v1**
No HTTP endpoint for pipeline triggers. Manual re-fetches run as local Python scripts. Eliminates a security surface; add a protected endpoint if a web-based trigger is needed post-v1.

### API & Communication Patterns

**Operator Mutations: Next.js Server Actions**
Player pool add/remove, manual clip re-fetch trigger — all handled via Server Actions co-located with the `/admin` pages. No separate API routes needed; the operator UI is the only consumer.

**Pipeline → Web Contract: Database Only**
The PostgreSQL database is the sole communication channel between the Python pipeline and the Next.js web app. No HTTP calls between services. Pipeline writes; web app reads. Satisfies the independent deployability constraint from the PRD.

**External API Calls: Pipeline Only**
All calls to YouTube Data API, cbbdata, hoopR, CBBpy, and NCAA endpoints happen in the Python pipeline. Zero upstream API calls at page load time in the web app.

**Error Handling:**
- Web: Next.js `error.tsx` boundaries per route segment; `notFound()` for missing players; conditional render (no throw) for clip unavailability
- Pipeline: per-player exception handling (one bad record doesn't abort the run); structured stdout logging captured by GitHub Actions; `last_run_at` and `last_run_status` written to DB and surfaced in operator view

### Frontend Architecture

**Chart Library: Recharts (v1)**
Percentile bar charts via `BarChart`; shot charts via `ScatterChart` or custom SVG layer. Accessible text alternatives via `label` props and ARIA patterns. Responsive rendering via `ResponsiveContainer`. Nivo retained as the upgrade path if shot chart complexity (hex bins, court overlay) outgrows Recharts.

**YouTube Embeds: Direct `<iframe>`**
Raw `<iframe src="https://www.youtube.com/embed/{videoId}">` with pipeline-verified video IDs. Playability verified and stored in DB by the pipeline before render — no live playability check at page load. `lite-youtube-embed` available as a performance optimization if needed.

**State Management: None (local React state only)**
Server Components handle all data fetching. Client-side state limited to `useState` for interactive UI elements (clip category tab selection, etc.) and URL search params for shareable filter state. No Zustand, no Redux.

### Infrastructure & Deployment

**Monorepo Structure:**

```
analytics-eye-test/
├── web/          # Next.js 15 app (Vercel deployment)
├── pipeline/     # Python data pipeline (GitHub Actions)
└── .github/
    └── workflows/
        ├── pipeline-schedule.yml   # Daily cron trigger
        └── pipeline-lint.yml       # On push to pipeline/
```

**Web Deployment: Vercel Git Integration**
Auto-deploy on push to `main` (Vercel root directory: `/web`). Preview deployments on pull requests. Zero config.

**Pipeline Scheduling: GitHub Actions Cron**
Daily scheduled run during season. `DATABASE_URL` and `YOUTUBE_API_KEY` stored as GitHub Actions secrets. Logs visible in GitHub UI. Free tier sufficient for once-daily runs.

**CI/CD:**
- Web: Vercel handles build, deploy, and preview — no additional CI needed
- Pipeline: GitHub Actions runs lint + tests on push to `pipeline/`; scheduled run triggers the actual data refresh

**Monitoring & Logging:**
- Web: Vercel Analytics (built-in) for traffic; Vercel function logs for debugging
- Pipeline: GitHub Actions run history + logs; `pipeline_runs` table in DB records `last_run_at`, `last_run_status`, per-player staleness — surfaced in operator view
- No external APM in v1; add Sentry if production errors become hard to diagnose

### Decision Impact Analysis

**Implementation Sequence:**
1. Initialize monorepo; scaffold `/web` with `create-next-app`
2. Provision Neon PostgreSQL; configure `DATABASE_URL` in Vercel + GitHub Actions
3. Define Drizzle schema; run initial migration
4. Build Python pipeline scaffold with psycopg3 connection
5. Implement data ingestion (cbbdata, hoopR) → DB writes
6. Implement YouTube clip discovery → DB writes
7. Build Next.js player profile pages (Server Components, Drizzle reads)
8. Build player index page
9. Build `/admin` operator view with Basic Auth middleware
10. Wire GitHub Actions cron for pipeline scheduling
11. Deploy to Vercel; validate end-to-end

**Cross-Component Dependencies:**
- Drizzle schema is the shared contract — pipeline SQL must match schema column names
- Clip playability status stored by pipeline is the source of truth for iframe rendering
- `pipeline_runs` table feeds the operator status view — must be written before admin UI
- Basic Auth middleware must be in place before `/admin` routes are deployed

## Implementation Patterns & Consistency Rules

### Naming Patterns

**Database Naming Conventions (PostgreSQL):**
- Tables: `snake_case`, plural — `players`, `player_clips`, `player_stats`, `pipeline_runs`
- Columns: `snake_case` — `player_id`, `last_updated_at`, `is_playable`, `video_id`
- Foreign keys: `{table_singular}_id` — `player_id` (not `fk_player`)
- Drizzle maps DB `snake_case` columns to TypeScript `camelCase` automatically — this is the explicit naming seam

**TypeScript/Next.js Naming Conventions:**
- Variables and functions: `camelCase` — `playerId`, `getPlayerProfile()`
- Components and types: `PascalCase` — `PlayerProfile`, `ClipCard`, `ActionResult`
- Component files: `PascalCase.tsx` — `PlayerProfile.tsx`, `ClipCard.tsx`
- Non-component TypeScript files: `kebab-case.ts` — `player-queries.ts`, `schema.ts`
- Next.js route files: framework convention — `page.tsx`, `layout.tsx`, `error.tsx`, `actions.ts`

**Python Naming Conventions (PEP 8):**
- All modules, functions, variables: `snake_case` — `player_ingestion.py`, `fetch_player_stats()`, `player_id`
- Constants: `UPPER_SNAKE_CASE` — `YOUTUBE_API_KEY`, `MAX_RETRIES`

### Structure Patterns

**Web Project Organization:**

```
web/src/
├── app/
│   ├── page.tsx                    # Player index (home)
│   ├── players/
│   │   └── [slug]/
│   │       ├── page.tsx            # Player profile (Server Component)
│   │       └── error.tsx           # Route error boundary
│   └── admin/
│       ├── layout.tsx              # Basic Auth middleware applied here
│       ├── page.tsx                # Pipeline status view
│       └── actions.ts              # All admin Server Actions
├── components/
│   ├── player/                     # Player-specific components
│   │   ├── PercentileBar.tsx
│   │   ├── ShotChart.tsx
│   │   └── ClipSection.tsx
│   └── ui/                         # Generic UI primitives
│       ├── StatUnavailable.tsx
│       └── DataFreshness.tsx
└── db/
    ├── schema.ts                   # Single source of truth for DB schema
    └── queries/                    # All DB query functions — centralized here
        ├── players.ts
        └── pipeline.ts
```

**Rule:** No raw Drizzle queries in Server Components or page files. All DB access goes through `db/queries/`. Components call query functions; they do not touch the DB directly.

**Pipeline Project Organization:**

```
pipeline/
├── ingestion/
│   ├── cbbdata.py                  # cbbdata API client + ingestion
│   ├── hoopr.py                    # hoopR/ESPN PBP ingestion
│   └── player_pool.py              # Big board seeding + pool sync
├── clips/
│   ├── discovery.py                # YouTube Data API search
│   └── verification.py             # Playability check logic
├── db/
│   └── writes.py                   # All DB write operations (psycopg3)
└── run.py                          # Pipeline entry point / orchestrator
```

**Rule:** Each data source in its own module. `run.py` orchestrates; source modules do not import from each other.

### Format Patterns

**Dates & Timestamps:**
- Store in PostgreSQL as `timestamptz`
- Python writes native `datetime` objects via psycopg3 (auto-converted)
- TypeScript receives as `Date` objects via Drizzle (mapped automatically)
- Display in UI with `Intl.DateTimeFormat` — never raw `.toISOString()` in rendered output

**Clip Unavailability:**
- `video_id` column is `TEXT NULL` — `null` means no verified playable clip
- Never render an `<iframe>` with a null or empty `src`
- Clip unavailability renders `<StatUnavailable />`, not an error state
- Never use empty string `""` as a sentinel — always use `null`

**Pipeline Status Values:**
- `pipeline_runs.status` is always one of: `'success'` | `'partial'` | `'failed'`
- No ad-hoc status strings — these three literals only

**Server Action Response Shape:**
```typescript
type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string }
```
All Server Actions return this shape. Never throw from a Server Action — return `{ success: false, error: message }` instead.

### Process Patterns

**Loading States:**
- Use Next.js `<Suspense>` with `loading.tsx` or inline skeleton components
- No manual `isLoading` boolean state in Server Component pages
- Each independently-loadable section (stats, clips) gets its own `<Suspense>` boundary

**Error States:**
- Player not found → `notFound()` → Next.js 404 page
- Expected unavailability (no clips, stale data) → conditional render, never `throw`
- Unexpected runtime errors → `error.tsx` boundary catches, displays generic message
- Pipeline per-player errors → caught individually, logged to `errors_json`, never abort full run

**Graceful Degradation Rule:**
If any section cannot render its content, show `<StatUnavailable label="..." />`. Never leave an empty or broken UI state visible to users. `throw` is only for truly unexpected errors — not for absent data.

### Enforcement Guidelines

**All AI agents MUST:**
- Query the DB only through `db/queries/` functions — never raw Drizzle in page/component files
- Return `ActionResult<T>` from all Server Actions — never throw
- Use `null` (never `""`) to represent absent/unavailable clip video IDs
- Render `<StatUnavailable />` for any absent optional data — never empty UI
- Keep all external API calls (YouTube, cbbdata, hoopR) inside the Python pipeline — never in Next.js server code
- Follow the naming conventions table above — DB columns are `snake_case`, TypeScript is `camelCase`/`PascalCase`, Python is `snake_case`

**Anti-Patterns to Avoid:**
- Raw `db.select()` calls inside `page.tsx` or component files
- `throw new Error("no clips")` for expected missing data
- `video_id = ""` as a "no clip" sentinel
- Importing pipeline modules from each other (only `run.py` orchestrates)
- Hardcoded credentials or API keys anywhere in source code
- Client Components fetching data that Server Components could provide

## Project Structure & Boundaries

### Complete Project Directory Structure

```
analytics-eye-test/
├── README.md
├── .gitignore
│
├── .github/
│   └── workflows/
│       ├── pipeline-schedule.yml     # Daily cron: runs pipeline/run.py
│       └── pipeline-ci.yml           # On push to pipeline/: lint + tests
│
├── web/                              # Next.js 15 app (Vercel deployment)
│   ├── package.json
│   ├── next.config.ts
│   ├── tailwind.config.ts
│   ├── tsconfig.json
│   ├── .env.local                    # Local secrets (gitignored)
│   ├── .env.example                  # Committed template
│   │
│   ├── drizzle/                      # Generated migration files
│   │   └── migrations/
│   │       └── 0000_init.sql
│   │
│   └── src/
│       ├── middleware.ts             # HTTP Basic Auth on /admin routes
│       │
│       ├── db/
│       │   ├── index.ts              # Drizzle client + Neon connection
│       │   ├── schema.ts             # Tables: players, player_stats,
│       │   │                         #   player_clips, pipeline_runs
│       │   └── queries/
│       │       ├── players.ts        # getPlayerBySlug(), getAllPlayers(),
│       │       │                     #   getPlayerWithStats(), getPlayerClips()
│       │       └── pipeline.ts       # getLastPipelineRun(), getStalePlayers(),
│       │                             #   getClipStatusByPlayer()
│       │
│       ├── app/
│       │   ├── globals.css
│       │   ├── layout.tsx            # Root layout (font, metadata)
│       │   ├── page.tsx              # FR1: Player index / home (Server Component)
│       │   ├── not-found.tsx         # Global 404 page
│       │   │
│       │   ├── players/
│       │   │   └── [slug]/
│       │   │       ├── page.tsx      # FR2,4–13: Player profile (Server Component)
│       │   │       └── error.tsx     # Route error boundary
│       │   │
│       │   ├── data-sources/
│       │   │   └── page.tsx          # FR3,24: Data attribution page
│       │   │
│       │   └── admin/
│       │       ├── layout.tsx        # Verifies Basic Auth header
│       │       ├── page.tsx          # FR18–19: Pipeline status + clip coverage
│       │       └── actions.ts        # FR20–21: Server Actions for re-fetch,
│       │                             #   player add/remove
│       │
│       └── components/
│           ├── player/
│           │   ├── PlayerHeader.tsx       # Name, position, school, big board rank
│           │   ├── StatTable.tsx          # FR4: Advanced stats table
│           │   ├── PercentileBar.tsx      # FR5–6: Recharts percentile bars
│           │   ├── ShotChart.tsx          # FR7: Recharts scatter shot chart
│           │   ├── DataFreshness.tsx      # FR8: Last updated timestamp
│           │   └── ClipSection.tsx        # FR9–13: Clip category tabs + iframes
│           │
│           └── ui/
│               ├── StatUnavailable.tsx    # FR11: "unavailable" fallback state
│               ├── PlayerCard.tsx         # Index page player card
│               └── SkeletonLoader.tsx     # Suspense skeleton
│
└── pipeline/                         # Python data pipeline (GitHub Actions)
    ├── requirements.txt              # psycopg3, requests, python-dotenv, etc.
    ├── .env.example                  # DATABASE_URL, YOUTUBE_API_KEY template
    ├── run.py                        # Entry point: orchestrates full pipeline run
    │
    ├── ingestion/
    │   ├── __init__.py
    │   ├── cbbdata.py                # FR14: cbbdata API → player_stats writes
    │   ├── hoopr.py                  # FR14: hoopR/ESPN PBP → shot location writes
    │   └── player_pool.py            # FR16: Big board scrape → players table sync
    │
    ├── clips/
    │   ├── __init__.py
    │   ├── discovery.py              # FR15: YouTube Data API search per player/skill
    │   └── verification.py           # FR12: Playability check → is_playable flag
    │
    ├── db/
    │   ├── __init__.py
    │   └── writes.py                 # All psycopg3 INSERT/UPDATE/UPSERT operations
    │
    ├── scripts/
    │   ├── refetch_player_clips.py   # FR20: Manual clip re-fetch for one player
    │   └── add_remove_player.py      # FR21: Add/remove player from pool (CLI)
    │
    └── tests/
        ├── test_cbbdata.py
        ├── test_clip_discovery.py
        └── test_db_writes.py
```

### Architectural Boundaries

**Pipeline → Web Boundary (Database):**
The PostgreSQL database is the only integration point. The pipeline writes to four tables; the web app reads from them. No HTTP communication between services.

```
pipeline writes:
  players          (id, slug, name, school, position, big_board_rank, is_active)
  player_stats     (player_id, stat_key, stat_value, percentile, updated_at)
  player_clips     (player_id, skill_category, video_id, is_playable, verified_at)
  pipeline_runs    (id, started_at, completed_at, status, players_updated, errors_json)

web reads:
  all four tables via db/queries/players.ts and db/queries/pipeline.ts
```

**Admin Boundary (HTTP Basic Auth):**
`web/src/middleware.ts` intercepts all requests to `/admin/*`. Credentials checked against `ADMIN_USER` and `ADMIN_PASS` environment variables. All admin mutations go through Server Actions in `admin/actions.ts`.

**External API Boundary (Pipeline only):**
YouTube Data API, cbbdata, hoopR, CBBpy, NCAA endpoints are called exclusively from `pipeline/ingestion/` and `pipeline/clips/`. The web app never calls external APIs at request time.

### Requirements to Structure Mapping

| FR | File(s) |
|---|---|
| FR1: Player index | `app/page.tsx` + `components/ui/PlayerCard.tsx` |
| FR2: Player profile URL | `app/players/[slug]/page.tsx` |
| FR3: Data sources page | `app/data-sources/page.tsx` |
| FR4: Advanced stats | `components/player/StatTable.tsx` + `db/queries/players.ts` |
| FR5–6: Percentile bars | `components/player/PercentileBar.tsx` (Recharts) |
| FR7: Shot chart | `components/player/ShotChart.tsx` (Recharts) |
| FR8: Data freshness | `components/player/DataFreshness.tsx` |
| FR9–10: Clip display + playback | `components/player/ClipSection.tsx` |
| FR11: Clip unavailable state | `components/ui/StatUnavailable.tsx` |
| FR12: Playability verification | `pipeline/clips/verification.py` → `player_clips.is_playable` |
| FR13: Skill category taxonomy | `pipeline/clips/discovery.py` (skill category constants) |
| FR14: Stats refresh | `pipeline/ingestion/cbbdata.py`, `hoopr.py` |
| FR15: Clip discovery | `pipeline/clips/discovery.py` |
| FR16: Player pool sync | `pipeline/ingestion/player_pool.py` |
| FR17: Cached stats | `player_stats` table read at request time (no live upstream calls) |
| FR18: Pipeline status view | `app/admin/page.tsx` + `db/queries/pipeline.ts` |
| FR19: Clip verification status | `app/admin/page.tsx` (reads `player_clips.is_playable`) |
| FR20: Manual clip re-fetch | `pipeline/scripts/refetch_player_clips.py` (CLI) |
| FR21: Player pool management | `pipeline/scripts/add_remove_player.py` (CLI) |
| FR22: Shareable URLs | Next.js App Router — each `[slug]` is a distinct URL |
| FR23: Mobile-readable | Tailwind responsive classes throughout |
| FR24: Data attribution | `app/data-sources/page.tsx` + footer attribution |
| FR25: YouTube IFrame embed | `components/player/ClipSection.tsx` (direct `<iframe>`) |
| FR26: No auth required | Public routes; only `/admin` is protected |

### Data Flow

```
External Sources → Python Pipeline → PostgreSQL (Neon) → Next.js (Vercel) → Browser

1. GitHub Actions triggers pipeline/run.py on schedule
2. run.py calls ingestion/ modules → writes to players, player_stats
3. run.py calls clips/ modules → writes to player_clips (with is_playable flag)
4. run.py writes pipeline_run record (status, errors)
5. User requests /players/[slug]
6. Next.js Server Component calls db/queries/players.ts
7. Drizzle queries Neon PostgreSQL
8. Server Component renders HTML with stats, percentile bars, verified clip iframes
9. Browser receives complete HTML — no client-side data fetching for core content
```

## Architecture Validation Results

### Pre-Implementation Decisions Resolved

**Player Slug Format:**
- Convention: `{first-last}` kebab-case → `cooper-flagg`, `bronny-james`
- Collision handling: append 4-char UUID suffix → `chris-johnson-a3f2`
- Generated by pipeline at player insert; immutable once set
- Stored in `players.slug` (TEXT, UNIQUE, NOT NULL)

**Skill Category Taxonomy (v1):**
Defined as typed constants in `pipeline/clips/discovery.py` and mirrored as a TypeScript union type in `web/src/db/schema.ts`. The YouTube search model uses broader categories than the full analytical model — this is intentional for v1 clip discoverability. Post-v1, the taxonomy constants remain stable even if the clip source changes.

| Constant | Display Name | YouTube Query Template |
|---|---|---|
| `rim_finishing` | Rim Finishing | `"{name} rim finishing layups"` |
| `three_point_shooting` | 3-Point Shooting | `"{name} three point shooting"` |
| `mid_range` | Mid-Range | `"{name} mid range floater"` |
| `catch_and_shoot` | Catch & Shoot | `"{name} catch and shoot"` |
| `shot_creation` | Shot Creation | `"{name} off dribble shot creation"` |
| `pick_and_roll` | Pick & Roll | `"{name} pick and roll"` |
| `isolation` | Isolation | `"{name} isolation"` |
| `playmaking` | Playmaking & Assists | `"{name} assists playmaking"` |
| `defense` | Defense | `"{name} defense steals blocks"` |
| `transition` | Transition | `"{name} transition offense"` |

Deferred to post-v1: granular P&R scenarios (hard hedge, empty side), split rebounding categories, fouls drawn/given, assisted vs. unassisted shot splits. These require a better clip source than YouTube search to be reliable.

### Coherence Validation ✅

**Decision Compatibility:** Next.js 15 + Drizzle + Neon is a proven stack with no version conflicts. Python psycopg3 connects to Neon via standard PostgreSQL URL. GitHub Actions and Vercel are fully independent — no shared infrastructure.

**Pattern Consistency:** Server Components + `db/queries/` pattern aligns with App Router model. `ActionResult<T>` is consistent with Server Actions semantics. Pipeline module isolation aligns with psycopg3 + raw SQL approach.

**Architectural Interpretation — Clip Verification:** The PRD states clips are "verified playable at page load." This architecture verifies playability in the pipeline and stores the result in `player_clips.is_playable`. The web app renders only verified clips — no blocking check at render time. This is architecturally superior and satisfies the intent of the requirement.

### Requirements Coverage Validation ✅

All 26 functional requirements have mapped files in the project structure.

**NFR Coverage:**
- Performance: Neon co-located with Vercel; Suspense boundaries prevent clip embeds from blocking stat render ✅
- Security: Basic Auth middleware on `/admin`, env vars for all credentials, external API calls pipeline-only ✅
- Accessibility: Recharts ARIA label support; `<StatUnavailable />` prevents empty states; keyboard navigation via standard HTML ✅
- Integration Reliability: per-player exception handling in pipeline; graceful degradation pattern enforced via `<StatUnavailable />` ✅
- Availability: pipeline and web independently deployable; pipeline failure cannot affect web app ✅

### Gap Analysis Results

**Resolved before implementation:**
- ✅ Skill category taxonomy — 10 v1 categories defined with YouTube query templates
- ✅ Player slug format — kebab-case with UUID collision suffix

**Minor gaps (resolve during implementation):**
- Add `web/drizzle.config.ts` to project (required by drizzle-kit for migrations)
- Add `web/src/__tests__/` directory for web unit tests (Vitest recommended for Next.js App Router); pipeline tests already defined

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**✅ Architectural Decisions**
- [x] Critical decisions documented with rationale
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance and security considerations addressed

**✅ Implementation Patterns**
- [x] Naming conventions established across all layers
- [x] Structure patterns defined with enforcement rules
- [x] Format patterns specified (dates, clip unavailability, action responses)
- [x] Process patterns documented (loading, error, degradation)

**✅ Project Structure**
- [x] Complete directory structure defined
- [x] All 26 FRs mapped to specific files
- [x] Architectural boundaries documented
- [x] Data flow end-to-end defined

### Architecture Readiness Assessment

**Overall Status: READY FOR IMPLEMENTATION**

**Confidence Level: High**

**Key Strengths:**
- Clean pipeline/web separation via database-as-contract satisfies the hard independence requirement from the PRD
- Server Components + Drizzle queries centralized in `db/queries/` gives AI agents unambiguous implementation guidance
- Skill taxonomy defined before pipeline implementation — removes the biggest pre-build open question
- Graceful degradation enforced via `<StatUnavailable />` pattern — no agent can accidentally ship a broken empty state

**Areas for Future Enhancement:**
- Skill taxonomy expansion as better clip sources become available
- Rebounding, fouls, and granular P&R scenario categories (post-v1)
- ISR or `unstable_cache` if page load performance warrants it
- Sentry integration if production errors become hard to diagnose
- Web-based pipeline trigger endpoint (currently CLI-only)

### Implementation Handoff

**First implementation story:** Initialize monorepo; scaffold `/web` with `create-next-app`; provision Neon PostgreSQL; define Drizzle schema and run initial migration.

**AI Agent Guidelines:**
- All DB access through `db/queries/` — never raw Drizzle in pages/components
- All Server Actions return `ActionResult<T>` — never throw
- Clip unavailability = `null` video_id = render `<StatUnavailable />` — never empty UI
- All external API calls stay in the Python pipeline — never in Next.js
- Skill categories use the 10 defined constants only — no ad-hoc strings
