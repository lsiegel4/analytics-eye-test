---
title: "Product Brief: Analytics Eye Test"
status: "complete"
created: "2026-03-29"
updated: "2026-03-29"
version: "1.1 - post-review"
inputs: ["user discovery conversation", "web research: competitive landscape, data sources, video APIs"]
---

# Product Brief: Analytics Eye Test

## Executive Summary

Every year, the NBA Draft forces evaluators to answer an impossible question with incomplete tools. The analysts who trust the numbers open KenPom in one tab, BartTorvik in another, and Synergy in a third — stitching together a picture of a player that no single platform provides. The scouts who trust their eyes watch film in isolation, disconnected from the data that would tell them whether what they're seeing is a pattern or a fluke. Neither camp is wrong. Both are working harder than they should.

Analytics Eye Test is a college basketball scouting platform that unifies these two workflows into a single player profile. For each of the ~150–200 draft-eligible prospects tracked each season, the platform surfaces advanced analytical profiles alongside curated video clips organized by skill category — so when the data says a player finishes exceptionally well at the rim, you can immediately watch him do it. No tab-switching. No hunting for clips. One page, two lenses, one complete picture.

Built for serious college basketball fans and analysts who are tired of choosing between depth and convenience, Analytics Eye Test starts as a lean, free-to-use tool and grows toward a brand and platform that bridges the gap the industry has left open.

## The Problem

The college basketball draft evaluation ecosystem is fragmented by design. Advanced analytics live on team-efficiency sites (KenPom, BartTorvik, EvanMiya) that were built for game prediction, not player profiling. Play-type and film data live behind enterprise paywalls (Synergy, Hudl) priced for NBA front offices, not independent analysts or serious fans. The result: anyone who wants to evaluate a prospect holistically is either paying thousands of dollars for institutional tools, or manually reconciling five different sources with no common vocabulary.

The problem is compounded at the film layer. There is no consumer-grade tool that says: "This player's assist-to-turnover ratio in pick-and-roll situations is elite — here are the clips that show you why." That connection — between a measurable outcome and the film evidence behind it — exists only in the workflows of analysts who have built it themselves, painstakingly, over years.

The 100–200 players who enter serious draft consideration each year are well-documented in aggregate, but no one has built a focused, prospect-oriented platform that treats their individual profiles as the primary unit of analysis.

## The Solution

Analytics Eye Test provides individual player profile pages for draft-eligible college basketball prospects. Each profile includes:

- **Advanced statistical profile** — efficiency metrics, usage rate, on/off splits, per-40 stats, shot location data, and percentile rankings contextualized within the draft class
- **Visual performance layer** — percentile bar charts, shot charts, and trend graphs that make multi-dimensional evaluation scannable
- **Skill-linked video** — YouTube clips organized by skill category (e.g., finishing at the rim, off-dribble threes, pick-and-roll creation, defensive positioning), surfaced programmatically via the YouTube Data API and linked to the corresponding analytical tags on the profile. In v1, the accuracy of clip-to-skill mapping is a hypothesis to validate — clip availability is best-effort given YouTube Content-ID enforcement by rights holders. Profiles degrade gracefully when clips are unavailable.
- **Player comparison** — a secondary feature allowing side-by-side analytical comparison between two prospects

The player pool is seeded from consensus public draft big boards (e.g., ESPN, The Athletic, Crafted NBA) to ensure the platform tracks who the community is already evaluating without manual curation overhead. Data is sourced from open community APIs (cbbdata, hoopR, NCAA stats portal) with appropriate attribution, and video is embedded — never downloaded or self-hosted — in compliance with YouTube's Terms of Service.

## What Makes This Different

**The connection, not just the data.** Every serious analytics site has the numbers. What none of them have is the direct path from a stat to the film that explains it. Analytics Eye Test treats that connection as the core product, not an afterthought.

**Draft-first framing.** KenPom and BartTorvik are team efficiency tools that happen to have player data. Analytics Eye Test is built around individual prospects and the questions draft evaluators actually ask: How does he perform under pressure? What's his shot creation profile? Does the film match the efficiency line?

**Prosumer accessibility without dumbing it down.** Advanced metrics — BPR, TS%, on/off differential, shot quality — are presented without apology. The design makes them legible, not safe. Users who want depth get it; those learning grow into it.

**No paywall friction at launch.** The platform is free and requires no account, lowering the barrier for a community of serious fans who are currently underserved by both the analytics sites (which are team-focused) and the draft editorial sites (which are stats-light).

## Who This Serves

**Primary: The Serious Draft Fan / Independent Analyst**
This person watches college basketball intentionally. They know what usage rate means, they have opinions about which metrics actually predict NBA success, and they currently use a combination of BartTorvik, CBB-Reference, and YouTube to build their own mental models. They would love a single place that does what they're doing manually — and they'd share it.

**Secondary: The Curious Fan Leveling Up**
Engaged college basketball fans who follow recruiting and the draft conversation but haven't yet crossed into advanced analytics. Analytics Eye Test is accessible enough to bring them in, deep enough to keep them.

## Success Criteria

**v1 (Personal / Friend Group)**
- Platform is live and stable with profiles for the current draft class
- Friends engage with it regularly and provide qualitative feedback
- Video clips are surfacing correctly for a meaningful percentage of tracked players
- Creator is using it as a personal scouting/analysis workflow tool

**Growth Phase**
- Social media content sourced from platform insights gains traction
- Organic traffic grows without paid promotion
- Return visits indicate the platform is becoming part of users' evaluation workflow

**Longer-Term**
- Platform is recognized as a credible brand in the college basketball analytics community
- Monetization is viable via a premium tier for deeper insights, historical data, or custom comparisons

## Scope

**In for v1:**
- Individual player profile pages (~150–200 draft prospects)
- Advanced stat display with percentile context (BartTorvik / cbbdata / open-source data stack)
- Shot charts and key visualizations
- YouTube clip integration by skill category (automated via YouTube Data API)
- Auto-synced player pool from public big boards
- No user accounts required; fully public

**Out for v1:**
- User accounts, saved lists, or annotations
- Paywall / premium tier
- Mobile app
- Historical draft class archives
- Recruiting profiles (high school / transfer portal)

## Roadmap Thinking

**Near-term after v1:** Transfer portal and broader player tracking. The MVP architecture naturally extends from "consensus draft prospects" to "all D1 players worth monitoring" — the player pool simply expands, the same profile infrastructure applies. This unlocks transfer portal analysis, early-entry tracking, and multi-year development arcs, which are high-interest topics for the same audience.

**In 2–3 years:** Analytics Eye Test is a recognized brand in the college basketball draft space. The platform powers social media analysis, builds an audience that trusts the methodology, and earns credibility through consistent, rigorous output. When monetization makes sense, a premium tier unlocks deeper historical comparisons, model-driven projections, and advanced filtering tools for the subset of users — agents, media, smaller front offices — who want more than the free tier provides. The brand is the moat: the platform succeeds not because it out-features Synergy, but because it earns trust with an audience that enterprise tools have never bothered to serve.
