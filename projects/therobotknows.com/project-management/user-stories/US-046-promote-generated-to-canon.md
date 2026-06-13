---
id: US-046
title: "Promote Generated Entry to Canon"
slug: "promote-generated-to-canon"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Generation Engine"
priority: "must-have"
complexity: "M"
tags: [generation, canon, promotion, workflow, draft]
---

# US-046: Promote Generated Entry to Canon

## User Story

**As a** epic novelist who has reviewed and approved a generated draft (P-001),
**I want to** promote a generated entry directly to my canon with a single action,
**So that** approved AI-generated content becomes part of my official universe lore without requiring a manual copy-paste workflow.

## Acceptance Criteria

- [ ] Given a generated draft is displayed and I have reviewed it, when I click "Promote to Canon", then the draft is saved as a new canon entry with all fields populated from the draft.
- [ ] Given the promotion action, when the canon entry is created, then it is tagged with metadata indicating it is AI-generated (e.g., a "Generated" badge visible in the Canon Editor).
- [ ] Given the promoted entry, when it is saved, then the source citations from generation (US-038) are preserved as metadata on the canon entry.
- [ ] Given I promote a draft, when the action completes, then I am taken to the Canon Editor for the newly created entry to make any final adjustments.
- [ ] Given the canon entry is created via promotion, when I view the knowledge graph, then the new entry appears as a node (after the graph refreshes or in real time).

## Notes

Depends on US-036, US-037, US-038. The "Generated" badge provides transparency to collaborators that an entry originated from AI generation. Promotion should trigger a re-index of the entry for future RAG context retrieval. Related: US-047 (discard), US-045 (history).
