# Review: Skill Quality Evaluator with Arize Phoenix

- **Story**: `project-management/user-stories/US-120-skill-quality-evaluator.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A heuristic quality evaluator exists — `src/npl_mcp/skills/validator.py` `evaluate_skill(content, filename)` (validator.py:470-508) scores four dimensions (description, examples, structure, completeness — `QualityScore`/`EvaluationResult` at validator.py:302-313, scorers at :315-440), returns a dimension-by-dimension breakdown with notes, and generates actionable suggestions (`_build_suggestions`, validator.py:442-468). It is exposed as the `Skill.Evaluate` MCP tool and REST endpoint and is well covered by `tests/test_skills_validator.py` (quality tests from :416 onward, e.g., high/low scoring, example-count effects, suggestion generation). However, the story's defining mechanism — Arize Phoenix — is entirely absent: no phoenix/arize dependency, import, or dashboard code exists anywhere in `pyproject.toml` or `src/` (grep confirms), there is no EVAL/rubric.md parsing, no fine-tuning-dataset (Parquet) or MULTI-SHOT evaluation, no Jupyter notebook generation, no cross-skill comparison, and no metric persistence over time. Low-quality identification exists only implicitly (low dimension scores), not against the story's 3.0/4.0 rubric scale. Nothing relevant exists in the Elixir backend (no phoenix/evaluator modules found in backend lib/).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Loads and parses EVAL/rubric.md into Phoenix metrics | Not Met | No rubric parsing or Phoenix integration anywhere in src/ (no arize/phoenix imports; pyproject.toml has no such dependency) |
| Evaluates fine-tuning dataset samples (10-20 examples) against rubric | Not Met | No Parquet/dataset reading code in src/npl_mcp/skills/ |
| Evaluates multi-shot examples against rubric | Partially Met | `_score_examples` counts fenced code blocks in the skill body (validator.py:348-370) — evaluates inline examples, not MULTI-SHOT/ files |
| Generates Arize Phoenix dashboard with quality metrics | Not Met | No Phoenix dashboard/export code exists |
| Creates interactive Jupyter notebook with 7+ analysis cells | Not Met | No notebook generation code found |
| Shows dimension-by-dimension breakdown | Met | `EvaluationResult.dimensions` list of four `QualityScore` entries with score + notes, validator.py:302-313,315-440; asserted in tests/test_skills_validator.py:423-437 |
| Identifies low-quality training examples (score < 3.0/4.0) | Partially Met | Low scores are derivable from the 0-1 dimension scores and drive suggestions (validator.py:442-468), but there is no per-example scoring or 3.0/4.0 threshold |
| Provides actionable improvement recommendations | Met | `_build_suggestions` emits targeted fixes keyed to low dimensions and validation errors, validator.py:442-468; asserted at tests/test_skills_validator.py:491 |
| Allows comparison across multiple skills | Not Met | `evaluate_skill` operates on one skill's content; no batch/compare API exists |
| Tracks quality metrics over time | Not Met | No persistence of evaluation results (results are returned, never stored) |

## Gaps / Risks

- The story name and acceptance criteria are built on Arize Phoenix; implementing any of the Phoenix-dependent criteria requires adding the dependency and an evaluation pipeline — currently 0% present.
- The existing heuristic evaluator and the story's rubric-based evaluator are different products; without a rubric scale, the current scores cannot be compared to the 3.0/4.0 threshold or across skills.
- Story dependency on US-119 is only partially satisfiable: US-119's directory validation (which would locate EVAL/, FINE-TUNE/, MULTI-SHOT/) is itself missing, so the evaluator has no structured inputs to consume.
- Risk of false confidence: `Skill.Evaluate` scoring is purely structural (lengths, block counts, headings) — it measures shape, not output quality; treat scores as lint signals, not quality verdicts.

## BDD Scenario

```gherkin
Feature: Measure skill quality against the EVAL rubric

  Scenario: Heuristic quality score for a single skill (today's behavior)
    Given a skill markdown with a 120-char description starting with an action verb and 3 fenced examples
    When the agent calls ToolCall("Skill.Evaluate", {"content": "<file text>", "filename": "my-skill.md"})
    Then the result carries four dimension scores (description, examples, structure, completeness) with notes
    And suggestions list concrete improvements for any dimension scoring below threshold

  Scenario: Phoenix-based dataset evaluation (not implemented)
    Given a skill directory with EVAL/rubric.md, FINE-TUNE/training_data.parquet, and MULTI-SHOT/ examples
    When the creator runs evaluate_skill_quality
    Then 10-20 fine-tune samples and all multi-shot examples are scored against the parsed rubric
    And an Arize Phoenix dashboard, a 7+ cell Jupyter notebook, cross-skill comparison, and a metrics-over-time history are produced
    # This scenario cannot be executed: no Phoenix integration, rubric parsing,
    # dataset evaluation, notebook, comparison, or persistence exists in the repo.
```
