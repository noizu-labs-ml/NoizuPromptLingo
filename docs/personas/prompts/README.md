# Prompts

Reusable prompt templates and system instructions for common workflows and domains.

## Prompts

### npl
Core NPL (Noizu Prompt Lingo) system prompt. Foundational instruction set for NPL agents and workflows.

### npl_load
NPL project loading prompt. Initializes agent context with project metadata and configuration.

### scripts
Scripts management prompt. Provides context and instructions for script-related tasks and utilities.

### sql-lite
SQLite database interaction prompt. Instructions for database operations, schema management, and queries.

## Organization

These prompts are organized by domain/context:

| Prompt | Domain | Use Case |
|--------|--------|----------|
| **npl** | Core | Agent initialization, general workflows |
| **npl_load** | Project | Loading project context and metadata |
| **scripts** | Automation | Script execution and management |
| **sql-lite** | Database | SQLite operations and schema work |

## Usage Patterns

**Project Initialization**
```
Load npl → Load npl_load → Initialize agent
```

**Database Operations**
```
Load npl → Load sql-lite → Execute DB queries
```

**Script Execution**
```
Load npl → Load scripts → Run script utilities
```

## Composition

Prompts can be composed together:
1. Load base prompt (npl)
2. Load domain-specific prompt (sql-lite, scripts, etc.)
3. Add task-specific instructions
4. Execute

## Integration

These prompts are:
- Used by all agent types during initialization
- Composable for multi-domain workflows
- Versioned alongside codebase for consistency
- Referenced by orchestration framework
