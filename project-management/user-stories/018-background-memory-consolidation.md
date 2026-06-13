---
id: story-018
title: "Run background memory consolidation"
persona: persona-the-dreamer
priority: should-have
complexity: XL
status: draft
---

# Run background memory consolidation

**As** The Dreamer,
**I want to** run periodic background consolidation that synthesizes related short-term memories into coherent knowledge summaries, identifies recurring themes, and surfaces insights that individual memories do not reveal,
**So that** the memory web develops higher-order understanding — not just "what happened" but "what it means."

## Acceptance Criteria
- [ ] Consolidation runs during low-activity periods (configurable quiet hours, or when ingestion rate drops below threshold)
- [ ] Related short-term memories (linked by The Weaver with combined weight >2.0 across links) are candidates for consolidation
- [ ] Consolidation produces `Synthesis` entities: a distilled summary, the emotional arc across constituent memories, identified themes, and an insight statement
- [ ] Syntheses are stored as first-class entities in the memory web with their own association links (linked to constituent memories and to other syntheses)
- [ ] Consolidation respects The Sentinel's compartmentalization — memories from different compartments are never consolidated together
- [ ] Each consolidation run processes a maximum of N memory clusters (default 10) to bound compute costs

## Scenario: Consolidating a week of debugging memories
- **Given** 8 memories from the past week all relate to "intermittent API timeout" with escalating frustration (0.3 → 0.9) and eventual resolution
- **When** The Dreamer runs background consolidation
- **Then** a Synthesis entity is created: summary "Intermittent API timeouts traced to connection pool exhaustion under load; resolved by increasing pool size and adding circuit breaker", emotional_arc: "curiosity → frustration → breakthrough → satisfaction", themes: ["connection-pooling", "resilience-patterns", "debugging-methodology"], insight: "Timeout symptoms often mask resource exhaustion — check pool sizes before network investigation"

## Scenario: Consolidation blocked by compartmentalization
- **Given** 5 memories about "auth system redesign" are in compartment "security-sensitive" and 3 related memories about "API refactoring" are in compartment "general"
- **When** The Dreamer attempts consolidation
- **Then** two separate synthesis entities are created (one per compartment), and no cross-compartment synthesis is attempted

## Technical Notes
- Consolidation is analogous to sleep-based memory consolidation in biological systems
- The LLM-based synthesis step is the most expensive operation — batch and rate-limit carefully
- Syntheses should have their own salience scores and decay curves (typically slower decay than raw memories)
- Consider a "consolidation depth" parameter: shallow (theme extraction only) vs. deep (full insight generation)

## Related Stories
- story-011: Weaver association links determine which memories are consolidation candidates
- story-017: Promotion decisions can be informed by whether a memory is part of a synthesis
- story-021: Sentinel compartmentalization constrains consolidation boundaries
- story-013: Weaver pattern discovery feeds into consolidation by identifying memory clusters
