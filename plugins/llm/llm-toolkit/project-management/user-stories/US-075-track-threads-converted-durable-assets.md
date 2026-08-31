---
id: US-075
title: "Track threads converted into durable assets"
slug: track-threads-converted-durable-assets
personas: [P-005]
epic: "Admin & Oversight"
priority: could-have
complexity: medium
tags: [admin, value-tracking]
---

# US-075: Track Threads Converted Into Durable Assets

## User Story

**As an** engineering lead auditing team AI usage
**I want to** see a view that cross-references which conversations were later converted into skills, agents, runbooks, or added to a dataset
**So that** I can gauge how much downstream value the team is actually extracting from Claude Code sessions, not just how many sessions exist

## Acceptance Criteria

- **Given** conversations have been run through the Convert wizard or added to a dataset
  **When** I open the "Conversion Tracking" view
  **Then** it lists each source conversation alongside the durable asset(s) it produced (asset type, name, and creation date)

- **Given** a conversation has not been converted into any asset
  **When** I view the tracking list with a "not yet converted" filter enabled
  **Then** it shows only conversations with zero downstream assets, letting me spot valuable-looking threads that were never captured

- **Given** a single conversation produced multiple assets (e.g. a skill and a dataset entry)
  **When** I view its row
  **Then** all produced assets are listed, not just the most recent one

## Notes
Daniel uses this to justify the tool's ROI to leadership and to nudge the team toward converting valuable debugging sessions instead of letting them go stale. Could-have — useful reporting layer, but not required for core oversight (Dashboard/Browse/Safety Watch cover the must-have/should-have baseline).
