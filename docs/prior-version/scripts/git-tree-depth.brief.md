# git-tree-depth

**Type**: Script
**Category**: Codebase Exploration
**Status**: Core

## Purpose

`git-tree-depth` is a Git-aware directory depth analyzer that lists all directories within a target folder along with their nesting depth relative to that target. Unlike traditional directory listing tools (`find -type d`, `tree -d`), this script respects `.gitignore` rules, making it ideal for navigating codebases without noise from build artifacts, dependencies, or ignored directories.

The script is particularly valuable for programmatic directory filtering, depth-based processing pipelines, and understanding repository structure at a glance. It provides machine-parseable output (path + depth per line) suitable for integration with `awk`, `sort`, and shell loops.

## Key Capabilities

- **Git-aware filtering**: Only surfaces directories containing tracked or non-ignored files via `git ls-files`
- **Relative depth calculation**: Outputs nesting depth as integer offset from target directory (0 = target itself)
- **`.gitignore` compliance**: Automatically excludes directories matching `.gitignore`, `.git/info/exclude`, and global excludes
- **Machine-parseable output**: Simple `<path> <depth>` format per line, optimized for piping to `awk`, `grep`, `sort`
- **Path normalization**: Handles spaces, unicode characters, and both absolute/relative paths cleanly
- **Parent path expansion**: Ensures all intermediate parent directories appear in output even if they only contain subdirectories

## Usage & Integration

- **Triggered by**: Direct shell invocation with target directory argument
- **Outputs to**: Standard output (two-column format: relative path and depth)
- **Complements**: `git-tree` (visual tree display), `dump-files` (content extraction), general shell pipelines

### Invocation Syntax

```bash
git-tree-depth <target-folder>
```

**Arguments**:
- `<target-folder>` (required): Directory to analyze; use `.` for repository root

**Exit Codes**:
- `0`: Success
- `1`: Missing argument or not in Git repository

## Core Operations

### Basic Usage

```bash
# Analyze current directory
git-tree-depth .

# Analyze specific subtree
git-tree-depth src/components
```

**Example Output**:
```
. 0
core 1
core/agents 2
core/scripts 2
docs 1
docs/scripts 2
```

### Filter by Depth

```bash
# List only directories at depth 2
git-tree-depth src | awk '$2 == 2 { print $1 }'
```

### Sort by Depth (Deepest First)

```bash
git-tree-depth . | sort -t' ' -k2 -rn
```

### Find Maximum Depth

```bash
git-tree-depth . | awk '{ if ($2 > max) max=$2 } END { print max }'
```

### Integration with Shell Loops

```bash
git-tree-depth src | while read -r dir depth; do
  echo "Processing $dir at depth $depth"
  # your-script "$dir"
done
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `<target-folder>` | Directory to analyze | (required) | Use `.` for repo root |
| `--cached` | Process tracked files | (implicit) | Via `git ls-files` flags |
| `--others` | Include untracked files | (implicit) | Respects `.gitignore` |
| `--exclude-standard` | Apply `.gitignore` rules | (implicit) | Uses `.gitignore`, global excludes |

*Note: Flags are baked into `git ls-files` invocation; not user-configurable.*

## Integration Points

- **Upstream dependencies**: Must be run inside a Git working tree; requires standard Unix tools (`awk`, `sort`, `dirname`, `xargs`)
- **Downstream consumers**: Shell scripts, Makefiles, filtering pipelines, depth-based directory processors
- **Related utilities**: Works alongside `git-tree` (tree visualization), `dump-files` (file content extraction)

### Makefile Example

```makefile
DIRS := $(shell git-tree-depth src | cut -d' ' -f1)

process-all:
	@for dir in $(DIRS); do \
		echo "Processing $$dir"; \
	done
```

## Limitations & Constraints

- **Empty directories**: Git does not track empty directories; they will not appear in output
- **Symlinks**: Symbolic links to directories are not followed (treated as files)
- **Large repositories**: Performance scales with file count; for 100k+ file repos, filter to subdirectories
- **Non-Git directories**: Exits with code 1 if target is not within a Git repository
- **Unicode paths**: Correctly handled via `core.quotepath=false`, but requires UTF-8 locale

## Success Indicators

- Exit code `0` with output lines in `<path> <depth>` format
- All listed directories are valid and reachable from target
- Depth values match actual nesting level relative to target (`.` = 0, `core` = 1, `core/agents` = 2)

---
**Generated from**: worktrees/main/docs/scripts/git-tree-depth.md, git-tree-depth.detailed.md
