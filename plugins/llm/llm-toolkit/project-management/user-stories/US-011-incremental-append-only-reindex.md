---
id: US-011
title: "Incremental append-only re-index"
slug: incremental-append-only-reindex
personas: [P-001, P-003]
epic: "Indexing & Ingestion"
priority: must-have
complexity: high
tags: [indexing, performance]
---

# US-011: Incremental Append-Only Re-Index

## User Story

**As a** power-user with long-running sessions (Marcus) or an ML engineer indexing a large corpus for training data mining (Elena)
**I want to** have only newly appended lines of a growing JSONL file parsed and indexed
**So that** indexing stays fast and CPU-light even as individual session files and the overall corpus grow large

## Acceptance Criteria

- **Given** a JSONL file that has already been fully indexed
  **When** new lines are appended (session continues)
  **Then** only the new lines are parsed and written to the FTS5 index and embeddings store — the previously indexed lines are not re-parsed or re-embedded

- **Given** the indexer tracks a byte-offset or line-count checkpoint per file
  **When** the watcher (US-010) triggers a re-index of a changed file
  **Then** the indexer reads from the last recorded checkpoint forward, and updates the checkpoint after successful indexing

- **Given** a file is modified in a non-append way (e.g. truncated or rewritten, not just appended to)
  **When** the indexer detects the file is smaller than its last checkpoint
  **Then** it falls back to a full re-index of that file rather than reading from a now-invalid offset

- **Given** Elena is running semantic search across her entire indexed corpus for training data mining
  **When** background indexing is happening concurrently on active sessions
  **Then** her large-scale queries are not slowed to full-file-reindex speeds by unrelated file growth elsewhere in the corpus

## Notes
High complexity: correct checkpointing across append vs. truncate/rewrite cases is the crux of the feature, and getting it wrong risks duplicate or missing index entries — worth explicit test coverage on file-rewrite detection.
