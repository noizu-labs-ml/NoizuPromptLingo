# FR-002: Directory Tree Visualization

**Status**: Implemented

## Description

Provide MCP tools to visualize directory structure (git_tree) and analyze directory depth (git_tree_depth).

## Interface

```python
async def git_tree(path: str) -> str:
    """Visualize directory tree structure.

    Args:
        path: Absolute directory path

    Returns:
        Tree visualization string

    Raises:
        ValueError: If path is relative
    """

async def git_tree_depth(path: str) -> str:
    """Analyze directory depth statistics.

    Args:
        path: Absolute directory path

    Returns:
        Depth analysis output

    Raises:
        ValueError: If path is relative
    """
```

## Behavior

- **Given** an absolute directory path
- **When** git_tree or git_tree_depth is invoked
- **Then** directory structure or depth analysis is returned

## Edge Cases

- **Relative path**: Raises ValueError
- **Non-existent path**: Script handles error
- **Symlinks**: Handled by underlying script

## Related User Stories

- US-025

## Test Coverage

Expected test count: 8-10 tests
Target coverage: N/A (external scripts)
