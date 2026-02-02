# Commands Summary

**Location**: `worktrees/main/core/commands/`

## Overview
Collection of documented commands and workflows for initializing projects, managing data, and orchestrating development tasks. These are runnable or reference-able command sequences organized by use case.

## Command Categories

### Project Initialization Commands
- **init-project.md** - Full project initialization with all bootstrap steps
  - Dependencies, environment setup
  - Project structure creation
  - Configuration templates
  - Initial documentation

- **init-project-fast.md** - Rapid project initialization
  - Minimal dependencies
  - Quick-start configuration
  - Essential structure only
  - Good for prototyping and POCs

### Data & Metadata Commands
- **generate-meta-data.md** - Metadata generation and indexing
  - Extract project information
  - Generate index files
  - Create summary documents
  - Update cross-references

## Typical Command Structure

Each command file contains:
- **Purpose**: What the command accomplishes
- **Prerequisites**: Required tools, permissions, state
- **Steps**: Sequential execution steps
- **Options/Flags**: Customization parameters
- **Expected Output**: What success looks like
- **Troubleshooting**: Common issues and fixes
- **Examples**: Concrete usage examples

## Integration with Workflows

### TDD Workflow Commands
- Project initialization happens before feature development
- Commands generate scaffolding that TDD agents build upon
- Metadata commands update documentation as code changes

### Agent Invocation
Commands are referenced or executed by:
- **Project Coordinator**: Initializes project structure
- **Technical Writer**: Updates metadata and documentation
- **Build Master**: Orchestrates command execution in CI/CD

## Common Patterns

### Parameterized Commands
Commands accept parameters for:
- Project name and type
- Language/framework selection
- Feature set (minimal vs. full)
- Output directory
- Configuration profiles

### Idempotent Execution
- Commands can be re-run safely
- Existing configurations preserved
- Only missing pieces added
- Safe for updates and maintenance

## Usage Examples

### Initialize New Project
```bash
./init-project.md --name=my-app --framework=phoenix --full
```

### Quick Start Prototype
```bash
./init-project-fast.md --name=poc --framework=express
```

### Generate/Update Metadata
```bash
./generate-meta-data.md --project=/path/to/project --update-indexes
```

## File Organization

```
commands/
├── init-project.md              # Full initialization
├── init-project-fast.md         # Quick-start initialization
└── generate-meta-data.md        # Metadata and indexing
```

## Integration Points

- **with setup scripts** (`worktrees/main/setup/`) - One-time system setup
- **with build system** - Commands invoke build tools (Mix, npm, etc.)
- **with configuration** - Commands generate config templates
- **with agents** - Agents use commands to bootstrap work

## Notes
- Commands are self-documenting markdown files
- Each can be read as documentation or executed as scripts
- Some commands require specific tools/languages installed
- Version-specific commands may exist for major framework versions
- Commands designed to be composable and stackable
