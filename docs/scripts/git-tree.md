# git-tree

A command-line tool for displaying a directory tree of files in a Git repository while respecting `.gitignore` rules.

## Synopsis

```bash
git-tree [target-folder]
```

## Description

`git-tree` displays a tree view of all files under a specified directory in a Git repository. It uses `git ls-files` to determine which files are visible (tracked and untracked-but-not-ignored) and renders the output using the `tree` command.

## Arguments

| Argument | Description |
|----------|-------------|
| `[target-folder]` | The directory to show tree for (defaults to current directory) |

## Requirements

- Must be run inside a Git repository
- Requires `tree` command to be installed

## Examples

### Show tree of current directory

```bash
git-tree
```

### Show tree of specific directory

```bash
git-tree src/components
```

### Show tree of deployment files

```bash
git-tree deployments/impact-simulation
```

## Sample Output

```
.
├── core
│   ├── agents
│   │   ├── npl-author.md
│   │   └── npl-grader.md
│   └── scripts
│       ├── dump-files
│       ├── git-tree
│       └── npl-load
├── docs
│   └── scripts
│       └── npl-load.md
└── npl.md
```

## Use Cases

- **Project orientation**: Quickly understand project structure
- **Documentation**: Generate directory structure for README files
- **Code review**: Identify files affected by changes
- **Navigation**: Find files without wading through ignored directories

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Not inside a Git repository |

## See Also

- [dump-files](./dump-files.md) - Dump file contents from Git repository
- [git-tree-depth](./git-tree-depth.md) - Show directory tree with nesting levels
