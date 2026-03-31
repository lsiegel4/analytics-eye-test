---
stepsCompleted: ["step-01-validate-prerequisites", "step-02-requirements-inventory", "step-03-epic-definition", "step-04-story-writing"]
inputDocuments:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/architecture.md"
  - "_bmad-output/planning-artifacts/product-brief-analytics-eye-test.md"
project_name: "analytics-eye-test"
created: "2026-03-30"
---

# Analytics Eye Test — Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Analytics Eye Test, decomposing all requirements from the PRD, Architecture, and Product Brief into implementable stories. Stories are sized for a solo developer and follow the architecture's implementation sequence. Each story is independently shippable within its epic.

---

## Requirements Inventory

### Functional Requirements

| ID | Requirement | Category |
|----|-------------|----------|
| FR1 | Users can browse a complete index of all tracked draft prospects | Player Discovery |
| FR2 | Users can navigate to a player's profile via a unique, shareable URL | Player Discovery |
| FR3 | Users can access a dedicated page listing all data sources and attribution | Player Discovery |
| FR4 | Users can view a player's advanced statistical profile (efficiency, usage, on/off, per-40, shot location) | Player Profile |
| FR5 | Users can view percentile rankings contextualized within the current draft class | Player Profile |
| FR6 | Users can view percentile rankings as visual bar charts | Player Profile |
| FR7 | Users can view a shot chart showing shot location distribution | Player Profile |
| FR8 | Users can view the timestamp of when a player's stats were last refreshed | Player Profile |
| FR9 | Users can view video clips organized by skill category | Video Integration |
| FR10 | Users can play embedded clips directly within the player profile | Video Integration |
| FR11 | Users see a clean "unavailable" indicator when no clips exist — no broken embeds | Video Integration |
| FR12 | System verifies clip playability at pipeline time; only verified clips are served | Video Integration |
| FR13 | System organizes clips under a defined skill category taxonomy | Video Integration |
| FR14 | System automatically refreshes player statistics on a scheduled cadence | Data Pipeline |
| FR15 | System automatically discovers and indexes clips per player per skill via YouTube Data API | Data Pipeline |
| FR16 | System seeds and maintains the tracked player pool from consensus public big boards | Data Pipeline |
| FR17 | System stores player statistics locally; profiles render from cached data, not live upstream calls | Data Pipeline |
| FR18 | Operator can view pipeline status: last refresh timestamp and per-player data staleness | Operator Tools |
| FR19 | Operator can view clip verification status per player per skill category | Operator Tools |
| FR20 | Operator can manually trigger a clip re-fetch for one or more specific players | Operator Tools |
| FR21 | Operator can add or remove a player from the tracked prospect pool without a full pipeline re-run | Operator Tools |
| FR22 | All player profile pages are accessible at distinct, shareable, indexable URLs | Platform |
| FR23 | Platform renders correctly on mobile browsers without a native app | Platform |
| FR24 | Platform displays attribution for all open-source data sources visibly within the product | Platform |
| FR25 | All video content delivered via YouTube IFrame Player API embed — no downloading or self-hosting | Platform |
| FR26 | Platform is fully accessible without user registration or authentication | Platform |

### Non-Functional Requirements

| ID | Requirement | Category |
|----|-------------|----------|
| NFR1 | Profile stats and visualizations render without perceptible delay on broadband | Performance |
| NFR2 | Clip embeds load lazily — must not block above-the-fold stat render | Performance |
| NFR3 | Profiles render from locally cached data; no live upstream API calls at page load | Performance |
| NFR4 | YouTube Data API key and all credentials not exposed to the client | Security |
| NFR5 | HTTPS required for all traffic | Security |
| NFR6 | No PII collected or stored in v1 | Security |
| NFR7 | Soft WCAG 2.1 AA compliance; percentile bars have accessible text alternatives | Accessibility |
| NFR8 | Color contrast meets AA standards; keyboard navigation functional for core flows | Accessibility |
| NFR9 | Platform degrades gracefully when any upstream dependency is unavailable | Integration Reliability |
| NFR10 | Player statistics no more than 7 days stale during active season | Integration Reliability |
| NFR11 | YouTube Data API quota usage monitored; bulk re-fetch batched to avoid exhaustion | Integration Reliability |
| NFR12 | All YouTube embeds verified playable before page is served | Integration Reliability |
| NFR13 | Platform reliably available during peak draft-season usage | Availability |
| NFR14 | Pipeline and web app independently deployable; pipeline failure must not take down the site | Availability |

### Architecture Requirements

| ID | Requirement |
|----|-------------|
| ARCH1 | Monorepo structure: `/web` (Next.js 15) + `/pipeline` (Python) + `.github/workflows/` |
| ARCH2 | PostgreSQL hosted on Neon; Drizzle ORM for web layer; psycopg3 for pipeline |
| ARCH3 | Database is the sole contract between pipeline and web app — no HTTP between services |
| ARCH4 | All external API calls (YouTube, cbbdata, hoopR) made in pipeline only — never in Next.js |
| ARCH5 | HTTP Basic Auth via Next.js middleware on all `/admin` routes |
| ARCH6 | All Server Actions return `ActionResult<T>` shape — never throw |
| ARCH7 | All DB access through `db/queries/` functions — no raw Drizzle in page/component files |
| ARCH8 | `null` video_id → render `<StatUnavailable />` — never empty UI, never `""` sentinel |
| ARCH9 | GitHub Actions cron for daily pipeline scheduling; credentials stored as Actions secrets |
| ARCH10 | Vercel Git Integration for web deployment; auto-deploy on push to `main` |

