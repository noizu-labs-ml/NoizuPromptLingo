# Review: Skill Structure Validator

- **Story**: `project-management/user-stories/US-119-skill-structure-validator.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A validator exists, but it validates a single SKILL.md *file*, not the skill *directory* the story describes. `src/npl_mcp/skills/validator.py` `validate_skill(content, filename)` (validator.py:85-222) splits YAML frontmatter, requires name/description, warns on name/filename mismatch and unknown fields, enforces description length bounds, and checks body presence/length (50-char minimum, `_check_body` validator.py:225-266) and headings. It is exposed as the `Skill.Validate` MCP tool (src/npl_mcp/launcher.py) and a REST endpoint, with solid test coverage in `tests/test_skills_validator.py` (15+ unit tests plus REST tests, e.g., test_rest_validate_valid_skill at :307). None of the SKILL-GUIDELINE.md *directory* requirements are implemented: there is no check for EVAL/, FINE-TUNE/, or MULTI-SHOT/ folders, no rubric.md/examples.md/checklist.md validation, no Parquet/training-data checks, no 1,500-line SKILL.md or 300+ line prompt-file thresholds, and no JSON/HTML report artifacts. No evidence of a directory-level validator in the Elixir backend either (grep for validate_skill/skill_valid in backend lib/ finds nothing).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Validates directory structure (SKILL.md, EVAL/, FINE-TUNE/, MULTI-SHOT/) | Not Met | `validate_skill` accepts file *content* only (validator.py:85-88); no directory walking anywhere in src/npl_mcp/skills/ |
| Checks file format requirements (YAML, Parquet, Markdown) | Partially Met | YAML frontmatter parsing (validator.py:134-145); body is markdown-ish text. No Parquet handling anywhere in the repo |
| Validates SKILL.md is 1,500+ lines with all required sections | Not Met | Body check requires only 50+ chars (validator.py:244); no line-count or required-section validation |
| Validates prompt files are 300+ lines with required sections | Not Met | No prompt-file concept exists in validator.py |
| Validates EVAL/ folder with rubric.md, examples.md, checklist.md | Not Met | No evidence found — "EVAL" appears nowhere in src/ |
| Validates FINE-TUNE/ folder with training_data.parquet (100-150 rows) | Not Met | No evidence found |
| Validates MULTI-SHOT/ folder with index.yaml and 3+ example files | Not Met | No evidence found |
| Provides clear error messages for failures | Met | Errors carry `{severity, field, message}`, incl. YAML parse errors quoting the exception (validator.py:136-143); asserted across tests/test_skills_validator.py |
| Validation completes in <1 second per skill | Partially Met | Single-file text validation is trivially fast by construction, but the criterion's directory-scan workload is unimplemented and no performance test exists |
| Outputs JSON and HTML reports | Partially Met | Returns a JSON-shaped dict via MCP tool and REST endpoint (tests/test_skills_validator.py:307-326); no HTML report generation anywhere |

## Gaps / Risks

- The story's core deliverable — guideline-compliant directory validation — is entirely missing; today's validator would pass a skill folder with no EVAL/, FINE-TUNE/, or MULTI-SHOT/ content at all.
- The 1,500-line SKILL.md and 300+ line prompt thresholds from SKILL-GUIDELINE.md are not encoded, so the tool cannot enforce the convention it exists to check.
- No HTML report output; consumers must render the JSON themselves.
- Threshold constants (50-char body, description min/max) are implicit policy not traceable to SKILL-GUIDELINE.md — worth aligning or documenting as intentionally different (the validator may target a slimmer convention deliberately).

## BDD Scenario

```gherkin
Feature: Automated skill structure validation

  Scenario: Validate a skill file's frontmatter and body (today's behavior)
    Given a skill markdown file with YAML frontmatter name/description and a 50+ char body
    When the agent calls ToolCall("Skill.Validate", {"content": "<file text>", "filename": "my-skill.md"})
    Then the result is valid=true with a summary (yaml_parseable, body_char_count, heading_count)
    When the same file lacks the description field
    Then an error {field: "frontmatter.description"} is reported with a human-readable message
    And a name/filename mismatch produces a warning, not an error

  Scenario: Validate a full skill directory (not implemented)
    Given a skill directory with SKILL.md, EVAL/rubric.md, FINE-TUNE/training_data.parquet, MULTI-SHOT/index.yaml
    When the creator runs the structure validator on the directory
    Then all guideline requirements are checked and a JSON + HTML report is produced
    # This scenario cannot be executed: directory validation, Parquet checks,
    # and report artifacts are not implemented in src/npl_mcp/skills/validator.py.
```
