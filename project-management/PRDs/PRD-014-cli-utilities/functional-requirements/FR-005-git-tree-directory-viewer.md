# FR-005: git-tree Directory Viewer

**Status**: Draft

## Description

Implement `git-tree` CLI utility for displaying directory structure with Git awareness (respects .gitignore, shows tracked files).

## Interface

```bash
# Show project structure
git-tree

# Target specific directory
git-tree src/

# Limit depth
git-tree --depth 3

# Include hidden files
git-tree --all

# Show file sizes
git-tree --sizes

# JSON output
git-tree --format json
```

## Behavior

- **Given** target directory and options
- **When** git-tree is invoked
- **Then** directory tree is displayed
- **And** .gitignore patterns are respected
- **And** only tracked and untracked (not ignored) files are shown
- **And** tree command is used if available, fallback to bash

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | positional | Target directory (default: current) |
| `--depth` | optional | Maximum depth to display |
| `--all` | optional | Include hidden files |
| `--sizes` | optional | Show file sizes |
| `--format` | optional | Output format: text, json, tree |

## Output Format (text)

```
.
├── src/
│   ├── main.py
│   ├── utils/
│   │   ├── __init__.py
│   │   └── helpers.py
│   └── tests/
│       └── test_main.py
├── pyproject.toml
└── README.md
```

## Output Format (json)

```json
{
  "path": ".",
  "type": "directory",
  "children": [
    {
      "path": "src",
      "type": "directory",
      "children": [
        {"path": "main.py", "type": "file", "size": 1024}
      ]
    }
  ]
}
```

## Edge Cases

- **Non-Git repository**: Fall back to standard directory listing
- **Missing tree command**: Use Python-based fallback
- **Deep directories**: Respect --depth limit
- **Symlinks**: Show but don't follow to avoid cycles
- **Large directories**: Paginate or stream output

## Related User Stories

- US-085

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
