# User Story: Skill Quality Evaluator with Arize Phoenix

**ID**: US-120
**Legacy ID**: US-016-002
**Persona**: P-005 (Dave)
**PRD Group**: validation
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-016

## Story

As a **skill creator**,
I want **an automated quality evaluator using Arize Phoenix**,
So that **I can measure the quality of my skill's fine-tuning dataset and multi-shot examples against the EVAL rubric**.

## Acceptance Criteria

- [ ] Loads and parses EVAL/rubric.md into Phoenix metrics
- [ ] Evaluates fine-tuning dataset samples (10-20 examples) against rubric
- [ ] Evaluates multi-shot examples against rubric
- [ ] Generates Arize Phoenix dashboard with quality metrics
- [ ] Creates interactive Jupyter notebook with 7+ analysis cells
- [ ] Shows dimension-by-dimension breakdown
- [ ] Identifies low-quality training examples (score < 3.0/4.0)
- [ ] Provides actionable improvement recommendations
- [ ] Allows comparison across multiple skills
- [ ] Tracks quality metrics over time

## Notes

- Story points: 8
- Related personas: skill-creator, quality-engineer

## Dependencies

- US-119 Skill Structure Validator
- PRD-016 Skill Validator Tool
- Arize Phoenix installation

## Related Commands

- `evaluate_skill_quality` - Evaluate skill quality with Phoenix
