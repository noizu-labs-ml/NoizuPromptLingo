---
id: US-024
title: "Add a knowledge-base entry to a persona's private KB"
slug: "add-knowledge-base-entry-to-private-kb"
personas: [P-002]
epic: "Agent Personas & Memory"
priority: "should-have"
complexity: "S"
tags: [personas, knowledge-base, memory, compartments]
---

# US-024: Add a knowledge-base entry to a persona's private KB

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** save a reusable fact or insight into my persona's private knowledge base,
**So that** I can build up durable domain knowledge that persists beyond any single session's context window.

## Acceptance Criteria

- [ ] Given Sable has a registered persona, when it submits a KB entry with a title and content body, then the entry is stored under that persona's private KB and is not visible to other personas by default.
- [ ] Given an existing KB entry, when Sable submits a new entry on the same topic, then both persist independently — no silent overwrite — unless Sable explicitly references the prior entry's ID to update it.
- [ ] Given a KB entry stored with tags or a category, when Sable later lists entries filtered by that tag, then only matching entries are returned.
- [ ] Given a KB entry belongs to Sable's persona, when a different persona without explicit compartment access attempts to read it, then access is denied.

## Notes

"Private" here maps to the access-controlled compartments in the underlying memory system; cross-persona compartment-sharing rules are out of scope for this story.
