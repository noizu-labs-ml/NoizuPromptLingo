# AT-016-008: End-to-End Validation Workflow

**Category**: End-to-End
**Related FR**: FR-016-001, FR-016-004, FR-016-006
**Status**: Not Started

## Description

Validates complete workflow from skill directory validation through quality evaluation and report generation.

## Test Implementation

```python
def test_e2e_complete_validation():
    """Test complete validation workflow."""
    # Step 1: Structure validation
    structure_report = validate_skill_structure("skills/test-skill/")
    assert structure_report.status == "PASS"

    # Step 2: Load rubric
    rubric = parse_rubric("skills/test-skill/EVAL/rubric.md")
    assert len(rubric.dimensions) >= 3

    # Step 3: Evaluate dataset
    training_data = load_parquet("skills/test-skill/FINE-TUNE/training_data.parquet")
    evaluation = evaluate_dataset(training_data, rubric)
    assert evaluation.avg_score >= 2.5

    # Step 4: Generate Phoenix dashboard
    dashboard_url = generate_phoenix_dashboard(evaluation)
    assert dashboard_url is not None

    # Step 5: Generate Jupyter notebook
    notebook_path = generate_evaluation_notebook("skills/test-skill/", evaluation)
    assert os.path.exists(notebook_path)

def test_e2e_failing_validation():
    """Test workflow with failing skill."""
    structure_report = validate_skill_structure("skills/bad-skill/")

    assert structure_report.status == "FAIL"
    assert len(structure_report.checks["directory_structure"]["issues"]) > 0
```

## Acceptance Criteria

- [ ] Complete workflow executes without errors
- [ ] All components integrate correctly
- [ ] Failing skills are properly identified
- [ ] Reports generated in all formats
