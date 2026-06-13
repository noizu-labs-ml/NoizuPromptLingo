# Personas Summary

Quick reference for core personas and their characteristics.

## Core Personas (7)

| ID | Name | Role | Key Goals | Tags |
|----|------|------|-----------|------|
| P-001 | AI Agent | Autonomous automation | Execute tasks independently, integrate with systems | autonomous, agent, technical |
| P-002 | Product Manager | Stakeholder & decision-maker | Monitor progress, make data-driven decisions | non-technical, observer, decision-maker |
| P-003 | Vibe Coder | Rapid prototyping developer | Build quickly, minimize process overhead | developer, rapid-iteration, hands-on |
| P-004 | Project Manager | Agent coordinator | Orchestrate workflows, track progress | manager, coordination, oversight |
| P-005 | Dave the Fellow Developer | Code quality expert | Ensure quality, maintain consistency | developer, senior, quality-focused |
| P-006 | Control Agent | Workflow orchestrator | Coordinate multi-agent sequences | agent, orchestration, control |
| P-007 | Sub-Agent | Task executor | Execute delegated work reliably | agent, execution, task-focused |

## Specialized Agent Categories

### Infrastructure Agents (3)
- **Build Manager** – Build process and deployment automation
- **Code Reviewer** – Automated code analysis and review
- **Prototyper** – Rapid prototype generation

### Quality Assurance (4)
- **Tester** – Test creation and execution
- **Validator** – Artifact validation
- **Benchmarker** – Performance benchmarking
- **Integrator** – Integration testing

### User Experience (3)
- **Accessibility Specialist** – Accessibility compliance
- **Onboarding Expert** – User onboarding optimization
- **Performance Optimizer** – Performance tuning

### Research & Analysis (4)
- **Claude Optimizer** – Claude API optimization
- **Cognitive Load Assessor** – Complexity analysis
- **Performance Monitor** – System performance monitoring
- **Research Validator** – Research methodology validation

### Project Management (4)
- **Project Coordinator** – Project planning and coordination
- **Risk Monitor** – Risk identification and tracking
- **Technical Reality Checker** – Technical feasibility assessment
- **User Impact Assessor** – User impact analysis

### Marketing (4)
- **Community Manager** – Community engagement
- **Conversion Specialist** – Conversion optimization
- **Marketing Copywriter** – Marketing content creation
- **Positioning Strategist** – Market positioning

### Core Domain Agents (5+)
- **NPL Author** – Content and documentation generation
- **NPL FIM** – Fill-in-the-middle code completion
- **NPL Grader** – Code quality evaluation
- **NPL QA** – Quality assurance testing
- **NPL Persona** – Persona creation and management

## Persona-Story Relationships

Personas anchor user stories. Each story connects to one or more personas:

### By Story Distribution
- **AI Agent (P-001)**: ~40 stories – Core automation capabilities
- **Vibe Coder (P-003)**: ~25 stories – Rapid prototyping and development
- **Product Manager (P-002)**: ~20 stories – Monitoring and dashboards
- **Project Manager (P-004)**: ~15 stories – Coordination and tracking
- **Dave the Developer (P-005)**: ~10 stories – Code quality and reviews
- **Control Agent (P-006)**: ~8 stories – Workflow orchestration
- **Sub-Agent (P-007)**: ~5 stories – Execution and reliability

## Tag Classifications

**User Type Tags**: `autonomous`, `human`, `agent`, `technical`, `non-technical`

**Role Tags**: `developer`, `manager`, `observer`, `decision-maker`, `executor`, `coordinator`

**Capability Tags**: `rapid-iteration`, `quality-focused`, `hands-on`, `oversight`, `analysis`

## Index Location

**File**: `project-management/personas/index.yaml`

**Manages**:
- Persona metadata (ID, name, file path)
- Tag assignments
- Story relationships
- Version tracking

**Updated by**: `npl-idea-to-spec` agent via `yq`
