# BookmarkFlow — Sitemap

**Project:** BookmarkFlow
**Domain:** bookmarkflow.com
**One-liner:** AI-native bookmarking for humans and their agents
**Status:** Concept
**Date:** 2026-05-26

---

## Page Flow

```mermaid
graph LR
    Landing["/\nLanding Page"]
    Login["/login\nLogin"]
    Signup["/signup\nSign Up"]
    Dashboard["/dashboard\nDashboard"]
    Search["/search\nSearch"]
    Collection["/collections/:id\nCollection"]
    Collections["/collections\nAll Collections"]
    Bookmark["/bookmarks/:id\nBookmark Detail"]
    Graph["/graph\nKnowledge Graph"]
    Import["/import\nImport"]
    Settings["/settings\nSettings"]
    Pricing["/pricing\nPricing"]
    API["/developers\nAPI & MCP Docs"]
    Digest["/digest\nWeekly Digest"]

    Landing -->|CTA| Signup
    Landing -->|nav| Login
    Landing -->|nav| Pricing
    Landing -->|nav| API

    Login -->|auth| Dashboard
    Signup -->|auth| Dashboard

    Dashboard -->|nav| Search
    Dashboard -->|nav| Collections
    Dashboard -->|nav| Graph
    Dashboard -->|nav| Import
    Dashboard -->|nav| Settings
    Dashboard -->|nav| Digest
    Dashboard -->|click bookmark| Bookmark

    Search -->|result click| Bookmark
    Search -->|filter| Collection

    Collections -->|click| Collection
    Collection -->|click bookmark| Bookmark

    Bookmark -->|related| Bookmark
    Bookmark -->|collection| Collection

    Settings -->|upgrade| Pricing
```

---

## Page Definitions

### Landing Page `/`

```mermaid
graph TD
    Page[Landing Page]
    Page --> Hero[Hero Section]
    Hero --> Headline["Your knowledge, searchable\nby you and your agents."]
    Hero --> Sub["AI-native bookmarking that\nboth humans and LLMs can query"]
    Hero --> CTA1["Get Started Free"]
    Hero --> Visual["Product screenshot / demo"]

    Page --> Problem[Problem Section]
    Problem --> P1["Save & forget"]
    Problem --> P2["Search by meaning, not URL"]
    Problem --> P3["Your agents have amnesia"]

    Page --> HowItWorks[How It Works]
    HowItWorks --> Step1["Save — browser ext or agent MCP"]
    HowItWorks --> Step2["Understand — AI summarizes & embeds"]
    HowItWorks --> Step3["Recall — semantic search, human or agent"]

    Page --> Features[Feature Grid]
    Features --> F1["Semantic Search"]
    Features --> F2["Agent Memory Bridge"]
    Features --> F3["Auto-Summaries"]
    Features --> F4["Knowledge Graph"]
    Features --> F5["Team Spaces"]
    Features --> F6["Import Everything"]

    Page --> Social[Social Proof / Early Access]
    Page --> PricingPreview[Pricing Preview]
    Page --> FooterCTA["Start building your knowledge base"]
    Page --> Footer[Footer]
```

**Purpose:** Convert visitors to signups. Lead with the agent memory angle — it's the differentiator.

**Data requirements:** None (static).

---

### Dashboard `/dashboard`

```mermaid
graph TD
    Page[Dashboard]
    Page --> TopBar[Top Bar]
    TopBar --> SearchBar["Global search input"]
    TopBar --> QuickAdd["+ Add bookmark"]
    TopBar --> UserMenu["Avatar / settings"]

    Page --> Sidebar[Sidebar Nav]
    Sidebar --> NavRecent["Recent"]
    Sidebar --> NavCollections["Collections"]
    Sidebar --> NavGraph["Knowledge Graph"]
    Sidebar --> NavDigest["Digest"]
    Sidebar --> NavImport["Import"]
    Sidebar --> NavSettings["Settings"]

    Page --> Main[Main Content Area]
    Main --> RecentSaves["Recent Saves (card grid)"]
    Main --> AgentActivity["Agent Activity Feed"]
    Main --> QuickStats["Stats: total saved, searches, agent queries"]
    Main --> Suggestions["Resurface: relevant past saves"]
```

**Purpose:** Home base. Show recent activity from both human and agent saves. Make search instantly accessible.

**Data requirements:**
- Recent bookmarks (paginated, user + agent saves distinguished)
- Agent activity log (last N agent interactions)
- Usage stats (counts)
- Resurfaced suggestions (based on recent activity context)

---

### Search `/search`

