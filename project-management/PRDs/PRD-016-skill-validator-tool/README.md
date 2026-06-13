# PRD-016: Skill Validator Tool

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

Automated validation and evaluation framework for skills. Creating skills requires following SKILL-GUIDELINE.md, which has many requirements including directory structure, specific file formats, content standards, and quality metrics. Without validation, manual checking is error-prone and time-consuming, quality issues are discovered late, skill structure becomes inconsistent, and onboarding new creators is difficult.

This PRD defines a two-part validator:
1. **Structure Validator**: Checks that skill directory follows SKILL-GUIDELINE.md requirements
2. **Quality Evaluator**: Evaluates skill quality using Arize Phoenix

## Goals

1. Automate skill structure validation against SKILL-GUIDELINE.md requirements
2. Provide quality evaluation using Arize Phoenix for fine-tuning datasets and multi-shot examples
3. Generate actionable reports with clear error messages and improvement recommendations
4. Create interactive Jupyter notebooks for quality exploration
5. Enable <1 second validation time per skill
6. Support JSON and HTML report formats

## Non-Goals

- Pre-commit hooks (future enhancement)
- GitHub Actions integration (future enhancement)
- Skill quality dashboard (future enhancement)
- Automated fix suggestions (future enhancement)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority | Story Points |
|----|-------|---------|----------|--------------|
| US-119 | [Skill Structure Validator](../../user-stories/US-119-skill-structure-validator.md) | P-005 | high | 8 |
| US-120 | [Skill Quality Evaluator with Arize Phoenix](../../user-stories/US-120-skill-quality-evaluator.md) | P-005 | high | 8 |

**Note**: Legacy IDs US-016-001, US-016-002 have been consolidated to global IDs US-119, US-120.

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-016-001**: [Structure Validation Engine](./functional-requirements/FR-016-001-structure-validation-engine.md) - Validates skill directory structure
- **FR-016-002**: [File Format Validators](./functional-requirements/FR-016-002-file-format-validators.md) - YAML, Parquet, Markdown validators
- **FR-016-003**: [CLI Interface](./functional-requirements/FR-016-003-cli-interface.md) - Command-line interface
- **FR-016-004**: [Arize Phoenix Integration](./functional-requirements/FR-016-004-arize-phoenix-integration.md) - Phoenix evaluation integration
- **FR-016-005**: [EVAL Rubric Parser](./functional-requirements/FR-016-005-eval-rubric-parser.md) - Parse rubric files
- **FR-016-006**: [Evaluation Engine](./functional-requirements/FR-016-006-evaluation-engine.md) - Score examples against rubrics
- **FR-016-007**: [Jupyter Notebook Generator](./functional-requirements/FR-016-007-jupyter-notebook-generator.md) - Generate interactive notebooks

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-016-001 | Test coverage | Line coverage | >= 80% |
| NFR-016-002 | Validation performance | Time per skill | < 1 second |
| NFR-016-003 | Report generation | JSON output | Valid JSON schema |
| NFR-016-004 | CLI usability | Error messages | Clear and actionable |
| NFR-016-005 | Phoenix integration | Fallback handling | Graceful degradation |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Missing directory | ValidationError | "Required directory not found: {path}" |
| Invalid YAML | ParseError | "YAML syntax error in {file}: {details}" |
| Corrupted Parquet | DataError | "Cannot read Parquet file: {file}" |
| Missing columns | SchemaError | "Required columns missing: {columns}" |
| Low dataset quality | QualityWarning | "{count} examples below 3.0/4.0 threshold" |
| Phoenix unavailable | ConnectionError | "Phoenix unavailable, using local evaluation" |
| Invalid rubric | RubricError | "Rubric validation failed: {reason}" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Test categories:
- **Unit Tests**: File format validators, rubric parsing, evaluation engine
- **Integration Tests**: Structure validator, CLI interface, Phoenix integration
- **End-to-End Tests**: Complete validation workflow

---

## Success Criteria

### Part 1: Structure Validator
1. Validates all directory structure requirements
2. Checks all file format requirements (YAML, Parquet, Markdown)
3. Clear error messages for failures
4. <1 second validation time per skill
5. JSON + HTML report output
6. CLI interface is intuitive

### Part 2: Quality Evaluator
1. Loads EVAL rubrics correctly
2. Runs Arize Phoenix evaluations
3. Generates Jupyter notebook with 7+ analysis cells
4. Shows dimension-by-dimension breakdown
5. Identifies low-quality training examples (score < 3.0/4.0)
6. Provides actionable improvement recommendations
7. Notebook is interactive and explorable

### Overall
- All user stories implemented with acceptance criteria passing
- Test coverage >= 80% for all new code
- All acceptance tests passing
- Clear and actionable error messages

---

## Out of Scope

- Pre-commit hook integration
- GitHub Actions workflow
- Skill quality dashboard (view all skills)
- Automated fix suggestions
- Quality metric trending over time
- Skill-to-skill comparisons

---

## Dependencies

- **pandas**: Parquet file handling
- **PyYAML**: YAML parsing
- **markdown**: Markdown parsing and validation
- **Arize Phoenix**: Quality evaluation and dashboards
- **Jupyter**: Notebook generation
- **matplotlib/seaborn**: Visualizations in notebooks

---

## Deliverables

### Structure Validator
- `tools/skill_validator.py` - Main CLI tool
- `tools/validators/` - Modular validator components
  - `structure_validator.py`
  - `skill_md_validator.py`
  - `eval_validator.py`
  - `fine_tune_validator.py`
  - `multi_shot_validator.py`

### Quality Evaluator
- `tools/skill_evaluator.py` - Arize Phoenix integration
- `notebooks/skill_evaluation_template.ipynb` - Template notebook
- `tools/arize_integration.py` - Phoenix client setup

---

## Timeline

**Part 1 (Structure Validator):** 8-12 hours
- Core validator logic
- Format validation (YAML, Parquet, Markdown)
- CLI interface
- Report generation

**Part 2 (Quality Evaluator):** 8-10 hours
- Arize Phoenix integration
- EVAL rubric parser
- Evaluation logic
- Jupyter notebook templates
- Visualization components

**Total:** 16-22 hours

---

## Open Questions

- [ ] Should we support other notebook formats (LiveBook, Observable)?
- [ ] What Phoenix version/API should we target?
- [ ] Should HTML reports include embedded visualizations?
- [ ] Do we need support for custom rubric formats beyond standard markdown?