---

### FR Coverage Map

| FR | Epic | Story |
|----|------|-------|
| FR1 | Epic 4 | 4.1 |
| FR2 | Epic 4 | 4.2 |
| FR3 | Epic 4 | 4.7 |
| FR4 | Epic 4 | 4.3 |
| FR5 | Epic 4 | 4.4 |
| FR6 | Epic 4 | 4.4 |
| FR7 | Epic 4 | 4.5 |
| FR8 | Epic 4 | 4.6 |
| FR9 | Epic 5 | 5.1 |
| FR10 | Epic 5 | 5.1 |
| FR11 | Epic 5 | 5.2 |
| FR12 | Epic 3 | 3.3 |
| FR13 | Epic 3 | 3.1 |
| FR14 | Epic 2 | 2.2, 2.3 |
| FR15 | Epic 3 | 3.2 |
| FR16 | Epic 2 | 2.1 |
| FR17 | Epic 2 | 2.2, 2.3 |
| FR18 | Epic 6 | 6.2 |
| FR19 | Epic 6 | 6.3 |
| FR20 | Epic 6 | 6.4 |
| FR21 | Epic 6 | 6.5 |
| FR22 | Epic 4 | 4.2 |
| FR23 | Epic 7 | 7.1 |
| FR24 | Epic 4 | 4.7 |
| FR25 | Epic 5 | 5.3 |
| FR26 | Epic 1 | 1.2 (public by default in Next.js) |

---

## Epic List

| Epic | Title | Summary |
|------|-------|---------|
| **Epic 1** | Project Foundation & Infrastructure | Monorepo setup, web scaffold, database provisioning, pipeline scaffold, CI/CD wiring |
| **Epic 2** | Data Pipeline — Player Pool & Statistics | Big board seeding, stats ingestion (cbbdata, hoopR), pipeline run logging |
| **Epic 3** | Data Pipeline — Clip Discovery & Verification | Skill taxonomy definition, YouTube Data API discovery, playability verification |
| **Epic 4** | Player Profile — Core Display | Index page, profile routing, stats table, percentile bars, shot chart, freshness indicator, data sources page |
| **Epic 5** | Video Integration | Clip section UI, unavailability state, YouTube embed compliance |
| **Epic 6** | Operator Tooling | Basic Auth middleware, pipeline status view, clip status view, manual re-fetch, player pool management |
| **Epic 7** | Polish, Compliance & NFRs | Responsive layout, accessibility foundations, error boundaries, graceful degradation, SEO basics |

---

## Epic 1: Project Foundation & Infrastructure

**Goal:** Establish the monorepo, scaffold both the Next.js web app and Python pipeline, provision the database, define the schema, and wire CI/CD. No user-facing features yet — but after this epic, a developer can run both services locally and deploy to Vercel with a live database connection.

### Story 1.1: Initialize Monorepo Structure

As a developer,
I want a monorepo with `/web`, `/pipeline`, and `.github/workflows/` directories initialized,
So that both services share a single repository with clear boundaries and no cross-imports.

**Acceptance Criteria:**

**Given** a fresh repository,
**When** the monorepo is initialized,
**Then** the root directory contains `/web/`, `/pipeline/`, `.github/workflows/`, `README.md`, and `.gitignore`
**And** `.gitignore` covers `node_modules/`, `.next/`, `.env.local`, `__pycache__/`, `*.pyc`, and `.env`
**And** there are no cross-imports between `/web` and `/pipeline` directories

---

### Story 1.2: Scaffold Next.js Web App

As a developer,
I want the Next.js 15 app scaffolded with TypeScript, Tailwind CSS, App Router, and ESLint,
So that the web layer is ready for feature development with all tooling configured.

**Acceptance Criteria:**

**Given** the `/web` directory exists,
**When** the scaffold is complete,
**Then** `npx create-next-app@latest` has been run with `--typescript --tailwind --app --eslint` flags
**And** Drizzle ORM (`drizzle-orm`, `pg`) and `drizzle-kit`, `@types/pg` are installed
**And** `web/src/db/index.ts` exists and exports a Drizzle client configured from `DATABASE_URL` env var
**And** `npm run dev` starts the development server without errors
**And** `npm run build` completes without errors
**And** TypeScript strict mode is enabled in `tsconfig.json`
**And** the app has no user authentication — all routes are public by default (FR26)

---

### Story 1.3: Define Drizzle Schema and Run Initial Migration

As a developer,
I want the PostgreSQL schema defined in `web/src/db/schema.ts` and a migration applied to Neon,
So that the database is ready to receive writes from the pipeline and reads from the web app.

**Acceptance Criteria:**

