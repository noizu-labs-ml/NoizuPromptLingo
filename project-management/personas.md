# Personas

Personas represent the different types of users and stakeholders who interact with the NPL MCP system. They provide the foundation for user story creation and help shape requirements from multiple perspectives.

## Purpose

Personas capture the roles, goals, and perspectives of different users. They serve as:
- **Anchors for user stories** – Each story is written from a persona's perspective
- **Requirement lenses** – Features are evaluated across multiple persona viewpoints
- **Communication tools** – Help teams align on who they're building for

## Structure

Each persona file contains:
- **ID**: Unique identifier (P-001 through P-XXX)
- **Name**: Human-readable persona name
- **Role**: Primary function within the system
- **Goals**: What the persona wants to achieve
- **Pain Points**: Challenges or frustrations they face
- **Skills**: Technical abilities or expertise
- **Tools**: Systems or technologies they use
- **Constraints**: Limitations or requirements
- **Related Stories**: User stories associated with this persona

## Core Personas

The system defines 7 core personas organized by category:

### Primary Users (5 personas)

| ID | Name | Role | Primary Goal |
|----|------|------|--------------|
| P-001 | AI Agent | Autonomous programmatic automation | Execute tasks independently with minimal intervention |
| P-002 | Product Manager | Non-technical stakeholder & decision-maker | Monitor progress and make data-driven decisions |
| P-003 | Vibe Coder | Rapid prototyping developer | Build and iterate quickly without process overhead |
| P-004 | Project Manager | Agent coordination specialist | Orchestrate multi-agent workflows and track progress |
| P-005 | Dave the Fellow Developer | Senior code reviewer & quality expert | Ensure code quality and architectural consistency |

### Infrastructure Personas (2 personas)

| ID | Name | Role | Primary Goal |
|----|------|------|--------------|
| P-006 | Control Agent | Orchestration and workflow manager | Coordinate complex multi-agent sequences |
| P-007 | Sub-Agent | Task execution specialist | Reliably execute delegated work |

## Specialized Agent Personas

Beyond the core personas, the system includes 16+ specialized agent personas organized by domain:

### Core Agents
- **NPL Author** – Content and documentation generation
- **NPL FIM** – Fill-in-the-middle code completion
- **NPL Grader** – Code quality evaluation
- **NPL QA** – Quality assurance testing
- **NPL Persona** – Persona creation and management

### Infrastructure Agents
- **Build Manager** – Build process and deployment automation
- **Code Reviewer** – Automated code review and analysis
- **Prototyper** – Quick prototype generation

### Quality Assurance
- **Tester** – Test creation and validation
- **Validator** – Artifact validation and verification
- **Benchmarker** – Performance benchmarking
- **Integrator** – Integration testing

### User Experience
- **Accessibility Specialist** – Accessibility compliance
- **Onboarding Expert** – User onboarding optimization
- **Performance Optimizer** – Performance tuning

### Research & Analysis
- **Claude Optimizer** – Claude API optimization
- **Cognitive Load Assessor** – Complexity analysis
- **Performance Monitor** – System performance tracking
- **Research Validator** – Research methodology validation

### Project Management
- **Project Coordinator** – Project planning and coordination
- **Risk Monitor** – Risk identification and tracking
- **Technical Reality Checker** – Technical feasibility assessment
- **User Impact Assessor** – User impact analysis

### Marketing
- **Community Manager** – Community engagement
- **Conversion Specialist** – Conversion optimization
- **Marketing Copywriter** – Marketing content creation
- **Positioning Strategist** – Market positioning

## Index Files

Persona metadata is maintained in `index.yaml` files:
- **Location**: `project-management/personas/index.yaml`
- **Maintains**: Persona IDs, names, file references, tags, and relationships
- **Updated by**: The `npl-idea-to-spec` agent via `yq`

## Organization

Personas are stored in individual markdown files and indexed for easy discovery:

```
project-management/personas/
├── index.yaml                      # Persona index with relationships
├── ai-agent.md                     # P-001
├── product-manager.md              # P-002
├── vibe-coder.md                   # P-003
├── project-manager.md              # P-004
├── dave-fellow-developer.md        # P-005
├── control-agent.md                # P-006
├── sub-agent.md                    # P-007
├── agents/                         # Specialized agent personas
│   ├── npl-author.md
│   ├── npl-fim.md
│   └── ... (16+ more)
└── additional-agents/              # Domain-organized agents
    ├── infrastructure/
    ├── quality-assurance/
    ├── user-experience/
    ├── research/
    ├── project-management/
    └── marketing/
```

## Creating Personas

New personas are created through the `npl-idea-to-spec` agent, which:
1. Analyzes feature pitches to identify user types
2. Creates new personas as needed
3. Updates the `index.yaml` with metadata
4. Links personas to their associated user stories

## Querying Personas

Personas can be queried using `yq` from the `index.yaml`:

```bash
# List all personas
yq '.personas[] | .id + ": " + .name' project-management/personas/index.yaml

# Find specific persona
yq '.personas[] | select(.id == "P-001")' project-management/personas/index.yaml

# Get personas by tag
yq '.personas[] | select(.tags[] == "autonomous")' project-management/personas/index.yaml
```

## Related Documentation

- **Index**: `project-management/personas/index.yaml` – Persona relationships and metadata
- **User Stories**: `project-management/user-stories/` – Stories written from persona perspectives
- **Product Architecture**: `docs/PROJ-ARCH.md` – How personas inform requirements
