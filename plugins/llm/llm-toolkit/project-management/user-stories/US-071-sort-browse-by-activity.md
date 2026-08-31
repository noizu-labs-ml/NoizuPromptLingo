---
id: US-071
title: "Sort Browse by activity"
slug: sort-browse-by-activity
personas: [P-005]
epic: "Admin & Oversight"
priority: should-have
complexity: low
tags: [admin, browse]
---

# US-071: Sort Browse by Activity

## User Story

**As an** engineering lead auditing team AI usage
**I want to** sort Browse results by message count or recency
**So that** unusually heavy sessions surface at a glance during my weekly scan instead of requiring me to open every thread

## Acceptance Criteria

- **Given** I am viewing Browse with conversations grouped by project
  **When** I select "Sort by message count" from the sort control
  **Then** conversations within each project group re-order from highest to lowest message count

- **Given** I select "Sort by recency" instead
  **When** the sort applies
  **Then** conversations within each group re-order by last-active timestamp, most recent first

- **Given** I've chosen a sort order
  **When** I navigate away from Browse and return later in the same session
  **Then** my last-selected sort order is remembered

## Notes
Daniel scans for outliers — a thread with an abnormally high message count or a burst of very recent activity is often the one worth a closer look during his audit pass.
