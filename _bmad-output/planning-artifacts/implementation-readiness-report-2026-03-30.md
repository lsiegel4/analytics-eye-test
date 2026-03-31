---
stepsCompleted: [step-01-document-discovery, step-02-prd-analysis, step-03-epic-coverage-validation, step-04-ux-alignment, step-05-epic-quality-review, step-06-final-assessment]
documentsIncluded:
  prd: _bmad-output/planning-artifacts/prd.md
  architecture: _bmad-output/planning-artifacts/architecture.md
  epics: _bmad-output/planning-artifacts/epics-and-stories.md
  ux: null
---

# Implementation Readiness Assessment Report

**Date:** 2026-03-30
**Project:** analytics-eye-test

---

## PRD Analysis

### Functional Requirements

**Player Discovery & Navigation**
- FR1: Users can browse a complete index of all tracked draft prospects
- FR2: Users can navigate directly to an individual player's profile via a unique, shareable URL
- FR3: Users can access a dedicated page listing all data sources and their attribution

**Player Profile**
- FR4: Users can view a player's advanced statistical profile (efficiency metrics, usage rate, on/off splits, per-40 stats, shot location data)
- FR5: Users can view a player's percentile rankings contextualized within the current draft class
- FR6: Users can view percentile rankings as visual bar charts
- FR7: Users can view a shot chart showing a player's shot location distribution
- FR8: Users can view the timestamp of when a player's statistics were last refreshed

**Video Integration**
- FR9: Users can view video clips for a player organized by skill category
- FR10: Users can play embedded video clips directly within the player profile without navigating away
- FR11: Users see a clean "unavailable" indicator when no clips exist for a skill category — no broken embeds, no empty UI states
- FR12: The system verifies clip playability at page load and surfaces only playable embeds to users
- FR13: The system organizes clips under a defined skill category taxonomy that maps to basketball evaluation dimensions

**Data Pipeline**
- FR14: The system automatically refreshes player statistics from open-source data sources on a scheduled cadence
- FR15: The system automatically discovers and indexes video clips per player per skill category via the YouTube Data API
- FR16: The system seeds and maintains the tracked player pool from consensus public big boards
- FR17: The system stores player statistics locally so profiles render from cached data, not live upstream API calls at page load

**Operator Tools**
- FR18: The operator can view current pipeline status including last refresh timestamp and per-player data staleness
- FR19: The operator can view clip verification status per player, showing which skill categories have verified playable clips
- FR20: The operator can manually trigger a clip re-fetch for one or more specific players
- FR21: The operator can add a player to or remove a player from the tracked prospect pool without triggering a full pipeline re-run

**Platform & Compliance**
- FR22: All player profile pages are accessible at distinct, shareable, indexable URLs
- FR23: The platform renders correctly on mobile browsers without a native app
- FR24: The platform displays attribution for all open-source data sources visibly within the product
- FR25: All video content is delivered via YouTube IFrame Player API embed — no downloading or self-hosting
- FR26: The platform is fully accessible without user registration or authentication

**Total FRs: 26**

---

### Non-Functional Requirements

**Performance**
- NFR1: Profile pages must render the statistical profile and visualizations without perceptible delay on a standard broadband connection
- NFR2: Video clips must load lazily — clip embeds must not block or delay rendering of the statistical profile above the fold
- NFR3: Profiles render from locally cached data; no live upstream API calls at page load time

**Security**
- NFR4: YouTube Data API key and all third-party API credentials must not be exposed to the client — all external API calls made server-side
- NFR5: HTTPS required for all traffic
- NFR6: No PII collected or stored in v1; server logs must be reviewed to confirm no inadvertent PII capture

**Accessibility**
- NFR7: Soft commitment to WCAG 2.1 AA compliance
- NFR8: Percentile bar charts must provide accessible text alternatives (not visual-only)
- NFR9: Color contrast for text and UI elements meets AA standards
- NFR10: Keyboard navigation functional for core user flows

**Integration Reliability**
- NFR11: The platform degrades gracefully when any upstream dependency is unavailable — a data source outage or YouTube API failure must not cause profile pages to error or render broken states
- NFR12: Player statistics are no more than 7 days stale during the active season
- NFR13: YouTube Data API quota usage must be monitored; bulk re-fetch operations should be batched to avoid quota exhaustion
- NFR14: All YouTube embeds are verified playable at page load; unplayable clips are replaced with a clean fallback state before the page is served

**Availability**
- NFR15: The platform must be reliably available during peak draft-season usage (combine week, draft week)
- NFR16: The data pipeline and web application are independently deployable — a pipeline failure must not take down the public-facing site

**Total NFRs: 16**

---

### Additional Requirements