```mermaid
graph TD
    Page[Search]
    Page --> SearchInput["Natural language search bar\n(full-width, prominent)"]
    Page --> Filters[Filter Bar]
    Filters --> FilterSource["Source: me / agent / team"]
    Filters --> FilterCollection["Collection"]
    Filters --> FilterDate["Date range"]
    Filters --> FilterType["Type: article / doc / repo / video"]

    Page --> Results[Results List]
    Results --> ResultCard["Bookmark Card"]
    ResultCard --> Title["Title + favicon"]
    ResultCard --> Summary["AI summary (2-3 lines)"]
    ResultCard --> Note["Your note (if any)"]
    ResultCard --> Meta["Saved by · date · collection · relevance score"]
    ResultCard --> Actions["Open · Copy · Add to collection · Delete"]

    Page --> Empty[Empty State]
    Empty --> EmptyMsg["No results — try different phrasing\nor save something about this topic"]
```

**Purpose:** The core interaction. Natural language in, ranked results out. Must feel instant.

**Data requirements:**
- Vector similarity search against embeddings
- Metadata filtering (source, date, collection, type)
- Bookmark data with summaries and notes

---

### Bookmark Detail `/bookmarks/:id`

```mermaid
graph TD
    Page[Bookmark Detail]
    Page --> Header[Header]
    Header --> Title["Title + source favicon"]
    Header --> URL["Original URL (clickable)"]
    Header --> SavedBy["Saved by: You / Agent name"]
    Header --> SavedDate["Date saved"]

    Page --> Summary[AI Summary]
    Summary --> KeyPoints["Key points (bullet list)"]
    Summary --> Topics["Extracted topics (chips)"]

    Page --> Notes[Notes Section]
    Notes --> UserNote["Your annotation"]
    Notes --> AgentNote["Agent context (why it saved this)"]
    Notes --> EditNote["Edit / add note"]

    Page --> Collections[Collections]
    Collections --> CollectionChips["Collection membership (editable)"]

    Page --> Related[Related Bookmarks]
    Related --> RelatedCards["Semantically similar saves"]

    Page --> Meta[Metadata]
    Meta --> ContentType["Type: article / doc / repo"]
    Meta --> LastChecked["Link health: last checked, status"]
    Meta --> WordCount["Estimated read time"]
```

**Purpose:** Deep view of a single bookmark. Surface the AI-extracted knowledge and connections.

**Data requirements:**
- Full bookmark record (URL, title, summary, notes, metadata)
- Related bookmarks (vector similarity)
- Collection memberships
- Link health status

---

### Collections `/collections` and `/collections/:id`

```mermaid
graph TD
    Page[Collections Index]
    Page --> CreateNew["+ New Collection"]
    Page --> CollectionGrid["Collection cards"]
    CollectionGrid --> Card["Collection Card"]
    Card --> Name["Collection name"]
    Card --> Count["N bookmarks"]
    Card --> Preview["Top 3 bookmark titles"]
    Card --> LastUpdated["Last updated"]

    Detail[Collection Detail]
    Detail --> DetailHeader["Collection name + description"]
    Detail --> DetailMeta["Created by · bookmark count · shared with"]
    Detail --> BookmarkList["Bookmark cards (same as search results)"]
    Detail --> AddBookmark["+ Add existing bookmark"]
    Detail --> ShareSettings["Share / team visibility toggle"]
```

**Purpose:** Lightweight grouping. Not hierarchical folders — flat, overlapping, taggable.

**Data requirements:**
- Collections list with counts and previews
- Collection detail with member bookmarks
- Share/visibility settings

---

### Knowledge Graph `/graph`

```mermaid
graph TD
    Page[Knowledge Graph]
    Page --> GraphView["Interactive node graph\n(topics as nodes, bookmarks as edges)"]
    Page --> Controls[Controls]
    Controls --> ZoomPan["Zoom / pan"]
    Controls --> FilterTopic["Filter by topic"]
    Controls --> FilterDate["Filter by date range"]
    Controls --> ClusterToggle["Cluster by: topic / collection / source"]

    Page --> DetailPanel["Side panel: selected node/edge detail"]
    DetailPanel --> NodeInfo["Topic: N bookmarks, key resources"]
    DetailPanel --> EdgeInfo["Connection: shared topics between bookmarks"]
```

**Purpose:** Visual discovery. See connections between saved resources. This is the "wow" feature for Tier 2.

**Data requirements:**
- Topic extraction from all bookmarks
- Co-occurrence/similarity relationships
- Graph layout computation (server-side or client D3/Sigma.js)

---

### Import `/import`

