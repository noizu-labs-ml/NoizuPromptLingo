---
id: story-028
title: "Tune association weights and decay parameters"
persona: persona-human-operator
priority: should-have
complexity: M
status: draft
---

# Tune association weights and decay parameters

**As** the Human Operator,
**I want to** manually adjust association link weights, decay parameters, recall scoring weights, and promotion thresholds through an administrative interface,
**So that** I can correct system behavior when automated tuning produces suboptimal results, and calibrate the memory system for specific deployment contexts.

## Acceptance Criteria
- [ ] Admin interface allows direct weight adjustment on individual association links with a reason field (logged for audit)
- [ ] Global decay parameters (base half-life, emotional intensity modifier, recall reset behavior) are editable with preview of impact on current memory distribution
- [ ] Recall scoring weights (semantic, emotional, recency, salience blend) are adjustable with a test query to preview ranking changes
- [ ] Promotion thresholds (recall count, emotional intensity, evaluation window duration) are editable
- [ ] All parameter changes are versioned — previous configurations can be viewed and rolled back
- [ ] A "simulation mode" allows previewing the effect of parameter changes on a sample of memories before applying globally

## Scenario: Boosting emotional recall weight for a therapy-focused deployment
- **Given** a deployment where emotional context is more important than semantic precision for recall quality
- **When** the Human Operator adjusts recall scoring weights from {semantic: 0.4, emotional: 0.3} to {semantic: 0.25, emotional: 0.5}
- **Then** the change is saved as version N+1, a test query shows the re-ranked results with emotional memories promoted, and the operator confirms application

## Scenario: Rolling back aggressive decay parameters
- **Given** a previous parameter change reduced the base half-life from 30 days to 7 days, causing too many memories to hit the pruning threshold
- **When** the Human Operator opens the parameter version history and selects rollback to version N-1
- **Then** the base half-life is restored to 30 days, affected memories' salience scores are recalculated, and a note is logged: "rollback: aggressive decay caused excessive pruning"

## Technical Notes
- The simulation mode is critical for safe tuning — parameter changes can have cascading effects through the system
- Consider implementing "parameter presets" for common deployment profiles (knowledge-worker, creative, therapeutic, technical-support)
- All parameter changes should emit events to The Monitor for anomaly correlation
- The versioning system should store diffs, not full snapshots, for storage efficiency
- Individual link weight adjustments should have a `source: manual` tag to distinguish from automated adjustments

## Related Stories
- story-012: Automated weight adjustment by The Weaver — manual tuning overrides or supplements this
- story-015: Decay parameters controlled here directly affect The Curator's behavior
- story-017: Promotion thresholds controlled here affect which memories become long-term
- story-024: Recall scoring weights controlled here affect The Recall Agent's ranking behavior
- story-027: Operator dashboard provides the observability that informs tuning decisions