**Domain / Compliance Constraints**
- YouTube embeds only (no download/self-hosting); minimum 200×200px embed size; no suppression of YouTube branding
- Data attribution required for cbbdata, hoopR, CBBpy, NCAA on profiles and/or a dedicated data sources page
- Sports-Reference / KenPom / BartTorvik / EvanMiya must NOT be used as data pipeline sources
- No user accounts, no PII in v1

**Architecture Constraints**
- MPA (multi-page application) architecture; one URL per player profile
- Server-side rendering; no SPA framework complexity
- Responsive web layout; modern evergreen browsers (last 2 major versions); no IE11
- Player-specific page titles and meta descriptions for SEO

**Scope Boundaries (Out of MVP)**
- No player comparison, user accounts, paywall, mobile app, historical archives, transfer portal, trend graphs, full SEO or full accessibility audit

---

---

## Epic Coverage Validation

### Coverage Matrix

| FR | PRD Requirement (summary) | Epic | Story | Status |
|----|--------------------------|------|-------|--------|
| FR1 | Browse complete prospect index | Epic 4 | 4.1 | ✓ Covered |
| FR2 | Navigate to player profile via unique URL | Epic 4 | 4.2 | ✓ Covered |
| FR3 | Dedicated data sources attribution page | Epic 4 | 4.7 | ✓ Covered |
| FR4 | View advanced statistical profile | Epic 4 | 4.3 | ✓ Covered |
| FR5 | View percentile rankings in draft class context | Epic 4 | 4.4 | ✓ Covered |
| FR6 | Percentile rankings as visual bar charts | Epic 4 | 4.4 | ✓ Covered |
| FR7 | Shot chart for shot location distribution | Epic 4 | 4.5 | ✓ Covered |
| FR8 | Data freshness timestamp on profiles | Epic 4 | 4.6 | ✓ Covered |
| FR9 | Video clips organized by skill category | Epic 5 | 5.1 | ✓ Covered |
| FR10 | Play embedded clips within profile | Epic 5 | 5.1 | ✓ Covered |
| FR11 | Clean "unavailable" indicator for missing clips | Epic 5 | 5.2 | ✓ Covered |
| FR12 | System verifies clip playability before serving | Epic 3 | 3.3 | ✓ Covered |
| FR13 | Skill category taxonomy for clip organization | Epic 3 | 3.1 | ✓ Covered |
| FR14 | Automated stats refresh on scheduled cadence | Epic 2 | 2.2, 2.3 | ✓ Covered |
| FR15 | Auto-discover clips per player per skill via YouTube API | Epic 3 | 3.2 | ✓ Covered |
| FR16 | Seed and maintain player pool from big boards | Epic 2 | 2.1 | ✓ Covered |
| FR17 | Store stats locally; profiles render from cache | Epic 2 | 2.2, 2.3 | ✓ Covered |
| FR18 | Operator: view pipeline status and data staleness | Epic 6 | 6.2 | ✓ Covered |
| FR19 | Operator: view clip verification status per player | Epic 6 | 6.3 | ✓ Covered |
| FR20 | Operator: manually trigger clip re-fetch | Epic 6 | 6.4 | ✓ Covered |
| FR21 | Operator: add/remove player without full re-run | Epic 6 | 6.5 | ✓ Covered |
| FR22 | Distinct, shareable, indexable URLs per profile | Epic 4 | 4.2 | ✓ Covered |
| FR23 | Renders correctly on mobile browsers | Epic 7 | 7.1 | ✓ Covered |
| FR24 | Visible attribution for all open-source data sources | Epic 4 | 4.7 | ✓ Covered |
| FR25 | Video via YouTube IFrame embed only (no download) | Epic 5 | 5.3 | ✓ Covered |
| FR26 | Fully accessible without registration | Epic 1 | 1.2 | ✓ Covered |

### Missing Requirements

**None.** All 26 FRs are accounted for with explicit story-level traceability.

### Coverage Statistics

- Total PRD FRs: 26
- FRs covered in epics: 26
- **Coverage: 100%**

---

---

## UX Alignment Assessment

### UX Document Status

**Not Found** — no dedicated UX design document exists in the planning artifacts.

### Alignment Issues

No misalignments identified. UX requirements are distributed inline across the PRD and epics and are internally consistent:
- All responsive layout requirements (FR23, NFR1, NFR2) are covered in Story 7.1 and component-level ACs (Stories 4.4, 4.5, 5.1)
- Accessibility requirements (NFR7, NFR8) are covered in Story 7.2
- The `<StatUnavailable />` pattern is consistently applied across all data-absent states (Stories 4.3, 4.4, 4.5, 5.2, 7.3)
- YouTube embed size minimums (200×200px) are enforced in both Story 5.3 (compliance) and Story 7.1 (mobile layout)
- Touch target minimums (44×44px) are specified in Story 7.1
- Social share preview (OG tags) is covered in Story 7.5

