# git-tree-depth

A command-line tool for listing directories in a Git repository with their nesting depth, while respecting `.gitignore` rules.

## Synopsis

```bash
git-tree-depth <target-folder>
```

## Description

`git-tree-depth` lists all directories under a specified target folder in a Git repository, showing each directory's nesting depth relative to the target. Depth 0 represents the target directory itself. The tool respects `.gitignore` patterns.

## Arguments

| Argument | Description |
|----------|-------------|
| `<target-folder>` | The directory to analyze (required) |

## Output Format

Each line contains the relative directory path and its depth, separated by a space:

```
<relative-path> <depth>
```

## Requirements

- Must be run inside a Git repository
- Uses `git ls-files`, `awk`, `sort`, `dirname`

## Examples

### Show depth for current project

```bash
git-tree-depth .
```

### Show depth for specific directory

```bash
git-tree-depth src/
```

### Analyze nested directory structure

```bash
git-tree-depth deployments/impact-simulation
```

## Sample Output

```
. 0
core 1
core/agents 2
core/scripts 2
docs 1
docs/scripts 2
npl 1
npl/fences 2
npl/pumps 2
```

## Use Cases

- **Structure analysis**: Understand directory depth and organization
- **Build scripts**: Process directories by depth order
- **Documentation**: Generate hierarchical outlines
- **Refactoring**: Identify deeply nested structures

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Missing target folder argument or not inside a Git repository |

## See Also

- [git-tree](./git-tree.md) - Display directory tree respecting `.gitignore`
- [dump-files](./dump-files.md) - Dump file contents from Git repository
