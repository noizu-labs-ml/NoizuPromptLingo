# Category: File and Knowledge

## Overview
Use tools in this category when a skill needs to read/write files, navigate a knowledge base, retrieve versioned documentation, search a vector store, or reason through a multi-step problem. This is the foundation layer — most skills will pull from at least one tool here.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Filesystem MCP | local stdio | Read/write files, directory tree, configurable roots | Scope roots tightly; no shell exec | Stable (official) |
| Desktop Commander MCP | local stdio | Terminal commands, diff-based edits, file ops | Full shell access — high risk | Beta |
| Memory MCP | local stdio | Knowledge graph, entity/relation/observation CRUD | Local only; graph stored on disk | Stable (official) |
| Notion MCP | hosted SSE (OAuth) | Workspace search, page/database management, block API | OAuth token required; data leaves machine | Stable |
| Obsidian MCP | local stdio | Graph-aware nav, tag search, wiki-links, backlinks | Local vault access only | Community / Beta |
| Qdrant MCP | self-hosted / cloud | Vector search, RAG integration, collection management | API key required for cloud; self-host preferred | Stable |
| Context7 MCP | hosted SSE | Version-specific library docs, prevents API hallucination | No auth; read-only public docs | Stable |
| Sequential Thinking MCP | local stdio | Structured problem-solving, step-by-step reasoning chains | No external calls | Stable (official) |

### Context7 MCP
- **What it does**: Resolves library/framework documentation at a specific version. Fetches accurate, current API signatures, options, and examples instead of relying on training data.
- **Deployment**: Hosted SSE — zero install, no auth required
- **Key features**: Version-pinned doc retrieval; resolves package name → doc source automatically; prevents hallucinated function signatures and deprecated-API errors
- **Security considerations**: Read-only, no credentials needed. Docs are fetched from public sources. No sensitive data should be passed as query terms.
- **When to use**: Any skill that generates code using third-party libraries (npm, PyPI, Hex). Always prefer over training-data recall for APIs newer than 2023.
- **When to avoid**: Internal/private libraries not indexed by Context7; offline environments

### Notion MCP
- **What it does**: Full Notion workspace access — search pages, read/write databases, manage blocks, create pages.
- **Deployment**: Hosted SSE via OAuth 2.0; configure once per workspace
- **Key features**: Database queries with filters, page content streaming, block-level editing, workspace-wide search
- **Security considerations**: OAuth token grants access to all shared pages in the integration scope. Scope the integration to only necessary pages. Treat the token as a secret — do not log or commit it.
- **When to use**: Skills that maintain a living knowledge base, track project status, or need structured data storage that non-technical collaborators can also edit.
- **When to avoid**: High-frequency automated writes (rate limits apply); projects where data must stay fully local; environments without internet access

### Obsidian MCP
- **What it does**: Navigates a local Obsidian vault — reads notes, follows wiki-links, searches by tag, traverses the backlink graph.
- **Deployment**: Local stdio; requires Obsidian Local REST API plugin running
- **Key features**: Graph-aware traversal (backlinks, forward links), tag-based filtering, full-text search, YAML frontmatter access
- **Security considerations**: Accesses the full vault directory. Limit vault root to the intended scope. No external data transmission.
- **When to use**: Skills that operate on a personal knowledge base, research corpus, or Zettelkasten. Excellent for trl-content-publishing and trl-market-intelligence skills working with accumulated notes.
- **When to avoid**: Team environments where Notion/Confluence is the canonical source; vaults without the REST API plugin installed

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| ripgrep (`rg`) | `brew install ripgrep` | Fast recursive text search | Code archaeology, finding references across a project |
| fd | `brew install fd` | Fast `find` alternative | File discovery by pattern, type, or modified date |
| jq | `brew install jq` | JSON processor | Parsing API responses, transforming structured data |
| yq | `brew install yq` | YAML/JSON/XML processor | Reading YAML configs, transforming design system tokens |

## Selection Guide

Choose based on where your knowledge lives and how it needs to flow:

| If your knowledge lives in... | Use |
|-------------------------------|-----|
| Local files (any format) | Filesystem MCP |
| A shared Notion workspace | Notion MCP |
| A personal Obsidian vault | Obsidian MCP |
| A vector/embedding store | Qdrant MCP |
| Third-party library docs | Context7 MCP |
| A reasoning chain you need to externalize | Sequential Thinking MCP |
| Long-lived facts across sessions | Memory MCP |

**Layering pattern**: Context7 + Filesystem MCP covers most code-generation skills. Add Memory MCP when the skill needs to recall user preferences or prior decisions across sessions. Add Qdrant when the skill operates on a large corpus too big to load into context.
