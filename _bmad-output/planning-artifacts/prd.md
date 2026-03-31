---
stepsCompleted: ["step-01-init", "step-02-discovery", "step-02b-vision", "step-02c-executive-summary", "step-03-success", "step-04-journeys", "step-05-domain", "step-06-innovation", "step-07-project-type", "step-08-scoping", "step-09-functional", "step-10-nonfunctional", "step-11-polish"]
inputDocuments:
  - "_bmad-output/planning-artifacts/product-brief-analytics-eye-test.md"
  - "_bmad-output/planning-artifacts/product-brief-analytics-eye-test-distillate.md"
workflowType: 'prd'
briefCount: 2
researchCount: 0
brainstormingCount: 0
projectDocsCount: 0
classification:
  projectType: web_app
  domain: general
  complexity: medium
  projectContext: greenfield
---

# Product Requirements Document - analytics-eye-test

**Author:** Lucas
**Date:** 2026-03-29

## Executive Summary

Analytics Eye Test is a college basketball scouting platform for NBA draft-eligible prospects, built for serious fans and independent analysts who currently piece together evaluation workflows across five or more disconnected tools. The platform provides individual player profile pages — advanced statistical profiles paired with curated YouTube clips organized by skill category — so that when the data says a player is an elite rim finisher, users can immediately watch him do it. The core bet: programmatic clip discovery via the YouTube Data API is *good enough* to be transformative for a prosumer audience that currently has nothing comparable at any price.

The platform tracks ~150–200 draft-eligible college basketball prospects per season. Player pool is auto-seeded from consensus public big boards (ESPN, The Athletic, Crafted NBA). No user accounts required; fully public and free at launch.

### What Makes This Special

Every analytics tool in this space has the numbers. None have the direct path from a stat to the film that explains it. That connection — between a measurable outcome and the evidence behind it — is the product. The differentiation moment is tactile: a user sees a percentile ranking, clicks a clip, and watches the player do the exact thing the number describes. That confirmation loop doesn't exist for prosumer analysts at any accessible price point today.

The barrier to building this wasn't demand — it was accessibility. Manually tagging film for 150 prospects is prohibitive for a solo developer. The YouTube Data API makes programmatic clip surfacing viable, if imperfect. Clip accuracy is a v1 hypothesis to validate, not a guarantee; the platform degrades gracefully when clips are unavailable. Best-effort clip discovery, free and unified with analytics, is more useful than the current fragmented state.

Advanced analytics have entered mainstream draft discourse. A growing public audience is actively engaged in evaluation conversations and frustrated by tool fragmentation. This is the window.

## Project Classification

- **Project Type:** Web application (consumer-facing, browser-based, no mobile in v1)
- **Domain:** Sports analytics / general (no regulated domain requirements)
- **Complexity:** Medium — data pipeline complexity (multi-source ingestion, third-party API dependencies, automated player pool sync, data freshness), plus video reliability risk from Content-ID enforcement
- **Project Context:** Greenfield

## Success Criteria

### User Success

- Users can navigate from a player's statistical profile to a relevant, playable video clip in a single interaction — the core stat-to-film loop works end-to-end
- Clips meet a dual bar: relevant to the labeled skill category *and* illustrative of that player's tendencies at that skill (not just any clip showing the skill)
- Users who currently use BartTorvik + YouTube manually find the unified profile faster and more useful than their existing workflow
- Qualitative feedback from v1 friend group indicates the platform is being used organically as part of their evaluation process — not just opened once and abandoned

### Business Success

- **v1:** Platform live and stable for the current draft class; creator using it as a primary personal scouting tool; 5–10 engaged friend/peer users providing qualitative feedback
- **Growth:** Organic inbound from a credible source (draft analyst, Substack writer, or social post generating unsolicited traffic); return visit rate indicates habitual use during draft season
- **Longer-term:** Platform recognized as a credible brand in the college basketball analytics community; monetization via premium tier viable when the free tier has demonstrated sustained value

### Technical Success

- **Video layer:** All embedded clips verified playable at page load; broken or removed clips surface a clean fallback state ("clip unavailable") — no silent degradation
- **Data layer:** Player statistics no more than 7 days stale during the active season; data freshness surfaced on profiles so users can assess recency
- **System reliability:** Platform available and responsive during peak draft-season usage

### Measurable Outcomes

