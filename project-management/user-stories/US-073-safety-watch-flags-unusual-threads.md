---
id: US-073
title: "Safety Watch flags unusual threads"
slug: safety-watch-flags-unusual-threads
personas: [P-005]
epic: "Admin & Oversight"
priority: could-have
complexity: high
tags: [admin, safety-watch]
---

# US-073: Safety Watch Flags Unusual Threads

## User Story

**As an** engineering lead auditing team AI usage
**I want to** view a Safety Watch list of conversations flagged for unusual characteristics — such as very long sessions or atypical tag patterns — ranked by flag severity
**So that** I can prioritize which threads deserve manual review instead of blindly sampling from the whole corpus

## Acceptance Criteria

- **Given** the indexer has processed the conversation corpus
  **When** I open the Safety Watch view
  **Then** it lists flagged conversations ordered from highest to lowest severity, each showing the specific flag reason(s) (e.g. "session length 8x above average", "no tags on a 200+ message thread")

- **Given** a conversation appears in Safety Watch
  **When** I click it
  **Then** I'm taken directly to that thread in the viewer with the flagged region (if applicable, e.g. an unusually long tool-call sequence) highlighted or scrolled into view

- **Given** I've reviewed a flagged conversation and determined it's not a concern
  **When** I mark it "Reviewed" from Safety Watch
  **Then** it's removed from the active flagged list but remains queryable in a "reviewed" history

- **Given** the flagging heuristics run against the full corpus
  **When** a new conversation is indexed that exceeds the configured length or pattern thresholds
  **Then** it appears in Safety Watch on the next refresh without requiring a manual audit trigger

## Notes
Daniel uses Safety Watch as a triage layer before his manual spot-checks (see US-074) — it directs his limited review time toward the statistically unusual threads rather than a random sample. Could-have: the heuristic engine (severity scoring, pattern baselines) is a meaningfully separate, higher-risk build from the rest of Admin & Oversight, so it's deferred behind the must-have Dashboard/Browse basics.
