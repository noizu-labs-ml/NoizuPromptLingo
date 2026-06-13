# Claude Assist — Site Map

> Local dev tool for searching, browsing, editing, and managing Claude Code conversations — then extracting reusable agents, skills, workflows, and fine-tuning datasets from them.

**Package:** `claude-assist` (npm)
**Status:** draft
**Last updated:** 2026-05-11

---

## Page Flow

```mermaid
graph LR
    ROOT["/ Layout (AppShell)"]
    ROOT -->|data-design-theme| DASH["/"]
    ROOT -->|data-design-theme| SEARCH["/search"]
    ROOT -->|data-design-theme| BROWSE["/browse"]
    ROOT -->|data-design-theme| THREAD["/thread/[id]"]
    ROOT -->|data-design-theme| EDIT["/thread/[id]/edit"]
    ROOT -->|data-design-theme| CONVERT["/thread/[id]/convert"]
    ROOT -->|data-design-theme| MERGE["/merge"]
    ROOT -->|data-design-theme| DATASETS["/datasets"]
    ROOT -->|data-design-theme| DATASET["/datasets/[name]"]
    ROOT -->|data-design-theme| SETTINGS["/settings"]

    DASH -->|search bar| SEARCH
    DASH -->|recent thread click| THREAD
    DASH -->|nav| BROWSE
    SEARCH -->|result click| THREAD
    BROWSE -->|thread click| THREAD
    THREAD -->|action| EDIT
    THREAD -->|action| CONVERT
    THREAD -->|action| MERGE
    EDIT -->|tag range| DATASET
    CONVERT -->|output preview| THREAD
    DATASETS -->|dataset click| DATASET
```

---

## / — Dashboard

Primary entry point after `claude-assist serve`. Provides quick access to search, recent conversations, and summary statistics. Designed for rapid orientation — "what was I working on?"

```mermaid
graph TD
    PAGE["/ Dashboard"]
    PAGE --> SEARCH["SearchBar\nglobal search input, mode toggle (text/semantic)"]
    PAGE --> STATS["StatRow\nconversation count, project count, indexed tokens, dataset entries"]
    STATS --> S1["StatCard\nTotal Conversations"]
    STATS --> S2["StatCard\nProjects Indexed"]
    STATS --> S3["StatCard\nDataset Entries"]
    STATS --> S4["StatCard\nLast Indexed"]
    PAGE --> RECENT["RecentThreads\nchronological list, 20 most recent"]
    RECENT --> THREAD_CARD["ThreadCard × N\ntitle, project badge, date, message count, preview snippet"]
    PAGE --> PROJECTS["ProjectSidebar\ngrouped project list with conversation counts"]
```

**Data:**
- Stats: `GET /api/stats`
- Recent threads: `GET /api/conversations?sort=updated_at&limit=20`
- Projects: `GET /api/projects`

---

## /search — Search

Full-featured search with dual modes (full-text and semantic), filters, and highlighted results. The primary discovery interface.

```mermaid
graph TD
    PAGE["/search"]
    PAGE --> SEARCH["SearchBar\nquery input + mode toggle"]
    SEARCH --> MODE_TEXT["ToggleChip: Full-Text"]
    SEARCH --> MODE_SEM["ToggleChip: Semantic"]
    PAGE --> FILTERS["FilterBar"]
    FILTERS --> F_PROJ["ProjectFilter\ndropdown"]
    FILTERS --> F_DATE["DateRange\nstart/end pickers"]
    FILTERS --> F_ROLE["RoleFilter\nuser/assistant/tool"]
    PAGE --> RESULTS["SearchResults"]
    RESULTS --> RESULT_CARD["ResultCard × N\nthread title, matched snippet with highlights, project, date, relevance score"]
    RESULTS --> PAGINATION["Pagination\npage controls"]
    PAGE --> EMPTY["EmptyState\nillustration + 'No results' + suggestions"]
```

**Data:**
- Full-text: `GET /api/search?q={query}&mode=fts&project={}&from={}&to={}&role={}`
- Semantic: `GET /api/search?q={query}&mode=semantic&project={}&from={}&to={}`

---

## /browse — Browse

Project-grouped conversation list. The organizational view — "everything in this project" or "everything this week."

```mermaid
graph TD
    PAGE["/browse"]
    PAGE --> CONTROLS["ViewControls\nsort (date/length/relevance) + group (project/date/none)"]
    PAGE --> PROJECT_GROUP["ProjectGroup × N"]
    PROJECT_GROUP --> GROUP_HEADER["GroupHeader\nproject name + conversation count"]
    PROJECT_GROUP --> THREAD_LIST["ThreadList"]
    THREAD_LIST --> THREAD_ROW["ThreadRow × N\ntitle, date, message count, tags, status badge"]
    PAGE --> BULK_ACTIONS["BulkActionBar\narchive, tag, rehome (visible when items selected)"]
```

**Data:**
- Conversations: `GET /api/conversations?group_by={project|date}&sort={field}&order={asc|desc}`
- Bulk ops: `POST /api/conversations/bulk`

---

## /thread/[id] — Thread Viewer