- v1 clip accuracy: majority of profiles in the initial player cohort have at least one clip per labeled skill category meeting the dual bar; manual spot-check at launch
- v1 player cohort: top 30–50 consensus prospects with verified clip quality, not 150 players with unreliable coverage
- Data pipeline: automated refresh cadence keeps stats within the 7-day staleness threshold during the season

## Product Scope

### MVP Strategy & Philosophy

**MVP Approach:** Validation MVP — ship the minimum needed to test whether the stat-to-film confirmation loop is genuinely useful to the target audience. Success is not scale; it's the friend group using this organically instead of opening five tabs.

**Resource Requirements:** Solo developer. Personal project budget. No external dependencies on team size or investor timeline.

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
- Primary analyst (success path): stat → percentile visualization → skill-category clips → evaluation decision
- Primary analyst (edge case): graceful degradation when clips unavailable or data stale
- Share-and-discover visitor: lands on a profile via social link, finds it legible without onboarding
- Creator/operator: monitor pipeline health, manage player pool, spot-check clip quality

**Must-Have Capabilities:**
- Individual player profile pages for top 30–50 consensus draft prospects (seeded from public big boards)
- Advanced statistical profile: efficiency metrics, usage rate, on/off splits, per-40 stats, shot location data
- Percentile rankings contextualized within the current draft class
- Visualizations: percentile bar charts, shot charts
- YouTube clip integration by skill category (automated via YouTube Data API, best-effort, verified playable at load, graceful fallback on unavailability)
- Data freshness indicator on profiles (last updated timestamp)
- Player index / home page with navigation
- Responsive layout (mobile-readable, not mobile-optimized)
- Data attribution for all open-source sources (cbbdata, hoopR, CBBpy, NCAA)
- Operator tooling: pipeline status view, manual clip re-fetch, player pool add/remove

**Explicitly Out of MVP:**
- Player comparison (post-v1)
- User accounts, saved lists, annotations
- Paywall / premium tier
- Mobile app
- Historical draft class archives
- Transfer portal / recruiting profiles
- Trend graphs (beyond percentile bars and shot charts)
- Full SEO optimization
- Full accessibility audit

### Phase 2 — Growth

- Expand player pool to full ~150–200 consensus draft prospects
- Player comparison: side-by-side analytical view between two prospects
- Trend graphs and additional visualizations
- SEO optimization pass
- WCAG AA accessibility audit and remediation

### Phase 3 — Expansion

- Transfer portal tracker: same profile infrastructure, expanded to all D1 players worth monitoring
- Historical draft class archives
- Premium tier: deeper comparisons, model-driven projections, advanced filtering
- Licensed data upgrade (ShotQuality API or Sportradar) if monetization justifies cost

### Risk Mitigation

**Technical:** YouTube clip quality is the single highest-risk v1 assumption. Mitigated by depth-first approach — 30–50 players with manual spot-check before launch. Clip accuracy validated against dual bar before sharing broadly.

**Market:** Target audience doesn't change their tab-switching workflow. Mitigated by starting with an existing audience who already trusts the creator's judgment.

**Resource:** Solo developer scope creep, particularly around operator tooling. Mitigated by keeping admin surface minimal: pipeline status + manual clip re-fetch + player pool management only. No CMS, no complex dashboard.

## User Journeys

### Journey 1: Marcus — The Independent Draft Analyst (Primary User, Success Path)

Marcus has been building his own mock draft board since February. It's mid-March, and he's trying to decide where he stands on a prospect everyone's debating — an efficient-but-undersized guard who posts elite efficiency numbers but gets flagged by scouts for shot-creation concerns.

He opens Analytics Eye Test and pulls up the player's profile. The percentile bars load instantly: 94th percentile in true shooting, 71st in usage, 38th in pull-up frequency. The numbers match what he's been hearing — high efficiency in catch-and-shoot situations, limited off-the-dribble creation. He clicks the "off-dribble shooting" clip category. Three clips load. He watches two of them. The first confirms what the numbers suggest — he's hunting spot-up looks. The second surprises him: a pull-up three in transition that shows real handle. He updates his board notes.

He didn't open BartTorvik. He didn't search YouTube. He got the answer in four minutes.

**Capabilities revealed:** Player profile page, percentile bar visualizations, skill-category clip display, verified playable embeds, graceful fallback, per-40 and shot location stats.

---

