---
id: US-012
title: "Manual re-index CLI command"
slug: manual-reindex-cli-command
personas: [P-001, P-008]
epic: "Indexing & Ingestion"
priority: must-have
complexity: low
tags: [indexing, cli]
---

# US-012: Manual Re-Index CLI Command

## User Story

**As a** power-user or multi-provider tinkerer who needs a reliable escape hatch
**I want to** run `llm-toolkit index` to force a full or targeted re-index
**So that** I can recover from a stalled watcher or deliberately rebuild the index without waiting on background detection

## Acceptance Criteria

- **Given** the user runs `llm-toolkit index` with no arguments
  **When** it executes
  **Then** it performs a full re-index of all JSONL files under `~/.claude/projects` and reports the count of conversations and messages processed on completion

- **Given** the user runs `llm-toolkit index --project <project-name>`
  **When** it executes
  **Then** it re-indexes only that project's JSONL files and reports counts scoped to that project

- **Given** the re-index encounters files that are already up to date
  **When** it processes them
  **Then** it skips re-processing unchanged files (reusing the incremental checkpoint logic from US-011) and the final report distinguishes "processed" from "skipped, already current"

## Notes
Yusuf (P-008) would use this after switching embedding models or diagnosing drift; Marcus (P-001) uses it as the manual fallback when the watcher (US-010) seems stuck, surfaced by `doctor` (US-008).
