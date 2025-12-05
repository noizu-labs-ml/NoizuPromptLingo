# Scripts Documentation

This document provides comprehensive documentation for all scripts and utilities in the NPL project.

## Overview

The NPL project includes various script utilities designed to enhance development workflows and integrate seamlessly with NPL agents.

## Project Scripts (.claude/scripts/)

<!-- PROJECT_SCRIPTS_DOCUMENTATION_SECTION_START -->

### dump-dir

**Purpose**: Dumps the contents of all files under a target folder in a Git repository, respecting .gitignore rules.

**Syntax**: 
```bash
dump-dir <target-folder>
```

**Parameters**:
- `target-folder`: Directory path to process (required)

**Behavior**:
- **Git-Aware Filtering**: Uses `git ls-files --cached --others --exclude-standard` to intelligently filter files:
  - `--cached`: Includes all tracked files in the Git repository
  - `--others`: Includes untracked files that aren't ignored
  - `--exclude-standard`: Respects `.gitignore`, `.git/info/exclude`, and core Git exclude patterns
- Outputs each file with a header showing the file path
- Separates files with `* * *` delimiter

**Output Format**:
```
# path/to/file.ext
---
[file contents]

* * *
```

**Usage Examples**:
```bash
# Dump all files in src directory
./.claude/scripts/dump-dir src/

# Dump configuration files
./.claude/scripts/dump-dir config/
```

**NPL Integration**: Provides formatted file content for NPL agents that need to analyze multiple files simultaneously.

---

### dump-files

**Purpose**: Enhanced version of dump-dir with comprehensive documentation and error handling. Dumps the contents of all files under a target folder in a Git repository.

**Syntax**: 
```bash
dump-files <target-folder> [--glob GLOB ...]
```

**Parameters**:
- `target-folder`: Directory path to process (required)
- `-g, --glob GLOB`: Shell pattern to filter files (optional, can be used multiple times)

**Glob Filtering**:
- Use `-g` or `--glob` followed by a shell pattern
- Multiple `-g` options can be specified
- A file matches if it matches ANY of the provided patterns
- Patterns are matched against repository-relative paths

**Behavior**:
- Identical functionality to dump-dir but with improved documentation
- Validates Git repository context before execution
- **Advanced Git Filtering**: Uses `git ls-files --cached --others --exclude-standard` for precise file selection:
  - Includes all tracked files regardless of working directory state
  - Includes new untracked files that aren't in ignore patterns
  - Automatically excludes files matching `.gitignore`, `.git/info/exclude`, and system excludes
- Formats output with clear file delimiters

**Output Format**:
```
# path/to/file.ext
---
[file contents]

* * *
```

**Usage Examples**:
```bash
# Analyze all source files
./.claude/scripts/dump-files src/

# Only Markdown files anywhere under docs/
./.claude/scripts/dump-files docs/ -g "*.md"

# Multiple patterns (Markdown + TypeScript)
./.claude/scripts/dump-files . -g "*.md" -g "src/*.ts"

# Extract deployment configurations
./.claude/scripts/dump-files deployments/impact-simulation
```

**NPL Integration**: Primary tool for providing file context to NPL agents for analysis and documentation tasks.

---

### git-tree

**Purpose**: Displays a tree view of files under a target folder in a Git repository, respecting .gitignore rules.

**Syntax**: 
```bash
git-tree [target-folder]
```

**Parameters**:
- `target-folder`: Directory path to visualize (optional, defaults to current directory)

**Requirements**:
- `tree` command must be installed
- Must run inside a Git repository

**Behavior**:
- Validates Git repository context
- Changes to repository root directory
- **Git-Integrated Visualization**: Uses `git ls-files --cached --others --exclude-standard` with `tree --fromfile`:
  - Shows all tracked files and clean untracked files
  - Respects all Git ignore patterns and exclusion rules
  - Provides accurate repository structure without noise from ignored files
- Shows only files tracked by Git or untracked but not ignored

**Output Format**:
Standard tree output showing directory structure with files

**Usage Examples**:
```bash
# Show entire repository structure
./.claude/scripts/git-tree

# Show specific directory structure
./.claude/scripts/git-tree deployments/impact-simulation
```

**NPL Integration**: Provides visual directory structure for NPL agents performing project analysis and navigation tasks.

---

### git-dir-depth

**Purpose**: Lists all directories under a target folder with their nesting depth relative to the target directory.

**Syntax**: 
```bash
git-dir-depth <target-folder>
```

**Parameters**:
- `target-folder`: Directory path to analyze (required)

**Requirements**:
- Must run inside a Git repository
- Uses `git ls-files`, `awk`, `sort`, `dirname`

**Behavior**:
- Validates Git repository context
- **Git-Aware Directory Processing**: Only analyzes directories containing files from `git ls-files --cached --others --exclude-standard`:
  - Focuses on directories with tracked or relevant untracked content
  - Ignores directories that only contain ignored files
  - Provides clean structural analysis without ignored file noise
