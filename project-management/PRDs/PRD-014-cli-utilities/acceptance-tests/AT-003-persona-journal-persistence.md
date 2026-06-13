# AT-003: Persona Journal Persistence

**Category**: Integration
**Related FR**: FR-002
**Status**: Not Started

## Description

Validates that persona journals are append-only and persist across invocations.

## Test Implementation

```python
def test_persona_journal_persistence(tmp_path):
    """Test journal entries persist and maintain chronological order."""
    # Setup: Initialize persona
    subprocess.run(
        ["npl-persona", "init", "test-persona", "--role", "Tester"],
        cwd=str(tmp_path)
    )

    # Action: Add multiple journal entries
    subprocess.run(
        ["npl-persona", "journal", "test-persona", "add", "Entry 1"],
        cwd=str(tmp_path)
    )
    subprocess.run(
        ["npl-persona", "journal", "test-persona", "add", "Entry 2"],
        cwd=str(tmp_path)
    )

    # Assert: Both entries exist in chronological order
    result = subprocess.run(
        ["npl-persona", "journal", "test-persona", "list"],
        cwd=str(tmp_path),
        capture_output=True
    )

    entries = result.stdout.decode().split("\n")
    assert "Entry 1" in entries[0]
    assert "Entry 2" in entries[1]
```

## Acceptance Criteria

- [ ] Journal entries are append-only
- [ ] Entries include timestamps
- [ ] Entries persist across invocations
- [ ] List operation returns chronological order
- [ ] Concurrent writes don't corrupt journal

## Coverage

Covers:
- Append-only semantics
- Persistence verification
- Chronological ordering
