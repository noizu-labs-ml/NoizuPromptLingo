---
id: US-037
title: "AI Reads Relevant Canon Context Before Generating"
slug: "ai-reads-canon-context"
personas: [P-001, P-002, P-003, P-004]
epic: "Generation Engine"
priority: "must-have"
complexity: "XL"
tags: [generation, ai, context, rag, canon, consistency]
---

# US-037: AI Reads Relevant Canon Context Before Generating

## User Story

**As a** epic novelist who needs generated content to be consistent with established lore (P-001),
**I want to** the AI generation engine to automatically retrieve and incorporate relevant canon entries as context before generating,
**So that** generated content does not contradict established facts about my universe.

## Acceptance Criteria

- [ ] Given I submit a generation prompt, when the request is processed, then the system automatically identifies and retrieves the top-N most semantically relevant canon entries from the universe.
- [ ] Given relevant canon entries are retrieved, when generation occurs, then the AI is instructed to treat those entries as ground truth and not contradict them.
- [ ] Given the generation is complete, when I view the result, then I can see which canon entries were used as context (see US-038 for citations UI).
- [ ] Given a universe has no relevant existing canon, when generation occurs, then the AI generates freely from the prompt without failing.
- [ ] Given the context retrieval step, when it runs, then it completes within 2 seconds and does not substantially increase the perceived total generation latency (pipelined).

## Notes

Depends on US-036. This story requires a vector search / RAG (Retrieval-Augmented Generation) architecture over the canon entry corpus. The quality of context retrieval is a primary driver of generation quality — embedding model selection is a key technical decision. Related: US-038 (citations), US-044 (edit sources).
