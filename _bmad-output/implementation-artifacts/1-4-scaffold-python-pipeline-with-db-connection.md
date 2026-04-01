# Story 1.4: Scaffold Python Pipeline with DB Connection

Status: done

## Story

As a developer,
I want the Python pipeline scaffolded with psycopg3 and a verified database connection,
So that the pipeline can begin writing data to PostgreSQL.

## Acceptance Criteria

1. **Given** the `/pipeline` directory exists and `DATABASE_URL` is set in `pipeline/.env`, **When** the scaffold is complete, **Then** `pipeline/requirements.txt` includes `psycopg[binary]`, `requests`, `python-dotenv`
2. **Given** the scaffold is complete, **Then** `pipeline/db/writes.py` exports a `get_connection()` function that establishes a psycopg3 connection using `DATABASE_URL`
3. **Given** the scaffold is complete, **Then** `pipeline/run.py` exists as the entry point and can be executed with `python run.py` (from within `pipeline/`) without errors
4. **Given** the scaffold is complete, **Then** `pipeline/.env.example` documents required env vars: `DATABASE_URL`, `YOUTUBE_API_KEY`
5. **Given** the scaffold is complete, **Then** all modules follow PEP 8 naming conventions (`snake_case` for functions and variables, `UPPER_SNAKE_CASE` for constants)
6. **Given** the scaffold is complete, **Then** each data source module lives in its own file under `pipeline/ingestion/` — modules do not import from each other

## Tasks / Subtasks

