# dump-files - Persona

**Type**: Script
**Category**: Codebase Exploration
**Version**: 1.0.0

## Overview

The `dump-files` script provides Git-aware file concatenation with formatted headers, designed for feeding codebase context to AI assistants, code review workflows, and documentation pipelines. It respects `.gitignore` rules while outputting both tracked and untracked-visible files in a consistent, parseable format.

## Purpose & Use Cases

- **AI Context Loading**: Concatenate entire feature directories for AI code review or assistance
- **Code Review**: Dump modified files for diff analysis or collaborative review
- **Documentation Generation**: Aggregate source files and documentation for context-building
- **Debugging Assistance**: Capture full file sets to share with debugging tools or human reviewers
- **Batch Processing**: Feed structured output to parsers, analyzers, or transformation scripts

## Key Features

✅ **Git-aware filtering** – Only outputs files visible to Git (tracked + untracked-not-ignored)
✅ **Formatted headers** – Each file wrapped with path header and separators for parsing
✅ **UTF-8 safe** – Handles non-ASCII filenames correctly via `core.quotepath=false`
✅ **Recursive traversal** – Automatically walks entire directory trees
✅ **Zero configuration** – Single command-line argument, no options needed
✅ **Terminal-safe output** – Consistent format suitable for piping or redirection

## Usage

```bash
dump-files <target-folder>
```

**Basic invocation**:
```bash
# Dump entire source directory
dump-files src/

# Dump project subdirectory
dump-files deployments/impact-simulation

# Dump entire repository
dump-files .
```

**Typical workflow**: Execute from repository root, specify target directory, redirect output to file or clipboard for AI assistant consumption. The script handles all file discovery and formatting automatically.

## Integration Points

- **Triggered by**: Manual invocation when gathering context for AI, review, or analysis
- **Feeds to**: AI assistants (via clipboard/paste), parsing tools (awk/grep), documentation generators
- **Complements**: `git-tree` (structure visualization), `git-tree-depth` (nesting analysis), `git ls-files` (raw file listing)

## Parameters / Configuration

- **`<target-folder>`** (required) – Directory path (relative or absolute) to dump; must exist and be within Git repository
- No flags or options – behavior controlled entirely by Git's ignore rules

**Environment considerations**:
- Must run inside Git repository (requires `.git` directory)
- Requires `git` command in PATH
- Read permissions needed for target files

## Success Criteria

- Outputs all Git-visible files under target directory
- Each file includes formatted header (`# path/to/file`) and footer (`* * *`)
- Respects `.gitignore` exclusions
- UTF-8 filenames render correctly
- Exit code 0 on successful completion

## Limitations & Constraints

- **No filtering**: Cannot limit output by file extension or pattern (workaround: pipe to `grep`)
- **No depth control**: Always recursive to full depth
- **Git-only**: Does not work outside Git repositories
- **Binary files**: Outputs binary content as-is, may garble terminal (filter with `file` or `grep`)
- **Large files**: No size limit, may cause memory issues in consuming tools

## Related Utilities

- **git-tree** – Display directory structure as ASCII tree
- **git-tree-depth** – Show nesting levels for directories
- **git ls-files** – Underlying Git command for file discovery
- **npl-load** – NPL resource loader for context injection
