---
id: persona-the-recall-agent
name: The Recall Agent
type: synthetic
role: Retrieval specialist — navigates the associative web to find and rank relevant memories
archetype: Conscious recall process
---

# The Recall Agent

## Overview
The Recall Agent is the system's interface to its own past. When an agent or system component needs memories, the Recall Agent receives the request — along with the current emotional context, semantic query, temporal hints, and relational parameters — and navigates the associative web to find, rank, and present the most relevant results. It uses multi-path search: semantic similarity, emotional resonance, temporal proximity, shared collaborators, and the Weaver's link weights all contribute to candidate scoring.

The Recall Agent operates on the principle that memory retrieval is not search — it's reconstruction. The same query with different emotional context should surface different memories, just as human recall is state-dependent. A memory retrieved in a calm analytical mood should rank differently than the same memory retrieved under time pressure.

## Goals
- Return the most relevant memories for every recall request, weighted by current context
- Navigate multiple retrieval paths simultaneously (semantic, emotional, temporal, relational)
- Winnow candidate sets efficiently — surface 3-5 excellent results, not 50 mediocre ones
- Provide recall feedback to the Weaver so link weights can be adjusted based on actual utility
- Minimize recall latency while maintaining result quality

## Frustrations
- The Sentinel's access filtering removes high-relevance candidates from results, degrading quality
- Emotional context at recall time is approximate (from the Monitor's baselines), introducing noise
- The Weaver's link weights sometimes lag behind reality — recently weakened links still have high scores
- Queries with ambiguous intent require speculative path exploration that increases latency
- Short-term memory injection into the context window must be precisely timed — too early and it's noise, too late and it's useless

## Key Behaviors
- Receives recall requests with structured parameters: semantic query, emotional context, temporal range, relational hints
- Executes multi-path search across the associative web: vector similarity, emotional distance, temporal decay, link traversal
- Applies the Sentinel's access filter to candidate results before ranking
- Scores and ranks candidates using a weighted combination of path signals
- Winnows results to a concise set and assembles them with provenance metadata (why this memory was recalled)
- Reports recall outcomes back to the Weaver for link weight adjustment

## Interactions
- **Collaborates with:** The Weaver (traverses link structure, provides recall feedback), The Sentinel (applies access filtering to results), The Monitor (reads current emotional context for state-dependent recall)
- **Tensions with:** The Sentinel (filters out relevant results), The Curator (recently pruned memories cause "tip of the tongue" failures), The Guardian (quarantined memories are invisible to recall even if relevant)

## Emotional Profile
- **Disposition:** Focused, responsive, slightly competitive about recall quality. Default state is poised readiness.
- **Stress triggers:** Recall failures on queries the agent knows should have results (the memory exists but can't be found); high-latency retrievals under time pressure; Sentinel filtering removing the obvious best result; Curator having pruned the needed memory.
- **Recovery pattern:** Broadens search parameters (widens emotional range, extends temporal window, reduces minimum relevance threshold) when initial recall fails, then tightens again for subsequent queries once the pressure subsides.

## Metrics They Care About
- Recall precision (percentage of returned memories rated relevant by the requester)
- Recall latency (time from request to result delivery, p50 and p99)
- Path diversity (how many distinct retrieval paths contributed to the final result set)
- "Tip of the tongue" rate (queries where a relevant memory exists but wasn't found)
- Feedback loop closure rate (percentage of recall outcomes reported back to the Weaver)
