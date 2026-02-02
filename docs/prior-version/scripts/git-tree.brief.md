# git-tree

**Type**: Script
**Category**: Codebase Exploration
**Status**: Core

## Purpose

`git-tree` is a Git-aware directory tree viewer that displays repository structure while respecting `.gitignore` rules. Unlike generic directory listing tools, it shows only files tracked by Git or not explicitly ignored, providing an accurate view of what's actually part of the repository. This makes it ideal for understanding project structure, generating documentation, and quickly assessing what files exist in a repository without noise from build artifacts, dependencies, or other ignored content.

The script automatically detects whether the native `tree` command is available and falls back to a built-in AWK renderer if not, ensuring consistent functionality across environments.

## Key Capabilities

- **Git-aware filtering**: Shows only files visible to Git (tracked or untracked-but-not-ignored)
- **Respects all ignore rules**: Applies `.gitignore`, `.git/info/exclude`, and global Git excludes
- **Dual rendering modes**: Uses native `tree` command when available, falls back to AWK renderer
- **Unicode support**: Correctly displays filenames containing non-ASCII characters
- **Flexible targeting**: Display entire repository or specific subdirectories
- **Zero configuration**: Works out-of-the-box in any Git repository

## Usage & Integration

- **Triggered by**: Manual invocation via command line; commonly used in documentation scripts and CI pipelines
- **Outputs to**: stdout (plain text tree structure)
- **Complements**: `dump-files` (content dumping), `git-tree-depth` (depth-annotated trees)

**Basic invocation**:
```bash
# Entire repository
git-tree

# Specific directory
git-tree src/components
```

## Core Operations

**Repository validation and enumeration**:
```bash
# Validates Git repo, then lists files respecting ignore rules
git -c core.quotepath=false ls-files --cached --others --exclude-standard -- "$TARGET"
```

**Flag breakdown**:
- `--cached`: Include tracked/staged files
- `--others`: Include untracked files
- `--exclude-standard`: Apply all ignore rules (.gitignore, etc.)
- `-c core.quotepath=false`: Preserve Unicode filenames without escaping

**Rendering process**:
- Primary: Pipes file list to `tree --fromfile` for professional tree rendering
- Fallback: Uses embedded AWK script when `tree` unavailable (uses `├──` for all entries)

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `target-folder` | Directory to display | `.` (current) | Relative to repository root |

**Shell options** (`set -euo pipefail`):
- Exit on error, undefined variables, and pipe failures

## Integration Points

- **Upstream dependencies**: Must run inside Git repository; requires Git installed
- **Downstream consumers**: Documentation generators, CI structure validation, codebase analysis tools
- **Related utilities**:
  - `dump-files`: Content extraction after structure preview
  - `git-tree-depth`: Tree with depth level annotations
  - Standard `tree`: Enhanced rendering when available

**Common integration patterns**:
```bash
# Count files in directory
git-tree src | grep -c "──"

# Documentation generation
git-tree > docs/structure.txt

# Conditional logic in scripts
if git-tree lib 2>/dev/null | grep -q "utils"; then
  echo "Utils directory exists"
fi

# Preview before content dump
git-tree src/api && dump-files src/api
```

## Limitations & Constraints

- Empty directories not shown (Git doesn't track empty dirs)
- Submodule contents require separate `git-tree` invocation inside submodule
- Fallback AWK renderer lacks last-item detection (no `└──` glyphs, all entries use `├──`)
- Large repositories produce extensive output; target specific directories for better usability
- Symbolic links appear only if tracked and not excluded

## Success Indicators

- Exit code 0 indicates successful tree generation
- Tree structure matches actual Git-visible files
- Unicode filenames render correctly without escape sequences

---
**Generated from**: worktrees/main/docs/scripts/git-tree.md + git-tree.detailed.md
