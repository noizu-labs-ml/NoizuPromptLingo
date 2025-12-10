# git-tree

Git-aware directory tree viewer respecting `.gitignore` rules.

## Synopsis

```bash
git-tree [target-folder]
```

## Quick Start

```bash
# Entire repository
git-tree

# Specific directory
git-tree src/components
```

## Arguments

| Argument | Default | Description |
|:---------|:--------|:------------|
| `target-folder` | `.` | Directory to display |

## Requirements

- Must run inside a Git repository
- `tree` command optional (fallback provided)

## Sample Output

```
.
├── core
│   ├── agents
│   │   └── npl-author.md
│   └── scripts
│       └── git-tree
└── docs
    └── scripts
        └── git-tree.md
```

## Exit Codes

| Code | Meaning |
|:-----|:--------|
| 0 | Success |
| 1 | Not inside a Git repository |

## More Information

See [git-tree.detailed.md](./git-tree.detailed.md) for:
- [How It Works](./git-tree.detailed.md#how-it-works) - Internal mechanics
- [Tree Rendering](./git-tree.detailed.md#tree-rendering) - Primary vs fallback renderer
- [Edge Cases](./git-tree.detailed.md#edge-cases) - Empty dirs, symlinks, submodules
- [Integration Examples](./git-tree.detailed.md#integration-with-other-tools) - Scripting patterns

## See Also

- [dump-files.md](./dump-files.md) - Dump file contents
- [git-tree-depth.md](./git-tree-depth.md) - Tree with depth indicators
