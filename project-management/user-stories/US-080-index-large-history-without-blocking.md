---
id: US-080
title: "Index large existing history without blocking"
slug: index-large-history-without-blocking
personas: [P-001, P-005]
epic: "Performance & Scale"
priority: must-have
complexity: high
tags: [performance, indexing, scale]
---

# US-080: Index Large Existing History Without Blocking

## User Story

**As a** solo power-user developer (or engineering lead auditing team AI usage)
**I want to** have an existing history of 10,000+ conversations index as a background job that keeps the UI and CLI responsive, with visible progress
**So that** first-run indexing of a large corpus doesn't lock me out of using the toolkit for the hours it might take to complete

## Acceptance Criteria

- **Given** a fresh install pointed at `~/.claude/projects/` containing 10,000+ conversation JSONL files
  **When** the initial index job starts
  **Then** the FTS5 keyword index and MiniLM embedding index build incrementally in a background worker, without blocking the web UI or CLI from responding to requests

- **Given** the background index job is running
  **When** I open the Dashboard or run `llm-toolkit index --status`
  **Then** I see live progress (e.g. "4,213 / 10,842 conversations indexed", estimated time remaining)

- **Given** indexing is still in progress
  **When** I search or browse conversations that have already been indexed
  **Then** those results are available and correct immediately, even though the full corpus isn't finished yet

- **Given** the indexing job is interrupted (e.g. app restart mid-run)
  **When** the app restarts
  **Then** indexing resumes from where it left off rather than restarting the full 10,000+ conversation scan from zero

## Notes
Marcus and Daniel are the personas most likely to onboard with a large pre-existing history (Marcus across years of client work, Daniel across a whole team's corpus) — both need the tool usable within seconds of install rather than blocked behind a multi-hour cold index. High complexity reflects the background-job architecture, incremental progress reporting, and resumability requirements together.
