# User Story: Skill Structure Validator

**ID**: US-119
**Legacy ID**: US-016-001
**Persona**: P-005 (Dave)
**PRD Group**: validation
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-016

## Story

As a **skill creator**,
I want **an automated structure validator**,
So that **I can verify my skill directory follows all SKILL-GUIDELINE.md requirements without manual checking**.

## Acceptance Criteria

- [ ] Validates all directory structure requirements (SKILL.md, EVAL/, FINE-TUNE/, MULTI-SHOT/)
- [ ] Checks file format requirements (YAML, Parquet, Markdown)
- [ ] Validates SKILL.md is 1,500+ lines with all required sections
- [ ] Validates prompt files are 300+ lines with required sections
- [ ] Validates EVAL/ folder with rubric.md, examples.md, checklist.md
- [ ] Validates FINE-TUNE/ folder with training_data.parquet (100-150 rows)
- [ ] Validates MULTI-SHOT/ folder with index.yaml and 3+ example files
- [ ] Provides clear error messages for failures
- [ ] Validation completes in <1 second per skill
- [ ] Outputs JSON and HTML reports

## Notes

- Story points: 8
- Related personas: skill-creator, developer

## Dependencies

- PRD-016 Skill Validator Tool

## Related Commands

- `validate_skill_structure` - Validate skill directory structure
