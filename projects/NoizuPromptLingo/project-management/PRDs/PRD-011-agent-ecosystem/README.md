# PRD-011: Agent Ecosystem Definition

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

The NPL framework documents 45 specialized agents across 8 functional categories, but no formal agent loading system exists. Agents are defined as markdown files with embedded metadata, yet there is no registry, discovery mechanism, or runtime loading infrastructure. This PRD defines the complete agent ecosystem implementation including schema definitions, a loader system, and registry management.

**Current State**:
- 45 agents documented in markdown specifications
- 0 agents loadable through programmatic system
- No agent registry or discovery mechanism
- No validation of agent definitions

**Target State**:
- Agent definition schema with validation
- Programmatic loader for agent discovery
- Registry for runtime agent management
- Template system for agent customization

## Goals

1. Define comprehensive agent definition schema with YAML structure
2. Implement loader system for hierarchical agent discovery
3. Build runtime registry for agent management and search
4. Create template system for agent customization
5. Ensure all 45 documented agents have valid, complete definitions

## Non-Goals

- Agent execution runtime (handled by orchestration system)
- Multi-agent communication protocols (separate PRD)
- Agent-specific logic implementation (each agent's internal behavior)
- Web UI for agent management (future enhancement)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

**Note**: PRD-011 user stories (US-001 through US-005) used same IDs as other PRDs. These represent distinct agent ecosystem stories, not to be confused with general US-001-US-005 stories.

| ID | Title | Persona |
|----|-------|---------|
| US-084 | [Create Agent Definition System](../../user-stories/US-084-create-agent-definition-system.md) | P-005 |
| US-086 | [Extract and Load Agent Specifications](../../user-stories/US-086-extract-and-load-agent-specifications.md) | P-001 |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Agent Loader System](./functional-requirements/FR-001-agent-loader-system.md)
- **FR-002**: [Path Resolution Hierarchy](./functional-requirements/FR-002-path-resolution.md)
- **FR-003**: [Schema Validation Rules](./functional-requirements/FR-003-schema-validation.md)
- **FR-004**: [Agent Definition Schema Structure](./functional-requirements/FR-004-agent-definition-schema.md)
- **FR-005**: [Agent Registry Implementation](./functional-requirements/FR-005-agent-registry.md)
- **FR-006**: [Agent Dependency Resolution](./functional-requirements/FR-006-dependency-resolution.md)
- **FR-007**: [Agent Instantiation with Configuration](./functional-requirements/FR-007-agent-instantiation.md)
- **FR-008**: [Agent Template System](./functional-requirements/FR-008-template-system.md)
- **FR-009**: [Markdown-Based Agent Definition Format](./functional-requirements/FR-009-agent-definition-format.md)
- **FR-010**: [Agent Documentation Standards](./functional-requirements/FR-010-documentation-standards.md)

---

## Agent Categories

### 1. Core Agents (16 agents)
Discovery & Analysis, Content Creation, Implementation & Quality, Data & Visualization, Planning & Architecture, Security & Risk, Collaboration, Enterprise Planning

**Key Agents**: gopher-scout, npl-system-digest, npl-thinker, npl-technical-writer, tdd-driven-builder, npl-grader, npl-fim, nimps, npl-threat-modeler, npl-persona, npl-project-coordinator

### 2. Infrastructure Agents (3 agents)
Build automation, code review, prototyping

**Key Agents**: npl-build-manager, npl-code-reviewer, npl-prototyper

### 3. Project Management Agents (4 agents)
Sprint planning, risk assessment, impact analysis, technical validation

**Key Agents**: npl-project-coordinator, npl-risk-monitor, npl-user-impact-assessor, npl-technical-reality-checker

### 4. Quality Assurance Agents (4 agents)
Testing, benchmarking, CI/CD, validation

**Key Agents**: npl-tester, npl-benchmarker, npl-integrator, npl-validator

### 5. User Experience Agents (4 agents)
User research, accessibility, performance, onboarding

**Key Agents**: npl-user-researcher, npl-accessibility, npl-performance, npl-onboarding

### 6. Marketing Agents (4 agents)
Positioning, content creation, conversion optimization, community building

**Key Agents**: npl-positioning, npl-marketing-copy, npl-conversion, npl-community

### 7. Research Agents (4 agents)
Hypothesis testing, performance monitoring, cognitive load assessment, Claude optimization

