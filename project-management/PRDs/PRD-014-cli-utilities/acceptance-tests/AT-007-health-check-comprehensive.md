# AT-007: Comprehensive Health Check

**Category**: End-to-End
**Related FR**: FR-007
**Status**: Not Started

## Description

Validates that npl-check performs comprehensive health checks across all components.

## Test Implementation

```python
def test_comprehensive_health_check(tmp_path):
    """Test health check validates all components."""
    # Setup: Create partial NPL installation
    (tmp_path / ".npl" / "agents").mkdir(parents=True)
    (tmp_path / ".npl" / "personas").mkdir(parents=True)
    (tmp_path / ".npl" / "sessions").mkdir(parents=True)

    # Create valid agent definition
    agent_file = tmp_path / ".npl" / "agents" / "test-agent.yaml"
    agent_file.write_text("""
id: test-agent
role: Tester
directives:
  - Test the system
""")

    # Action: Run health check
    result = subprocess.run(
        ["npl-check", "--verbose"],
        cwd=str(tmp_path),
        capture_output=True
    )

    # Assert: All categories checked
    output = result.stdout.decode()
    assert "Paths:" in output
    assert "Agents:" in output
    assert "Personas:" in output
    assert "Sessions:" in output
    assert "[OK]" in output
    assert result.returncode == 0  # Overall healthy
```

## Acceptance Criteria

- [ ] All check categories execute
- [ ] Status indicators are clear (OK/WARN/ERROR)
- [ ] Missing components produce warnings
- [ ] Critical failures produce errors
- [ ] Exit code reflects overall health

## Coverage

Covers:
- Multi-component validation
- Status reporting
- Exit code logic
