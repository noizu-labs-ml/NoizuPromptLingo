---
id: story-032
title: "Tangential Insertion: Passive Memory Surfacing During Conversation"
persona: persona-the-recall-agent
priority: must-have
complexity: XL
status: draft
---

# Tangential Insertion: Passive Memory Surfacing During Conversation

**As** the Recall Agent,
**I want to** passively monitor ongoing conversation and inject relevant memories when emotional or contextual resonance exceeds a threshold,
**So that** the agent benefits from its memory without having to explicitly ask — creating the "oh, that reminds me..." experience.

## Acceptance Criteria
- [ ] Tangential insertion runs continuously during active conversation without explicit trigger
- [ ] Latency stays under 100ms — must not disrupt conversational flow
- [ ] Uses pre-computed hot index (Redis/Valkey), NOT the full vector/graph pipeline
- [ ] Only surfaces memories scoring above the tangential threshold (high bar — strong matches only)
- [ ] Winnowed results are 1–3 memories maximum per insertion
- [ ] Injection format is subtle and parenthetical — brief context notes, not structured XML blocks
- [ ] Hot index refreshes on significant emotional state change or every N conversational turns
- [ ] Tangential insertions receive weaker reinforcement signals than active recall (they weren't explicitly sought)
- [ ] Insertion frequency is rate-limited: at most 1 tangential insertion per 5 conversational turns to avoid noise

## Scenario: Emotional resonance triggers tangential recall
- **Given** the agent is debugging a flaky CI pipeline and its cortisol is elevated (0.7)
- **And** the hot index contains a memory about a previous 2 AM debugging session with similar stress levels
- **When** the conversation mentions "intermittent failure"
- **Then** the system injects a brief note: "(Reminds me: similar intermittent failures in the Postgres migration runner last December — root cause was advisory lock contention)"

## Scenario: No tangential insertion when threshold not met
- **Given** the agent is having a routine planning conversation with low emotional intensity
- **And** the hot index has some weakly related memories about project planning
- **When** the conversation discusses sprint priorities
- **Then** no tangential insertion occurs because no memory exceeds the resonance threshold

## Scenario: Hot index refresh on emotional state change
- **Given** the agent's emotional state shifts from calm (cortisol 0.2) to stressed (cortisol 0.7)
- **When** the Monitor broadcasts the state change
- **Then** the hot index is refreshed within 500ms with memories having high emotional resonance for the new stress state
- **And** subsequent conversational turns may trigger tangential insertions from the refreshed index

## Scenario: Rate limiting prevents noise
- **Given** the agent is in an emotionally intense conversation with many potential tangential matches
- **When** a tangential insertion was injected 2 turns ago
- **Then** no new tangential insertion occurs for at least 3 more turns, even if resonance threshold is met

## Technical Notes
- Hot index is maintained in Redis/Valkey as a sorted set keyed by emotional state bucket
- Background prefetch process queries vector DB for top-50 memories matching current emotional state, stores in hot index
- Resonance detector runs a lightweight check on each conversational turn: keyword overlap + emotional state distance
- Tangential insertion token budget: 200 tokens max (1–2 sentences per memory)
- Reinforcement weight for tangential recall is 0.3x the weight of active recall reinforcement
- The Monitor's emotional state broadcast is the primary trigger for hot index refresh

## Related Stories
- story-031: Active recall deep search (the other retrieval mode — contrasts this)
- story-008: Track mood drift over time (emotional state that drives hot index)
- story-024: Emotional context recall (foundational emotional retrieval)
- story-026: Winnow and rank recall results (winnowing at a stricter threshold)
- story-012: Adjust link weights (reinforcement at reduced weight)