### Journey 2: Marcus — Edge Case (Clip Unavailability + Data Staleness)

Same analyst, two weeks later. He's checking a prospect who plays in a smaller conference with less YouTube coverage. The stats are solid but the clip section shows "No clips available" for three of five skill categories. The data freshness indicator shows stats last updated 9 days ago — outside the normal window.

He doesn't see a broken page. He sees a clean "unavailable" state with a note that clips may be limited for this player and a timestamp showing when stats were last refreshed. He knows the limitations and adjusts his confidence accordingly. He doesn't lose trust in the platform — he appreciates that it's honest about what it doesn't know.

**Capabilities revealed:** Graceful clip fallback UI, data freshness display on profiles, "unavailable" state that maintains platform credibility.

---

### Journey 3: Creator/Operator — Pipeline Monitoring and Player Pool Management

It's the week before the draft combine. The platform needs to be verified — player pool current, stats fresh, clip coverage holding for the top prospects.

An operator view shows pipeline status: last data refresh timestamp, number of players with stale data (>7 days), and clip verification status per player. Two players have no valid clips in any category — both recently added from an updated big board. A manual clip re-fetch is triggered for those players and confirmed before going live. One player addition is made without a full pipeline re-run.

**Note:** The operational loop — monitor freshness, spot-check clips, manage player pool — repeats throughout draft season. Without purpose-built tooling, it becomes a manual, error-prone process that undermines platform credibility at the worst times.

**Capabilities revealed:** Operator pipeline status view, data refresh monitoring, manual clip re-fetch trigger, player pool management (add/remove), clip verification tooling.

---

### Journey 4: Priya — The Share-and-Discover Visitor

Priya follows college basketball casually and saw a tweet from an analyst she respects linking to a prospect profile with the caption "this is what I've been waiting for." She clicks the link on her phone.

The profile loads. She doesn't know what BPR means, but the percentile bars make it immediately legible — this player is in the top 10% of the draft class at finishing at the rim. She scrolls to the clip section, taps a video, watches 30 seconds. She gets it. She bookmarks the page, navigates to the home page, and spends 12 minutes looking at three more profiles.

She doesn't become a power user today — but she comes back during draft week. The platform was legible enough on first contact that she didn't need to understand the methodology to find it valuable.

**Capabilities revealed:** Mobile-readable profile layout (responsive web, not a mobile app), legible percentile visualizations for non-expert users, player index / home page with navigation, no-account-required entry.

---

### Journey Requirements Summary

| Capability Area | Driven By |
|---|---|
| Player profile page with stats + percentile bars | Journeys 1, 2, 4 |
| Skill-category clip display with verified playable embeds | Journey 1 |
| Graceful clip fallback ("unavailable" state) | Journey 2 |
| Data freshness indicator on profiles | Journey 2 |
| Player index / home page navigation | Journey 4 |
| Responsive web layout (mobile-readable) | Journey 4 |
| Operator pipeline status view | Journey 3 |
| Manual clip re-fetch + player pool management | Journey 3 |

## Domain-Specific Requirements

### Terms of Service & Data Rights

**YouTube / Video Layer**
- Embed only — never download or self-host video (YouTube ToS §6)
- Minimum embed size: 200×200px (YouTube IFrame Player API policy)
- Content-ID enforcement makes all embeds potentially ephemeral without advance notice; platform must treat clip availability as non-guaranteed at all times
- No programmatic playback manipulation violating the IFrame Player API terms
- YouTube branding must not be suppressed in the embedded player

**Data Source Constraints**
- cbbdata, hoopR, CBBpy, NCAA Stats Portal — require visible attribution; treat as a credibility and goodwill requirement, not just legal obligation
- Sports-Reference / CBB-Reference — ToS explicitly prohibits building a competing database from scraped data; must not be used as a bulk data backend
- KenPom, BartTorvik, EvanMiya — no published ToS but one-person operations; bulk scraping to power a competing product is ethically off-limits; reference/inspiration only, never data pipeline sources
- Sportradar / ShotQuality — commercial licensing required at costs not viable for personal project; revisit if product monetizes
- All approved open-source data sources (cbbdata, hoopR, CBBpy, NCAA) require visible attribution surfaced on player profiles and/or a dedicated data sources page

### Privacy

