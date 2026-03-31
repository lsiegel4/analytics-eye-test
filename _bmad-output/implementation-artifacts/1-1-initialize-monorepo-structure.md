# Story 1.1: Initialize Monorepo Structure

Status: review

## Story

As a developer,
I want a monorepo with `/web`, `/pipeline`, and `.github/workflows/` directories initialized,
So that both services share a single repository with clear boundaries and no cross-imports.

## Acceptance Criteria

1. **Given** a fresh repository, **When** the monorepo is initialized, **Then** the root directory contains `/web/`, `/pipeline/`, `.github/workflows/`, `README.md`, and `.gitignore`
2. **Given** the `.gitignore` file exists, **Then** it covers `node_modules/`, `.next/`, `.env.local`, `__pycache__/`, `*.pyc`, and `.env`
3. **Given** the monorepo structure is complete, **Then** there are no cross-imports between `/web` and `/pipeline` directories

## Tasks / Subtasks

- [x] Task 1: Initialize git repository (AC: #1)
  - [x] 1.1 Run `git init` in the project root
  - [x] 1.2 Create root `.gitignore` with all required patterns
- [x] Task 2: Create monorepo directory structure (AC: #1, #3)
  - [x] 2.1 Create `/web/` directory with a `.gitkeep` placeholder
  - [x] 2.2 Create `/pipeline/` directory with a `.gitkeep` placeholder
  - [x] 2.3 Create `/.github/workflows/` directory with a `.gitkeep` placeholder
- [x] Task 3: Create root README.md (AC: #1)
  - [x] 3.1 Write a minimal README with project name, description, and directory overview
- [x] Task 4: Validate monorepo structure (AC: #1, #2, #3)
  - [x] 4.1 Verify all required directories exist: `/web/`, `/pipeline/`, `/.github/workflows/`
  - [x] 4.2 Verify `.gitignore` contains all required patterns
  - [x] 4.3 Verify no cross-imports exist between `/web` and `/pipeline`
  - [x] 4.4 Verify `README.md` exists at root

## Dev Notes

### Architecture Requirements

- **Monorepo layout** (ARCH1): `analytics-eye-test/` root with three top-level directories: `web/` (Next.js 15), `pipeline/` (Python), `.github/workflows/` (CI/CD)
- The web and pipeline are **independent services** connected only via a shared PostgreSQL database — no HTTP between them, no cross-imports
- Pipeline failure must never take down the web app (NFR14) — this boundary starts at the directory level

### .gitignore Must Include

```
# Node / Next.js
node_modules/
.next/
.env.local

# Python
__pycache__/
*.pyc
.env

# OS
.DS_Store

# IDE
.vscode/
.idea/
```

Additional entries to include for completeness (from architecture doc):
- `web/.env.local` and `pipeline/.env` must be gitignored (credentials — NFR4)
- `web/.env.example` and `pipeline/.env.example` will be committed later (with placeholders only)

### README.md Content Guidance

Minimal — just enough to orient a developer:
- Project name: Analytics Eye Test
- One-line description: College basketball scouting platform for NBA draft prospects
- Directory layout table: `web/` → Next.js 15 app, `pipeline/` → Python data pipeline, `.github/workflows/` → CI/CD

Do NOT include setup instructions yet — those come in later stories (1.2, 1.4, 1.5).

### Project Structure Notes

- This is the very first story — the project root currently contains only `_bmad/`, `_bmad-output/`, `.claude/`, `.windsurf/`, and `docs/` directories
- The `.gitignore` should also cover the existing `_bmad-output/` and other non-source directories if appropriate, but the acceptance criteria only require the listed patterns
- The `web/` and `pipeline/` directories will be populated in Stories 1.2 and 1.4 respectively — for now they just need to exist

### What NOT To Do

- Do NOT scaffold Next.js or install any packages — that's Story 1.2
- Do NOT scaffold the Python pipeline — that's Story 1.4
- Do NOT create workflow YAML files — that's Story 1.5
- Do NOT provision any database — that's Story 1.3
- Keep this story focused purely on the monorepo skeleton and git initialization

### References

- [Source: _bmad-output/planning-artifacts/architecture.md — Monorepo Structure section]
- [Source: _bmad-output/planning-artifacts/architecture.md — Complete Project Directory Structure]
- [Source: _bmad-output/planning-artifacts/epics-and-stories.md — Story 1.1]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6

### Debug Log References

No issues encountered.

### Completion Notes List

- Initialized git repository with `git init` on `main` branch
- Created `.gitignore` covering all required patterns: node_modules/, .next/, .env.local, __pycache__/, *.pyc, .env, plus .DS_Store and IDE directories
- Created `/web/`, `/pipeline/`, and `/.github/workflows/` directories with `.gitkeep` placeholders
- Created minimal `README.md` with project name, description, and directory layout table
- All acceptance criteria validated: directories exist, .gitignore patterns present, no cross-imports (directories are empty)

### File List

- `.gitignore` (new)
- `README.md` (new)
- `web/.gitkeep` (new)
- `pipeline/.gitkeep` (new)
- `.github/workflows/.gitkeep` (new)

### Change Log

- 2026-03-30: Story 1.1 implemented — monorepo skeleton initialized with git, .gitignore, README, and directory structure
