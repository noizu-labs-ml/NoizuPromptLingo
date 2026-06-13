# BookmarkFlow

**Domain:** bookmarkflow.com
**Tagline:** Your knowledge, searchable by you and your agents.

## Project Idea

AI-native bookmarking system for humans and LLMs. BookmarkFlow is a shared knowledge layer between people and their AI agents — both can save, annotate, search, and build upon web resources using semantic search, AI-generated summaries, and knowledge graphs.

**Differentiator:** Not a better bookmark manager — a **human↔agent knowledge bridge**. Agents query your saved knowledge via MCP. Your past research compounds instead of evaporating.

## Core Features (MVP)

- **Save** — Browser extension (humans) + MCP tool / API (agents)
- **Auto-summarize** — LLM extracts key points, topics, and relevance on save
- **Semantic search** — Natural language queries, not keyword/tag matching
- **Collections** — Lightweight, flat, overlapping groupings
- **Quick notes** — "Why I saved this" captured at save-time
- **Import** — Browser bookmarks, Pocket, Raindrop, Pinboard

## Tech Stack

- **Frontend:** Next.js 15 (App Router, React 19, Tailwind CSS 4)
- **Backend:** Phoenix 1.8 (Elixir, Ecto, Guardian JWT, Oban)
- **Vector DB:** Qdrant or Weaviate (semantic search + embeddings)
- **Database:** PostgreSQL + Redis
- **Agent Interface:** MCP server + REST API
- **Infrastructure:** Kubernetes (existing k8 cluster)

## Design Direction

- **Style:** Minimal Tech (80%) + Editorial accent (20%)
- **Accent:** Violet (#7C3AED) — signals AI/innovation
- **Tone:** Intelligent, utilitarian, calm confidence

## Monetization

| Tier | Price | Key Limits |
|------|-------|------------|
| Free | $0 | 500 bookmarks, 50 searches/mo, 1 agent |
| Pro | $8/mo | Unlimited, 5 agents, knowledge graph |
| Team | $12/user/mo | Shared spaces, admin, SSO |

## Status

Concept → **Design** (concept doc + sitemap complete)

## Key Documents

- [docs/CONCEPT.md](docs/CONCEPT.md) — Full product concept (personas, features, competitive landscape, architecture)
- [design/SITEMAP.md](design/SITEMAP.md) — Information architecture and page definitions
