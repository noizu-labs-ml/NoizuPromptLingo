# AT-001: Hierarchical Path Resolution

**Category**: Integration
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates that npl-load resolves resources in correct hierarchical order: environment → project → user → system.

## Test Implementation

```python
def test_hierarchical_path_resolution(tmp_path, monkeypatch):
    """Test path resolution follows correct priority order."""
    # Setup: Create resources at each level
    monkeypatch.setenv("NPL_HOME", str(tmp_path / "env"))
    (tmp_path / "env" / "syntax.npl").write_text("env syntax")
    (tmp_path / "project" / ".npl" / "syntax.npl").write_text("project syntax")
    (tmp_path / "user" / ".npl" / "syntax.npl").write_text("user syntax")

    # Action: Load syntax from environment (highest priority)
    result = subprocess.run(
        ["npl-load", "c", "syntax"],
        cwd=str(tmp_path / "project"),
        capture_output=True
    )

    # Assert: Environment version loaded
    assert b"env syntax" in result.stdout
    assert b"project syntax" not in result.stdout
```

## Acceptance Criteria

- [ ] Environment variable path takes highest priority
- [ ] Project-local .npl/ overrides user and system
- [ ] User-global ~/.npl/ overrides system
- [ ] System-wide /etc/npl/ is lowest priority
- [ ] Missing levels are skipped without error

## Coverage

Covers:
- Normal hierarchical resolution
- Missing intermediate levels
- Environment variable override
