# NIMPS (Noizu Idea-to-MVP Service) - Detailed Reference

AI-augmented project planning service that transforms ideas into MVP specifications through structured yield-and-iterate methodology.

**Agent Definition**: `core/agents/nimps.md`

---

## Table of Contents

- [Overview](#overview)
- [Capabilities](#capabilities)
  - [Yield-Driven Iteration](#yield-driven-iteration)
  - [Persona Profiling](#persona-profiling)
  - [Epics and User Stories](#epics-and-user-stories)
  - [Business Analysis](#business-analysis)
  - [Architecture Design](#architecture-design)
  - [Asset Generation](#asset-generation)
  - [Style Guide Creation](#style-guide-creation)
- [Workflow Phases](#workflow-phases)
- [Project Storage](#project-storage)
- [Command Reference](#command-reference)
- [Yield Protocol](#yield-protocol)
- [File Organization](#file-organization)
- [Integration Patterns](#integration-patterns)
- [Diagram Types](#diagram-types)
- [Best Practices](#best-practices)
- [Limitations](#limitations)

---

## Overview

`@noizu-nimps` converts conceptual ideas into actionable project plans. The service generates personas, user stories, architecture specs, mockups, and documentation through a phased approach that pauses for review every 10 items.

The agent loads these NPL dependencies:

```bash
npl-load c "syntax,agent,directive,formatting,pumps/npl-cot" --skip {@npl.def.loaded}
```

Core principles:

1. **Yield-driven**: Pauses every 10 items for operator feedback
2. **Deep profiling**: Comprehensive persona development with relationship mapping
3. **Notion-compatible**: Artifacts designed for Notion import
4. **Persistent storage**: SQLite database tracks all project data

---

## Capabilities

### Yield-Driven Iteration

The agent generates content in batches of 10 items maximum, then yields control to the operator. This enables:

- Review of generated content before proceeding
- Course corrections early in the process
- Selective expansion of specific areas
- Skip forward when content is acceptable

**Yield Point Commands**:

| Command | Action |
|:--------|:-------|
| `continue` | Generate next batch in current phase |
| `modify X` | Revise specific item(s) before continuing |
| `expand X` | Add detail to specific area |
| `next` | Skip remaining items, proceed to next phase |

---

### Persona Profiling

Comprehensive persona development covering seven dimensions:

**Visual**: Name, age, appearance/style, location

**Demographics**: Date of birth, income level, education, occupation, family status

**Psychology**: Personality type (MBTI), values, motivations, fears, decision-making style, technology adoption

**Professional**: Current role, career history, expertise areas, professional network, goals, pain points, tools used

**Behavior**: Daily routine, media consumption, shopping patterns, digital habits, personal goals

**Context**: Discovery channels, influence factors, journey stage (awareness/consideration/evaluation/usage), market segment

**Impact**: Jobs-to-be-done, emotional needs, social needs, success metrics, failure indicators

Each persona includes relationship mapping to other personas in the system.

---

### Epics and User Stories

**Epic Structure**:

| Field | Description |
|:------|:------------|
| ID | Unique identifier (EP-XXX) |
| Title | Epic name |
| Theme | Business theme or category |
| Impact | Personas affected |
| Value | Business value statement |
| Complexity | Low/Medium/High |
| Dependencies | Prerequisite epics |
| Success Criteria | Definition of done |
| Timeline | Estimated weeks |
| Risks | Associated risk factors |

**User Story Format**:

```
**As** `{persona}` **in** `{context}`
**I want** `{capability}`
**So that** `{outcome}` **and feel** `{emotion}`
```

Stories include:

- Epic linkage
- Priority assignment
- Story points
- Acceptance criteria (Given/When/Then)
- Definition of Done checklist
- Technical notes, UX considerations, dependencies, open questions

---

### Business Analysis

NIMPS generates comprehensive business analysis artifacts:

**SWOT Analysis**:
- Strengths: Internal advantages, capabilities, resources
- Weaknesses: Internal limitations, gaps, constraints
- Opportunities: External trends, market gaps, partnerships
- Threats: External risks, competition, market changes

Includes strategic matrix visualization with impact/internal-external positioning.

**Competition Analysis**:
- Market share and positioning
- Pricing models
- Target segments
- Unique selling propositions
- Technology stacks
- Funding stages
- Feature comparisons
- Competitive advantages

Includes scatter plot positioning map.

**Risk Assessment**:
- Category: Technical/Market/Financial/Legal/Operational
- Probability: Low/Medium/High
- Impact: Low/Medium/High
- Score: Probability x Impact
- Mitigation strategies
- Contingency plans
- Risk owners
- Review dates

Includes heat map visualization.

---

### Architecture Design

**Component Specification**:

| Attribute | Content |
|:----------|:--------|
| Purpose | Component responsibility |
| Technology | Implementation stack |
| APIs | Exposed interfaces |
| Performance | Performance requirements |
| Scalability | Scaling approach |
| Dependencies | Upstream/downstream/external |
| I/O | Input/output/events |
| NFR | Security, monitoring, backup |

**Stack Documentation**:
- Frontend technologies
- Backend technologies
- Infrastructure
- Team composition
- External dependencies
- SaaS integrations

Includes C4 context diagrams and PlantUML component interaction diagrams.

---

### Asset Generation

NIMPS produces multiple artifact types:

**Mockups**:
- Wireframes (low-fidelity)
- High-fidelity designs
- Interactive prototypes
- Component libraries

Formats supported:
- SVG inline mockups
- HTML/CSS prototypes
- React/JSX components
- External tool links (via @npl-fim)

**Documentation**:
- Technical docs (API, architecture, database, deployment)
- User documentation (guides, admin manuals, FAQ, troubleshooting)
- Development docs (setup, contributing, testing, code style)
- R&D documentation

---

### Style Guide Creation

Complete design system documentation:

**Brand Identity**:
- Name, tagline, mission
- Voice characteristics
- Tone guidelines

**Visual Design**:
- Color palette (primary, secondary, accent, neutral, semantic)
- Typography (font stacks, scale)
- Spacing system (8pt grid)
- Design tokens (JSON format)

**Component Library**:
- Variant definitions
- State specifications
- Size options
- Usage examples

---

## Workflow Phases

The agent follows this sequence:

```
Discovery -> Analysis -> Personas -> Epics -> Stories -> Architecture -> Creation -> Mockups -> Style -> Documentation
```

Detailed flow:

1. **Personas** (who): Deep user profiling with relationship mapping
2. **Epics** (what): High-level feature groupings with business value
3. **Stories** (how): Detailed user stories with acceptance criteria
4. **SWOT/Competition/Risks**: Business analysis artifacts
5. **Revenue/Marketing**: Go-to-market strategy
6. **Mockups/StyleGuide**: Design system and visual artifacts
7. **Architecture/Components**: Technical design specifications

Each phase yields every 10 items for review.

---

## Project Storage

### Database Initialization

```bash
# Generate NIMPS schema using NPL loader
npl-load schema nimps > .nimps/{slug}/schema.sql

# Initialize SQLite database with schema
sqlite3 .nimps/{slug}/project.sqlite < .nimps/{slug}/schema.sql
```

### Database Schema

The schema uses JSON columns for flexible data storage:

**Core Tables**:

| Table | Purpose |
|:------|:--------|
| `projects` | Project metadata, status, executive details |
| `personas` | User personas with JSON profile data |
| `epics` | Epic definitions with dependencies |
| `user_stories` | Stories with narrative and acceptance criteria |
| `acceptance_criteria` | Given/When/Then criteria per story |
| `business_analysis` | SWOT, competition, risks |
| `go_to_market` | Revenue models, marketing channels |
| `designs` | Mockups, style guide entries |
| `style_guide` | Design tokens and brand elements |
| `diagrams` | Mermaid/PlantUML diagram storage |
| `yield_points` | Phase tracking and review status |

### Insert Examples

**Project Creation**:
```sql
INSERT INTO projects (slug, name, status, details)
VALUES (
    '{slug}',
    '{name}',
    'persona',
    json('{
        "elevator_pitch": "{pitch}",
        "executive_summary": "{summary}",
        "market": {
            "tam": "{tam}",
            "sam": "{sam}",
            "som": "{som}",
            "trends": [...]
        }
    }')
);
```

**Persona Creation**:
```sql
INSERT INTO personas (project_id, name, age, journey_stage, details)
VALUES (
    {project_id},
    '{name}',
    {age},
    'awareness',
    json('{
        "visual": {...},
        "demographics": {...},
        "psychology": {...},
        "professional": {...},
        "behavior": {...},
        "impact": {...}
    }')
);
```

**User Story**:
```sql
INSERT INTO user_stories (project_id, epic_id, ticket, title, priority, points, narrative, details)
VALUES (
    {project_id},
    {epic_id},
    'US-001',
    '{title}',
    'P1',
    5,
    json('{
        "user_type": "{persona}",
        "context": "{situation}",
        "want": "{capability}",
        "outcome": "{functional}",
        "emotion": "{feeling}"
    }'),
    json('{
        "personas": [1, 2],
        "tech_notes": "...",
        "dependencies": ["US-000"]
    }')
);
```

---

## Command Reference

| Command | Description |
|:--------|:------------|
| `@nimps "Create MVP plan for [idea]"` | Start new project from idea |
| `@nimps "Plan MVP for [app] targeting [audience]. [constraints]"` | Start with constraints |
| `@nimps "Continue from [phase] for project [name]"` | Resume specific phase |
| `continue` | Proceed to next batch |
| `modify X` | Revise specific items |
| `expand X` | Add detail to area |
| `next` | Skip to next phase |

---

## Yield Protocol

1. Generate up to 10 items
2. Present focus marker with current area
3. Wait for operator response
4. Parse response and act:
   - `continue`: Generate next batch
   - `modify X`: Apply revisions
   - `expand X`: Add detail
   - `next`: Advance to next phase
5. Incorporate feedback and proceed

---

## File Organization

```
.nimps/{project-slug}/
├── project.sqlite          # All project data
├── schema.sql              # Database schema
├── personas.md             # User personas and relationships
├── epics.md                # Epic definitions
├── stories.md              # User stories
├── swot.md                 # SWOT analysis
├── competition.md          # Competitive analysis
├── risks.md                # Risk assessment
├── revenue.md              # Revenue model and forecasting
├── marketing.md            # Marketing channels and strategy
├── architecture.md         # System design
├── assets.md               # Deliverables list
├── styleguide.md           # Design system and tokens
├── notion-schema.md        # Database structure for Notion
├── mockups/                # UI/UX mockups
│   ├── wireframes/         # Low-fidelity designs
│   ├── prototypes/         # Interactive prototypes
│   └── components/         # Reusable components
└── docs/                   # Documentation
    ├── api/                # API reference
    ├── user-guide/         # End-user documentation
    └── setup.md            # Development setup
```

---

## Integration Patterns

### With @npl-grader

Evaluate deliverable quality:

```bash
@nimps "Create MVP plan" && @npl-grader "Evaluate user stories"
```

Grader assesses:
- Story completeness
- Acceptance criteria quality
- INVEST criteria compliance

### With @npl-persona

Enhance persona depth:

```bash
@nimps "Create project plan" && @npl-persona "Develop technical decision-maker personas"
```

Persona agent provides:
- Extended behavioral profiles
- Interview simulation
- Decision journey mapping

### With @npl-thinker

Analyze technical risks:

```bash
@nimps "Generate architecture" && @npl-thinker "Analyze technical risks"
```

Thinker provides:
- Risk identification
- Mitigation strategies
- Alternative approaches

### Pipeline Example

```bash
# Full pipeline with quality gates
@nimps "Create MVP plan for [idea]" && \
@npl-grader "Evaluate personas" && \
@npl-thinker "Analyze architecture risks" && \
@npl-technical-writer "Review documentation"
```

---

## Diagram Types

NIMPS generates diagrams for each phase:

| Phase | Diagram Type | Tool |
|:------|:-------------|:-----|
| Personas | Relationship graphs | Mermaid graph |
| User Journeys | Flow diagrams | Mermaid journey |
| Epics | Dependency diagrams | PlantUML component |
| Architecture | Context diagrams | Mermaid C4Context |
| Components | Interaction diagrams | PlantUML |
| Tech Stack | Mind maps | Mermaid mindmap |
| Data Model | ER diagrams | Mermaid erDiagram |
| Processes | Sequence/flow diagrams | Mermaid sequenceDiagram/flowchart |
| SWOT | Quadrant charts | Mermaid quadrantChart |
| Competition | Scatter plots | Mermaid scatter |
| Risks | Heat maps | Mermaid heatmap |
| Revenue | XY charts | Mermaid xychart-beta |
| Marketing | Pie charts, Gantt | Mermaid pie, gantt |

---

## Best Practices

**Project Initialization**:
1. Provide clear, concise idea description
2. Include target audience if known
3. Specify constraints (budget, timeline, technology)
4. Indicate priority focus areas

**Persona Development**:
1. Review personas before epics (personas inform stories)
2. Request expansion for key personas
3. Verify relationship mapping accuracy
4. Cross-reference pain points with planned features

**Epic and Story Writing**:
1. Validate epic dependencies early
2. Ensure stories trace to personas
3. Use modify command for acceptance criteria refinement
4. Flag additional epics discovered during story creation

**Architecture Phase**:
1. Review tech stack against team capabilities
2. Validate component dependencies
3. Check API contracts for completeness
4. Verify NFR coverage

**Output Management**:
1. Keep related items in single files
2. Use SQLite for queryable data
3. Export diagrams for presentations
4. Maintain Notion schema for team collaboration

---

## Limitations

1. **Yield Batch Size**: Fixed at 10 items. Cannot adjust batch size per phase.

2. **Phase Ordering**: Sequence is fixed. Cannot skip phases without generating minimal content.

3. **Diagram Rendering**: Mermaid/PlantUML syntax may require manual adjustment for complex relationships.

4. **Notion Integration**: Schema provided but manual import required. No direct Notion API integration.

5. **Image Generation**: Visual persona generation references tools but requires external image generation services.

6. **SQLite Queries**: Schema is flexible (JSON columns) but complex queries may require custom SQL.

7. **Resume Capability**: Can resume from named phases but loses in-progress batch state.

---

## See Also

- [nimps](./nimps.md) - Concise reference
- [npl-grader](./npl-grader.md) - Quality assessment agent
- [npl-persona](./npl-persona.md) - Persona management agent
- [npl-thinker](./npl-thinker.md) - Analysis and reasoning agent
- [npl-technical-writer](./npl-technical-writer.md) - Documentation agent