**Key Agents**: npl-research-validator, npl-performance-monitor, npl-cognitive-load-assessor, npl-claude-optimizer

### 8. Specialized Domain Agents (6 agents)
Tool creation, system analysis, QA testing, knowledge management, scripting

**Key Agents**: npl-tool-forge, npl-tool-creator, npl-system-analyzer, npl-qa-tester, nb, npl-scripting

**Total**: 45 specialized agents across 8 categories

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Agent discovery performance | Discovery latency | < 100ms for typical projects |
| NFR-2 | Schema validation coverage | Validation pass rate | 100% of agent definitions |
| NFR-3 | Registry search precision | Search accuracy | >= 90% precision |
| NFR-4 | Documentation completeness | Agent coverage | 100% of 45 agents documented |
| NFR-5 | Test coverage | Line coverage | >= 80% for loader/registry code |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid agent file | ParseError | "Agent definition has invalid YAML syntax at line {N}" |
| Missing required field | ValidationError | "Agent missing required field: {field_name}" |
| Agent not found | NotFoundError | "Agent '{agent_id}' not found in registry" |
| Circular dependency | CyclicDependencyError | "Circular dependency detected: {agent_path}" |
| Invalid configuration | ConfigurationError | "Invalid config value for '{param}': {reason}" |
| Path not accessible | PermissionError | "Cannot access agent path: {path}" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Key tests:
- **AT-001**: [Agent Discovery Performance](./acceptance-tests/AT-001-agent-discovery-performance.md)
- **AT-002**: [Complete Schema Validation](./acceptance-tests/AT-002-schema-validation-complete.md)
- **AT-003**: [Registry Search Precision](./acceptance-tests/AT-003-registry-search-precision.md)
- **AT-004**: [Agent Dependency Resolution](./acceptance-tests/AT-004-dependency-resolution.md)
- **AT-005**: [Agent Template Instantiation](./acceptance-tests/AT-005-template-instantiation.md)
- **AT-006**: [Markdown Agent Definition Parsing](./acceptance-tests/AT-006-markdown-parsing.md)
- **AT-007**: [Agent Documentation Completeness](./acceptance-tests/AT-007-documentation-completeness.md)
- **AT-008**: [End-to-End Agent Loading Workflow](./acceptance-tests/AT-008-end-to-end-workflow.md)

---

## Success Criteria

1. **Agent Coverage**: All 45 documented agents have valid definitions
2. **Schema Compliance**: 100% of definitions pass validation
3. **Loader Performance**: Agent discovery <100ms for typical project
4. **Registry Accuracy**: Search returns relevant agents with >90% precision
5. **Template Flexibility**: Custom variants load without errors
6. **Documentation**: Each agent has usage examples and capability descriptions
7. **Test Coverage**: >= 80% line coverage for loader and registry components
8. **Integration**: Multi-agent orchestration workflows can load and compose agents

---

## Out of Scope

- Agent execution runtime (handled by orchestration framework)
- Multi-agent communication protocols (separate PRD)
- Agent-specific prompt engineering (each agent owns its prompts)
- Web-based agent browser (future enhancement)
- Agent marketplace/sharing (future enhancement)
- Version migration for agent definitions (future)
- Hot-reloading of agent changes (future)

---

## Dependencies

**Internal**:
- File system access for hierarchical path scanning
- YAML parser for frontmatter extraction
- Markdown parser for documentation content

**External**:
- Python 3.11+ (for type hints and language features)
- `pyyaml` library for YAML parsing
- `pathlib` for path operations

**Agent Dependencies**:
All 45 agents depend on this ecosystem infrastructure being implemented before they can be programmatically loaded.

---

## File Organization

```
.npl/agents/
├── core/
│   ├── gopher-scout.md
│   ├── npl-thinker.md
│   └── ...
├── infrastructure/
│   ├── npl-build-manager.md
│   └── ...
├── project-management/
├── quality-assurance/
├── user-experience/
├── marketing/
├── research/
└── specialized/
```

---

## Open Questions

- [ ] Should agent versioning support backward compatibility checks?
- [ ] How should agent updates be handled in long-running sessions?
- [ ] Should the registry support agent hot-reloading during development?
- [ ] What's the strategy for deprecating/retiring agents?

---

## Legacy Reference

- Core Agents: `.tmp/docs/agents/summary.brief.md`
- Additional Agents: `.tmp/docs/additional-agents/summary.brief.md`
- Agent README: `.tmp/docs/agents/README.brief.md`
