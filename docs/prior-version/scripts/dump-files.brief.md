# dump-files

**Type**: Script
**Category**: Codebase Exploration
**Status**: Core Utility

## Purpose

`dump-files` is a Git-aware utility script that outputs the complete contents of all tracked and untracked-but-not-ignored files under a specified directory. Each file is wrapped with a formatted header and separator to enable structured parsing and downstream processing. This tool bridges local filesystem exploration with context-aware operations like AI assistant integration, code review pipelines, and documentation generation.

The script respects `.gitignore` rules and leverages Git's file listing capabilities to ensure only repository-visible files are included. It's designed for scenarios where you need to concatenate multiple file contents while preserving clear file boundaries and paths.

## Key Capabilities

- **Git-aware file discovery**: Uses `git ls-files` with flags to capture both tracked and untracked files while respecting `.gitignore`, `.git/info/exclude`, and global exclusion patterns
- **Structured output format**: Each file wrapped with header (`# path`), separator (`---`), contents, and footer (`* * *`)
- **UTF-8 filename support**: Preserves non-ASCII characters via `core.quotepath=false`
- **Recursive directory traversal**: No depth limit; processes all files within target directory tree
- **Fail-safe execution**: Shell options (`set -euo pipefail`) ensure pipeline failures propagate correctly
- **Raw content preservation**: Outputs file contents exactly as stored (binary files included)

## Usage & Integration

The script is invoked from the command line with a single required argument:

```bash
dump-files <target-folder>
```

- **Triggered by**: Manual invocation or build/automation scripts requiring file concatenation
- **Outputs to**: STDOUT (redirectable to files, pipes, or clipboard for AI context loading)
- **Complements**: `git-tree`, `git-tree-depth` for directory structure visualization

## Core Operations

**Basic usage**:
```bash
# Dump all files in src/
dump-files src/

# Dump nested directory
dump-files deployments/impact-simulation

# Dump entire project
dump-files .
```

**Output structure**:
```
# src/main.py
---
print("hello")

* * *

# src/utils.py
---
def helper():
    pass

* * *
```

**AI context loading**:
```bash
dump-files src/feature/ | pbcopy
```

**Code review integration**:
```bash
git diff --name-only main | xargs -I{} dump-files {}
```

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `<target-folder>` | Directory to dump | (required) | Relative or absolute path |
| Git flags | Control file visibility | `--cached --others --exclude-standard` | Built into script |
| Shell options | Fail-safe execution | `-euo pipefail` | Built into script |
| Quotepath | UTF-8 preservation | `false` | Built into script (`-c core.quotepath=false`) |

## Integration Points

- **Upstream dependencies**: Git repository (`.git` directory must exist), `git` command in PATH, read permissions on target files
- **Downstream consumers**: AI assistants (Claude, GPT), documentation generators, code review tools, parsing scripts (AWK, Python)
- **Related utilities**: `git ls-files` (underlying command), `git-tree` (directory structure), clipboard tools (`pbcopy`, `xclip`)

## Limitations & Constraints

- **No glob/pattern filtering**: Cannot filter by file extension without post-processing (workaround: pipe to `grep` or modify script)
- **No depth limit control**: Always recursive to full depth of target directory
- **Git repository required**: Fails with exit code 128 outside Git repositories
- **Binary file handling**: Outputs binary files as-is; terminal may display garbage (filter with `file` or `grep -v "Binary file"`)
- **No custom output formats**: Fixed header/separator format (`# path`, `---`, `* * *`)

## Success Indicators

- **Exit code 0**: All files processed successfully
- **Valid output format**: Each file block includes header, separator, contents, and footer
- **Git-visible files only**: Output respects `.gitignore` and exclusion patterns
- **UTF-8 filenames preserved**: Non-ASCII characters display correctly in headers

---
**Generated from**: worktrees/main/docs/scripts/dump-files.md, dump-files.detailed.md