- No user accounts, no PII collected in v1 — minimal privacy surface
- Server logs and analytics tooling must be reviewed to confirm no inadvertent PII capture
- Data collected (server logs, page analytics) must be explicitly documented as the product grows

## Innovation & Novel Patterns

### Detected Innovation Areas

**The Stat-to-Film Confirmation Loop**
The core innovation is an interaction pattern, not a technology: the direct, in-product path from a statistical outcome to the video evidence behind it. This connection exists in enterprise tools (Synergy) and in the manual workflows of experienced analysts — but has never been built for a prosumer audience at any accessible price point. Analytics Eye Test treats this connection as the primary product, not a secondary feature.

**Programmatic Skill-Category Clip Discovery**
Using the YouTube Data API to automatically surface skill-specific clips per player — `"[Player Name] [skill category]"` search queries mapped to statistical tags — is a novel application for basketball scouting. Content-ID enforcement and search result quality are real constraints, but automated clip discovery at this tier has not been deployed for draft evaluation before. The v1 hypothesis: imperfect automated clips are more useful than the current state of nothing.

**Draft-First Player Profile Framing**
Existing analytics platforms (KenPom, BartTorvik, EvanMiya) are team efficiency tools with player data as a secondary feature. Analytics Eye Test is built around the individual prospect as the primary unit of analysis — percentile rankings contextualized within the current draft class, skill-category organization, direct comparison capability. Novel at the free tier.

### Market Context & Competitive Landscape

No free, public tool currently combines per-possession analytics, shot location data, and skill-linked video for draft-eligible college players:
- Analytics tools are team-focused and film-free
- Film tools (Synergy) are enterprise-gated at $15K–$50K+/year
- Editorial draft content (The Ringer, Crafted NBA) is analytics-light
- The prosumer audience is actively underserved and growing

### Validation Approach

- **v1 clip hypothesis:** Manual spot-check at launch — do YouTube search queries surface clips meeting the dual bar? Validate across the initial 30–50 player cohort before sharing broadly
- **Core loop validation:** Do v1 users navigate from a stat to a clip and back? Qualitative feedback from the friend group confirms whether the confirmation loop is being used as intended
- **Differentiation validation:** Does the friend group stop opening BartTorvik separately? That's the signal the integration is working

### Innovation Risk Mitigation

| Risk | Mitigation |
|---|---|
| YouTube Content-ID removes clips post-launch | Verified-playable check at page load; graceful "unavailable" fallback; no silent failures |
| Search query approach surfaces irrelevant clips | Manual spot-check pre-launch; dual-bar clip standard documented for future curation |
| YouTube Data API quota limits constrain scale | Monitor quota usage; batch re-fetch operations during off-peak hours; rate-limit player pool expansion |
| Open data source APIs (cbbdata, hoopR) break without notice | No SLA guarantees documented; data freshness indicator surfaces staleness; fallback to last-known-good data |

## Web Application Specific Requirements

### Architecture

Analytics Eye Test is a multi-page application (MPA) — one URL per player profile, a home/index page, and supporting pages (data sources, about). MPA architecture keeps implementation straightforward, enables server-side rendering for SEO, and makes each profile a shareable, indexable URL. No SPA framework complexity needed for v1.

### Browser Matrix

- Target: modern evergreen browsers (Chrome, Firefox, Safari, Edge — last 2 major versions)
- No IE11 or legacy browser support required
- Mobile browsers in scope for responsive layout — the share-and-discover user lands on mobile

### Responsive Design

- All player profile pages must be mobile-readable — responsive layout required
- Percentile bar charts and shot charts must scale gracefully on small screens
- Embedded YouTube clips must respect minimum embed size (200×200px) at all viewport sizes
- Graceful degradation on small screens acceptable; pixel-perfect mobile optimization is not a v1 priority

### SEO

- MPA architecture provides native SEO benefits — each player profile is a distinct, indexable URL
- Page titles and meta descriptions should be player-specific (e.g., "Cooper Flagg — 2025 NBA Draft Analytics Profile | Analytics Eye Test")
- Good SEO is desirable but not a v1 priority — no dedicated SEO optimization work planned until growth phase
- Structured data / schema markup: out of scope for v1

### Implementation Considerations

- No user authentication in v1 — fully public, stateless from the user's perspective
- Data pipeline runs server-side on a scheduled cadence; player profiles render from stored/cached data, not live API calls at page load
- YouTube clip embeds are the only required third-party client-side script dependency; keep client-side JS footprint minimal
- Shot charts and percentile visualizations require a charting library — must support responsive rendering and accessible labeling (see NFRs for accessibility requirements)