**Given** Neon PostgreSQL is provisioned and `DATABASE_URL` is set,
**When** the schema is defined and migration is run,
**Then** `web/src/db/schema.ts` defines all four tables: `players`, `player_stats`, `player_clips`, `pipeline_runs`
**And** the `players` table has columns: `id` (serial PK), `slug` (text, unique, not null), `name` (text), `school` (text), `position` (text), `big_board_rank` (integer), `is_active` (boolean, default true)
**And** the `player_stats` table has columns: `id`, `player_id` (FK → players), `stat_key` (text), `stat_value` (numeric), `percentile` (numeric), `updated_at` (timestamptz)
**And** the `player_clips` table has columns: `id`, `player_id` (FK → players), `skill_category` (text), `video_id` (text, nullable), `is_playable` (boolean), `verified_at` (timestamptz)
**And** the `pipeline_runs` table has columns: `id`, `started_at` (timestamptz), `completed_at` (timestamptz, nullable), `status` (text — `'success'` | `'partial'` | `'failed'`), `players_updated` (integer), `errors_json` (jsonb, nullable)
**And** all columns use `snake_case` naming
**And** `drizzle-kit generate` produces a migration file in `web/drizzle/migrations/`
**And** `drizzle-kit migrate` applies the migration to the Neon database without errors
**And** `web/drizzle.config.ts` exists and references `DATABASE_URL`

---

### Story 1.4: Scaffold Python Pipeline with DB Connection

As a developer,
I want the Python pipeline scaffolded with psycopg3 and a verified database connection,
So that the pipeline can begin writing data to PostgreSQL.

**Acceptance Criteria:**

**Given** the `/pipeline` directory exists and `DATABASE_URL` is set in `pipeline/.env`,
**When** the scaffold is complete,
**Then** `pipeline/requirements.txt` includes `psycopg[binary]`, `requests`, `python-dotenv`
**And** `pipeline/db/writes.py` exports a `get_connection()` function that establishes a psycopg3 connection using `DATABASE_URL`
**And** `pipeline/run.py` exists as the entry point and can be executed with `python run.py` without errors
**And** `pipeline/.env.example` documents required env vars: `DATABASE_URL`, `YOUTUBE_API_KEY`
**And** all modules follow PEP 8 naming conventions (`snake_case` for functions and variables, `UPPER_SNAKE_CASE` for constants)
**And** each data source module lives in its own file under `pipeline/ingestion/` — modules do not import from each other

---

### Story 1.5: Wire GitHub Actions CI/CD

As a developer,
I want GitHub Actions workflows configured for pipeline scheduling and lint,
So that the pipeline runs automatically on a daily cadence and CI runs on push.

**Acceptance Criteria:**

**Given** the `.github/workflows/` directory exists,
**When** the workflows are configured,
**Then** `.github/workflows/pipeline-schedule.yml` defines a cron trigger for a daily run during season (e.g., `0 8 * * *`) and executes `python pipeline/run.py`
**And** `.github/workflows/pipeline-ci.yml` runs on push to any path under `pipeline/` and executes lint (`flake8` or `ruff`) and tests
**And** both workflows reference `DATABASE_URL` and `YOUTUBE_API_KEY` as GitHub Actions secrets (not hardcoded)
**And** Vercel Git Integration is configured so that pushes to `main` auto-deploy the `/web` app (Vercel root directory: `/web`)
**And** the pipeline schedule workflow and Vercel deploy are fully independent — a pipeline failure does not affect Vercel deployment (NFR14)

---

## Epic 2: Data Pipeline — Player Pool & Statistics

**Goal:** Ingest real player data into the database. After this epic, the database contains an active player pool with advanced statistics, and the pipeline can be re-run to keep data fresh. The web app can read player data even before the UI is built.

### Story 2.1: Player Pool Seeding from Big Boards

As the operator,
I want the pipeline to seed and maintain a player pool from consensus public big boards,
So that tracked prospects reflect who the community is currently evaluating (FR16).

**Acceptance Criteria:**

**Given** `pipeline/ingestion/player_pool.py` is implemented,
**When** the player pool sync runs,
**Then** the module reads from at least one public consensus big board source (e.g., ESPN, The Athletic, or Crafted NBA)
**And** new prospects are upserted into the `players` table (insert if new, update `big_board_rank` if exists)
**And** players removed from the big board are marked `is_active = false` rather than hard-deleted
**And** each player's `slug` is generated as kebab-case `{first-last}` (e.g., `cooper-flagg`)
**And** slug collision is handled by appending a 4-character UUID suffix (e.g., `chris-johnson-a3f2`)
**And** once assigned, a player's `slug` is never changed on subsequent syncs
**And** the sync is idempotent — running it twice does not create duplicate rows

---

### Story 2.2: Statistics Ingestion via cbbdata

As the operator,
I want the pipeline to ingest advanced player statistics from cbbdata into the database,
So that player profiles can display efficiency metrics, usage rate, on/off splits, and per-40 stats (FR4, FR14, FR17).

**Acceptance Criteria:**

**Given** `pipeline/ingestion/cbbdata.py` is implemented and `DATABASE_URL` is set,
**When** the stats ingestion run executes,
**Then** the module fetches advanced stats from the cbbdata API for all active players in the `players` table
**And** stats are written to `player_stats` as `(player_id, stat_key, stat_value, percentile, updated_at)` rows
**And** percentile values are computed within the current tracked player pool (draft class context)
**And** `updated_at` is set to the current timestamp in UTC (`timestamptz`)
**And** the ingestion is upsert-based — re-running updates existing rows rather than inserting duplicates
**And** a failure for one player is caught and logged; it does not abort the full run
**And** visible attribution for cbbdata is stored or referenced so the web layer can surface it (FR24)

