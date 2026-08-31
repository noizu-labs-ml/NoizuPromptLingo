---
id: US-090
title: "Rehome exposed via API"
slug: rehome-exposed-via-api
personas: [P-006]
epic: "Integration & API"
priority: should-have
complexity: low
tags: [api, ops]
---

# US-090: Rehome Exposed Via API

## User Story

**As an** open-source maintainer
**I want to** call a documented rehome API endpoint
**So that** I can script repo-reorg workflows across my many small repos instead of clicking through the web UI one at a time

## Acceptance Criteria

- **Given** Sofia wants to script a repo-reorg
  **When** she calls `POST /api/conversations/rehome` with a source project path and a target project path
  **Then** matching conversations' project association is moved and the JSONL is relocated/repathed accordingly

- **Given** the API rehome documentation
  **When** Sofia reads it
  **Then** it matches the same behavior as the web UI's rehome action (non-destructive, source JSONL preserved)

- **Given** an invalid or nonexistent source path is passed
  **When** the call is made
  **Then** it returns HTTP 400/404 with a clear message rather than silently no-op'ing

## Notes
Enables Sofia's rehome-after-repo-rename workflow to run as a batch script across many repos, rather than repeating the web UI flow for each one.
