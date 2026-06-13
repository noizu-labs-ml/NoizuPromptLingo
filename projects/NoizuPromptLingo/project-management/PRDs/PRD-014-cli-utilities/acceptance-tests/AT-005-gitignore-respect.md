# AT-005: .gitignore Respect

**Category**: Integration
**Related FR**: FR-004, FR-005
**Status**: Not Started

## Description

Validates that dump-files and git-tree respect .gitignore patterns.

## Test Implementation

```python
def test_gitignore_respect(tmp_path):
    """Test utilities respect .gitignore patterns."""
    # Setup: Create files and .gitignore
    (tmp_path / "included.py").write_text("# included")
    (tmp_path / "ignored.py").write_text("# ignored")
    (tmp_path / ".gitignore").write_text("ignored.py\n*.log\n")
    (tmp_path / "debug.log").write_text("log content")

    # Initialize git repo
    subprocess.run(["git", "init"], cwd=str(tmp_path))
    subprocess.run(["git", "add", "included.py", ".gitignore"], cwd=str(tmp_path))

    # Action: dump-files
    result_dump = subprocess.run(
        ["dump-files", str(tmp_path)],
        capture_output=True
    )

    # Action: git-tree
    result_tree = subprocess.run(
        ["git-tree", str(tmp_path)],
        capture_output=True
    )

    # Assert: Ignored files not in output
    assert b"included.py" in result_dump.stdout
    assert b"ignored.py" not in result_dump.stdout
    assert b"debug.log" not in result_dump.stdout

    assert b"included.py" in result_tree.stdout
    assert b"ignored.py" not in result_tree.stdout
```

## Acceptance Criteria

- [ ] .gitignore patterns are respected
- [ ] Tracked files are included
- [ ] Untracked but not ignored files are included
- [ ] Ignored files are excluded
- [ ] Nested .gitignore files work

## Coverage

Covers:
- Basic .gitignore patterns
- Wildcard patterns
- Binary file exclusion
