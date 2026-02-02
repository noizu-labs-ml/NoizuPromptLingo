# AT-016-001: Structure Validator Basic Checks

**Category**: Integration
**Related FR**: FR-016-001, FR-016-002, FR-016-003
**Status**: Not Started

## Description

Validates that structure validator correctly identifies valid and invalid skill directories, checking all required folders and files.

## Test Implementation

```python
def test_structure_validator_valid_skill():
    """Test validator passes for correctly structured skill."""
    # Setup: Create mock skill directory with all requirements
    skill_path = create_mock_skill("valid-skill")

    # Action: Run validator
    report = validate_skill_structure(skill_path)

    # Assert: All checks pass
    assert report.status == "PASS"
    assert report.checks["directory_structure"]["status"] == "PASS"
    assert report.checks["skill_md"]["status"] == "PASS"
    assert report.checks["eval_folder"]["status"] == "PASS"

def test_structure_validator_missing_directory():
    """Test validator fails for missing EVAL directory."""
    # Setup: Create skill without EVAL folder
    skill_path = create_mock_skill("incomplete-skill", exclude=["EVAL/"])

    # Action: Run validator
    report = validate_skill_structure(skill_path)

    # Assert: Validation fails with clear message
    assert report.status == "FAIL"
    assert "EVAL/ folder exists" in report.checks["directory_structure"]["issues"]
```

## Acceptance Criteria

- [ ] Validates all required directories (SKILL.md, EVAL/, FINE-TUNE/, MULTI-SHOT/)
- [ ] Reports specific missing directories
- [ ] Completes validation in <1 second
- [ ] Returns structured JSON report
