---
id: US-072
title: "Dashboard stat row"
slug: dashboard-stat-row
personas: [P-005, P-001]
epic: "Admin & Oversight"
priority: must-have
complexity: low
tags: [admin, dashboard, stats]
---

# US-072: Dashboard Stat Row

## User Story

**As an** engineering lead auditing team AI usage (or solo power-user developer)
**I want to** see a stat row on the Dashboard showing total conversations, projects indexed, dataset entries, and last-indexed timestamp
**So that** I get an immediate, refreshed sense of the corpus's overall health and size every time I open the app

## Acceptance Criteria

- **Given** the background indexer has completed at least one pass
  **When** I open the Dashboard
  **Then** the stat row displays four figures: total conversation count, count of distinct projects indexed, total dataset entries across all datasets, and the last-indexed timestamp

- **Given** I am viewing the Dashboard and the background watcher indexes a new conversation
  **When** I reload the Dashboard (or the stat row auto-refreshes on load, per its spec)
  **Then** the stat row values reflect the updated counts and a newer last-indexed timestamp

- **Given** no conversations have been indexed yet (fresh install)
  **When** I open the Dashboard
  **Then** the stat row shows zero values and the last-indexed field shows "never" rather than an error or blank state

## Notes
This is Daniel's first stop for his weekly oversight scan and gives Marcus quick confirmation that the background indexer is keeping up with his active client repos.