### Warnings

⚠️ **WARNING: No dedicated UX design document** — This is a user-facing web application with meaningful UI complexity (shot charts, percentile bars, clip tabs, operator dashboard). The inline UX guidance within the PRD and stories is sufficient for v1 solo development but may be limiting if a designer or second developer joins. No blocking issue for implementation readiness at current team size.

✅ Architecture (Next.js 15 App Router, Recharts, Tailwind CSS, `ResponsiveContainer`) directly supports all implied UX requirements. No architectural gaps identified for UX delivery.

---

---

## Epic Quality Review

### Best Practices Compliance Summary

#### 🟠 Major Issues

**Issue 1: Epics 1, 2, and 3 are technical milestone epics, not user-value epics**
- Epic 1's goal explicitly states "No user-facing features yet"
- Epics 2 and 3 deliver pipeline infrastructure with no user-observable value until Epics 4 and 5 render the data
- **Impact:** Violates the "epics deliver user value" principle. A user cannot benefit from Epic 2 alone.
- **Recommendation:** For a solo developer greenfield project, this structure is pragmatically acceptable. However, acknowledge these as technical foundation epics and ensure Epic 1 is treated as a sprint 0 / setup epic rather than measuring its "value" against user-facing criteria. Low risk of actual implementation failure.

**Issue 2: Story 1.3 creates all four database tables upfront**
- `player_clips` (used in Epic 3) and `pipeline_runs` (used in Epic 2, Story 2.4) are defined in Story 1.3 alongside `players` and `player_stats`
- Best practice: each story/epic creates only the tables it needs when it first needs them
- **Impact:** Low risk in practice — a comprehensive upfront schema is common and defensible for a solo developer who has already designed the full data model. However, it does mean the schema must be "correct" before any feature is built.
- **Recommendation:** Acceptable as-is for solo greenfield development. No remediation required unless the team intends to evolve the schema incrementally.

**Issue 3: Story 6.4 architectural incompatibility with Vercel deployment**
- Story 6.4 implements "Operator: manually trigger a clip re-fetch" by having a Next.js Server Action call `pipeline/scripts/refetch_player_clips.py` via a subprocess
- **Critical problem:** Vercel serverless functions do not have a Python runtime available and cannot spawn long-running subprocesses. This implementation approach is incompatible with the declared deployment target (Vercel).
- **Impact:** This story as written cannot be implemented. FR20 (manual clip re-fetch) would be blocked.
- **Recommendation (required):** The re-fetch trigger mechanism must be redesigned. Options:
  1. **GitHub Actions manual trigger via API** — Server Action calls the GitHub REST API to trigger `workflow_dispatch` on the re-fetch workflow. Python stays in GitHub Actions; Next.js makes an HTTP call to GitHub API.
  2. **Separate worker service** — Move the re-fetch to a dedicated worker (e.g., Railway, Render) that exposes an HTTP endpoint for the admin to call.
  3. **Deferred re-fetch** — Admin marks players as "needs re-fetch" in the DB; the nightly GitHub Actions cron job processes the queue. No real-time trigger.
  Option 1 aligns best with the existing ARCH9 (GitHub Actions cron) and requires minimal infrastructure addition.

**Issue 4: NFR security requirements deferred to Epic 7**
- NFR4 ("API credentials not exposed to the client") first becomes relevant in Epic 2 (cbbdata/hoopR API calls) and Epic 3 (YouTube API calls)
- Deferring security hardening confirmation to Story 7.4 creates a window where API key exposure could be inadvertently introduced in Epics 2–3 and not caught until late
- **Impact:** Medium risk — a solo developer aware of the constraint is unlikely to expose keys accidentally, but there's no checkpoint to verify it until Epic 7
- **Recommendation:** Add a security AC to Stories 2.2, 2.3, and 3.2 confirming all API calls are server-side only. Story 7.4 can remain as the consolidated security audit, but the individual stories should enforce it at implementation time.

#### 🟡 Minor Concerns

**Minor 1: Dual FR20/FR21 coverage — CLI scripts in Epic 3, UI in Epic 6**
- Story 3.4 creates `pipeline/scripts/refetch_player_clips.py` and `pipeline/scripts/add_remove_player.py` noted as "FR20 CLI path / FR21 CLI path"
- The FR Coverage Map attributes FR20 and FR21 to Epic 6 (Stories 6.4, 6.5), not Epic 3
- **Impact:** Minor traceability confusion only. Both stories are needed (CLI script + UI trigger). The FR map should ideally note both Epic 3 and Epic 6 for FR20/FR21.
- **Recommendation:** Update FR Coverage Map to reflect: FR20 → Epic 3 (3.4, CLI) + Epic 6 (6.4, UI); FR21 → Epic 3 (3.4, CLI) + Epic 6 (6.5, UI). No story changes needed.

