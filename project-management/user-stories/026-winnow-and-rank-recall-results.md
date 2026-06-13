---
id: story-026
title: "Winnow and rank recall results for relevance"
persona: persona-the-recall-agent
priority: must-have
complexity: L
status: draft
---

# Winnow and rank recall results for relevance

**As** The Recall Agent,
**I want to** apply a winnowing pass to multi-path search results — filtering out low-relevance candidates, re-ranking by contextual fit, and returning a concise, high-signal result set,
**So that** the calling agent receives a focused set of memories rather than a noisy list of everything tangentially related.

## Acceptance Criteria
- [ ] Winnowing reduces the merged candidate set (up to 100 candidates) to a final result set of N memories (configurable, default 5-10)
- [ ] Re-ranking uses a cross-encoder or LLM-based relevance scorer that considers the original query, current emotional context, and each candidate's full metadata
- [ ] Results below a minimum relevance threshold (configurable, default 0.3) are excluded even if they would fill the result count
- [ ] Each result includes a `relevance_score`, `relevance_explanation` (1-sentence justification), and `retrieval_paths` (which search paths surfaced it)
- [ ] Counterfactual entities (story-020) are ranked with a 0.7x discount and labeled `[counterfactual]`
- [ ] Winnowing adds <200ms to total recall latency

## Scenario: Winnowing from 80 candidates to 7 results
- **Given** multi-path search returns 80 unique candidates for "How should we handle the auth migration?"
- **When** The Recall Agent applies winnowing
- **Then** 7 memories are returned: 3 about past auth migrations (high semantic relevance), 2 about data migration best practices (emotional resonance — previous migration anxiety), 1 synthesis about migration methodology, and 1 about the current auth system architecture — each with relevance scores from 0.92 to 0.45

## Scenario: All candidates below threshold
- **Given** a query about a topic with no relevant memories in the web
- **When** winnowing evaluates all 15 candidates and finds none above the 0.3 threshold
- **Then** an empty result set is returned with metadata `{ result_count: 0, candidates_evaluated: 15, reason: "no candidates above relevance threshold" }`

## Technical Notes
- The cross-encoder re-ranking step is more expensive than initial retrieval but critical for quality — consider caching frequent query patterns
- The LLM-based relevance scorer should be a lightweight model (not the full agent model) for latency reasons
- Relevance explanations serve double duty: they help the calling agent understand why a memory was surfaced, and they generate recall feedback for The Weaver's weight adjustment (story-012)
- Consider implementing "diversity-aware" re-ranking: if the top 5 results all come from the same topic cluster, inject one from a different cluster for breadth

## Related Stories
- story-025: Multi-path search produces the candidate set that winnowing refines
- story-012: Recall feedback (accepted/rejected results) feeds Weaver weight adjustment
- story-020: Counterfactual entities need special handling during winnowing
- story-024: Emotional recall results are blended into the winnowing process
- story-021: Access gating is applied before winnowing — only authorized memories enter the candidate pool
