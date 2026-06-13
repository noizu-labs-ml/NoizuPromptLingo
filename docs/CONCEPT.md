# BookmarkFlow — Product Concept

**Domain:** bookmarkflow.com
**Tagline:** Your knowledge, searchable by you and your agents.
**Status:** Concept → Design

---

## The Problem

Bookmarking is a graveyard. People save links they never revisit, tag systems they never maintain, and folders they never organize. Meanwhile, AI agents — the fastest-growing class of "users" on the web — have no persistent memory of what their human collaborators have found, read, or deemed important.

**Three failures of current bookmarking:**

1. **Save-and-forget** — Pocket reports <15% of saved articles are ever re-read. The act of saving creates false closure.
2. **Search is broken** — You remember *what* you read, not *where* you read it. Title/URL search fails when you need "that article about cache invalidation with the good diagram."
3. **Agents are blind** — When you ask Claude, GPT, or a coding agent "remember that API doc I found last week?", the answer is always no. Agent memory and human memory are disconnected silos.

## The Insight

Bookmarking should be a **shared knowledge layer** between humans and their AI agents. Not a filing cabinet — a living, queryable memory that both parties contribute to and draw from.

## What BookmarkFlow Is

An AI-native knowledge management system where:

- **Humans** save, annotate, and search web resources using natural language
- **AI agents** save discoveries, query the knowledge base, and build on prior research via MCP/API
- **Semantic search** replaces tags and folders — find things by *meaning*, not metadata
- **AI summaries** extract and preserve the *why you saved it*, not just the URL
- **Knowledge graphs** surface connections between saved resources that neither human nor agent would spot alone

## Who It's For

### Primary Persona: The Technical Knowledge Worker

**"Dev Maya"** — Senior developer, 32, uses Claude Code and Cursor daily. Has 2,000+ browser bookmarks she never searches. Frequently re-googles things she's already found. Wants her AI coding assistant to "just know" about the libraries and docs she's already vetted.

- Saves 5-15 links/week across research, docs, tutorials, tools
- Uses AI assistants 4+ hours/day for coding, writing, research
- Pain: "I know I read a great article about this exact problem last month"
- Goal: Stop re-discovering things. Let her agents leverage her past research.

### Secondary Persona: The AI-Augmented Researcher

**"Research Raj"** — Product manager, 28, runs multi-step research workflows with AI agents. Agents find great resources during research but the findings evaporate when the conversation ends.

- Runs 3-5 deep research sessions/week using AI agents
- Pain: Agent research is ephemeral — no persistent knowledge accumulation
- Goal: Research compounds over time instead of starting from zero each session

### Secondary Persona: The Team Knowledge Builder

**"Lead Lena"** — Engineering team lead, 36, wants shared team knowledge that's actually searchable. Confluence is where knowledge goes to die.

- Manages 6-person team, each finding useful resources independently
- Pain: "Someone on the team found the perfect solution for this last sprint"
- Goal: Team knowledge base that humans and agents both contribute to and query

### Anti-Personas