Full conversation renderer. Shows the complete thread with collapsible tool calls, thinking blocks, and code blocks. Action hub for edit, convert, and dataset tagging.

```mermaid
graph TD
    PAGE["/thread/[id]"]
    PAGE --> HEADER["ThreadHeader\ntitle, project, date, message count, model"]
    HEADER --> ACTIONS["ActionBar\nEdit, Convert, Merge, Tag, Archive, Rehome"]
    PAGE --> TIMELINE["ThreadTimeline\nvisual timeline showing decision points and direction changes"]
    PAGE --> MESSAGES["MessageList"]
    MESSAGES --> USER_MSG["UserMessage\navatar + rendered content"]
    MESSAGES --> ASST_MSG["AssistantMessage\navatar + content blocks"]
    ASST_MSG --> THINKING["ThinkingBlock\ncollapsible, dimmed"]
    ASST_MSG --> TEXT["TextBlock\nmarkdown rendered"]
    ASST_MSG --> TOOL_USE["ToolUseBlock\ncollapsible, tool name + input preview"]
    MESSAGES --> TOOL_RESULT["ToolResultMessage\ncollapsible, stdout/stderr + truncation"]
    PAGE --> METADATA["MetadataPanel\ntags, summary, token usage, session info"]
```

**Data:**
- Thread: `GET /api/conversations/{id}`
- Messages: `GET /api/conversations/{id}/messages`
- Metadata: `GET /api/conversations/{id}/metadata`

---

## /thread/[id]/edit — Thread Editor

Interactive editor for curating conversation threads. Non-destructive — all edits produce a new version, original JSONL is never modified.

```mermaid
graph TD
    PAGE["/thread/[id]/edit"]
    PAGE --> TOOLBAR["EditToolbar\nCollapse, Simplify, Remove, Reorder, Inject, Fork"]
    PAGE --> DIFF_VIEW["DiffView\nside-by-side original vs edited"]
    DIFF_VIEW --> ORIGINAL["OriginalPane\nread-only message list with selection checkboxes"]
    DIFF_VIEW --> EDITED["EditedPane\ndraggable message list with inline editing"]
    PAGE --> INJECT["InjectPanel\nslide-out: add annotation/correction/context message"]
    PAGE --> SIMPLIFY["SimplifyPanel\nslide-out: LLM-assisted rewrite preview + accept/reject"]
    PAGE --> SAVE["SaveBar\ndescription input + Save as New Version / Discard"]
```

**Data:**
- Source thread: `GET /api/conversations/{id}/messages`
- Existing edits: `GET /api/conversations/{id}/edits`
- Save: `POST /api/conversations/{id}/edits`
- Simplify: `POST /api/llm/simplify` (body: message range)

---

## /thread/[id]/convert — Convert Wizard

Step-by-step wizard for extracting reusable artifacts (agents, skills, commands, snippets, runbooks) from a conversation.

```mermaid
graph TD
    PAGE["/thread/[id]/convert"]
    PAGE --> STEP1["Step 1: Select Type\nAgent / Skill / Command / Snippet / Runbook"]
    STEP1 --> STEP2["Step 2: Select Messages\nhighlight message range that contains the pattern"]
    STEP2 --> STEP3["Step 3: Configure\nname, description, parameters, output path"]
    STEP3 --> STEP4["Step 4: Preview\nrendered artifact with syntax highlighting"]
    STEP4 --> STEP5["Step 5: Export\ndownload or write to filesystem"]
    PAGE --> CANDIDATES["CandidatePanel\nAI-suggested extraction points with confidence scores"]
```

**Data:**
- Thread: `GET /api/conversations/{id}/messages`
- Candidates: `POST /api/convert/candidates` (body: conversation_id, type)
- Preview: `POST /api/convert/preview` (body: messages, type, config)
- Export: `POST /api/convert/export` (body: artifact definition)

---

## /merge — Merge View

Side-by-side thread comparison with drag-and-drop section assembly. For combining related conversations into a single reference document.

```mermaid
graph TD
    PAGE["/merge"]
    PAGE --> PICKER["ThreadPicker\nsearch + select 2-5 threads to merge"]
    PAGE --> COMPARE["CompareView\nside-by-side thread panels, scrollable independently"]
    COMPARE --> THREAD_A["ThreadPanel A\nmessage list with drag handles"]
    COMPARE --> THREAD_B["ThreadPanel B\nmessage list with drag handles"]
    PAGE --> ASSEMBLY["AssemblyZone\ndrop target, ordered list of selected sections"]
    ASSEMBLY --> SECTION["MergedSection × N\nsource thread badge + message range + reorder handle"]
    PAGE --> OUTPUT["OutputPreview\nrendered merged document + export controls"]
```

**Data:**
- Thread selection: `GET /api/conversations?ids={id1,id2,...}`
- Save merge: `POST /api/merges`

---

## /datasets — Dataset Manager

List and manage fine-tuning datasets. Overview of all datasets with entry counts, quality distribution, and export options.

