# AT-002: Skip Flag Functionality

**Category**: Unit
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates that npl-load --skip flag correctly skips already-loaded resources.

## Test Implementation

```python
def test_skip_flag_prevents_duplicate_loading():
    """Test --skip flag skips resources matching expression."""
    # Setup: Set flag for loaded resources
    os.environ["NPL_DEF_LOADED"] = "syntax,agent"

    # Action: Load with skip flag
    result = subprocess.run(
        ["npl-load", "c", "syntax,agent,pumps", "--skip", "{@npl.def.loaded}"],
        capture_output=True
    )

    # Assert: Syntax and agent skipped, pumps loaded
    assert b"syntax: skipped" in result.stdout
    assert b"agent: skipped" in result.stdout
    assert b"pumps: loaded" in result.stdout
```

## Acceptance Criteria

- [ ] Resources matching skip expression are skipped
- [ ] Skipped resources appear in output
- [ ] Non-matching resources are loaded normally
- [ ] Invalid skip expressions produce error
- [ ] Wildcard patterns work in skip expressions

## Coverage

Covers:
- Exact match skip
- Wildcard skip patterns
- Error handling for invalid expressions