---

### Story 2.3: Shot Location Data Ingestion via hoopR

As the operator,
I want the pipeline to ingest shot location data from hoopR/ESPN PBP into the database,
So that player profiles can display shot charts (FR7, FR14, FR17).

**Acceptance Criteria:**

**Given** `pipeline/ingestion/hoopr.py` is implemented,
**When** the shot location ingestion run executes,
**Then** the module fetches shot location data for all active players
**And** shot location records are written to `player_stats` using a consistent `stat_key` naming convention for shot zones (e.g., `shot_zone_paint`, `shot_zone_midrange_left`, `shot_zone_three_right_corner`)
**And** `stat_value` stores the shot frequency or percentage for each zone
**And** a failure for one player is caught and logged without aborting the full run
**And** attribution for hoopR/ESPN is stored or referenced for the data sources page (FR24)

---

### Story 2.4: Pipeline Run Logging

As the operator,
I want every pipeline run to write a status record to the `pipeline_runs` table,
So that the operator dashboard can surface last run time, status, and errors (FR18).

**Acceptance Criteria:**

**Given** `pipeline/run.py` orchestrates the full pipeline,
**When** a pipeline run completes (successfully or with errors),
**Then** a row is written to `pipeline_runs` with `started_at`, `completed_at`, `status` (`'success'` | `'partial'` | `'failed'`), `players_updated` count, and `errors_json` (array of per-player error messages, or null)
**And** `status` is `'success'` only if all players processed without error; `'partial'` if some failed; `'failed'` if the run aborted entirely
**And** the pipeline run record is written even if the run fails mid-way
**And** `errors_json` contains structured error objects (e.g., `{player_id, step, message}`) — not raw stack traces

---

## Epic 3: Data Pipeline — Clip Discovery & Verification

**Goal:** Build the YouTube clip discovery and verification system. After this epic, the database contains verified clip video IDs per player per skill category, and the `is_playable` flag is accurate. This is the highest-risk epic — clip accuracy is a v1 hypothesis being validated.

### Story 3.1: Skill Category Taxonomy Definition

As a developer,
I want the skill category taxonomy defined as constants in both Python and TypeScript,
So that clip discovery, storage, and display all use a consistent, typed vocabulary (FR13).

**Acceptance Criteria:**

**Given** the taxonomy needs to be consistent across both the pipeline and web app,
**When** the taxonomy is defined,
**Then** `pipeline/clips/discovery.py` defines the following 10 skill category constants and YouTube query templates:

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

**And** `web/src/db/schema.ts` defines a TypeScript union type `SkillCategory` with the same 10 values
**And** no ad-hoc skill category strings are used anywhere — only these 10 constants

---

### Story 3.2: YouTube Clip Discovery per Player per Skill

As the operator,
I want the pipeline to discover and store YouTube clip video IDs for each active player per skill category,
So that the web app can display relevant clips on player profiles (FR15).

**Acceptance Criteria:**

**Given** `pipeline/clips/discovery.py` is implemented and `YOUTUBE_API_KEY` is set,
**When** clip discovery runs for an active player,
**Then** the module calls the YouTube Data API v3 search endpoint using the query template for each skill category
**And** the top result's `videoId` is stored in `player_clips` for that `(player_id, skill_category)` pair
**And** if no results are returned for a skill category, `video_id` is set to `null` (never `""`)
**And** the discovery module tracks and logs YouTube Data API quota usage
**And** bulk re-fetch operations are batched (e.g., max N players per run, configurable) to avoid quota exhaustion (NFR11)
**And** all YouTube Data API calls occur only in the pipeline — never in the Next.js web layer (ARCH4)
**And** a failure for one player/category combination is caught and logged without aborting the full run

---

### Story 3.3: Clip Playability Verification

As the operator,
I want the pipeline to verify that each stored video ID is actually playable before marking it as verified,
So that the web app never renders a broken embed (FR12, NFR12).

**Acceptance Criteria:**

**Given** `pipeline/clips/verification.py` is implemented and a `video_id` is stored in `player_clips`,
**When** verification runs for a player's clips,
**Then** the module checks each non-null `video_id` for playability (e.g., via YouTube oEmbed endpoint or API video status check)
**And** `is_playable` is set to `true` only if the video is confirmed playable and embeddable
**And** `is_playable` is set to `false` if the video is unavailable, deleted, or has embedding disabled
**And** `verified_at` is updated to the current UTC timestamp after verification
**And** a video that was previously playable but is now unavailable has `is_playable` flipped to `false` (Content-ID enforcement handling)
**And** the web app renders `<StatUnavailable />` for any clip where `is_playable = false` or `video_id = null` (ARCH8)

---

### Story 3.4: Clip Discovery Integration into Pipeline Orchestrator

As a developer,
I want clip discovery and verification wired into `pipeline/run.py` as part of the full pipeline run,
So that each scheduled run refreshes both statistics and clips.

