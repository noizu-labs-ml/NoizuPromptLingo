# git-tree-depth - Persona

**Type**: Script
**Category**: Codebase Exploration
**Version**: 1.0.0

## Overview

`git-tree-depth` is a Git-aware directory analysis tool that lists all directories under a target folder with their nesting depth relative to that target. It respects `.gitignore` rules and processes only Git-visible files, making it ideal for understanding repository structure without traversing ignored build artifacts or dependencies.

## Purpose & Use Cases

- **Repository structure analysis** - Quickly assess directory hierarchy complexity and organization depth
- **Depth-based filtering** - Target specific directory levels for processing or documentation
- **Build system integration** - Feed directory lists to Makefiles or CI pipelines with depth awareness
- **Refactoring guidance** - Identify deeply nested structures that may need flattening
- **Selective processing** - Process directories at specific depths for staged migrations or transformations

## Key Features

✅ **Git-aware traversal** - Uses `git ls-files` to respect `.gitignore` and exclude hidden files
✅ **Depth calculation** - Reports nesting level relative to target (0 = target itself)
✅ **Path normalization** - Handles absolute paths, relative paths, and edge cases (`.`, trailing `/`)
✅ **Parent directory expansion** - Generates all parent paths even if only deeply nested files exist
✅ **Unicode support** - Correctly processes non-ASCII filenames via `core.quotepath=false`
✅ **Pipeline-friendly output** - Simple `<path> <depth>` format for easy parsing with `awk`, `cut`, `grep`

## Usage

```bash
git-tree-depth <target-folder>
```

Provide a target directory (use `.` for repository root). The script outputs one line per directory containing the relative path and integer depth separated by a space. Depth 0 represents the target directory itself. Exit code 0 indicates success; exit code 1 means missing argument or not in a Git repository.

## Integration Points

- **Triggered by**: Developers analyzing repository layout, build scripts needing directory enumeration, refactoring tools assessing structure complexity
- **Feeds to**: Makefiles (via `$(shell ...)`), shell loops processing directories, depth filters (`awk '$2 == 2'`), documentation generators
- **Complements**: `git-tree` (visual tree display), `dump-files` (content extraction), `find -type d` (non-Git-aware alternative)

## Parameters / Configuration

- **`<target-folder>`** - Required positional argument specifying the directory to analyze (must exist or have valid parent)
- **Working directory** - Script changes to Git repository root internally; can be invoked from any subdirectory
- **Git flags** - Uses `--cached --others --exclude-standard` for file enumeration (tracked + untracked but not ignored)
- **Output format** - Always `<relative-path> <depth>`, no configuration options or flags

## Success Criteria

- **Correct depth calculation** - Depth 0 for target, increments by 1 per directory level
- **Complete enumeration** - All directories containing Git-visible files appear in output
- **`.gitignore` compliance** - Excluded directories do not appear (e.g., `node_modules`, `build/`)
- **No duplicates** - Each directory listed exactly once, even if multiple files at different levels

## Limitations & Constraints

- **Empty directories invisible** - Git does not track empty directories; they will not appear in output
- **Symlinks not followed** - Symbolic links to directories are treated as files, not traversed
- **Performance at scale** - For repositories with 100k+ files, consider filtering to a subdirectory rather than processing entire repo

## Related Utilities

- **git-tree** - Displays hierarchical tree structure with visual formatting (complements this tool's flat depth list)
- **dump-files** - Extracts file contents for analysis (often follows directory enumeration)
- **find -type d** - Non-Git-aware directory listing (faster but includes ignored paths)
