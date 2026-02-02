# git-tree - Persona

**Type**: Script
**Category**: Codebase Exploration
**Version**: 1.0.0

## Overview

`git-tree` is a Git-aware directory tree visualization utility that displays repository structure while respecting `.gitignore` rules. It combines `git ls-files` for intelligent file enumeration with tree rendering (native `tree` command or AWK fallback) to provide clean, accurate repository views without noise from ignored artifacts.

## Purpose & Use Cases

- **Repository structure documentation** - Generate clean tree diagrams for READMEs and technical documentation
- **Codebase exploration** - Quickly understand project layout without IDE overhead
- **Pre-context for AI agents** - Provide structural overview before file-content dumps
- **CI/CD structure validation** - Verify expected directory layouts in automated workflows
- **Code review preparation** - Show reviewers which areas are affected by changes

## Key Features

✅ **Git-native filtering** - Automatically excludes files matching `.gitignore`, `.git/info/exclude`, and global ignore rules
✅ **Tracked + untracked visibility** - Shows both committed files and new files not yet staged
✅ **Unicode filename support** - Correctly displays non-ASCII characters via `core.quotepath=false`
✅ **Graceful fallback** - Uses native `tree` command when available, otherwise renders via embedded AWK script
✅ **Relative path targeting** - View entire repository or drill into specific subdirectories
✅ **Zero configuration** - Works out-of-box in any Git repository

## Usage

```bash
# Entire repository
git-tree

# Specific directory
git-tree src/components

# Nested path
git-tree deployments/impact-simulation
```

When invoked, `git-tree` validates it's inside a Git repository, locates the repository root, enumerates visible files via `git ls-files --cached --others --exclude-standard`, and pipes the file list to a tree renderer. Output shows standard tree formatting with `├──` and `│` box-drawing characters.

## Integration Points

- **Triggered by**: Manual invocation, documentation scripts, pre-analysis hooks
- **Feeds to**: Documentation generators, AI context builders (combined with `dump-files`), structure validators
- **Complements**: `dump-files` (content extraction), `git-tree-depth` (depth annotations), standard `tree` command

## Parameters / Configuration

- **`target-folder`** (default: `.`) - Directory path relative to repository root; can be nested path or repository root
- **Environment**: Requires Git repository; optional `tree` binary enhances rendering quality
- **Git flags**: Uses `--cached` (tracked), `--others` (untracked), `--exclude-standard` (ignore rules)

## Success Criteria

- Correctly excludes all `.gitignore` patterns (build artifacts, dependencies, IDE files)
- Shows newly created files that haven't been staged yet
- Renders readable tree structure even in large repositories
- Handles Unicode filenames without garbled output
- Exits gracefully with error message when run outside Git repository

## Limitations & Constraints

- **Empty directories invisible** - Git doesn't track empty folders; `git-tree` only shows directories containing files
- **Submodule boundaries** - Submodule root appears but contents require running `git-tree` inside submodule
- **Fallback rendering quality** - AWK fallback uses `├──` uniformly instead of `└──` for last items; aesthetically inferior to native `tree`
- **Large repository performance** - Repositories with thousands of files produce extensive output; consider targeting specific directories

## Related Utilities

- **dump-files** - Extract file contents with headers; often used after `git-tree` for comprehensive context
- **git-tree-depth** - Annotated tree view showing nesting depth relative to target directory
- **tree** - Generic directory tree tool (no Git awareness)
