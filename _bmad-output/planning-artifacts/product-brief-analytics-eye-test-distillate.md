---
title: "Product Brief Distillate: analytics-eye-test"
type: llm-distillate
source: "product-brief-analytics-eye-test.md"
created: "2026-03-29"
purpose: "Token-efficient context for downstream PRD creation"
---

# Product Brief Distillate: Analytics Eye Test

## Product Identity

- Name: Analytics Eye Test
- Type: College basketball scouting and analytics platform, NBA draft-focused
- Stage: Personal project → test with friends → potential monetized product
- Creator doubles as primary user and analyst; platform is also personal scouting infrastructure

## Target Users

- **Primary**: Serious college basketball fans / independent analysts. Know what usage rate means. Currently stitch together BartTorvik + CBB-Reference + YouTube manually. Will share a good tool.
- **Secondary**: Engaged fans leveling up into advanced analytics. Not the design target but will benefit from good UX.
- **Not in scope**: Casual fans, NBA team front offices (enterprise), recruiting-focused audiences

## Core Problem Being Solved

- Analytics tools (KenPom, BartTorvik, EvanMiya) are team-efficiency tools with shallow player data — not built for individual prospect evaluation
- Film tools (Synergy, Hudl) are enterprise-priced and inaccessible to independent analysts
- No platform connects a statistical outcome to the film evidence behind it for a prosumer audience
- Analysts currently context-switch across 5+ tools; no unified player profile exists at the prosumer tier

## Scope: In for v1

- Individual player profile pages for ~150–200 draft-eligible prospects
- Advanced stats: efficiency metrics, usage rate, on/off splits, per-40, shot location data
- Percentile rankings contextualized within the current draft class
- Visualizations: percentile bar charts, shot charts, trend graphs
- YouTube clip integration by skill category (automated, best-effort)
- Player pool auto-seeded from public consensus big boards
- No user accounts required; fully public
- Player comparison (secondary feature, lower priority than profiles)

## Scope: Explicitly Out for v1

- User accounts, saved lists, annotations — rejected; adds friction with no v1 benefit
- Paywall / premium tier — not until product has proven value
- Mobile app — out of scope for v1
- Historical draft class archives — out of scope for v1
- Transfer portal / recruiting profiles (high school) — out of v1 but near-term roadmap item
- Option B film integration (fully synced analytics-to-clip, dynamic filtering) — rejected as too technically complex; replaced by Option A (pre-tagged curated clips)

## Near-Term Roadmap (Post-v1)

- Transfer portal tracker: same architecture, expand player pool from "consensus draft prospects" to all D1 players worth monitoring; no new infrastructure needed

## Data Strategy

### Approved Sources (open, defensible)
- **cbbdata API** (aweatherman.com) — Flask-based API, 26 functions, game logs, advanced metrics, box scores back to 2008. Free API key. No SLA (individual developer). Best current option for player-level advanced stats.
- **hoopR (R package / sportsdataverse)** — wraps ESPN PBP endpoints including shot locations. Unofficial ESPN endpoints; stable but could break without notice. MIT license.
- **CBBpy (Python)** — NCAA.com-based PBP and box scores. Open source.
- **NCAA Stats Portal (stats.ncaa.org)** — official source, no explicit ToS restriction on programmatic access, community wrappers exist
- **All sources require attribution** — goodwill and credibility concern, not just legal

### Rejected Data Sources (with rationale)
- **Sports-Reference / CBB-Reference** — ToS explicitly prohibits building a competing database from scraped data. Use for reference only; not for bulk ingestion powering a public product.
- **KenPom** — ~$20/year individual subscription; no API; scraping for a commercial product violates ToS. Cannot use as a data backend.
- **BartTorvik / EvanMiya** — No published ToS but one-person operations; bulk scraping to power a competing product is ethically murky and risks being blocked. Use for reference/inspiration only.
- **Sportradar NCAAMB API** — $500–$2K+/month developer tier; enterprise for Synergy integration ($15K–$50K+/year). Viable only if product monetizes.
- **ShotQuality API** — Commercial partnership required; pricing not public, likely $1K+/month. Worth revisiting if product grows.

