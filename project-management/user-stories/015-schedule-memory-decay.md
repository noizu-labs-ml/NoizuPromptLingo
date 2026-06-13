---
id: story-015
title: "Schedule memory decay based on relevance and recency"
persona: persona-the-curator
priority: must-have
complexity: L
status: draft
---

# Schedule memory decay based on relevance and recency

**As** The Curator,
**I want to** apply time-based decay to memory salience scores, with decay rates modulated by emotional intensity, recall frequency, and association density,
**So that** the memory web naturally forgets low-value memories while preserving emotionally significant and frequently accessed ones — mimicking organic forgetting curves.

## Acceptance Criteria
- [ ] Each memory has a `salience` score (0.0 to 1.0) that decays over time according to a modified Ebbinghaus forgetting curve
- [ ] Decay rate modifiers: high emotional intensity slows decay (0.5x), frequent recall resets the decay clock, high association degree slows decay (0.7x per 5+ links)
- [ ] Memories reaching salience <0.1 are flagged as `decay_candidate` for pruning review
- [ ] Decay computation runs as a daily batch job, updating salience scores across all memories
- [ ] Memories with `pinned: true` flag are exempt from decay (set by Human Operator or promotion from short-term)
- [ ] Decay parameters (base half-life, modifier weights) are configurable per memory type and domain

## Scenario: Routine memory decays normally
- **Given** a 90-day-old memory about a routine deployment with neutral emotional metadata, no recalls, and 2 association links
- **When** The Curator runs the daily decay job
- **Then** the memory's salience drops from 0.35 to 0.28 (standard decay rate), approaching the pruning threshold

## Scenario: Emotionally intense memory resists decay
- **Given** a 90-day-old memory about a critical production outage with high emotional intensity (frustration: 0.95, cortisol: 0.9), recalled 3 times, and 8 association links
- **When** The Curator runs the daily decay job
- **Then** the memory's salience remains at 0.72 (emotional intensity 0.5x decay, high link density 0.7x decay, recent recall reset), far above pruning threshold

## Technical Notes
- The Ebbinghaus curve provides a well-understood base model: R = e^(-t/S) where S is stability (modulated by our factors)
- Consider implementing spaced repetition principles: each successful recall increases the stability parameter
- Decay should be computed incrementally (delta since last computation) not recomputed from creation time
- The interaction between decay and The Weaver's passive link weight decay (story-012) should be coordinated to avoid double-counting

## Related Stories
- story-012: Weaver link weight decay is a parallel mechanism — coordinate to avoid compounding
- story-016: Pruning acts on memories that decay below threshold
- story-017: Short-to-long promotion pins memories, making them decay-exempt
- story-008: Monitor mood drift tracking may influence decay parameters (avoid pruning positive memories during negative drift periods)
