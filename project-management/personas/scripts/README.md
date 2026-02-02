# Scripts

Utility scripts for development, project management, configuration, and data operations.

## Scripts

### dump-files
File extraction utility. Exports files or directory contents in various formats for analysis and processing.

### git-tree-depth
Git analysis script. Analyzes repository structure depth and complexity metrics.

### git-tree
Git visualization script. Generates tree-view representations of git history and repository structure.

### npl-fim-config
NPL Fill-in-the-Middle (FIM) configuration script. Sets up and manages FIM model configuration for the project.

### npl-load
Project loader script. Loads and initializes NPL project context, configurations, and metadata.

### npl-persona
Persona management script. Creates, updates, and manages agent and utility personas.

### npl-session
Session management script. Initializes and manages NPL sessions, context, and state.

## Organization

| Script | Purpose | Frequency |
|--------|---------|-----------|
| **dump-files** | Data export | As needed |
| **git-tree-depth** | Analysis | Diagnostic |
| **git-tree** | Visualization | Reference |
| **npl-fim-config** | Configuration | Setup/maintenance |
| **npl-load** | Project setup | Frequent |
| **npl-persona** | Persona management | Development |
| **npl-session** | Session management | Frequent |

## Common Workflows

**Project Initialization**
```bash
npl-load          # Load project context
npl-session       # Start new session
```

**Development Setup**
```bash
npl-fim-config    # Configure FIM model
npl-load          # Load context
npl-session       # Initialize session
```

**Troubleshooting**
```bash
git-tree-depth    # Analyze repo structure
git-tree          # Visualize git history
dump-files        # Export data for analysis
```

**Persona Management**
```bash
npl-persona       # Create/update personas
```

## Integration

These scripts:
- Support command and prompt execution
- Interface with CLI tools and utilities
- Are versioned with codebase
- Can be chained for multi-step workflows
- Provide diagnostic and visualization capabilities