- **Casual browser** — Saves recipes and vacation ideas. Doesn't use AI tools. (Not our user.)
- **Enterprise knowledge management buyer** — Wants Confluence/Notion replacement with governance. (Not our product.)
- **Bookmark hoarder** — Saves 100+ links/day, never reads them. (We can't fix hoarding behavior.)

## Core Features

### Tier 1: MVP (Launch)

| Feature | Human | Agent | Description |
|---------|-------|-------|-------------|
| **Save** | Browser extension, paste URL | MCP tool, API | Capture URL + context about *why* |
| **Auto-summarize** | See summary on save | Receive structured summary | LLM extracts title, key points, topics, relevance |
| **Semantic search** | Natural language search bar | MCP query tool, API | "that article about Postgres connection pooling" finds it |
| **Collections** | Create/manage manually | Create via API | Lightweight grouping (not folders — flat, overlapping) |
| **Quick notes** | Inline annotation on save | Structured metadata | "Why I saved this" captured at save-time |
| **Import** | Browser bookmarks, Pocket, Raindrop | Bulk API | Migration path from existing tools |

### Tier 2: Growth

| Feature | Description |
|---------|-------------|
| **Knowledge graph** | Visual map of connections between saved resources (shared topics, citations, related concepts) |
| **Agent memory bridge** | MCP server that agents use as persistent memory — "save this for later" and "what do we know about X?" |
| **Team spaces** | Shared collections with role-based access; agents can query team knowledge |
| **Smart resurface** | Proactively surfaces relevant past saves when you're researching a related topic |
| **Digest** | Weekly email/notification summarizing what you saved, connections discovered, and suggestions |

### Tier 3: Differentiation

| Feature | Description |
|---------|-------------|
| **Agent research log** | Agents automatically save notable findings during research sessions (opt-in) |
| **Cross-agent knowledge** | Bookmarks saved by Claude are queryable by GPT and vice versa (agent-agnostic) |
| **Citation network** | When you save academic papers or blog posts, auto-map the citation/reference graph |
| **Knowledge decay** | Flag stale bookmarks (dead links, outdated content, superseded docs) |
| **Public knowledge bases** | Publish curated collections as shareable, searchable pages |

## How It Works (User Stories)

### Story 1: Human saves, agent recalls
> Maya finds an excellent blog post about Elixir GenServer patterns. She clicks the browser extension, adds a note: "Good patterns for supervision trees in our payment service." Two weeks later, she's pair-programming with Claude Code and asks: "What resources do we have on GenServer supervision?" Claude queries BookmarkFlow via MCP and surfaces the article with Maya's annotation.

### Story 2: Agent saves, human discovers
> Raj asks Claude to research vector database options. Claude evaluates six options, finding particularly strong documentation for Qdrant. Claude saves the three best resources to BookmarkFlow with structured notes. Next week, Raj opens BookmarkFlow and sees Claude's research — summarized, organized, and searchable.

### Story 3: Team knowledge compounds
> Lena's team each independently discover useful resources about Kubernetes networking. BookmarkFlow notices the cluster of related saves across team members and surfaces: "Your team has 8 resources about K8s networking — view the knowledge graph." Now a new team member can query "how does our team handle K8s ingress?" and get curated, annotated answers.

## Competitive Landscape

| Product | Bookmarking | AI Search | Agent Integration | Shared Knowledge |
|---------|------------|-----------|-------------------|-----------------|
| **Raindrop.io** | Excellent | Basic | None | Team plans |
| **Pocket** | Good (read-later focus) | None | None | None |
| **Pinboard** | Good (minimalist) | None | None | None |
| **Notion Web Clipper** | Good (into Notion) | Notion AI search | None | Notion workspaces |
| **Are.na** | Good (visual/creative) | None | None | Channels |
| **BookmarkFlow** | Good | **Semantic/NL** | **MCP + API first** | **Human + Agent shared** |

**Differentiation axis:** We're not competing on bookmarking UX (Raindrop wins there). We're competing on the **human↔agent knowledge bridge** — the thing nobody else does at all.

## Technical Architecture (High-Level)

```
┌─────────────────────────────────────────────────────────┐
│                    BookmarkFlow                          │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ Next.js  │  │ Browser  │  │   MCP Server          │  │
│  │ Web App  │  │Extension │  │ (Agent Interface)     │  │
│  └────┬─────┘  └────┬─────┘  └─────────┬────────────┘  │
│       │              │                   │               │
│       └──────────────┼───────────────────┘               │
│                      │                                    │
│              ┌───────▼────────┐                           │
│              │  Phoenix API   │                           │
│              │  (REST + WS)   │                           │
│              └───────┬────────┘                           │
│                      │                                    │
│         ┌────────────┼────────────┐                      │
│         │            │            │                       │
│   ┌─────▼──┐  ┌──────▼──┐  ┌────▼─────┐                │
│   │Postgres│  │ Qdrant / │  │  Redis   │                │
│   │(data)  │  │ Weaviate │  │ (cache/  │                │
│   │        │  │(vectors) │  │  queue)  │                │
│   └────────┘  └─────────┘  └──────────┘                 │
│                                                          │
│   ┌─────────────────────────────────┐                    │
│   │  Background Workers (Oban)      │                    │
│   │  - URL fetch + content extract  │                    │
│   │  - LLM summarization            │                    │
│   │  - Embedding generation         │                    │
│   │  - Link health checking         │                    │
│   └─────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

**Key technical decisions:**
- **Phoenix + Oban** for background processing (URL fetch, LLM summarization, embedding)
- **Vector DB** (Qdrant or Weaviate — already in the k8 cluster) for semantic search
- **MCP server** as first-class interface, not an afterthought
- **Browser extension** (Chrome/Firefox) for human capture flow

## Monetization

| Tier | Price | Limits |
|------|-------|--------|
| **Free** | $0 | 500 bookmarks, 50 searches/mo, 1 agent connection, no teams |
| **Pro** | $8/mo | Unlimited bookmarks, unlimited search, 5 agent connections, knowledge graph |
| **Team** | $12/user/mo | Shared team spaces, admin controls, agent research logs, SSO |

**Why this works:** Free tier is generous enough to get hooked on agent memory. The jump to Pro is driven by hitting the agent connection or search limit — the more you use agents, the faster you hit it.

## Name & Brand Direction

**BookmarkFlow** — the name suggests both *bookmarks* and *flow state*. Your knowledge flows to you when you need it, instead of sitting in a graveyard.

**Brand signals:** Intelligence, utility, calm confidence. Not playful, not corporate — technically sophisticated but approachable.

**Style recommendation:** **Minimal Tech** (primary) with light **Editorial** accent (20%) for the content-heavy views (reading summaries, knowledge graph descriptions). This signals "smart tool for smart people" while respecting that the product is ultimately about *content*.

**Accent color recommendation:** **Violet (#7C3AED)** — signals AI/innovation, differentiates from the sea of blue SaaS products, works well in both light and dark modes.