## Functional Requirements

### Player Discovery & Navigation

- **FR1:** Users can browse a complete index of all tracked draft prospects
- **FR2:** Users can navigate directly to an individual player's profile via a unique, shareable URL
- **FR3:** Users can access a dedicated page listing all data sources and their attribution

### Player Profile

- **FR4:** Users can view a player's advanced statistical profile (efficiency metrics, usage rate, on/off splits, per-40 stats, shot location data)
- **FR5:** Users can view a player's percentile rankings contextualized within the current draft class
- **FR6:** Users can view percentile rankings as visual bar charts
- **FR7:** Users can view a shot chart showing a player's shot location distribution
- **FR8:** Users can view the timestamp of when a player's statistics were last refreshed

### Video Integration

- **FR9:** Users can view video clips for a player organized by skill category
- **FR10:** Users can play embedded video clips directly within the player profile without navigating away
- **FR11:** Users see a clean "unavailable" indicator when no clips exist for a skill category — no broken embeds, no empty UI states
- **FR12:** The system verifies clip playability at page load and surfaces only playable embeds to users
- **FR13:** The system organizes clips under a defined skill category taxonomy that maps to basketball evaluation dimensions (e.g., rim finishing, off-dribble shooting, pick-and-roll creation, defensive positioning)

### Data Pipeline

- **FR14:** The system automatically refreshes player statistics from open-source data sources on a scheduled cadence
- **FR15:** The system automatically discovers and indexes video clips per player per skill category via the YouTube Data API
- **FR16:** The system seeds and maintains the tracked player pool from consensus public big boards
- **FR17:** The system stores player statistics locally so profiles render from cached data, not live upstream API calls at page load

### Operator Tools

- **FR18:** The operator can view current pipeline status including last refresh timestamp and per-player data staleness
- **FR19:** The operator can view clip verification status per player, showing which skill categories have verified playable clips
- **FR20:** The operator can manually trigger a clip re-fetch for one or more specific players
- **FR21:** The operator can add a player to or remove a player from the tracked prospect pool without triggering a full pipeline re-run

### Platform & Compliance

- **FR22:** All player profile pages are accessible at distinct, shareable, indexable URLs
- **FR23:** The platform renders correctly on mobile browsers without a native app
- **FR24:** The platform displays attribution for all open-source data sources (cbbdata, hoopR, CBBpy, NCAA) visibly within the product
- **FR25:** All video content is delivered via YouTube IFrame Player API embed — no downloading or self-hosting
- **FR26:** The platform is fully accessible without user registration or authentication

## Non-Functional Requirements

### Performance

- Profile pages must render the statistical profile and visualizations (percentile bars, shot chart) without perceptible delay on a standard broadband connection — Core Web Vitals targets to be defined post-v1 if organic growth warrants optimization
- Video clips must load lazily — clip embeds must not block or delay rendering of the statistical profile above the fold
- Profiles render from locally cached data; no live upstream API calls at page load time

### Security

- YouTube Data API key and all third-party API credentials must not be exposed to the client — all external API calls made server-side
- HTTPS required for all traffic
- No PII collected or stored in v1; server logs must be reviewed to confirm no inadvertent PII capture

### Accessibility

- Soft commitment to WCAG 2.1 AA compliance
- Percentile bar charts must provide accessible text alternatives (not visual-only)
- Color contrast for text and UI elements meets AA standards
- Keyboard navigation functional for core user flows
- Full accessibility audit deferred to post-v1

### Integration Reliability

- The platform degrades gracefully when any upstream dependency is unavailable — a data source outage or YouTube API failure must not cause profile pages to error or render broken states
- Player statistics are no more than 7 days stale during the active season; the data freshness timestamp on profiles allows users to assess recency
- YouTube Data API quota usage must be monitored; bulk re-fetch operations should be batched to avoid quota exhaustion
- All YouTube embeds are verified playable at page load; unplayable clips are replaced with a clean fallback state before the page is served

### Availability

- No formal SLA for v1, but the platform must be reliably available during peak draft-season usage (combine week, draft week)
- The data pipeline and web application are independently deployable — a pipeline failure must not take down the public-facing site
