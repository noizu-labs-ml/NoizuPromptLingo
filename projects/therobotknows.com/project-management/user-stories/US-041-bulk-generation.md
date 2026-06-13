---
id: US-041
title: "Bulk Generation"
slug: "bulk-generation"
personas: [P-003, P-007]
epic: "Generation Engine"
priority: "could-have"
complexity: "XL"
tags: [generation, bulk, batch, queue, automation, api]
---

# US-041: Bulk Generation

## User Story

**As a** narrative designer who needs to seed a new game area with 20+ NPC entries rapidly (P-003),
**I want to** submit a batch of generation prompts at once,
**So that** I can populate a large section of my universe in a single session without manually triggering each generation.

## Acceptance Criteria

- [ ] Given I am in the Generation Studio, when I switch to "Bulk Mode", then I can enter multiple prompts (one per line or as a structured list) and submit them as a batch.
- [ ] Given a bulk batch is submitted, when processing begins, then each prompt is queued and processed sequentially or in parallel (up to a concurrency limit).
- [ ] Given bulk generation is running, when I view the generation queue (US-042), then I can see the status of each prompt (pending, in progress, completed, failed).
- [ ] Given one prompt in a bulk batch fails, when the failure occurs, then the remaining prompts continue processing and the failure is flagged individually.
- [ ] Given a bulk batch completes, when I review results, then I can accept, edit, or discard each generated entry individually before any are promoted to canon.

## Notes

Depends on US-036, US-042 (generation queue). Bulk generation has significant cost implications — a per-batch cost preview should be shown before submission. Related: US-048 (cost tracking), US-049 (API-based generation for agents like P-007).