**Acceptance Criteria:**

**Given** `pipeline/run.py` is the pipeline entry point,
**When** the full pipeline run executes,
**Then** `run.py` calls the player pool sync, stats ingestion, and clip discovery/verification modules in sequence
**And** each module is invoked independently — a failure in one module does not skip subsequent modules (errors are caught and logged per Story 2.4)
**And** `pipeline/scripts/refetch_player_clips.py` exists as a standalone script that re-runs discovery + verification for a single named player (FR20 CLI path)
**And** `pipeline/scripts/add_remove_player.py` exists as a standalone CLI script to add or remove a player from the pool (FR21 CLI path)

---

## Epic 4: Player Profile — Core Display

**Goal:** Build all the public-facing pages of the web app. After this epic, a user can visit the home page, browse prospects, open a player's profile, and see their statistics, percentile bars, shot chart, and data freshness. No video yet — that's Epic 5.

### Story 4.1: Player Index / Home Page

As a user,
I want to browse a complete index of all tracked draft prospects on the home page,
So that I can discover players and navigate to their profiles (FR1).

**Acceptance Criteria:**

**Given** active players exist in the `players` table,
**When** a user visits `/`,
**Then** a `PlayerCard` is rendered for each `is_active = true` player, showing at minimum: name, school, position, and big board rank
**And** each card links to `/players/{slug}` (FR22)
**And** players are sorted by `big_board_rank` ascending
**And** the page is a Next.js Server Component — no client-side data fetching
**And** all DB access goes through `db/queries/players.ts` — no raw Drizzle in `page.tsx` (ARCH7)
**And** the page renders correctly on mobile viewports (FR23)
**And** no user authentication is required to view the page (FR26)

---

### Story 4.2: Player Profile Page Shell and Routing

As a user,
I want to navigate to a player's unique profile URL and see their name, school, position, and big board rank,
So that each prospect has a distinct, shareable, indexable page (FR2, FR22).

**Acceptance Criteria:**

**Given** a player exists with a valid `slug`,
**When** a user visits `/players/{slug}`,
**Then** the page renders the player's `PlayerHeader` component with name, school, position, and big board rank
**And** the page title is player-specific (e.g., `"Cooper Flagg — 2025 NBA Draft Analytics Profile | Analytics Eye Test"`)
**And** the route is a Next.js Server Component using `generateStaticParams` or dynamic rendering
**And** visiting `/players/{invalid-slug}` calls `notFound()` and renders the Next.js 404 page
**And** an `error.tsx` boundary exists at `app/players/[slug]/error.tsx` for unexpected runtime errors
**And** the URL is bookmarkable and shareable — visiting it directly renders the full profile without login (FR26)

---

### Story 4.3: Advanced Statistics Table

As a user,
I want to view a player's advanced statistical profile on their profile page,
So that I can assess their efficiency, usage, on/off splits, and per-40 performance (FR4).

**Acceptance Criteria:**

**Given** a player has `player_stats` rows in the database,
**When** the profile page renders,
**Then** the `StatTable` component displays the player's stats organized by category (efficiency, usage, on/off, per-40)
**And** each stat row shows the stat name and value
**And** stats are read from `db/queries/players.ts` — no raw Drizzle in the component (ARCH7)
**And** if a stat is missing or null, the cell renders a `<StatUnavailable />` component — not an empty cell or error (ARCH8)
**And** the table is wrapped in a `<Suspense>` boundary so it does not block above-the-fold render (NFR2)

---

### Story 4.4: Percentile Bar Charts

As a user,
I want to view a player's percentile rankings as visual bar charts contextualized within the current draft class,
So that I can quickly scan where a player ranks relative to peers (FR5, FR6).

**Acceptance Criteria:**

**Given** a player has percentile values in `player_stats`,
**When** the profile page renders the `PercentileBar` component,
**Then** each stat with a `percentile` value renders as a horizontal bar chart using Recharts `BarChart`
**And** the bar fills proportionally to the percentile (0–100)
**And** the percentile value is displayed as a label (e.g., "94th percentile")
**And** the chart uses `ResponsiveContainer` so it scales correctly on mobile viewports (FR23, NFR1)
**And** each bar has an accessible text alternative via ARIA or visible label — not visual-only (NFR7)
**And** color contrast for bar fill and labels meets WCAG AA standards (NFR8)
**And** if no percentile data exists for a stat, `<StatUnavailable />` is rendered in its place (ARCH8)

---

### Story 4.5: Shot Chart

As a user,
I want to view a shot chart showing a player's shot location distribution,
So that I can see where they take and make their shots on the court (FR7).

**Acceptance Criteria:**

**Given** a player has shot location stats in `player_stats`,
**When** the profile page renders the `ShotChart` component,
**Then** the chart renders shot zones on a half-court diagram using Recharts `ScatterChart` or a custom SVG overlay
**And** each zone is visually encoded by shot frequency or percentage
**And** the chart uses `ResponsiveContainer` to scale gracefully on small screens
**And** if shot location data is unavailable, `<StatUnavailable label="Shot chart unavailable" />` is rendered (ARCH8)
**And** the chart is wrapped in its own `<Suspense>` boundary

---

### Story 4.6: Data Freshness Indicator

