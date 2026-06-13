---
id: US-008
title: "Iterate on a previous mockup with modification instructions"
slug: "iterate-on-previous-mockup"
personas: [P-001, P-003]
epic: "MCP Core Service"
priority: "must-have"
complexity: "L"
tags: [mcp, iteration, refinement, mockup-id, version-history]
---

# US-008: Iterate on a previous mockup with modification instructions

## User Story

**As a** UX designer (P-003),
**I want to** call an `iterate_mockup` tool with an existing `mockup_id` and a delta instruction,
**So that** I can refine a generated mockup incrementally without regenerating from scratch and losing approved elements.

## Acceptance Criteria

- [ ] Given a valid `mockup_id` and a modification instruction, when `iterate_mockup` is called, then the response returns a new mockup that preserves unchanged elements and applies only the specified modifications
- [ ] Given a valid `mockup_id` belonging to a different user, when `iterate_mockup` is called, then a 403 error is returned
- [ ] Given an expired or deleted `mockup_id`, when `iterate_mockup` is called, then a 404 error is returned with the original `mockup_id` echoed in the error details
- [ ] Given a successful iteration, when the new artifact is returned, then it includes `parent_mockup_id` linking it to the source, forming a version chain visible in US-024

## Notes

Iteration depth is not limited but each iteration creates a new `mockup_id` in the version chain. The modification instruction uses the same natural-language format as the original prompt. Related to US-024 (version history).
