---
id: story-024
title: "Recall memories by emotional context"
persona: persona-the-recall-agent
priority: must-have
complexity: L
status: draft
---

# Recall memories by emotional context

**As** The Recall Agent,
**I want to** retrieve memories by matching the current emotional context (mood, frustration level, simulated hormones) against stored emotional metadata,
**So that** the agent can recall experiences that "felt like this" — enabling mood-congruent recall that surfaces contextually relevant memories beyond keyword matching.

## Acceptance Criteria
- [ ] Recall queries accept an `emotional_context` parameter with mood valence, arousal, frustration, and hormone levels
- [ ] Emotional similarity is computed using cosine similarity across the emotional metadata vector
- [ ] Results are ranked by a blended score: configurable weights for semantic relevance (default 0.4), emotional similarity (default 0.3), recency (default 0.15), and salience (default 0.15)
- [ ] A `recall_mode` parameter allows: `semantic_only`, `emotional_only`, `blended` (default), or `emotional_boost` (2x emotional weight)
- [ ] Emotional recall respects access gating and compartmentalization
- [ ] Response includes the emotional similarity score per result for transparency

## Scenario: Recalling similar frustration experiences
- **Given** the current interaction has high frustration (0.85) and elevated cortisol (0.8) related to a deployment failure
- **When** The Recall Agent searches with `emotional_context: {frustration: 0.85, cortisol: 0.8}` in `emotional_boost` mode
- **Then** memories of past deployment failures, CI/CD incidents, and other high-frustration operational events are returned, ranked by emotional similarity, even if the specific technologies differ

## Scenario: Mood-congruent recall surfaces forgotten context
- **Given** the current interaction has calm satisfaction (valence: 0.7, serotonin: 0.8) after completing a project milestone
- **When** The Recall Agent searches with the satisfaction emotional context
- **Then** memories of past successful completions, positive retrospectives, and celebrations are surfaced — providing context like "last time we finished a milestone like this, we took a team lunch and then started planning the next quarter"

## Technical Notes
- Emotional recall is the key differentiator of this memory system — it enables "that reminds me of how I felt when..." retrieval
- The emotional metadata vector should be normalized before cosine similarity computation
- Consider caching frequently-accessed emotional embeddings for recall performance
- The blended scoring weights should be tunable per agent deployment (story-026)
- Emotional recall can traverse Weaver's emotional-type association links for expanded results

## Related Stories
- story-001: Emotional metadata captured by The Archivist is the foundation for emotional recall
- story-011: Weaver emotional-type links can be traversed for expanded recall paths
- story-021: Sentinel access gating filters results before they are returned
- story-025: Multi-path search uses emotional recall as one of several retrieval strategies
