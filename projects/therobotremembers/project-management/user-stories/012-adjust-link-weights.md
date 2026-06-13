---
id: story-012
title: "Adjust association link weights based on recall patterns"
persona: persona-the-weaver
priority: should-have
complexity: M
status: draft
---

# Adjust association link weights based on recall patterns

**As** The Weaver,
**I want to** strengthen links that are frequently traversed during successful recalls and weaken links that are never used or lead to irrelevant results,
**So that** the association graph self-optimizes over time, surfacing the most useful connections and letting noise fade.

## Acceptance Criteria
- [ ] Each recall event logs which association links were traversed and whether the recalled memory was accepted (used) or rejected (skipped/irrelevant)
- [ ] Traversed-and-accepted links receive a weight boost (configurable, default +0.05 per successful recall)
- [ ] Traversed-and-rejected links receive a weight penalty (configurable, default -0.02 per rejection)
- [ ] Links that have not been traversed in N days (configurable, default 90) receive passive decay of -0.01/day
- [ ] Weight adjustments are bounded: weights cannot exceed 1.0 or drop below 0.05 (at 0.05 the link is flagged for pruning consideration)
- [ ] Weight adjustment history is logged for auditability (timestamp, old_weight, new_weight, reason)

## Scenario: Frequently useful association strengthens
- **Given** a link between "Redis timeout" and "connection pool exhaustion" memories has weight 0.6 and has been traversed in 5 successful recalls this week
- **When** The Weaver processes the recall feedback
- **Then** the link weight increases to 0.85 (5 * 0.05 boost), and the adjustment is logged with reason: "5 successful recall traversals"

## Scenario: Stale link decays toward pruning threshold
- **Given** a link with weight 0.15 has not been traversed in 120 days
- **When** The Weaver processes passive decay
- **Then** the link weight drops to 0.05, is flagged with `prune_candidate: true`, and The Curator is notified for pruning consideration

## Technical Notes
- The reinforcement loop (recall → weight adjustment → better future recall) is the core learning mechanism of the memory web
- Weight adjustment should be batched and processed asynchronously to avoid slowing recall
- Consider a "recency-weighted" boost where recent successful traversals count more than old ones
- The decay rate should be tunable per link type — emotional links may decay slower than temporal links

## Related Stories
- story-011: Link creation establishes initial weights; this story refines them
- story-015: Curator pruning acts on links that decay to the pruning threshold
- story-022: Recall Agent traversals generate the feedback that drives weight adjustment
- story-026: Human Operator weight tuning allows manual override of automated weight adjustments