- Calculates depth relative to target directory (depth 0 = target itself)
- Removes duplicate directory entries
- Normalizes path formats

**Output Format**:
```
. 0
subdir 1
subdir/nested 2
```

**Usage Examples**:
```bash
# Analyze project structure depth
./.claude/scripts/git-dir-depth src/

# Get deployment directory structure
./.claude/scripts/git-dir-depth deployments/impact-simulation
```

**NPL Integration**: Provides structured directory depth analysis for NPL agents performing architectural analysis and code organization tasks.

<!-- PROJECT_SCRIPTS_DOCUMENTATION_SECTION_END -->

## Scaffolding Scripts (agentic/scaffolding/scripts/)

<!-- SCAFFOLDING_SCRIPTS_DOCUMENTATION_SECTION_START -->

The scaffolding scripts provide the same functionality as project scripts but are designed for distribution with NPL agent scaffolding. These scripts are identical to their project counterparts and can be deployed to any NPL-enabled project.

### dump-files

**Purpose**: Scaffolding version of the file content dumping utility for NPL agent deployment.

**Syntax**: 
```bash
agentic/scaffolding/scripts/dump-files <target-folder> [--glob GLOB ...]
```

**Parameters**:
- `target-folder`: Directory path to process (required)
- `-g, --glob GLOB`: Shell pattern to filter files (optional, can be used multiple times)

**Behavior**:
- Identical functionality to `.claude/scripts/dump-files`
- Designed for distribution with NPL scaffolding packages
- Maintains consistent interface across NPL deployments

**Deployment**:
```bash
# Copy to project scripts directory
cp agentic/scaffolding/scripts/dump-files ./.claude/scripts/
chmod +x ./.claude/scripts/dump-files
```

**NPL Integration**: Provides standardized file content extraction across all NPL-enabled projects.

---

### git-tree

**Purpose**: Scaffolding version of the Git-aware tree visualization utility.

**Syntax**: 
```bash
agentic/scaffolding/scripts/git-tree [target-folder]
```

**Parameters**:
- `target-folder`: Directory path to visualize (optional, defaults to current directory)

**Requirements**:
- `tree` command must be installed
- Must run inside a Git repository

**Behavior**:
- Identical functionality to `.claude/scripts/git-tree`
- Provides consistent tree visualization across NPL projects
- Respects Git ignore patterns uniformly

**Deployment**:
```bash
# Copy to project scripts directory
cp agentic/scaffolding/scripts/git-tree ./.claude/scripts/
chmod +x ./.claude/scripts/git-tree
```

**NPL Integration**: Standard directory visualization tool for NPL agent project analysis workflows.

---

### git-dir-depth

**Purpose**: Scaffolding version of the directory depth analysis utility.

**Syntax**: 
```bash
agentic/scaffolding/scripts/git-dir-depth <target-folder>
```

**Parameters**:
- `target-folder`: Directory path to analyze (required)

**Requirements**:
- Must run inside a Git repository
- Uses `git ls-files`, `awk`, `sort`, `dirname`

**Behavior**:
- Identical functionality to `.claude/scripts/git-dir-depth`
- Provides consistent directory depth analysis
- Supports NPL agent architectural analysis workflows

**Deployment**:
```bash
# Copy to project scripts directory
cp agentic/scaffolding/scripts/git-dir-depth ./.claude/scripts/
chmod +x ./.claude/scripts/git-dir-depth
```

**NPL Integration**: Standard tool for project structure analysis in NPL agent workflows.

### Scaffolding Script Deployment

To deploy all scaffolding scripts to a project:

```bash
# Copy all scaffolding scripts
cp agentic/scaffolding/scripts/* ./.claude/scripts/

# Make executable
chmod +x ./.claude/scripts/*
```

**Version Consistency**: Scaffolding scripts maintain identical functionality to project scripts, ensuring consistent behavior across NPL deployments.

**Distribution Purpose**: These scripts are designed to be copied into NPL-enabled projects, providing standard utilities for Git-aware file analysis and project structure visualization.

<!-- SCAFFOLDING_SCRIPTS_DOCUMENTATION_SECTION_END -->

## Usage Patterns

### Integration with NPL Agents

Scripts are designed to work seamlessly with NPL agents:

```bash
# Generate project analysis for agents
./script-name --analyze

# Export data for agent processing
./script-name --export target/
```

### Development Workflow Integration

Scripts support common development workflows:

- Code analysis and documentation generation
- Project structure visualization
- File content extraction for agent context
- Repository analysis and reporting

## Contributing

When adding new scripts:
1. Place them in the appropriate directory (`.claude/scripts/` or `agentic/scaffolding/scripts/`)
2. Make them executable (`chmod +x script-name`)
3. Follow existing naming conventions
4. Update this documentation using the NPL documentation agents

## Related Documentation

- [Architecture Overview](../README.md)
- [NPL Framework](../../../agentic/npl/)
- [Project README](../../../README.md)