As a user,
I want to see when a player's statistics were last refreshed on their profile page,
So that I can assess the recency of the data and adjust my confidence accordingly (FR8, NFR10).

**Acceptance Criteria:**

**Given** a player has `player_stats` rows with `updated_at` timestamps,
**When** the profile page renders the `DataFreshness` component,
**Then** the most recent `updated_at` timestamp across all of the player's stats is displayed as a human-readable label (e.g., "Stats last updated March 28, 2026")
**And** the timestamp is formatted using `Intl.DateTimeFormat` — never raw `.toISOString()` (ARCH format pattern)
**And** if the most recent update is more than 7 days ago, the component visually flags the data as potentially stale (NFR10)
**And** if no stats exist, the component displays "Stats not yet available" — not an error state

---

### Story 4.7: Data Sources Page

As a user,
I want to view a dedicated page listing all data sources and their attribution,
So that the platform is transparent about where data comes from (FR3, FR24).

**Acceptance Criteria:**

**Given** the `/data-sources` route exists,
**When** a user visits `/data-sources`,
**Then** the page lists all open-source data sources used: cbbdata, hoopR, CBBpy, NCAA Stats Portal
**And** each entry includes the source name, description, and a link to the source
**And** the page notes YouTube as the video source and explains the embed-only approach (no downloading)
**And** the page is a static Server Component with no database reads required
**And** attribution is also surfaced within player profiles (e.g., in a footer or profile sidebar)
**And** Sports-Reference, KenPom, BartTorvik, EvanMiya are explicitly NOT listed as data sources

---

## Epic 5: Video Integration

**Goal:** Wire the YouTube clip section into player profiles. After this epic, users can view and play embedded skill-category clips directly on player profiles, with a clean fallback when clips are unavailable.

### Story 5.1: Clip Section UI with Skill Category Tabs

As a user,
I want to view and play video clips organized by skill category on a player's profile page,
So that I can watch the film that corresponds to the player's statistical profile (FR9, FR10, FR13).

**Acceptance Criteria:**

**Given** a player has `player_clips` rows with `is_playable = true` and non-null `video_id`,
**When** the `ClipSection` component renders,
**Then** skill categories are displayed as tabs or a tab-like UI (e.g., scrollable pill buttons)
**And** selecting a skill category shows the verified playable clip(s) for that category
**And** clips are rendered as `<iframe src="https://www.youtube.com/embed/{videoId}">` elements
**And** iframes are never rendered with a null or empty `src` (ARCH8)
**And** the component is a Client Component (`'use client'`) only for the tab selection state — clip data is fetched server-side and passed as props
**And** the clip section is wrapped in a `<Suspense>` boundary that does not block above-the-fold stat render (NFR2)
**And** each iframe meets the minimum embed size of 200×200px at all viewport sizes (YouTube ToS compliance)

---

### Story 5.2: Clip Unavailability State

As a user,
I want to see a clean "unavailable" indicator when no verified clips exist for a skill category,
So that I understand the limitation without losing trust in the platform (FR11).

**Acceptance Criteria:**

**Given** a skill category has `video_id = null` or `is_playable = false` in `player_clips`,
**When** the `ClipSection` component renders that category,
**Then** the `<StatUnavailable label="No clips available" />` component is rendered in place of the iframe
**And** a supporting note is shown explaining that clip availability may be limited for some players
**And** no broken iframe, empty container, or error boundary is triggered — this is an expected state (ARCH process pattern)
**And** the tab for the unavailable category is still shown (so users can see all 10 categories), but its content shows the unavailable state
**And** if ALL 10 categories are unavailable, a single "No clips available for this player" message is shown rather than 10 individual unavailable states

---

### Story 5.3: YouTube Embed Compliance

As a developer,
I want all YouTube embeds to comply with YouTube's Terms of Service and IFrame Player API policies,
So that the platform remains compliant and embeds remain playable (FR25).

**Acceptance Criteria:**

**Given** the `ClipSection` component renders YouTube iframes,
**When** an embed is rendered,
**Then** video is always embedded via `<iframe src="https://www.youtube.com/embed/{videoId}">` — never downloaded or self-hosted (FR25)
**And** the YouTube player is never rendered below 200×200px at any viewport (YouTube IFrame API policy)
**And** YouTube branding is not suppressed in the embedded player
**And** no programmatic playback manipulation violates the IFrame Player API terms (no `autoplay=1` without user interaction)
**And** all embed parameters follow YouTube's current IFrame Player API documentation

---

## Epic 6: Operator Tooling

**Goal:** Build the protected `/admin` section for the operator (creator) to monitor pipeline health and manage the player pool. After this epic, the full operational loop — monitor freshness, spot-check clips, manage player pool — has purpose-built tooling.

### Story 6.1: HTTP Basic Auth Middleware on /admin

As the operator,
I want all `/admin` routes protected by HTTP Basic Auth,
So that the operator dashboard is not publicly accessible (ARCH5).

**Acceptance Criteria:**

