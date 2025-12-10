# dump-files

Dump Git-visible file contents with formatted headers.

## Synopsis

```bash
dump-files <target-folder>
```

## Description

Outputs all tracked and untracked-but-not-ignored files under a directory. Each file includes a path header and separator for parsing.

## Arguments

| Argument | Description |
|:---------|:------------|
| `<target-folder>` | Directory to dump (required) |

## Output Format

```
# path/to/file.ext
---
[file contents]

* * *
```

## Requirements

- Must run inside a Git repository
- Uses `git ls-files` to determine visible files

## Examples

```bash
# Dump all files in src/
dump-files src/

# Dump nested directory
dump-files deployments/impact-simulation

# Dump entire project
dump-files .
```

## Exit Codes

| Code | Meaning |
|:-----|:--------|
| 0 | Success |
| 1 | Missing target folder argument |

## Limitations

- No glob/pattern filtering
- No depth limit control
- Git repository required

See [dump-files.detailed.md](./dump-files.detailed.md) for:
- [Implementation Details](./dump-files.detailed.md#implementation-details)
- [Edge Cases](./dump-files.detailed.md#edge-cases)
- [Integration Patterns](./dump-files.detailed.md#integration-patterns)
- [Workarounds](./dump-files.detailed.md#limitations)

## See Also

- [git-tree](./git-tree.md) - Display directory tree
- [git-tree-depth](./git-tree-depth.md) - Show tree with nesting levels
