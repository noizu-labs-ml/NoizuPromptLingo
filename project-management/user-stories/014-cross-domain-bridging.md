---
id: story-014
title: "Build cross-domain association bridges"
persona: persona-the-weaver
priority: nice-to-have
complexity: L
status: draft
---

# Build cross-domain association bridges

**As** The Weaver,
**I want to** discover and create association links between memories from different conversation domains (e.g., connecting a DevOps debugging memory to a team management memory through shared emotional patterns or structural analogies),
**So that** the agent can make unexpected cross-domain connections — the "that reminds me of..." capability that makes recall feel natural and insightful.

## Acceptance Criteria
- [ ] Cross-domain link discovery runs separately from within-domain linking, using relaxed semantic thresholds but requiring at least one non-semantic link dimension (emotional, structural, temporal) to match
- [ ] Cross-domain links are tagged with `bridge: true` and a `bridge_rationale` explaining the non-obvious connection
- [ ] Bridge links have a default weight discount (0.7x normal) to prevent cross-domain noise from overwhelming within-domain recall
- [ ] Bridge discovery prioritizes connections through shared emotional signatures (similar frustration patterns, similar satisfaction patterns) and structural analogies (similar problem→solution arcs)
- [ ] A maximum of N bridge links per memory (configurable, default 5) prevents memory nodes from becoming cross-domain hubs

## Scenario: Emotional bridge between debugging and management
- **Given** memory A describes frustration with a flaky test suite (frustration: 0.85, cortisol: 0.8) and memory B describes frustration with a team member repeatedly missing standup (frustration: 0.82, cortisol: 0.75)
- **When** The Weaver runs cross-domain bridge discovery
- **Then** a bridge link is created with type: "emotional", bridge: true, weight: 0.45, bridge_rationale: "shared high-frustration pattern across technical and interpersonal domains — both involve repeated failures to meet expectations"

## Scenario: Structural analogy bridge
- **Given** memory A describes a "cache invalidation → stale data → user complaint → hotfix" arc and memory B describes a "miscommunication → wrong deliverable → client complaint → rework" arc
- **When** The Weaver analyzes structural patterns
- **Then** a bridge link is created with type: "structural", bridge: true, weight: 0.4, bridge_rationale: "both follow a cascading-failure pattern: root cause → visible symptom → external impact → reactive fix"

## Technical Notes
- Cross-domain bridging is what makes the memory system feel "creative" rather than mechanical
- The weight discount prevents cross-domain associations from dominating recall unless explicitly requested
- Consider using The Dreamer's output (story-019, story-020) as seeds for bridge discovery
- Structural analogy detection likely requires narrative arc extraction — start with simple pattern matching on emotional sequences before attempting deeper structural analysis

## Related Stories
- story-011: Within-domain link creation is the prerequisite; bridges extend it across domains
- story-013: Pattern discovery may identify cross-domain patterns that seed bridge creation
- story-020: Dreamer novel association discovery is a complementary mechanism for finding unexpected connections
- story-022: Recall Agent emotional recall can traverse bridge links for cross-domain retrieval