### Player Pool Sourcing
- Seed from consensus public big boards: ESPN, The Athletic, Crafted NBA (aggregates multiple sources)
- ~150–200 players per year is the target scope
- Manual curation rejected (too time-intensive for creator); automated sync preferred

## Video Strategy

### Approved Approach
- **YouTube Data API v3** — free, well-documented; search by player name + skill keyword, retrieve metadata, embed via IFrame Player API
- Embed only — never download or self-host video (YouTube ToS)
- Minimum embed size: 200x200px per YouTube policy
- Clip-to-skill mapping approach: search `"[Player Name] [skill category]"` (e.g., "finishing at the rim", "off-dribble threes", "pick and roll") per player per category; surface top results
- **This mapping is a v1 hypothesis to validate** — clip accuracy is not guaranteed; some players will have zero quality clips
- Profiles must degrade gracefully when clips are unavailable (no broken UI states)

### Key Video Risk
- **Content-ID**: NCAA and conference rights holders actively enforce Content-ID on YouTube. Clips can be removed, muted, or geo-blocked at any time with no warning. This is the platform's single largest reliability risk for the video layer. Design must assume clips are ephemeral.

### Rejected Video Sources
- **Hudl** — requires team cooperation + enterprise partnership; no public API access for third parties. Not viable.
- **Synergy (via Sportradar)** — enterprise only; pre-tagged clip data would be ideal but inaccessible at personal project budget.
- **ESPN / CBS / ABC** — full-game broadcasts behind paywalls; no programmatic video access.
- **Self-hosted video** — requires rights; not viable without licensing.

## Competitive Landscape (Key Context)

| Tool | What it does | Gap |
|---|---|---|
| KenPom | Team efficiency ratings, limited player stats | Team-focused, no player profiles, no film |
| BartTorvik | Free KenPom alternative, better player filtering | No shot quality, no film, no draft framing |
| EvanMiya | BPR player impact metric, lineup data | Analytics-only, no video, no draft framing |
| ShotQuality | Computer vision shot quality scores, NCAA coverage | Data-only, no video, betting-oriented |
| Synergy (Sportradar) | Pre-tagged video + play-type data, gold standard | Enterprise-only, $15K–$50K+/year |
| The Ringer Draft Guide | Editorial draft content, Comp Cloud visualization | No underlying data, editorial-first |
| Crafted NBA | Aggregates metrics from multiple sources, big board | No original data, no video |
| CBB-Reference | Most complete historical stats database | ToS restricts commercial scraping |

**Core whitespace**: No platform combines per-possession analytics + shot quality + skill-linked video for draft-eligible college players at a prosumer price point (free).

## UX / Design Signals

- Advanced metrics should NOT be watered down — present BPR, TS%, on/off differential, shot quality without apology
- Design makes metrics legible, not safe — good labeling and context, not dumbed-down simplification
- Player card pattern is the industry-standard UX (stat summary, percentile viz, peer comparisons, narrative) — expected by target audience
- Radar/spider charts and horizontal percentile bars are the standard visualization pattern (see FBref for reference)
- Comparison feature: side-by-side, secondary priority to individual profiles
- No login friction — fully public, no accounts

## Technical Context Captured

- Creator is comfortable with an automated pipeline (not manual curation) for both player pool and video
- Open-source data stack (cbbdata, hoopR, NCAA) is acceptable for v1 knowing there's no SLA guarantee
- YouTube "best effort" model is accepted — reliability is a known constraint, not a blocker
- No preference stated for frontend framework or tech stack — not yet discussed
- Platform starts as web; mobile is out of scope for v1

## Open Questions (Not Resolved in Brief)

- Which specific big boards to use as authoritative sources for the player pool, and how to handle disagreements between boards
- Whether cbbdata API will provide sufficient shot location data or if hoopR/ESPN PBP is needed to supplement
- How to handle in-season data freshness (cbbdata updates — frequency? reliability during season?)
- Exact skill categories to use for YouTube search tagging (needs a defined taxonomy before building the video pipeline)
- Whether player comparison is in v1 or post-v1 (brief says secondary/on the radar; needs a decision)
- Long-term: if product grows, which licensed data source to upgrade to first (ShotQuality API vs. Sportradar NCAAMB)
