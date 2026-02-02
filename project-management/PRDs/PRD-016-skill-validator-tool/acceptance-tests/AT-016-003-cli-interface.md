# AT-016-003: CLI Interface

**Category**: Integration
**Related FR**: FR-016-003
**Status**: Not Started

## Description

Validates that CLI interface accepts correct arguments and produces expected output formats.

## Test Implementation

```python
def test_cli_single_skill_validation():
    """Test CLI validates single skill."""
    result = subprocess.run(
        ["python", "tools/skill_validator.py", "skills/test-skill/"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0
    assert "Status: PASS" in result.stdout

def test_cli_json_output():
    """Test CLI produces valid JSON output."""
    result = subprocess.run(
        ["python", "tools/skill_validator.py", "skills/test-skill/", "--output", "json"],
        capture_output=True,
        text=True
    )
    report = json.loads(result.stdout)
    assert "skill" in report
    assert "status" in report

def test_cli_html_report():
    """Test CLI generates HTML report."""
    subprocess.run(
        ["python", "tools/skill_validator.py", "skills/test-skill/", "--report", "html"]
    )
    assert os.path.exists("report.html")
```

## Acceptance Criteria

- [ ] Accepts skill path argument
- [ ] Supports --all flag for bulk validation
- [ ] Generates JSON and HTML reports
- [ ] Returns correct exit codes
