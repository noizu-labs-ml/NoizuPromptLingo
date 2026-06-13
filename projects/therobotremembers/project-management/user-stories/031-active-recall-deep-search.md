---
id: story-031
title: "Active Recall: Deep Multi-Path Search on Explicit Request"
persona: persona-the-recall-agent
priority: must-have
complexity: XL
status: draft
---

# Active Recall: Deep Multi-Path Search on Explicit Request

**As** the Recall Agent,
**I want to** perform a deep, exhaustive multi-path search when explicitly asked "what do I know about X?",
**So that** the requesting agent gets a comprehensive, structured view of everything the system knows about a topic — including emotionally resonant and tangentially related memories.

## Acceptance Criteria
- [ ] Active recall triggers on explicit API call or agent self-query (not on passive conversation)
- [ ] Search traverses all three paths: semantic (vector), emotional (metadata), relational (graph edges up to 3 hops)
- [ ] Candidate pool is large (up to 50 memories before winnowing)
- [ ] Winnowed result set is 10–20 memories, ranked by composite relevance score
- [ ] Latency stays under 2 seconds for 95th percentile
- [ ] Results are formatted as structured XML with full content for top-5, summaries for the rest
- [ ] If initial results are sparse (< 5 candidates), the Dreamer is invoked for real-time synthesis
- [ ] All recalled memories receive reinforcement signals (weight bump + recall_count increment)
- [ ] Association edges used in the recall path are also reinforced

## Scenario: Deep search on known topic
- **Given** the agent has 200+ memories, 15 of which relate to "database connection pooling"
- **When** an active recall request arrives for "connection pooling"
- **Then** the system returns 12–15 memories ranked by relevance, including 3 emotionally resonant memories from frustrating debugging sessions that mention pooling tangentially

## Scenario: Sparse topic triggers Dreamer
- **Given** the agent has only 2 direct memories about "Kubernetes RBAC"
- **When** an active recall request arrives for "RBAC"
- **Then** the system invokes the Dreamer for real-time synthesis, which finds 4 additional memories related via access-control patterns and security frustration, returning 6 total

## Scenario: Active recall under emotional distress
- **Given** the agent's current emotional state is high cortisol / low serotonin (stressed)
- **When** an active recall is triggered for "deployment failures"
- **Then** memories formed under similar stress states are boosted by emotional resonance, surfacing a memory about a 3 AM prod incident that wouldn't rank highly on content alone

## Technical Notes
- Active recall uses the full retrieval pipeline: Vector DB → Postgres metadata filter → Graph traversal → Winnowing
- The composite relevance score combines: semantic_similarity * 0.4 + emotional_resonance * 0.25 + recency * 0.15 + association_weight * 0.2
- Dreamer invocation adds ~500ms latency; only trigger when candidate pool < 5
- Token budget for active recall injection: up to 2000 tokens

## Related Stories
- story-024: Emotional context recall (foundational retrieval)
- story-025: Multi-path recall search (the search mechanics this builds on)
- story-026: Winnow and rank recall results (winnowing pipeline)
- story-032: Tangential insertion (the other retrieval mode — contrasts this)
- story-019: Dreamer discovers novel associations (invoked when results are sparse)
