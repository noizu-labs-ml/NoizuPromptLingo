# npl-winnower: Context-Efficient File Reader Agent — Design Document

## Problem Statement

Agents routinely read large files (500-2000+ lines), consuming massive context windows for content that's mostly irrelevant to their specific query. There's no systematic way to:
- Pre-check file sizes before committing to a read
- Get a tailored view of a file focused on what matters
- Progressively expand sections of interest
- Compare structural patterns across multiple files

The npl-winnower agent sits between callers and files, returning winnowed content with expandable section IDs. Callers get exactly the detail they need at the verbosity they request.

## Design Decisions

- **Sub-agent only** — invoked via Claude Code's Agent tool, not registered as MCP catalog tools
- **Images deferred to v2** — v1 covers code, docs, config, and notebooks
- **Progressive disclosure** — every collapsed section has a unique ID for on-demand expansion

---

## User Stories

### US-W01: Code File Public API Summary

**As a** tasker-sonnet performing code review,
**I want to** request only the public API surface of a large source file,
**so that** I review the interface contract without consuming context on implementation bodies.

**Acceptance Criteria:**
- 2000-line Python file returns class/function signatures + docstrings
- Implementation bodies replaced with `--- N lines collapsed [sec:fn-2] ---`
- Output stays under 200 lines at `summary` verbosity
- Section IDs allow expanding any specific method body on demand

### US-W02: Test Pattern Extraction

**As an** npl-tdd-coder writing new tests,
**I want to** see test structure and fixture patterns without every assertion,
**so that** I write new tests consistent with the existing suite.

**Acceptance Criteria:**
- Returns test class hierarchy, fixture setup patterns, and test method names
- Shows one fully-expanded "representative" test per pattern (first test in each class)
- Other test bodies collapsed with assertion count annotations
- Any collapsed test expandable by section ID

### US-W03: Multi-File Architecture Scan

**As an** explorer agent mapping codebase architecture,
**I want to** get skeleton summaries of multiple files in one batch,
**so that** I build a mental model without sequential full reads.

**Acceptance Criteria:**
- Accepts a list of file paths (up to 20)
- Returns per-file skeleton: imports, top-level definitions, class outlines
- Total batch output respects a configurable line budget
- Files that exceed per-file budget are further condensed with expand markers

### US-W04: Image/Diagram Simplification *(v2 — deferred)*

**As a** caller needing to understand a diagram,
**I want to** receive a text description or simplified rendering instead of the full image,
**so that** I consume minimal context tokens while understanding the content.

**Acceptance Criteria:**
- PNG/JPG files get an LLM-generated text description
- SVG files get a simplified version with reduced path complexity
- ASCII/braille rendering available as options
- Always includes dimensions and file size

*Deferred to v2. Will reuse existing `tools/image_convert.py` and `describe_image()` from `src/npl_mcp/meta_tools/llm_client.py`.*

### US-W05: Progressive Drill-Down

**As a** caller who received a summary,
**I want to** expand specific collapsed sections by ID,
**so that** I progressively load detail only where needed.

**Acceptance Criteria:**
- First call returns summary with section IDs on every collapsed marker
- Subsequent call with `expand=["sec:fn-2", "sec:cls-1.3"]` returns those sections fully expanded
- Expanded sections include their own child section IDs for further drilling
- Deterministic section IDs: same file content produces same IDs

### US-W06: Cross-File Pattern Comparison

**As a** caller comparing patterns across files,
**I want to** extract the same structural element (e.g., "all function signatures") from multiple files side by side,
**so that** I spot inconsistencies without reading each file fully.

**Acceptance Criteria:**
- Accepts file list plus a structural query (e.g., "public methods", "imports", "class hierarchy")
- Returns unified comparison view grouped by the query dimension
- Each entry has file attribution and section IDs for expansion

### US-W07: File Size Pre-Check

**As a** caller agent deciding how to read a file,
**I want to** check size and type before committing to a full read or winnow,
**so that** I don't waste a winnow call on a 30-line config file.

**Acceptance Criteria:**
- Returns: path, line count, byte size, detected language, estimated token count
- Returns recommendation: `direct` (small enough to read), `winnow` (use winnower), or `skip` (binary/unsupported)
- Default threshold: winnow if > 150 lines or > 6000 estimated tokens
- Threshold is configurable per invocation

---

## Use Cases

### UC-1: Python Source File (summary verbosity)

**Input:**
```
Winnow src/npl_mcp/launcher.py at summary verbosity.
```

**Output:**
```
# src/npl_mcp/launcher.py (247 lines, ~4200 tokens)

## Imports [sec:imp]
subprocess, sys, pathlib, uvicorn, FastAPI, FastMCP, starlette

## Constants [sec:const]
HOST, PORT, REPO_ROOT, FRONTEND_DIR, DIST_DIR

## Functions
### build_frontend() -> bool [sec:fn-1]
  Build Next.js frontend if needed. Returns success status.

### create_app() -> FastMCP [sec:fn-2]
  Create FastMCP instance with all discovery tools.
  Registers: ToolSummary, ToolSearch, ToolDefinition, ToolHelp, ToolCall
  --- 5 inner functions collapsed [sec:fn-2.inner] ---

### create_asgi_app(mcp, ...) -> FastAPI [sec:fn-3]
  Mount MCP SSE on FastAPI, add static files, return ASGI app.

### main() [sec:fn-4]
  CLI entry point: parse args, build frontend, start uvicorn.
```

