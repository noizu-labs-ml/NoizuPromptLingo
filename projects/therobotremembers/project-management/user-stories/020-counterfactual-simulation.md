---
id: story-020
title: "Simulate counterfactual memory scenarios"
persona: persona-the-dreamer
priority: nice-to-have
complexity: XL
status: draft
---

# Simulate counterfactual memory scenarios

**As** The Dreamer,
**I want to** generate "what if" counterfactual scenarios by traversing the memory graph along alternative paths and simulating different outcomes,
**So that** the agent can reason about alternative histories, learn from near-misses, and surface preventive insights.

## Acceptance Criteria
- [ ] Counterfactual simulation takes a seed memory and a "divergence point" (what if X had been different?) and traces the likely downstream effects through the association graph
- [ ] Simulations produce `Counterfactual` entities with: seed memory, divergence description, simulated outcome, confidence level, and lessons-learned summary
- [ ] Confidence levels are based on the strength of association paths traversed (strong paths = higher confidence)
- [ ] Counterfactuals are stored but clearly tagged as synthetic (not real memories) with `source: counterfactual`
- [ ] A maximum of N counterfactuals are generated per consolidation cycle (default 3)
- [ ] Counterfactuals can be recalled alongside real memories but are always presented with a `[counterfactual]` qualifier

## Scenario: "What if we had added monitoring earlier?"
- **Given** a chain of memories: "deployed without monitoring" → "silent failure went undetected for 3 hours" → "customer data loss discovered" → "incident postmortem"
- **When** The Dreamer simulates the counterfactual "what if monitoring had been added before deployment"
- **Then** a Counterfactual entity is created: divergence: "monitoring added pre-deploy", simulated_outcome: "failure detected within 5 minutes based on similar monitored services' detection times", confidence: 0.7, lesson: "monitoring is a prerequisite for deployment, not a follow-up task"

## Scenario: Low-confidence counterfactual discarded
- **Given** a memory about a team decision with no clear causal chain in the association graph
- **When** The Dreamer attempts counterfactual simulation
- **Then** the simulation produces confidence <0.3 (weak association paths) and is discarded rather than stored

## Technical Notes
- Counterfactual reasoning is speculative by nature — always tag outputs clearly and present with appropriate uncertainty
- This is the most advanced Dreamer capability — implement after consolidation (story-018) and novel association (story-019) are stable
- Causal chain traversal requires directional association links; consider adding a `causal` link type to The Weaver's vocabulary
- Counterfactuals are valuable for incident retrospectives and decision support, not for asserting facts

## Related Stories
- story-018: Background consolidation provides the synthesized understanding that counterfactuals build on
- story-019: Novel associations may reveal alternative paths that seed counterfactual scenarios
- story-011: Weaver association links form the causal chains that counterfactuals traverse
- story-024: Recall Agent winnowing must handle counterfactual entities appropriately (lower ranking, clear labeling)