**Given** `web/src/middleware.ts` is implemented,
**When** a request is made to any route under `/admin/*`,
**Then** Next.js middleware intercepts the request and checks for a valid `Authorization: Basic ...` header
**And** credentials are validated against `ADMIN_USER` and `ADMIN_PASS` environment variables
**And** an invalid or missing credential returns a 401 response with a `WWW-Authenticate: Basic` header, prompting the browser's native auth dialog
**And** valid credentials allow the request to proceed to the admin route
**And** credentials are never stored in source code or client bundles (NFR4)
**And** all routes outside `/admin/*` are completely unaffected by the middleware — no auth required for public pages (FR26)

---

### Story 6.2: Pipeline Status View

As the operator,
I want to view the current pipeline status including the last run timestamp and per-player data staleness,
So that I can monitor data freshness and identify players with stale stats (FR18).

**Acceptance Criteria:**

**Given** the operator is authenticated and visits `/admin`,
**When** the admin page renders,
**Then** the last pipeline run record is displayed: `started_at`, `completed_at`, `status`, `players_updated`, and a summary of `errors_json`
**And** the current timestamp is compared to each player's most recent `updated_at` to compute staleness
**And** players with stats older than 7 days are flagged as stale with a visible indicator (NFR10)
**And** the count of stale players is shown as a summary metric
**And** the page is a Server Component reading from `db/queries/pipeline.ts` — no raw Drizzle in `page.tsx` (ARCH7)
**And** timestamps are formatted with `Intl.DateTimeFormat` — not raw ISO strings

---

### Story 6.3: Clip Verification Status View

As the operator,
I want to view clip verification status per player per skill category,
So that I can spot-check clip coverage and identify players with poor clip quality before sharing broadly (FR19).

**Acceptance Criteria:**

**Given** the operator is on the `/admin` page,
**When** the clip status section renders,
**Then** a table or grid shows each active player with a count of skill categories that have `is_playable = true` clips (e.g., "7/10 categories covered")
**And** players with zero verified clips in any category are highlighted
**And** clicking or expanding a player row shows the per-category breakdown (which categories have clips, which do not)
**And** the `verified_at` timestamp is shown per player to indicate when verification last ran
**And** data is read from `db/queries/pipeline.ts` — no raw Drizzle in page files (ARCH7)

---

### Story 6.4: Manual Clip Re-Fetch via GitHub Actions Dispatch

As the operator,
I want to trigger a clip re-fetch for a specific player from the admin UI,
So that I can refresh clips for players with poor coverage without running the full pipeline (FR20).

**Implementation Note:** The pipeline runs Python on GitHub Actions — Vercel serverless functions have no Python runtime and cannot spawn subprocesses. The re-fetch is triggered by calling the GitHub Actions `workflow_dispatch` REST API from the Server Action. The pipeline job runs asynchronously; the UI confirms the dispatch was triggered, not that the re-fetch completed.

**Acceptance Criteria:**

**Given** `.github/workflows/refetch-player-clips.yml` exists and is configured with `workflow_dispatch` trigger accepting a `player_slug` input,
**When** the operator submits the re-fetch action for a player on the `/admin` page,
**Then** a Server Action in `web/src/app/admin/actions.ts` is invoked
**And** the action makes a `POST` request to `https://api.github.com/repos/{GITHUB_REPO}/actions/workflows/refetch-player-clips.yml/dispatches` with `{ "ref": "main", "inputs": { "player_slug": "{slug}" } }` using `GITHUB_PAT` from environment variables for authentication
**And** the action returns `{ success: true, data: { dispatched: true } }` if the GitHub API responds with HTTP 204
**And** the action returns `{ success: false, error: string }` if the GitHub API call fails — never throws (ARCH6)
**And** `GITHUB_PAT` and `GITHUB_REPO` (e.g., `"owner/repo"`) are stored as Vercel environment variables — never hardcoded in source
**And** the UI shows a "Re-fetch triggered — check clip status in ~2 minutes" confirmation after a successful dispatch
**And** the UI shows a descriptive error message if the dispatch fails
**And** the `refetch-player-clips.yml` workflow: (1) accepts `player_slug` as a required `workflow_dispatch` input, (2) runs `python pipeline/scripts/refetch_player_clips.py ${{ inputs.player_slug }}`, and (3) uses `DATABASE_URL` and `YOUTUBE_API_KEY` from GitHub Actions secrets

---

### Story 6.5: Player Pool Management — Add and Remove

As the operator,
I want to add a player to or remove a player from the tracked prospect pool without triggering a full pipeline re-run,
So that I can keep the player pool current as big boards update (FR21).

**Acceptance Criteria:**

**Given** the operator is on the `/admin` page,
**When** the operator adds a new player (by name, school, position, and big board rank),
**Then** a Server Action in `admin/actions.ts` inserts the player into the `players` table with `is_active = true` and a generated slug
**And** when the operator removes a player, the player's `is_active` is set to `false` — not hard-deleted
**And** removed players no longer appear on the public index page or in search
**And** adding or removing a player does not trigger stats ingestion or clip discovery for that player (a separate re-fetch handles that)
**And** all mutations return `ActionResult<T>` shape — never throw (ARCH6)
**And** slug generation follows the same kebab-case + UUID collision rule as Story 2.1

---

## Epic 7: Polish, Compliance & NFRs

**Goal:** Ensure the platform meets its non-functional commitments. After this epic, the product is responsive on mobile, gracefully handles all failure modes, meets baseline accessibility requirements, and is ready for the initial v1 launch to the friend group.

