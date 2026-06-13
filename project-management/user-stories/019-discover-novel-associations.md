---
id: story-019
title: "Discover novel cross-domain associations"
persona: persona-the-dreamer
priority: nice-to-have
complexity: L
status: draft
---

# Discover novel cross-domain associations

**As** The Dreamer,
**I want to** explore the memory web for unexpected connections between distant memory clusters — associations that The Weaver's proximity-based linking would not discover,
**So that** the agent can generate creative insights by connecting ideas from different domains, time periods, and emotional contexts.

## Acceptance Criteria
- [ ] Novel association discovery uses random walk + restart on the memory graph to find structurally distant but potentially meaningful connections
- [ ] Candidate connections are scored by "surprise value": high semantic distance but shared structural patterns (similar emotional arcs, analogous problem shapes, temporal echoes)
- [ ] Only candidates exceeding a minimum surprise threshold (configurable, default 0.6) are proposed as novel associations
- [ ] Novel associations are stored as `NovelLink` entities with type: "dreamer_discovery", a `rationale` explaining the connection, and a `surprise_score`
- [ ] The Dreamer proposes a maximum of N novel associations per run (default 5) to prevent noise
- [ ] Novel associations are initially created with low weight (0.2) and must be reinforced by recall to strengthen

## Scenario: Connecting a coding pattern to a cooking metaphor
- **Given** memory A discusses "layered architecture with clear separation of concerns" and memory B (from a personal conversation) discusses "mise en place — preparing all ingredients before cooking"
- **When** The Dreamer runs novel association discovery
- **Then** a NovelLink is created with surprise_score: 0.78, rationale: "both describe preparation-and-layering strategies where upfront organization prevents downstream chaos — architectural mise en place", weight: 0.2

## Scenario: Temporal echo across years
- **Given** memory A from December 2024 describes "year-end sprint pressure causing corners to be cut" and memory B from December 2023 describes the same pattern
- **When** The Dreamer identifies the temporal echo
- **Then** a NovelLink is created with surprise_score: 0.65, rationale: "recurring seasonal pattern — year-end pressure leads to technical debt accumulation, two years running", weight: 0.2

## Technical Notes
- Novel association discovery is computationally expensive — schedule during off-peak hours alongside consolidation
- Random walk with restart (personalized PageRank) is a good starting algorithm for finding distant-but-relevant nodes
- The "surprise value" metric should combine: graph distance (longer path = more surprising), semantic distance (different domains = more surprising), and structural similarity (similar shapes = more meaningful)
- This is the most "creative" component of the system — accept that precision will be lower than other components

## Related Stories
- story-014: Weaver cross-domain bridging handles proximity-detectable cross-domain links; this handles truly distant ones
- story-018: Background consolidation may use novel associations as seeds for synthesis
- story-012: Recall-based weight adjustment will strengthen or let novel associations decay naturally
- story-020: Counterfactual simulation can explore "what if" scenarios using novel association paths
