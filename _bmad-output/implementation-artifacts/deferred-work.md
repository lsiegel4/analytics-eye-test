# Deferred Work

## Deferred from: code review of 1-2-scaffold-nextjs-web-app (2026-03-31)

- `db/queries/` directory absent (ARCH7) — by design, implemented in Epic 4 when player profile queries are needed

## Deferred from: code review of 1-3-define-drizzle-schema-and-run-initial-migration (2026-03-31) — Blind Hunter addendum

- `ActionResult<T>` type and Server Actions pattern (ARCH6) — by design, implemented in Epic 6 (admin/operator tooling)
- `<StatUnavailable />` component (ARCH8) — by design, implemented in Epic 5 (video integration)
- `ON DELETE no action` on `player_stats` and `player_clips` FK constraints — intentional; players are soft-deleted via `is_active = false`, never hard-deleted; child rows remain valid
- `errorsJson` column is untyped `jsonb` — acceptable v1; TypeScript consumers will type-assert at read time; revisit if error shape stabilizes post-v1
- No indexes on `player_stats(player_id)` / `player_clips(player_id)` — full scans for per-player queries acceptable at v1 scale (30–50 players); add indexes in Epic 4 once query patterns are established
- `pipelineRuns.status` has no check constraint enforcing `'success'|'partial'|'failed'` — Drizzle requires raw SQL for check constraints; enforce in pipeline code instead; revisit if schema-level enforcement needed post-v1
- `playerStats.percentile` has no [0, 100] range constraint — same reason; enforce in pipeline ingestion logic

## Deferred from: code review of 1-4-scaffold-python-pipeline-with-db-connection (2026-03-31)

- Relative import in `run.py` breaks when executed from repo root — GHA must use `cd pipeline && python run.py` per ARCH9; address in GHA wiring story
- `load_dotenv()` called at module import time in `db/writes.py` — spec-inherited pattern; harmless (no-op if .env absent) but makes unit testing surprising
- `DATABASE_URL` captured at module load time (`os.environ.get` at top level) — spec-inherited; re-reading inside `get_connection()` would improve testability
- `psycopg.connect()` raises unhandled `OperationalError` on bad credentials or network failure — callers responsible per docstring; add error handling in future ingestion modules
- No connection pooling — fresh TCP connection per call; acceptable at v1 scale, revisit with `psycopg_pool` when pipeline runs have many concurrent writes
- Module named `writes.py` contains only a connection factory — rename to `connection.py` or expand with actual write functions in Epic 2
- No `pyproject.toml` or installable package definition — `pipeline/` runs as a directory project; acceptable until packaging is needed for CI
- `requirements.txt` uses only minimum version bounds with no lockfile — add `pip-tools` or equivalent lockfile when GHA CI is wired (Story 1.5)
- `SELECT 1` connectivity check doesn't verify schema, role permissions, or migration state — scaffold-level check; add schema version assertion once migrations stabilize
