# NIMPS (Noizu Idea-to-MVP Service)

AI-augmented project planning service that transforms ideas into MVP specifications through structured yield-and-iterate methodology.

**Agent Definition**: `core/agents/nimps.md`
**Detailed Reference**: [nimps.detailed.md](./nimps.detailed.md)

## Purpose

NIMPS converts conceptual ideas into actionable project plans: personas, user stories, architecture specs, and prototypes. Yields every 10 items for review, enabling iterative refinement at each phase.

## Capabilities

- **Yield-driven iteration**: Pauses every 10 items for feedback. See [Yield Protocol](./nimps.detailed.md#yield-protocol).
- **Deep persona profiling**: Demographics, psychology, behavior, relationship mapping. See [Persona Profiling](./nimps.detailed.md#persona-profiling).
- **Structured planning**: Epics with business value, user stories with acceptance criteria. See [Epics and User Stories](./nimps.detailed.md#epics-and-user-stories).
- **Business analysis**: SWOT, competition, risks, revenue forecasting. See [Business Analysis](./nimps.detailed.md#business-analysis).
- **Architecture design**: Component specs, dependencies, API contracts. See [Architecture Design](./nimps.detailed.md#architecture-design).
- **Asset generation**: Mockups, prototypes, style guides. See [Asset Generation](./nimps.detailed.md#asset-generation).
- **SQLite storage**: Project data persisted to `.nimps/{project-slug}/project.sqlite`. See [Project Storage](./nimps.detailed.md#project-storage).

## Usage

```bash
# Basic MVP planning
@nimps "Create an MVP plan for [your idea]"

# With constraints
@nimps "Plan MVP for task management app targeting freelancers. $50K budget, 6-month timeline."

# Resume from specific phase
@nimps "Continue from persona phase for project [name]"
```

### Yield Point Commands

At each yield point, respond with:

| Command | Action |
|:--------|:-------|
| `continue` | Proceed to next batch |
| `modify X` | Revise specific items |
| `expand X` | Add detail to area |
| `next` | Skip to next phase |

See [Yield Protocol](./nimps.detailed.md#yield-protocol) for details.

## Workflow

```
Personas -> Epics -> Stories -> SWOT/Competition/Risks -> Revenue/Marketing -> Mockups/Style -> Architecture -> Documentation
```

See [Workflow Phases](./nimps.detailed.md#workflow-phases) for phase details.

## Integration

```bash
# Evaluate deliverables
@nimps "Create MVP plan" && @npl-grader "Evaluate user stories"

# Enhance personas
@nimps "Create project plan" && @npl-persona "Develop technical decision-maker personas"

# Analyze risks
@nimps "Generate architecture" && @npl-thinker "Analyze technical risks"
```

See [Integration Patterns](./nimps.detailed.md#integration-patterns) for pipeline examples.

## File Structure

```
.nimps/{project-slug}/
├── project.sqlite      # All project data
├── personas.md         # User personas
├── epics.md            # Epic definitions
├── stories.md          # User stories
├── architecture.md     # System design
├── mockups/            # UI/UX mockups
└── docs/               # Documentation
```

See [File Organization](./nimps.detailed.md#file-organization) for complete structure.

## See Also

- [Detailed Reference](./nimps.detailed.md) - Complete capability and usage documentation
- [npl-grader](./npl-grader.md) - Quality assessment
- [npl-persona](./npl-persona.md) - Persona management
- [npl-thinker](./npl-thinker.md) - Analysis agent
