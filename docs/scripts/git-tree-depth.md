# git-tree-depth

List Git repository directories with nesting depth.

## Synopsis

```bash
git-tree-depth <target-folder>
```

## Description

Lists directories under a target folder with their depth relative to target. Respects `.gitignore` rules.

## Quick Reference

| Item | Value |
|:-----|:------|
| Required argument | `<target-folder>` (use `.` for root) |
| Output format | `<path> <depth>` per line |
| Exit 0 | Success |
| Exit 1 | Missing argument or not in Git repo |

## Examples

```bash
# Analyze current directory
git-tree-depth .

# Analyze specific path
git-tree-depth src/components
```

Output:

```
. 0
core 1
core/agents 2
docs 1
```

## Common Patterns

```bash
# Directories at depth 2 only
git-tree-depth src | awk '$2 == 2 { print $1 }'

# Maximum depth
git-tree-depth . | awk '{ if ($2 > max) max=$2 } END { print max }'

# Sort deepest first
git-tree-depth . | sort -t' ' -k2 -rn
```

## Detailed Documentation

See [git-tree-depth.detailed.md](./git-tree-depth.detailed.md) for:

- [Implementation Details](./git-tree-depth.detailed.md#implementation-details) - Processing pipeline and internal logic
- [Edge Cases and Limitations](./git-tree-depth.detailed.md#edge-cases-and-limitations) - Empty dirs, symlinks, unicode, performance
- [Integration Patterns](./git-tree-depth.detailed.md#integration-patterns) - Makefiles, shell loops, filtering

## See Also

- [git-tree](./git-tree.md) - Display directory tree
- [dump-files](./dump-files.md) - Dump file contents