### Story 7.1: Responsive Layout (Mobile-Readable)

As a share-and-discover visitor landing on mobile,
I want all pages to render correctly on my phone without a native app,
So that I can view player profiles shared to me on social media (FR23).

**Acceptance Criteria:**

**Given** a user accesses the site on a mobile browser (viewport ≤ 390px),
**When** any public page renders,
**Then** all text is readable without horizontal scrolling
**And** `PercentileBar`, `ShotChart`, and `ClipSection` components scale gracefully using Tailwind responsive classes and Recharts `ResponsiveContainer`
**And** YouTube iframes are never smaller than 200×200px on any viewport (YouTube ToS compliance)
**And** the player index `PlayerCard` grid reflows to a single-column layout on small screens
**And** touch targets (links, tabs, buttons) are at least 44×44px to meet mobile usability standards
**And** graceful degradation on small screens is acceptable; pixel-perfect mobile optimization is not required

---

### Story 7.2: Accessibility Foundations

As a user who relies on keyboard navigation or screen readers,
I want core content to be navigable and charts to have text alternatives,
So that the platform is usable beyond visual-only interaction (NFR7, NFR8).

**Acceptance Criteria:**

**Given** the player profile page is fully rendered,
**When** a user navigates using only a keyboard,
**Then** all interactive elements (links, clip category tabs, admin buttons) are reachable via Tab key
**And** focus indicators are visible (not suppressed by `outline: none` without a replacement)
**And** percentile bar charts provide accessible text alternatives — either visible numeric labels or ARIA labels on chart elements (not visual-only)
**And** all non-decorative images and icons have descriptive `alt` text or `aria-label`
**And** `<StatUnavailable />` renders meaningful text content, not just a visual dash or icon
**And** color is not the sole means of conveying information (e.g., stale data warnings have both a color indicator AND a text label)
**And** a full WCAG AA audit is deferred to post-v1 — this story covers baseline compliance only

---

### Story 7.3: Error Boundaries and Graceful Degradation

As a user,
I want the platform to remain functional and informative when data or clips are unavailable,
So that I never see a broken page regardless of upstream failures (NFR9).

**Acceptance Criteria:**

**Given** the platform is in production,
**When** any upstream dependency (YouTube API, cbbdata, hoopR) is unavailable or a player has incomplete data,
**Then** profile pages render all available data sections and show `<StatUnavailable />` for unavailable sections — no broken empty states (ARCH8)
**And** `app/players/[slug]/error.tsx` catches unexpected runtime errors and displays a generic error message with a reload prompt — no stack traces exposed to users
**And** `app/not-found.tsx` provides a user-friendly 404 page for invalid player slugs
**And** a pipeline failure does not cause profile pages to error — the web app reads from the last-known-good data in the database (NFR14)
**And** each independently-loadable page section (stats, clips) has its own `<Suspense>` boundary — a slow section does not block other sections from rendering (NFR2)
**And** `throw` is never used for expected absent-data conditions — only `<StatUnavailable />` conditional renders (ARCH process pattern)

---

### Story 7.4: Security Hardening

As a developer,
I want all security NFRs met before launch,
So that API credentials are never exposed, all traffic is encrypted, and no PII is collected (NFR4, NFR5, NFR6).

**Acceptance Criteria:**

**Given** the platform is deployed to Vercel,
**When** the site is live,
**Then** all traffic is served over HTTPS — Vercel enforces this by default; confirm it is not disabled
**And** `YOUTUBE_API_KEY`, `DATABASE_URL`, `ADMIN_USER`, and `ADMIN_PASS` are stored as Vercel environment variables and GitHub Actions secrets — never in source code or client bundles
**And** `next/headers` or server-only modules are used where needed to ensure credentials stay server-side
**And** `web/.env.local` and `pipeline/.env` are in `.gitignore` — never committed
**And** `web/.env.example` and `pipeline/.env.example` are committed with placeholder values only
**And** Vercel function logs are reviewed to confirm no PII (IP addresses, user-agent strings beyond standard logging) is captured beyond what Vercel's default logging provides
**And** no user-submitted input exists in v1 — the PII attack surface is minimal

---

### Story 7.5: Player-Specific Meta Tags

As a developer,
I want player profile pages to have player-specific `<title>` and `<meta description>` tags,
So that links shared on social media show meaningful previews (from PRD web requirements).

**Acceptance Criteria:**

**Given** a player profile page at `/players/{slug}`,
**When** the page is rendered,
**Then** the `<title>` tag is `"{Player Name} — {Year} NBA Draft Analytics Profile | Analytics Eye Test"` (e.g., `"Cooper Flagg — 2025 NBA Draft Analytics Profile | Analytics Eye Test"`)
**And** the `<meta name="description">` includes the player's school, position, and a brief stat highlight
**And** the home page and data sources page have their own distinct title and description
**And** Open Graph tags (`og:title`, `og:description`, `og:url`) are set for profile pages to improve social share previews
**And** structured data and full SEO optimization are explicitly deferred to the growth phase

---

*End of Epic and Story Breakdown — 7 Epics, 30 Stories, 26 FRs fully covered.*
