---
id: US-081
title: "Graceful handling of locked/corrupted index"
slug: graceful-locked-corrupted-index
personas: [P-001, P-005]
epic: "Edge Cases & Error States"
priority: must-have
complexity: high
tags: [error-state, resilience]
---

# US-081: Graceful Handling Of Locked/Corrupted Index

## User Story

**As a** solo power-user developer
**I want to** see a clear error state with a recovery action when the index database is locked or corrupted
**So that** I can recover fast recall of my client repos' history instead of hitting a silent hang or crash

## Acceptance Criteria

- **Given** the FTS5 index file is locked by another process
  **When** Marcus runs `search` from the CLI or opens the web UI
  **Then** the app shows an "Index is locked" error state with a Retry action instead of hanging silently

- **Given** the index database is detected as corrupted (schema/checksum mismatch on open)
  **When** the watcher or web UI attempts to open it
  **Then** a "Rebuild index" recovery action is offered, clearly labeled as safe (source JSONL is never touched)

- **Given** the user clicks "Rebuild index"
  **When** the rebuild completes
  **Then** the error state clears and normal search/browse functionality resumes

- **Given** the lock is transient (e.g. another indexer process mid-write)
  **When** Marcus retries a few seconds later
  **Then** the retry succeeds without requiring a full rebuild

## Notes
Marcus depends on fast CLI recall across his 4-6 client repos, so a silent hang is especially costly mid-context-switch. Daniel, in his auditing-lead role, needs assurance that any corruption/rebuild path is non-destructive to source JSONL before he'd trust the tool for oversight scans.
