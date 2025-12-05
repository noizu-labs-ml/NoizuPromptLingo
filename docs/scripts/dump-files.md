# dump-files

A command-line tool for dumping file contents from a Git repository while respecting `.gitignore` rules.

## Synopsis

```bash
dump-files <target-folder> [-g <glob-pattern>]
```

## Description

`dump-files` recursively outputs the contents of all files under a specified directory in a Git repository. Each file is preceded by a formatted header showing its path. The tool respects `.gitignore` patterns, only showing tracked and untracked-but-not-ignored files.

## Arguments

| Argument | Description |
|----------|-------------|
| `<target-folder>` | The directory to dump files from (required) |

## Options

| Option | Description |
|--------|-------------|
| `-g <pattern>` | Glob pattern to filter files (e.g., `"*.md"`, `"*.py"`) |

## Output Format

Each file is output in the following format:

```
# path/to/file.ext
---
[file contents]

* * *
```

## Requirements

- Must be run inside a Git repository
- Uses `git ls-files` to determine visible files

## Examples

### Dump all files in a directory

```bash
dump-files src/
```

### Dump files from a nested directory

```bash
dump-files deployments/impact-simulation
```

### Dump only markdown files

```bash
dump-files docs/ -g "*.md"
```

### Dump Python files in project

```bash
dump-files . -g "*.py"
```

## Use Cases

- **Code review**: Quickly view all files in a module or feature directory
- **Documentation**: Generate a consolidated view of project files
- **AI context**: Provide file contents to AI assistants for analysis
- **Backup verification**: Review contents of a directory before archiving

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Missing target folder argument |

## See Also

- [git-tree](./git-tree.md) - Display directory tree respecting `.gitignore`
- [git-tree-depth](./git-tree-depth.md) - Show directory tree with nesting levels