```mermaid
graph TD
    PAGE["/datasets"]
    PAGE --> CREATE["CreateDatasetBtn\nname + description dialog"]
    PAGE --> LIST["DatasetList"]
    LIST --> DATASET_CARD["DatasetCard × N\nname, description, entry count, quality breakdown, last updated"]
    DATASET_CARD --> QUALITY_BAR["QualityBar\ngold/silver/bronze stacked bar"]
    PAGE --> EXPORT["BulkExportPanel\nformat selector (OpenAI/Anthropic/generic JSONL) + download"]
```

**Data:**
- Datasets: `GET /api/datasets`
- Create: `POST /api/datasets`
- Export: `GET /api/datasets/{name}/export?format={openai|anthropic|jsonl}`

---

## /datasets/[name] — Dataset Detail

Browse, review, and manage entries within a specific dataset. Preview training examples and manage quality labels.

```mermaid
graph TD
    PAGE["/datasets/[name]"]
    PAGE --> HEADER["DatasetHeader\nname, description, version, entry count"]
    PAGE --> FILTERS["EntryFilters\nquality (gold/silver/bronze), source conversation, date"]
    PAGE --> ENTRIES["EntryList"]
    ENTRIES --> ENTRY["DatasetEntry × N"]
    ENTRY --> SOURCE["SourceBadge\nconversation title + link"]
    ENTRY --> PREVIEW["EntryPreview\nsystem/user/assistant message sequence"]
    ENTRY --> QUALITY["QualitySelector\ngold/silver/bronze toggle"]
    ENTRY --> DELETE["DeleteBtn"]
    PAGE --> ADD["AddFromThread\nlink to /thread/[id] with dataset tagging mode active"]
    PAGE --> EXPORT["ExportPanel\nformat + download"]
```

**Data:**
- Dataset: `GET /api/datasets/{name}`
- Entries: `GET /api/datasets/{name}/entries?quality={}&source={}`
- Update entry: `PATCH /api/datasets/{name}/entries/{id}`
- Delete entry: `DELETE /api/datasets/{name}/entries/{id}`

---

## /settings — Settings

Configuration for index paths, embedding provider, LLM provider, and display preferences.

```mermaid
graph TD
    PAGE["/settings"]
    PAGE --> INDEX["IndexConfig\nwatched paths, reindex button, last index time"]
    INDEX --> PATH_LIST["PathList\nadd/remove conversation directories"]
    INDEX --> REINDEX["ReindexBtn\nfull / incremental"]
    PAGE --> EMBEDDING["EmbeddingConfig\nprovider selector + API key input"]
    EMBEDDING --> LOCAL["LocalOption\nTransformers.js + model selector"]
    EMBEDDING --> HOSTED["HostedOption\nOpenAI/Voyage/Anthropic + key"]
    PAGE --> LLM["LLMConfig\nprovider for simplify/summarize operations"]
    PAGE --> DISPLAY["DisplayConfig\ntheme (nocturne only for now), code font, line numbers"]
```

**Data:**
- Config: `GET /api/config`
- Update: `PATCH /api/config`
- Reindex: `POST /api/index/rebuild`

---

## Page Inventory

| Route | Purpose | Key Components | Data Sources |
|-------|---------|----------------|--------------|
| `/` | Dashboard — quick stats + recent threads | SearchBar, StatCard, ThreadCard | API: /stats, /conversations |
| `/search` | Full-text + semantic search | SearchBar, FilterBar, ResultCard | API: /search |
| `/browse` | Project-grouped thread list | ViewControls, ProjectGroup, ThreadRow | API: /conversations |
| `/thread/[id]` | Full conversation viewer | ThreadHeader, MessageList, ToolUseBlock | API: /conversations/{id} |
| `/thread/[id]/edit` | Non-destructive thread editor | DiffView, EditToolbar, InjectPanel | API: /conversations/{id}/edits |
| `/thread/[id]/convert` | Artifact extraction wizard | StepWizard, CandidatePanel, OutputPreview | API: /convert |
| `/merge` | Side-by-side thread merge | CompareView, AssemblyZone, OutputPreview | API: /conversations, /merges |
| `/datasets` | Dataset list + management | DatasetCard, QualityBar, ExportPanel | API: /datasets |
| `/datasets/[name]` | Dataset entry browser | EntryList, EntryPreview, QualitySelector | API: /datasets/{name} |
| `/settings` | App configuration | IndexConfig, EmbeddingConfig, LLMConfig | API: /config |

---

## Navigation

### Primary Nav (sidebar, persistent)
- Dashboard → `/`
- Search → `/search`
- Browse → `/browse`
- Datasets → `/datasets`
- Settings → `/settings`

### Contextual Nav (within thread views)
- Thread → `/thread/[id]`
- Edit → `/thread/[id]/edit`
- Convert → `/thread/[id]/convert`

### Global Elements
- **SearchBar** — appears on Dashboard hero and in navbar (compact mode)
- **CommandPalette** — `Cmd+K` overlay, routes to any page or action
- **IndexStatus** — indicator in navbar showing indexer state (idle/running/stale)

### No Auth Gates
All pages are local-only. No authentication required — the tool runs on localhost.