```mermaid
graph TD
    Page[Import]
    Page --> Sources[Import Sources]
    Sources --> Browser["Browser bookmarks (Chrome, Firefox, Safari)"]
    Sources --> Pocket["Pocket export"]
    Sources --> Raindrop["Raindrop.io export"]
    Sources --> Pinboard["Pinboard export"]
    Sources --> CSV["Generic CSV/JSON"]

    Page --> Upload["Upload file / connect account"]
    Page --> Progress["Import progress bar"]
    Page --> Preview["Preview imported bookmarks\n(before confirming)"]
    Page --> Dedup["Duplicate detection"]
```

**Purpose:** Migration path. Make switching painless.

**Data requirements:**
- File upload/parsing
- Deduplication against existing bookmarks
- Background processing (Oban job for AI summarization of imports)

---

### Settings `/settings`

```mermaid
graph TD
    Page[Settings]
    Page --> Profile["Profile (name, email, avatar)"]
    Page --> Plan["Plan & billing"]
    Page --> Agents[Agent Connections]
    Agents --> ConnectedAgents["Connected MCP agents list"]
    Agents --> APIKeys["API keys (create / revoke)"]
    Agents --> AgentPermissions["Per-agent permissions (read/write/search)"]

    Page --> Preferences[Preferences]
    Preferences --> Theme["Theme (light / dark / system)"]
    Preferences --> DigestFreq["Digest frequency"]
    Preferences --> AutoSummarize["Auto-summarize on save (on/off)"]
    Preferences --> DefaultCollection["Default collection"]

    Page --> Data[Data]
    Data --> Export["Export all data (JSON)"]
    Data --> Delete["Delete account"]
```

**Purpose:** Account management. Agent connections are a key settings surface — users need to see and control what agents can access.

---

### Pricing `/pricing`

```mermaid
graph TD
    Page[Pricing]
    Page --> Toggle["Monthly / Annual toggle"]
    Page --> Tiers[Three-column layout]
    Tiers --> Free["Free\n$0\n500 bookmarks\n50 searches/mo\n1 agent connection"]
    Tiers --> Pro["Pro\n$8/mo\nUnlimited bookmarks\nUnlimited search\n5 agent connections\nKnowledge graph"]
    Tiers --> Team["Team\n$12/user/mo\nShared spaces\nAdmin controls\nAgent research logs\nSSO"]

    Page --> FAQ["Pricing FAQ"]
    Page --> CTA["Start free → upgrade when ready"]
```

---

### API & MCP Docs `/developers`

```mermaid
graph TD
    Page[Developers]
    Page --> Overview["What BookmarkFlow offers agents"]
    Page --> MCP[MCP Server Setup]
    MCP --> Install["Installation (npm / docker)"]
    MCP --> Config["Configuration (API key, permissions)"]
    MCP --> Tools["Available MCP tools"]
    Tools --> T1["bookmark_save — save a URL with context"]
    Tools --> T2["bookmark_search — semantic search"]
    Tools --> T3["bookmark_list — list recent/filtered"]
    Tools --> T4["collection_query — search within collection"]
    Tools --> T5["knowledge_ask — natural language Q&A over saved knowledge"]

    Page --> REST[REST API Reference]
    REST --> Auth["Authentication (API keys, OAuth)"]
    REST --> Endpoints["Endpoint reference"]

    Page --> Examples["Integration examples\n(Claude Code, Cursor, custom agents)"]
```

**Purpose:** Developer adoption surface. MCP setup should be copy-paste simple.

---

### Weekly Digest `/digest`

```mermaid
graph TD
    Page[Digest]
    Page --> Current["This week's digest"]
    Current --> SavedSummary["What you saved (count + highlights)"]
    Current --> AgentSummary["What your agents saved"]
    Current --> Connections["New connections discovered"]
    Current --> Stale["Stale bookmarks (dead links, outdated)"]
    Current --> Suggestions["Suggested: resurface these"]

    Page --> Archive["Past digests"]
```

---

## Component Inventory

| Component | Used On | Notes |
|-----------|---------|-------|
| **BookmarkCard** | Dashboard, Search, Collection, Digest | Title, summary, note, meta, actions |
| **SearchBar** | Dashboard (compact), Search (full) | Natural language input with typeahead |
| **CollectionChip** | BookmarkCard, Bookmark Detail | Clickable, removable |
| **TopicChip** | Bookmark Detail, Knowledge Graph | Extracted topic tag |
| **AgentBadge** | BookmarkCard, Dashboard feed | Indicates agent-sourced content |
| **StatCard** | Dashboard | Numeric stat with label |
| **EmptyState** | Search, Collections, Dashboard | Contextual message + action |
| **ImportProgress** | Import | Progress bar with status messages |
| **PricingCard** | Pricing | Tier card with feature list + CTA |
| **GraphCanvas** | Knowledge Graph | D3/Sigma.js interactive graph |
| **DigestSection** | Digest | Collapsible summary section |
