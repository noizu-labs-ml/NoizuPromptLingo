---
id: US-010
title: "Real-time file watcher"
slug: realtime-file-watcher
personas: [P-001]
epic: "Indexing & Ingestion"
priority: must-have
complexity: high
tags: [indexing, watcher, realtime]
---

# US-010: Real-Time File Watcher

## User Story

**As a** solo power-user developer actively working across 4-6 client repos
**I want to** have new and changed JSONL files under `~/.claude/projects` picked up automatically within seconds
**So that** I can search or resume a conversation I just had without manually triggering a re-index

## Acceptance Criteria

- **Given** the background watcher is running
  **When** a new JSONL file appears under `~/.claude/projects/<project>/`
  **Then** its messages appear in keyword search results within a few seconds, without the user running `llm-toolkit index`

- **Given** an existing JSONL file is actively being appended to during a live session
  **When** new lines are written
  **Then** the watcher detects the change and indexes the new content within a few seconds of the write, not only when the file is closed

- **Given** the watcher is monitoring many project directories simultaneously (Marcus's multi-client setup)
  **When** multiple files change in quick succession across different projects
  **Then** all changes are indexed without dropped events or requiring the watcher to be restarted

- **Given** the watcher process crashes or is killed
  **When** it is restarted (manually or by the doctor/health check)
  **Then** it resumes watching without requiring a full re-index of already-indexed files

## Notes
High complexity: this underpins near-real-time freshness across the whole product (search, dashboard health indicator, resume) and must handle filesystem event edge cases (rapid appends, file rotation, many concurrent directories) reliably. Depends on incremental append-only indexing (US-011) to avoid re-processing whole files on every change.
