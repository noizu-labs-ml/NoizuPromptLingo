---
id: US-009
title: "Defer indexing large history"
slug: defer-indexing-large-history
personas: [P-001, P-005]
epic: "Onboarding & Install"
priority: should-have
complexity: medium
tags: [onboarding, performance, indexing]
---

# US-009: Defer Indexing Large History

## User Story

**As a** power-user with years of accumulated history (Marcus) or an engineering lead onboarding onto a team's shared history (Daniel)
**I want to** be offered incremental background indexing when the first-run scan detects thousands of existing JSONL files
**So that** I can start using the tool immediately instead of being blocked for a long upfront indexing run

## Acceptance Criteria

- **Given** the first-run scan detects a history size above a defined large-history threshold (e.g. thousands of JSONL files)
  **When** the wizard presents the indexing step
  **Then** it offers a choice between "index everything now" and "index recent history now, continue the rest in the background"

- **Given** the user chooses background/incremental indexing
  **When** the wizard completes
  **Then** the user is taken into the app immediately (Dashboard/Browse usable for already-indexed content) while remaining history continues indexing in the background

- **Given** background indexing is still catching up
  **When** the user views the Dashboard
  **Then** the index health indicator (per US-013) shows an "indexing" status with progress, not a false "up to date" state

## Notes
Complexity is medium because it requires prioritizing recent-first indexing order plus a persistent background job, not just a progress bar; should-have since a blocking full index (US-002) is still functionally correct, just slower for large histories like Marcus's multi-client backlog.
