---
id: US-048
title: "Narrative coherence across turns"
slug: "narrative-coherence"
personas: [P-001, P-002]
epic: "Narrative Engine"
priority: "must-have"
complexity: "L"
tags: [narrative-engine, coherence, history, memory, continuity]
---

# US-048: Narrative Coherence Across Turns

## User Story

**As a** interactive fiction author building long-form narratives (P-002),
**I want to** have the Narrative Engine maintain and summarize conversation history so that each new generation is contextually grounded in prior turns,
**So that** characters remember what was said, established facts persist, and the narrative feels like a continuous story rather than a series of disconnected responses.

## Acceptance Criteria

- [ ] Given a session with N prior turns, when `engine.generate(action)` is called for turn N+1, then the assembled context includes a representation of prior turns (either verbatim recent turns, a rolling summary, or both).
- [ ] Given a session exceeding the token budget for full history, when context is assembled, then the engine automatically summarizes older turns into a compact summary block via a configurable summarization strategy.
- [ ] Given a summarization strategy set to `"llm"`, when history is summarized, then an LLM call is made to produce the summary; given `"truncate"`, then only the N most recent turns are included without summarization.
- [ ] Given a fact established in turn 3 (e.g. "the player gave the key to the guard"), when the player references "the key" in turn 15, then the assembled context makes the prior fact available so the LLM can respond coherently.
- [ ] Given a session restored from a snapshot (US-031), when `engine.generate()` is called after restore, then narrative coherence is maintained as if the session had never been interrupted.
- [ ] Given a coherence test fixture with a known 10-turn script, when the engine processes all 10 turns, then assertions on turn 10's context confirm that salient facts from turns 1-5 are present in assembled context.

## Notes

This is a large story because coherence spans history management, summarization strategies, and snapshot integration. It is the primary quality-of-experience story for P-002 and fundamental for any game longer than a few turns. Depends on US-039 (token budget) and US-031 (snapshots). Relates to the Memory System epic (future).
