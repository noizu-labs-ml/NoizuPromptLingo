# npl-persona

Persona-based collaboration agent that simulates character-driven interactions with persistent file-backed state for reviews, discussions, and multi-agent problem-solving.

## Purpose

Enables consistent character voices across interactions by loading persona definitions, maintaining state through journal/tasks/knowledge files, and orchestrating multi-persona collaboration for code reviews, architecture discussions, and team simulations.

## Capabilities

- Single persona invocation with maintained voice and expertise
- Multi-persona team discussions and debates
- Persistent state via journal, tasks, and knowledge base files
- Hierarchical persona resolution (project, user, system paths)
- Relationship tracking across interactions
- CLI tool for persona lifecycle management

## Usage

```bash
# Single persona
@persona sarah-architect "How would you design the auth layer?"

# Multiple personas
@persona alice-dev,bob-qa,charlie-security "Review authentication PR #482"

# Team discussion
@persona --team=architects "Discuss: microservices vs monolith"

# Sequential collaboration
@persona sarah-architect "Design the system" | @persona qa-engineer "Create test plan"
```

## CLI Tool

```bash
npl-persona init <id> --role=<role>     # Create persona with 4 files
npl-persona get <id>                     # Load persona files
npl-persona list                         # List all personas
npl-persona journal <id> add --message="..."
npl-persona task <id> add "Review code"
npl-persona kb <id> add "GraphQL patterns"
npl-persona health --all                 # Check file integrity
```

## Workflow Integration

```bash
# Persona-reviewed documentation
@persona tech-leads "Review spec" | @writer "Format as RFC"

# Team quality review
@persona --panel=architects "Architecture review" | @grader "Grade against rubric"

# Expert panel
@thinker "Analyze problem" | @persona --expert-panel "Provide insights"
```

## File Structure

```
$NPL_PERSONA_DIR/
├── {id}.persona.md       # Role, voice, expertise
├── {id}.journal.md       # Experience log
├── {id}.tasks.md         # Active tasks
└── {id}.knowledge-base.md
```

## See Also

- Core definition: `core/agents/npl-persona.md`
- Environment variables: `$NPL_PERSONA_DIR`, `$NPL_PERSONA_TEAMS`, `$NPL_PERSONA_SHARED`