- [x] Task 1: Create full pipeline directory skeleton (AC: #5, #6)
  - [x] 1.1 Create `pipeline/ingestion/__init__.py` (empty)
  - [x] 1.2 Create `pipeline/clips/__init__.py` (empty)
  - [x] 1.3 Create `pipeline/db/__init__.py` (empty)
  - [x] 1.4 Create `pipeline/scripts/` directory (no `__init__.py` — scripts run directly, not imported)
  - [x] 1.5 Create `pipeline/tests/` directory (no `__init__.py` needed for this story)
- [x] Task 2: Create `requirements.txt` and `.env.example` (AC: #1, #4)
  - [x] 2.1 Create `pipeline/requirements.txt` with `psycopg[binary]>=3.1`, `requests>=2.31.0`, `python-dotenv>=1.0.0`
  - [x] 2.2 Create `pipeline/.env.example` documenting `DATABASE_URL` and `YOUTUBE_API_KEY` with format hints
- [x] Task 3: Create `pipeline/db/writes.py` with DB connection (AC: #2)
  - [x] 3.1 Implement `get_connection()` that calls `psycopg.connect(DATABASE_URL)` — `DATABASE_URL` loaded from environment via `python-dotenv`
  - [x] 3.2 Raise a clear `EnvironmentError` if `DATABASE_URL` is not set
- [x] Task 4: Create stub ingestion modules (AC: #6)
  - [x] 4.1 Create `pipeline/ingestion/player_pool.py` — stub only (no implementation), module-level docstring describing its future role
  - [x] 4.2 Create `pipeline/ingestion/cbbdata.py` — stub only
  - [x] 4.3 Create `pipeline/ingestion/hoopr.py` — stub only
  - [x] 4.4 Create `pipeline/clips/discovery.py` — stub only
  - [x] 4.5 Create `pipeline/clips/verification.py` — stub only
- [x] Task 5: Create `pipeline/run.py` entry point (AC: #3)
  - [x] 5.1 Create `run.py` that loads env vars, calls `get_connection()`, verifies connection with a `SELECT 1` test query, prints confirmation, and closes the connection
  - [x] 5.2 Verify `python run.py` executes without errors from inside `pipeline/` (with `.env` present and `DATABASE_URL` valid)
- [x] Task 6: Install and verify
  - [x] 6.1 Run `pip install -r requirements.txt` from `pipeline/` — confirm all three packages install without errors
  - [x] 6.2 Copy `pipeline/.env.example` to `pipeline/.env` and set real `DATABASE_URL` (Neon connection string)
  - [x] 6.3 Run `python run.py` from `pipeline/` — confirm "Database connection verified" output and no errors

## Dev Notes

### Critical: psycopg3, not psycopg2

This project uses **psycopg3** (the third-generation driver). The package name and import differ from psycopg2:

| | psycopg2 (DO NOT USE) | psycopg3 (CORRECT) |
|--|--|--|
| `requirements.txt` | `psycopg2-binary` | `psycopg[binary]` |
| import | `import psycopg2` | `import psycopg` |
| connect | `psycopg2.connect(...)` | `psycopg.connect(...)` |

Never install or import `psycopg2`. The `[binary]` extra bundles the compiled C extension; no separate system library install needed.

### `get_connection()` Implementation Pattern

```python
# pipeline/db/writes.py
import os
import psycopg
from dotenv import load_dotenv

load_dotenv()  # loads pipeline/.env when run from pipeline/ directory

DATABASE_URL = os.environ.get("DATABASE_URL")


def get_connection() -> psycopg.Connection:
    """Return an open psycopg3 connection using DATABASE_URL.

    Callers are responsible for closing the connection.
    Prefer using as a context manager: `with get_connection() as conn: ...`
    """
    if not DATABASE_URL:
        raise EnvironmentError("DATABASE_URL is not set. Copy .env.example to .env and fill in the value.")
    return psycopg.connect(DATABASE_URL)
```

psycopg3 connections support context manager protocol — callers can use `with get_connection() as conn:` which auto-commits/rolls back and closes on exit.

### `run.py` Implementation Pattern

`run.py` must be executable from inside the `pipeline/` directory:

```python
# pipeline/run.py
"""Pipeline entry point — orchestrates a full data refresh run."""
from db.writes import get_connection


def main() -> None:
    print("Starting pipeline run...")
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            result = cur.fetchone()
            assert result is not None, "DB connectivity check failed"
    print("Database connection verified. Pipeline scaffold ready.")


if __name__ == "__main__":
    main()
```

**Run from:** `pipeline/` directory — imports are relative to `pipeline/` (e.g., `from db.writes import ...` works because `pipeline/` is the working directory / sys.path root).

### `pipeline/.env.example` Content

```
# Copy this file to .env and fill in real values.
# Never commit .env to source control.

# Neon PostgreSQL connection string
# Format: postgresql://user:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require
DATABASE_URL=postgresql://user:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require

# YouTube Data API v3 key (used in Epic 3)
YOUTUBE_API_KEY=your_youtube_data_api_v3_key
```

### `requirements.txt` Content

```
psycopg[binary]>=3.1
requests>=2.31.0
python-dotenv>=1.0.0
```

Note: `requests` and `python-dotenv` are needed for Epic 2/3 ingestion modules. Adding them now keeps the scaffold complete.

### Stub Module Pattern

Ingestion and clips stubs should have a module docstring and no importable symbols (no functions yet). Do NOT add placeholder functions that future stories would have to delete or rename. Keep stubs minimal:

```python
# pipeline/ingestion/player_pool.py
"""Player pool synchronization: seeds and maintains the tracked prospect pool
from consensus public big boards. Implemented in Story 2.1."""
```

### PEP 8 Naming — Enforcement Checklist

- Module files: `snake_case.py` ✓ (`writes.py`, `player_pool.py`, `cbbdata.py`)
- Function names: `snake_case` ✓ (`get_connection`, `main`)
- Variables: `snake_case` ✓ (`player_id`, `database_url`)
- Constants (module-level): `UPPER_SNAKE_CASE` ✓ (`DATABASE_URL`, `YOUTUBE_API_KEY`)
- No `camelCase` in Python — reserved for TypeScript/JavaScript side

### Database Connection: Neon-Specific Notes

The `DATABASE_URL` must include `?sslmode=require` for Neon. Without it, the connection will be refused. The Neon connection string from the dashboard already includes this parameter.

psycopg3 handles the SSL requirement transparently when `sslmode=require` is in the URL — no additional SSL config needed in Python code.

### Project Structure After This Story

```
pipeline/
├── requirements.txt          # psycopg[binary], requests, python-dotenv
├── .env.example              # DATABASE_URL, YOUTUBE_API_KEY template
├── .env                      # (gitignored) — developer creates from .env.example
├── run.py                    # Entry point — tests DB connection; future: orchestrates pipeline
│
├── db/
│   ├── __init__.py           # (empty)
│   └── writes.py             # get_connection() — all future DB write functions go here
│
├── ingestion/
│   ├── __init__.py           # (empty)
│   ├── player_pool.py        # stub — implemented Story 2.1
│   ├── cbbdata.py            # stub — implemented Story 2.2
│   └── hoopr.py              # stub — implemented Story 2.3
│
├── clips/
│   ├── __init__.py           # (empty)
│   ├── discovery.py          # stub — implemented Story 3.2
│   └── verification.py       # stub — implemented Story 3.3
│
├── scripts/                  # (empty dir — no __init__.py)
│                             # refetch_player_clips.py, add_remove_player.py in Epic 6
│
└── tests/                    # (empty dir — no __init__.py needed yet)
                              # test files added in Story 1.5 (CI/CD wiring)
```

### What NOT To Do

- **Do NOT use `psycopg2`** — the installed driver is psycopg3; `import psycopg2` will fail
- **Do NOT hard-code `DATABASE_URL`** — always load from environment via `python-dotenv`
- **Do NOT add functions/classes to stub modules** — Epic 2/3 stories implement them; stubs have docstrings only
- **Do NOT create a `pipeline/__init__.py`** — `pipeline/` is not a Python package; it's a project root
- **Do NOT run `run.py` from the repo root with `python pipeline/run.py`** — imports like `from db.writes import ...` will break; always `cd pipeline && python run.py`
- **Do NOT install or reference `psycopg2-binary`** — wrong package; use `psycopg[binary]`
- **Do NOT add `scripts/__init__.py`** — scripts are standalone CLI tools, not a package
- **Do NOT add `.env` to source control** — it contains real credentials; `.gitignore` already covers `.env` from Story 1.1

### Previous Story Intelligence (Story 1.3)

- Database is live on Neon with all 4 tables created and migration applied
- Confirmed `DATABASE_URL` format: `postgresql://user:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require`
- Column names to target in future pipeline writes (snake_case):
  - `players`: `id`, `slug`, `name`, `school`, `position`, `big_board_rank`, `is_active`
  - `player_stats`: `id`, `player_id`, `stat_key`, `stat_value`, `percentile`, `updated_at`
  - `player_clips`: `id`, `player_id`, `skill_category`, `video_id`, `is_playable`, `verified_at`
  - `pipeline_runs`: `id`, `started_at`, `completed_at`, `status`, `players_updated`, `errors_json`
- `video_id` on `player_clips` is nullable — `null` means no verified clip (never use `""`)
- `pipelineRuns.status` values: `'success'` | `'partial'` | `'failed'` only

### Architecture Constraints

- **ARCH2:** psycopg3 for all pipeline DB access — no SQLAlchemy, no other ORM
- **ARCH3:** Database is the sole contract between pipeline and web app — pipeline only writes SQL; never calls Next.js APIs
- **ARCH4:** All external API calls (YouTube, cbbdata, hoopR) made in pipeline only — never in Next.js
- **ARCH9:** GitHub Actions cron for scheduling — pipeline runs via `python pipeline/run.py` in GHA context (env vars from Actions secrets, not `.env` file)

### References

- [Source: _bmad-output/planning-artifacts/architecture.md — Pipeline Project Organization]
- [Source: _bmad-output/planning-artifacts/architecture.md — Python Naming Conventions]
- [Source: _bmad-output/planning-artifacts/architecture.md — Complete Project Directory Structure]
- [Source: _bmad-output/planning-artifacts/architecture.md — Data Architecture]
- [Source: _bmad-output/planning-artifacts/epics-and-stories.md — Story 1.4]
- [Source: _bmad-output/implementation-artifacts/1-3-define-drizzle-schema-and-run-initial-migration.md — Dev Notes, Completion Notes]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

_No issues encountered. DATABASE_URL sourced from web/.env.local (same Neon connection string)._

### Completion Notes List

- Created full pipeline directory skeleton: ingestion/, clips/, db/, scripts/, tests/
- requirements.txt: psycopg[binary]>=3.1, requests>=2.31.0, python-dotenv>=1.0.0 — all installed successfully
- pipeline/db/writes.py: get_connection() uses psycopg3 (not psycopg2), loads DATABASE_URL via python-dotenv, raises EnvironmentError if unset
- pipeline/run.py: entry point runs SELECT 1 connectivity check — confirmed "Database connection verified. Pipeline scaffold ready."
- 5 stub modules created (ingestion: player_pool, cbbdata, hoopr; clips: discovery, verification) — docstrings only, no importable symbols
- pipeline/.env created from web/.env.local DATABASE_URL (gitignored)
- All ACs satisfied: requirements.txt ✓, get_connection() ✓, run.py executes ✓, .env.example ✓, PEP 8 ✓, module isolation ✓

### File List

- pipeline/ingestion/__init__.py
- pipeline/clips/__init__.py
- pipeline/db/__init__.py
- pipeline/scripts/.gitkeep
- pipeline/tests/.gitkeep
- pipeline/requirements.txt
- pipeline/.env.example
- pipeline/db/writes.py
- pipeline/ingestion/player_pool.py
- pipeline/ingestion/cbbdata.py
- pipeline/ingestion/hoopr.py
- pipeline/clips/discovery.py
- pipeline/clips/verification.py
- pipeline/run.py

### Change Log

- 2026-03-31: Story 1.4 implemented — Python pipeline scaffold created with psycopg3 DB connection, stub ingestion/clips modules, and verified run.py entry point

### Review Findings

- [x] [Review][Patch] Replace bare `assert` with `if/raise RuntimeError` in run.py [pipeline/run.py:11]
- [x] [Review][Patch] `DATABASE_URL` empty-string or whitespace-only passes the falsy guard — add `.strip()` check [pipeline/db/writes.py:17]
- [x] [Review][Defer] Relative import breaks when `run.py` is executed from repo root [pipeline/run.py:2] — deferred, pre-existing; GHA will need `cd pipeline && python run.py` (see ARCH9)
- [x] [Review][Defer] `load_dotenv()` side-effect at module import time [pipeline/db/writes.py:6] — deferred, spec-inherited pattern
- [x] [Review][Defer] `DATABASE_URL` captured at module load time, not inside `get_connection()` [pipeline/db/writes.py:8] — deferred, spec-inherited pattern; affects testability
- [x] [Review][Defer] `psycopg.connect()` raises unhandled `OperationalError` on bad credentials/network [pipeline/db/writes.py:21] — deferred, callers responsible per docstring
- [x] [Review][Defer] No connection pooling — fresh TCP connection on every `get_connection()` call [pipeline/db/writes.py] — deferred, scaffold scope
- [x] [Review][Defer] Module named `writes.py` but contains only a connection factory — misleading name [pipeline/db/writes.py] — deferred, rename out of scope
- [x] [Review][Defer] No `pyproject.toml` / installable package definition [pipeline/] — deferred, `pipeline/` intentionally runs as a directory project
- [x] [Review][Defer] `requirements.txt` uses only minimum version pins, no lockfile [pipeline/requirements.txt] — deferred, add lockfile when CI is wired
- [x] [Review][Defer] `SELECT 1` check doesn't verify schema, role permissions, or migration state [pipeline/run.py:9] — deferred, scaffold-level check is sufficient for this story
