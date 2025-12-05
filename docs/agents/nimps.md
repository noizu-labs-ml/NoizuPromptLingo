# NIMPS (Noizu Idea to MVP Service)

AI-augmented project planning service that transforms ideas into MVP specifications through structured yield-and-iterate methodology.

## Purpose

NIMPS converts conceptual ideas into actionable project plans: personas, user stories, architecture specs, and prototypes. It yields every 10 items for review, allowing iterative refinement at each phase.

## Capabilities

- **Yield-driven iteration**: Pauses every 10 items for user feedback before continuing
- **Deep persona profiling**: Demographics, psychology, behavior, and relationship mapping
- **Structured planning**: Epics with business value tied to detailed user stories with acceptance criteria
- **Architecture design**: Component specs, dependencies, API contracts, tech stack recommendations
- **Artifact generation**: Mockups, prototypes, style guides, documentation
- **SQLite storage**: Project data persisted to `.nimps/{project-slug}/project.sqlite`

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
- `continue` - proceed to next batch
- `modify X` - revise specific items
- `expand X` - add detail to area
- `next` - skip to next phase

## Workflow Integration

```bash
# Grade deliverables for completeness
@nimps "Create MVP plan" && @npl-grader "Evaluate user stories"

# Enhance personas with specialized profiles
@nimps "Create project plan" && @npl-persona "Develop technical decision-maker personas"

# Analyze architecture risks
@nimps "Generate architecture" && @npl-thinker "Analyze technical risks"
```

## See Also

- Core definition: `core/agents/nimps.md`
- Database schema: `npl-load schema nimps`
