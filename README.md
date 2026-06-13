# BloggersCompete

**Domain:** bloggerscompete.com
**Stack:** Next.js 15 + Phoenix 1.8 + PostgreSQL + Redis
**Style:** Consumer Playful (80%) + Minimal Tech (20%)

## Project Idea

AI-powered blog discovery and competition platform for analyzing, listing, and showcasing blogs. The platform uses AI to evaluate blog quality, engagement metrics, and content originality, enabling bloggers to compete in curated challenges and gain visibility. Features include automated blog indexing, AI-driven ranking algorithms, competition hosting tools, and audience analytics dashboards.

## Value Proposition

**For indie bloggers** who want recognition beyond follower counts, BloggersCompete is the platform that objectively evaluates and showcases blog quality through AI scoring and competitive challenges — unlike blog directories that just list URLs, or social media where engagement metrics reward virality over quality.

## Revenue Model

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | Blog listing, 2 competitions/month, basic AI score, public profile |
| Pro | $12/mo | Unlimited competitions, full analytics, host competitions, priority indexing, export reports |
| Team | $29/mo | Multi-blog management, team analytics, API access, white-label competitions |

## Key Features

- **AI Blog Scoring** — Six-dimension evaluation: Originality, Engagement, Consistency, Writing Quality, SEO, Visual Design
- **Competitions** — Time-boxed challenges with AI judging + community voting
- **Leaderboards** — Global and per-niche rankings with animated position tracking
- **Blog Indexing** — Automated crawling, RSS monitoring, and post-level scoring
- **Analytics Dashboard** — Score trends, dimension breakdowns, peer benchmarking (Pro)
- **Competition Hosting** — Create custom competitions with configurable judging criteria (Pro)

## Status

Design / Pre-development

## Design Artifacts

| Document | Purpose |
|----------|---------|
| [`design/STYLE-DIRECTION.md`](design/STYLE-DIRECTION.md) | Color, typography, shape, motion, voice |
| [`design/SITEMAP.md`](design/SITEMAP.md) | Information architecture, page flow, route inventory |
| [`design/SCREENS.md`](design/SCREENS.md) | Screen inventory, component specs, interaction patterns |

## Next Steps

1. Scaffold full-stack app (`init-proj-scaffold bloggerscompete.com blogcomp BlogComp`)
2. Build style guide YAML from STYLE-DIRECTION.md
3. Implement landing page + explore page (public, no auth)
4. Build blog indexing pipeline (backend)
5. Add auth + dashboard shell
6. Implement AI scoring engine
7. Build competition system
