---
name: trl-conversion-engineer
description: >
  Strategic coordinator for building a passive income portfolio across three
  complementary digital product streams: AI Templates, Content Publishing, and
  Print on Demand. Use this skill when the user wants to plan a multi-stream
  income strategy, understand how different revenue streams work together,
  decide which stream to prioritize, plan a portfolio rollout sequence,
  understand cross-promotion synergies, set up weekly cadences for multiple
  streams, or review portfolio performance — even if they don't use the word
  "conversion." Also trigger when users mention passive income systems,
  digital product portfolios, or ask about combining templates with content
  or merchandise.
---

# Conversion Engineer

Strategic coordinator for building and managing a multi-stream passive income portfolio.

## Overview

This skill orchestrates three independent income streams into a coherent portfolio strategy. Each stream has its own dedicated skill for execution — this coordinator handles **selection, sequencing, synergies, and portfolio-level decisions**.

> For choosing your first stream, see **trl-monetization-strategy** (`references/assessment.md`). This skill assumes you've already decided to build and want to plan execution.

**Core Purpose:**
- Coordinate across AI Templates, Content Publishing, and Print on Demand
- Sequence stream launches for maximum synergy
- Plan weekly cadences that balance multiple streams
- Track portfolio-level performance and rebalancing
- Identify cross-promotion opportunities

## Three Income Streams

### 1. AI Templates
Generate and monetize prompt libraries, automation workflows, and developer tools.

| Attribute | Value |
|---|---|
| Revenue model | $27-497 per sale (one-time or subscription) |
| Time to revenue | 2-4 weeks |
| Effort | 4-6 hrs/week |
| Y1 ceiling (top quartile) | $5,000/month |
| Best for | Technical expertise, prompt engineering, automation |

> For execution details, see **trl-ai-templates** (`SKILL.md` for overview, `references/templates-reference.md` for launch frameworks).

### 2. Content Publishing
Build authority and recurring revenue through technical writing, newsletters, and courses.

| Attribute | Value |
|---|---|
| Revenue model | Subscriptions ($5-50/month) + sponsorships |
| Time to revenue | 2-3 months (list building), 4-6 months (paid tier) |
| Effort | 3-4 hrs/week (ongoing) |
| Y1 ceiling (top quartile) | $2,500/month |
| Best for | Writing ability, teaching, authority building |

> For execution details, see **trl-content-publishing** (`SKILL.md` for overview, `references/content-calendar.md` for planning).

### 3. Print on Demand
Design and sell niche merchandise through print fulfillment partners.

| Attribute | Value |
|---|---|
| Revenue model | $5-15 margin per item |
| Time to revenue | 2-6 weeks |
| Effort | 2-3 hrs/week (design batches) |
| Y1 ceiling (top quartile) | $1,000/month |
| Best for | Creative/design skills, niche audience understanding |

> For execution details, see **trl-print-on-demand** (`SKILL.md` for overview, `references/prompt-library.md` for AI image generation).

## Stream Synergies

```
Templates → generate content topics → drive POD audience
Content   → promote templates → build authority → grow email list
POD       → strengthen community → reinforce brand → grow email list
```

**Key insight:** The streams compound. Template customers become content subscribers. Content readers discover templates. POD builds community identity that feeds both.

## Revenue Projections (Year 1 Optimistic Scenario)

> **Important:** These projections represent a top-quartile outcome -- a motivated creator who executes consistently, finds product-market fit relatively quickly, and faces no major setbacks. Median outcomes are significantly lower. Many creators earn $0-200/month in Year 1 while still learning what sells.

| Stream | Month 3 | Month 6 | Month 12 | Effort/Week |
|--------|---------|---------|----------|-------------|
| AI Templates (5 products) | $200 | $1,500 | $5,000 | 4-6 hrs |
| Content (500 subscribers) | $0 | $500 | $2,500 | 3-4 hrs |
| POD (20 designs) | $100 | $400 | $1,000 | 2-3 hrs |
| **Combined** | **$300** | **$2,400** | **$8,500** | **9-13 hrs** |

## Portfolio Strategies

### Conservative (Single Stream)
Focus 100% on AI Templates to $5K/month. All effort on validation, build, scale. Revisit diversification after 12 months.

### Moderate (Primary + Secondary)
- Months 1-4: AI Templates (faster revenue)
- Months 2-8: Content Publishing (slower burn, authority)
- Months 8-12: Content drives template discovery
- **Synergy:** Templates for revenue, content for SEO/audience

### Aggressive (Diversified)
- Months 1-4: AI Templates (revenue baseline)
- Months 3-8: Content Publishing (audience building)
- Months 6-12: POD (batch design, volume play)
- **Synergy:** Full cross-promotion flywheel

> For detailed platform comparisons, weekly cadences, monthly review templates, and scaling paths, see [references/portfolio-strategy.md](references/portfolio-strategy.md).

## Competitive Advantages

| Skill | Application | Advantage |
|-------|-------------|-----------|
| Software engineering | Build APIs, SaaS, automation | Can code solutions, not just templates |
| Creative ability | AI-assisted design, brand positioning | Higher quality, faster iteration |
| Technical insight | Authoritative content, developer tools | Credibility + SEO authority |
| Systems thinking | Automate and scale across streams | Compounding returns |

## Quick Start

### Week 1: Foundation
1. Choose primary stream (use **trl-monetization-strategy** if undecided)
2. Set up platform accounts for chosen stream
3. Initialize project tracker from stream skill assets

### Weeks 2-4: First Product
1. Run market research (use **trl-market-intelligence**)
2. Create and launch first product using stream skill workflows
3. Optimize listing with keywords and preview assets

### Month 2+: Build System
1. Launch second product in primary stream
2. Start secondary stream (usually content for authority + traffic)
3. Track metrics using stream project trackers
4. Iterate based on performance data

## Metrics to Track

**Portfolio-level:**
- Total revenue ($/month across all streams)
- Time allocation (hrs/week per stream)
- Products launched (cumulative)
- Audience size (subscribers, followers, email list)

**Per-stream:** Each stream skill defines its own key metrics. Review monthly using the template in [references/portfolio-strategy.md](references/portfolio-strategy.md).

## Related Skills

| Skill | When to Invoke | Key File |
|-------|---------------|----------|
| **trl-monetization-strategy** | Before this skill -- decide which stream to start with | `references/assessment.md` |
| **trl-market-intelligence** | Before building any product -- validate niche demand | `references/niche-discovery.md` |
| **trl-ai-templates** | When executing AI template products within your portfolio | `SKILL.md` + `references/templates-reference.md` |
| **trl-content-publishing** | When executing content strategy within your portfolio | `SKILL.md` + `references/content-calendar.md` |
| **trl-print-on-demand** | When executing POD products within your portfolio | `SKILL.md` + `references/prompt-library.md` |
| **trl-user-experience-engineer** | When designing landing pages, mockups, or brand identity for any stream | `references/outputs/landing-pages.md` |

## Bundled Resources

### References
- [portfolio-strategy.md](references/portfolio-strategy.md) — Weekly cadence templates, monthly review framework, scaling path, and agent invocation patterns. Read when planning multi-stream execution or reviewing portfolio performance.
- [platform-comparison.md](references/platform-comparison.md) — **Canonical pricing reference** for all selling and monetization platforms (Gumroad, Lemon Squeezy, Stan Store, Etsy, Substack, Patreon, Medium, Redbubble, Printful/Printify). All other skills reference this file.
