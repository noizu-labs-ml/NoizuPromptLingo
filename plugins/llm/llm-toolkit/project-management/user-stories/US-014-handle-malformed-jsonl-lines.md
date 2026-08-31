---
id: US-014
title: "Handle malformed JSONL lines"
slug: handle-malformed-jsonl-lines
personas: [P-001, P-006]
epic: "Indexing & Ingestion"
priority: must-have
complexity: medium
tags: [indexing, error-handling]
---

# US-014: Handle Malformed JSONL Lines

## User Story

**As a** power-user or open-source maintainer whose sessions sometimes end in a crash
**I want to** have the indexer skip and log malformed or truncated JSONL lines instead of failing the whole file
**So that** one bad line from a crashed session doesn't cause me to lose visibility into the rest of that conversation

## Acceptance Criteria

- **Given** a JSONL file contains one truncated or invalid JSON line (e.g. from a crashed session write)
  **When** the indexer processes the file
  **Then** it skips only that line, continues parsing subsequent valid lines, and the file is still marked as indexed

- **Given** a line is skipped
  **When** indexing completes for that file
  **Then** the skip is logged with the file path, line number, and a brief reason (e.g. "invalid JSON", "unexpected EOF"), retrievable via `llm-toolkit doctor` or a log file

- **Given** a file has multiple malformed lines scattered throughout
  **When** the indexer processes it
  **Then** all valid lines are still indexed and all malformed lines are individually logged, rather than the indexer aborting on the first error

## Notes
Sofia (P-006) works in short bursts across many small repos and would otherwise lose an entire session's searchability to a single crash-truncated line; grounding this in Marcus's (P-001) crash-prone client work too. Medium complexity: requires per-line error isolation in the JSONL parser rather than whole-file try/catch.