**Context savings:** 247 lines → ~20 lines (92% reduction)

### UC-2: Markdown Documentation (skeleton verbosity)

**Input:**
```
Winnow docs/PROJ-ARCH.md at skeleton verbosity.
```

**Output:**
```
# docs/PROJ-ARCH.md (skeleton, 156 lines -> 22 lines)

# Project Architecture
## Overview [sec:1] -- 8 lines
## System Diagram [sec:2] -- mermaid (12 lines, preserved)
## Core Components [sec:3] -- table, 9 rows
## Meta Tool Pattern [sec:4] -- 15 lines
## Technology Stack [sec:5] -- table, 10 rows
## Data Flow [sec:6] -- mermaid sequence diagram
## Key Decisions [sec:7] -- 4 decisions
```

**Context savings:** 156 lines → 10 lines (94% reduction). Mermaid diagrams noted as preserved (available via expand).

### UC-3: Large Config/Lock File

**Input:**
```
Winnow uv.lock at summary verbosity.
```

**Output:**
```
# uv.lock (2847 lines, ~48000 tokens)

## Package Index [sec:pkg]
142 packages resolved.
Top-level: fastmcp 2.3.1, fastapi 0.115.0, asyncpg 0.30.0, ...
--- full package list collapsed [sec:pkg-all] ---

## Resolution Metadata [sec:meta]
python: ">=3.12", resolver: uv 0.5.x
```

**Context savings:** 2847 lines → 8 lines (99.7% reduction)

### UC-4: Progressive Disclosure (multi-turn)

**Turn 1 — Skeleton:**
```
Winnow src/npl_mcp/launcher.py at skeleton verbosity.
```
Returns: heading outline with section IDs (15 lines from 247-line file)

**Turn 2 — Expand one function:**
```
Expand sec:fn-2 from src/npl_mcp/launcher.py at summary verbosity.
```
Returns: function summary with inner function list and their section IDs (20 lines)

**Turn 3 — Full detail on one inner function:**
```
Expand sec:fn-2.3 from src/npl_mcp/launcher.py at full verbosity.
```
Returns: full verbatim code of that inner function (15 lines)

**Result:** ~50 lines total context consumed instead of 247. Caller got exactly the detail needed at each step.

### UC-5: Batch Cross-File Query

**Input:**
```
Winnow batch [src/npl_mcp/launcher.py, src/npl_mcp/unified.py, src/npl_mcp/meta_tools/catalog.py]
at summary verbosity. Query: "public functions". Budget: 100 lines.
```

**Output:**
```
# Batch: "public functions" across 3 files (budget: 100 lines)

## launcher.py (4 public functions)
- build_frontend() -> bool [sec:f1-fn-1]
- create_app() -> FastMCP [sec:f1-fn-2]
- create_asgi_app(...) -> FastAPI [sec:f1-fn-3]
- main() [sec:f1-fn-4]

## unified.py (2 public functions)
- build_mcp() -> FastMCP [sec:f2-fn-1]
- create_asgi() -> FastAPI [sec:f2-fn-2]

## catalog.py (3 public functions)
- load_catalog() -> list[dict] [sec:f3-fn-1]
- get_category_tools(cat) -> list [sec:f3-fn-2]
- search_tools(query) -> list [sec:f3-fn-3]
```

---

## Prompt Architecture Overview

### Caller Flow

```
1. STAT: wc -l <path> → if ≤ 150 lines, read directly; if > 150, winnow
2. WINNOW: spawn npl-winnower with file path + verbosity + optional focus
3. EXPAND: spawn npl-winnower with section IDs to drill into
4. BATCH: spawn npl-winnower with file list + budget + optional query
```

See `sub-agent-prompts/winnower-caller-protocol.md` for full caller instructions.
See `agents/npl-winnower.md` for the agent system prompt.

### Verbosity Levels

| Level | Reduction | Shows | Collapses |
|-------|-----------|-------|-----------|
| skeleton | 90-95% | Headings, signatures, line counts | All content |
| summary | 70-85% | + docstrings, key logic, types | Implementation bodies |
| detailed | 30-50% | Most content | Boilerplate, repetitive patterns |
| full | 0% | Everything | Nothing |

### Section ID Scheme

Deterministic, position-based IDs. Same file content → same IDs.

| Pattern | Meaning | Example |
|---------|---------|---------|
| `sec:imp` | Imports block | `sec:imp` |
| `sec:const` | Constants/globals | `sec:const` |
| `sec:cls-N` | Nth class | `sec:cls-1` |
| `sec:cls-N.M` | Mth method in Nth class | `sec:cls-1.3` |
| `sec:fn-N` | Nth top-level function | `sec:fn-2` |
| `sec:fn-N.inner` | Inner functions of fn-N | `sec:fn-2.inner` |
| `sec:H` | Heading at position H (docs) | `sec:3` |
| `sec:H.S` | Sub-heading | `sec:3.2` |
| `sec:cN` | Notebook cell N | `sec:c7` |
| `sec:fX-*` | Batch file prefix (X = file index) | `sec:f2-fn-1` |

---

## v2 Roadmap

- **Image handling**: `describe`, `ascii`, `braille`, `svg_simplify` modes
- **Cache layer**: `.tmp/winnower/` for session-aware caching of parsed structures
- **Focus queries**: LLM-powered content filtering (e.g., "show only error handling")
- **Notebook output summarization**: Describe plot outputs, summarize DataFrames
