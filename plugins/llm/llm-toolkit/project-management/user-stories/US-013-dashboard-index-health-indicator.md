---
id: US-013
title: "Dashboard index health indicator"
slug: dashboard-index-health-indicator
personas: [P-005]
epic: "Indexing & Ingestion"
priority: should-have
complexity: low
tags: [indexing, dashboard]
---

# US-013: Dashboard Index Health Indicator

## User Story

**As an** engineering lead auditing team AI usage
**I want to** see a "last indexed" timestamp and a status badge (up to date / indexing / stalled) on the Dashboard
**So that** I can tell at a glance during my weekly oversight scan whether indexing is healthy without running diagnostic commands

## Acceptance Criteria

- **Given** the Dashboard is loaded
  **When** the stat row renders
  **Then** it displays a "last indexed" timestamp reflecting the most recent successful watcher activity and a status badge of one of: "up to date", "indexing", or "stalled"

- **Given** the watcher has not processed any new activity in longer than a defined stalled threshold while unindexed changes are detected on disk
  **When** the Dashboard evaluates status
  **Then** it shows "stalled" rather than silently continuing to show "up to date"

- **Given** background indexing is actively catching up (e.g. after US-009's deferred large-history indexing)
  **When** the Dashboard renders during that window
  **Then** it shows "indexing" with the last-indexed timestamp still visible, not a misleading "up to date"

## Notes
Directly serves Daniel's (P-005) weekly oversight scan pattern — he needs a glance-able signal, not a drill-down, to know whether the corpus he's auditing is current before spot-checking threads for leaked secrets.
