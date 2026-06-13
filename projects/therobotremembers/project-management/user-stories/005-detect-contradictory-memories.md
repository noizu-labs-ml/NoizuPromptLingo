---
id: story-005
title: "Detect contradictory memories before storage"
persona: persona-the-guardian
priority: must-have
complexity: XL
status: draft
---

# Detect contradictory memories before storage

**As** The Guardian,
**I want to** detect when an incoming memory directly contradicts an existing memory and flag the contradiction for resolution before allowing storage,
**So that** the memory web maintains logical consistency and agents do not recall conflicting facts as equally valid.

## Acceptance Criteria
- [ ] Incoming memories are compared against semantically similar existing memories using vector similarity + keyword overlap
- [ ] Contradictions are classified by severity: `hard` (factual opposites), `soft` (nuanced disagreement), `temporal` (superseded by newer information)
- [ ] Hard contradictions block storage and raise a `ContradictionAlert` with both memory records attached
- [ ] Soft contradictions allow storage but tag both memories with `contradiction_ref` links and `confidence_degraded` flags
- [ ] Temporal contradictions trigger a supersession workflow: old memory gets `superseded_by` reference, new memory gets `supersedes` reference
- [ ] Contradiction checks complete within 500ms for real-time ingestion paths

## Scenario: Hard factual contradiction
- **Given** an existing memory states "The production database runs PostgreSQL 15"
- **When** a new memory arrives stating "The production database runs MySQL 8"
- **Then** The Guardian blocks the new memory, raises a `ContradictionAlert` with severity `hard`, and presents both memories to the operator for resolution

## Scenario: Temporal supersession
- **Given** an existing memory from January states "The API rate limit is 100 req/s"
- **When** a new memory from March states "The API rate limit is 500 req/s"
- **Then** The Guardian marks the January memory as `superseded_by: story-new` and stores the new memory with `supersedes: story-old`, both linked bidirectionally

## Technical Notes
- Contradiction detection is one of the hardest problems in the system — start with high-precision/low-recall and tune
- Consider using an LLM-in-the-loop for hard contradiction classification, with a simpler embedding-distance check as a pre-filter
- The emotional metadata can help: if the contradicting memory has very different mood/frustration values, it may indicate context shift rather than factual contradiction
- Temporal contradictions are the most common case — build the supersession workflow robustly first

## Related Stories
- story-001: Emotional metadata helps distinguish context-dependent contradictions from factual ones
- story-006: Injection blocking is a related Guardian function — some contradictions may be adversarial
- story-015: Curator pruning may resolve soft contradictions by merging or removing low-confidence versions
- story-007: Guardian integrity validation runs periodically to catch contradictions missed at ingestion time