**Minor 2: Epic 7 defers responsive layout verification**
- Responsive layout (Story 7.1) is built as a polish pass over existing components rather than validating responsiveness as components are built in Epics 4–5
- **Impact:** If Epic 7 is skipped or cut, mobile readiness (FR23) may be incomplete despite being individually wired at component level
- **Recommendation:** Ensure each component story in Epics 4–5 includes a mobile viewport AC (most already do). Story 7.1 becomes a verification/polish pass rather than initial implementation.

### Best Practices Compliance Checklist

| Epic | Delivers User Value | Epic Independence | No Forward Dependencies | DB Tables When Needed | Clear ACs | FR Traceability |
|------|--------------------|--------------------|------------------------|----------------------|-----------|-----------------|
| Epic 1 | ⚠️ Technical | ✓ | ✓ | ⚠️ All tables upfront | ✓ | ✓ |
| Epic 2 | ⚠️ Pipeline only | ✓ (needs Epic 1) | ✓ | ✓ | ✓ | ✓ |
| Epic 3 | ⚠️ Pipeline only | ✓ (needs 1-2) | ✓ | ✓ | ✓ | ⚠️ Dual coverage |
| Epic 4 | ✓ | ✓ (needs 1-3) | ✓ | ✓ | ✓ | ✓ |
| Epic 5 | ✓ | ✓ (needs 1-3) | ✓ | ✓ | ✓ | ✓ |
| Epic 6 | ✓ (operator) | ✓ (needs 1-5) | ✓ | ✓ | ✓ ✅ Story 6.4 fixed | ✓ |
| Epic 7 | ✓ | ✓ (needs 1-6) | ✓ | ✓ | ✓ | ✓ |

---

---

## Summary and Recommendations

### Overall Readiness Status

**READY** — The one critical blocker (Story 6.4 subprocess incompatibility) has been resolved. All remaining concerns are advisory.

---

### Critical Issues Requiring Immediate Action

**1. Story 6.4 — Clip Re-Fetch Trigger ✅ RESOLVED**
- Previously: planned to invoke a Python subprocess from a Vercel Server Action (incompatible with Vercel runtime)
- **Fixed:** Story 6.4 rewritten to use GitHub Actions `workflow_dispatch` REST API. Server Action calls `POST /repos/{GITHUB_REPO}/actions/workflows/refetch-player-clips.yml/dispatches` with `player_slug` input. New `refetch-player-clips.yml` workflow defined in story ACs. `GITHUB_PAT` and `GITHUB_REPO` added as required Vercel env vars.

---

### Recommended Next Steps

1. **Fix Story 6.4 now** — Update the acceptance criteria to reflect the GitHub Actions `workflow_dispatch` trigger approach (or chosen alternative). Add GITHUB_TOKEN as an environment variable in the architecture/deployment notes. This is the only blocker.

2. **Add security enforcement ACs to Stories 2.2, 2.3, and 3.2** — Add a single AC to each confirming all external API calls are made server-side (pipeline only, never client bundle). This catches NFR4 violations at the story where they could first be introduced, rather than waiting for the Epic 7 audit.

3. **Clarify FR20/FR21 dual coverage in the FR map** — Update the coverage map to show FR20 and FR21 are addressed in both Epic 3 (CLI scripts) and Epic 6 (admin UI). Minor traceability cleanup only.

4. **Proceed with Epic 1 through Epic 5** — All foundation, pipeline, and display epics are well-specified and ready to implement. The Story 6.4 issue doesn't surface until Epic 6.

---

### Final Note

This assessment identified **5 issues** across **3 categories**:
- 1 critical architectural blocker (Story 6.4)
- 3 major advisories (technical epics, upfront schema, NFR deferral)
- 1 minor traceability concern (FR20/21 dual coverage)

The planning artifacts are otherwise high-quality. The PRD is thorough with 26 clearly numbered FRs and 16 NFRs. Epic coverage is complete at 100%. Story acceptance criteria are specific, testable, and BDD-structured throughout. The single critical issue is resolvable with a focused Story 6.4 rewrite before Epic 6 begins.

**Assessor:** Winston (BMad Architect Agent)
**Date:** 2026-03-30
**Report:** `_bmad-output/planning-artifacts/implementation-readiness-report-2026-03-30.md`

---

### PRD Completeness Assessment

The PRD is thorough and well-structured. Requirements are clearly numbered (FR1–FR26, NFR1–NFR16), scoped, and tied to concrete user journeys. Risk mitigations are explicitly called out. The document is implementation-ready with no ambiguous or missing requirement areas for the v1 scope.
