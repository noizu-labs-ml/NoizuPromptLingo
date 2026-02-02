# PRD-010: Agent Ecosystem Definition

**Version**: 1.0
**Status**: Draft
**Owner**: NPL Framework Team
**Last Updated**: 2026-02-02

---

## Executive Summary

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

---

## Problem Statement

The NPL framework requires a systematic approach to agent management. Currently:

1. Agent definitions exist as scattered markdown files with inconsistent structure
2. No mechanism to discover available agents at runtime
3. No validation that agent definitions are complete and correct
4. No way to instantiate or configure agents programmatically
5. No registry for agent composition in multi-agent workflows

Without an agent ecosystem, multi-agent orchestration patterns cannot be reliably implemented, and Claude Code cannot dynamically load appropriate agents for tasks.

---

## Agent Specifications by Category

### 1. Core Agents (16 agents)

#### Discovery & Analysis Layer (3)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **gopher-scout** | Reconnaissance agent for codebase exploration | Adaptive depth analysis, pattern identification, evidence-backed findings |
| **npl-system-digest** | Multi-source intelligence aggregator | Local/external source synthesis, cross-referenced outputs, IDE navigation |
| **npl-thinker** | Multi-cognitive reasoning engine | Intent planning, chain-of-thought, critique, reflection, tangent exploration |

#### Content Creation Layer (3)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-technical-writer** | Technical documentation specialist | Specs, PRs, APIs, READMEs; anti-fluff filtering; house style support |
| **npl-marketing-writer** | Conversion-focused content creator | AIDA/PAS/BAB frameworks, landing pages, product descriptions |
| **npl-author** | NPL prompt/agent definition generator | Semantic boundaries, attention anchors, in-fill patterns |

#### Implementation & Quality Layer (3)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **tdd-driven-builder** | Test-Driven Development agent | Red-Green-Refactor cycles, >90% coverage, convention detection |
| **npl-grader** | Quality assurance validator | Syntax checking, edge case testing, rubric-based scoring |
| **npl-qa** | Test case generation engine | Equivalency partitioning, boundary analysis, multi-category testing |

#### Data & Visualization Layer (1)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-fim** | Visualization specialist | 150+ frameworks (D3, Chart.js, Plotly, Three.js, Mermaid) |

#### Planning & Architecture Layer (3)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **nimps** | Idea-to-MVP service | 8-phase yield-driven iteration, personas through architecture |
| **npl-prd-manager** | PRD lifecycle manager | SMART validation, requirement traceability, progress tracking |
| **npl-templater** | Template creation/hydration | 4 complexity tiers, smart fill detection |

#### Security & Risk Layer (1)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-threat-modeler** | Defensive security specialist | STRIDE methodology, compliance frameworks (SOC2, ISO27001, NIST, GDPR, HIPAA, PCI-DSS) |

#### Collaboration Layer (1)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-persona** | Multi-perspective collaboration | Persistent file-backed state, role-playing, team discussions |

#### Enterprise Planning Layer (1)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-project-coordinator** | Enterprise PRD management | SMART validation, traceability matrices, codebase-to-requirement mapping |

---

### 2. Infrastructure Agents (3 agents)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-build-manager** | Automated build orchestration | Dependency resolution, deployment pipelines, CI/CD integration |
| **npl-code-reviewer** | Multi-lens code review | Security, performance, style analysis; inline annotations; PR feedback |
| **npl-prototyper** | Specification-to-code generation | Framework-aware scaffolding, boilerplate, API stubs |

**Integration Points**: Pre-commit hooks, GitHub Actions, GitLab CI, Jenkins pipelines

---

### 3. Project Management Agents (4 agents)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-project-coordinator** | Sprint planning and coordination | Resource allocation, dependency management, progress reporting |
| **npl-risk-monitor** | Risk assessment specialist | Technical debt tracking, schedule/budget evaluation, compliance monitoring |
| **npl-user-impact-assessor** | Feature impact predictor | Adoption prediction, stakeholder satisfaction, change analysis |
| **npl-technical-reality-checker** | Architecture validator | Decision validation, complexity analysis, best practices compliance |

**Use Cases**: Sprint ceremonies, release planning, stakeholder reporting

---

### 4. Quality Assurance Agents (4 agents)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-tester** | Test suite generator | Coverage analysis, mock/stub creation, regression maintenance |
| **npl-benchmarker** | Performance profiler | Comparative benchmarking, load testing, optimization recommendations |
| **npl-integrator** | CI/CD configurator | Pipeline configuration, deployment strategies, release coordination |
| **npl-validator** | Contract tester | Schema validation, API testing, data integrity, compliance checking |

**Use Cases**: Pre-release quality gates, continuous monitoring, pre-commit validation

---

### 5. User Experience Agents (4 agents)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-user-researcher** | User research conductor | Behavioral analysis, persona creation, research-backed recommendations |
| **npl-accessibility** | Accessibility auditor | WCAG/ADA compliance, accessible alternatives, screen reader optimization |
| **npl-performance** | Performance optimizer | Bottleneck analysis, load time optimization, Core Web Vitals |
| **npl-onboarding** | Onboarding designer | Progressive disclosure, interactive tutorials, contextual help |

**Use Cases**: UX audits, mobile optimization, accessibility redesigns

---

### 6. Marketing Agents (4 agents)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-positioning** | Value proposition specialist | Competitive analysis, feature matrices, differentiation |
| **npl-marketing-copy** | Developer content creator | Technical content, documentation-style materials, code examples |
| **npl-conversion** | Developer journey optimizer | Frictionless onboarding, trial optimization, time-to-first-value |
| **npl-community** | Community builder | Engagement strategies, contributor programs, ecosystem building |

**Use Cases**: Product launches, open-source growth, developer adoption

---

### 7. Research Agents (4 agents)

| Agent | Purpose | Key Capabilities |
|-------|---------|------------------|
| **npl-research-validator** | Hypothesis tester | A/B testing, statistical significance, empirical validation |
| **npl-performance-monitor** | Real-time monitor | Latency tracking, token efficiency, resource utilization |
| **npl-cognitive-load-assessor** | Complexity evaluator | Cognitive scoring, information density, task decomposition |
| **npl-claude-optimizer** | Claude-specific tuner | Prompt optimization, parameter adjustment, context tuning |

**Use Cases**: Prompt validation, performance monitoring, adaptive optimization

---

### 8. Specialized Domain Agents (6 agents)

| Agent | Purpose | Domain |
|-------|---------|--------|
| **npl-tool-forge** | Development tool creator | CLI tools, utilities |
| **npl-tool-creator** | Tool implementation specialist | Tool development |
| **npl-system-analyzer** | System documentation | Architecture |
| **npl-qa-tester** | Test case specialist | Testing |
| **nb** | Knowledge management | Documentation |
| **npl-scripting** | Script generation | Automation |

---

## Functional Requirements

### 1. Agent Definition Schema

Each agent definition must include:

```yaml
agent:
  id: "gopher-scout"
  version: "1.0.0"
  name: "Gopher Scout"
  category: "discovery"

  metadata:
    author: "NPL Framework Team"
    created: "2026-01-15"
    updated: "2026-02-02"
    tags: ["exploration", "analysis", "reconnaissance"]

  capabilities:
    - id: "codebase-exploration"
      description: "Systematic exploration of code structures"
      inputs: ["directory_path", "depth", "filters"]
      outputs: ["structure_map", "findings"]
    - id: "pattern-identification"
      description: "Identify recurring patterns in codebase"
      inputs: ["source_files"]
      outputs: ["pattern_report"]

  dependencies:
    agents: []
    tools: ["glob", "grep", "read"]

  configuration:
    max_depth: 5
    file_patterns: ["*.py", "*.ts", "*.md"]
    output_format: "markdown"

  prompts:
    system: |
      You are Gopher Scout, a reconnaissance agent for systematic codebase exploration...
    examples:
      - input: "Analyze src/ directory"
        output: "## Codebase Structure..."

  orchestration:
    parallelizable: true
    max_instances: 3
    timeout_seconds: 300
    retry_count: 2
```

### 2. Agent Loader System

```python
class AgentLoader:
    """Discovers and loads agent definitions from hierarchical paths."""

    def discover(self, paths: list[Path]) -> list[AgentMetadata]:
        """Scan paths for agent definition files."""

    def load(self, agent_id: str) -> AgentDefinition:
        """Load and validate a specific agent definition."""

    def validate(self, definition: AgentDefinition) -> ValidationResult:
        """Validate agent definition against schema."""

    def instantiate(self, definition: AgentDefinition, config: dict) -> AgentInstance:
        """Create configured agent instance."""
```

**Path Resolution Order**:
1. `$NPL_AGENTS` environment variable
2. `.npl/agents/` (project-local)
3. `~/.npl/agents/` (user-global)
4. `/etc/npl/agents/` (system-wide)

### 3. Agent Registry

```python
class AgentRegistry:
    """Runtime registry for available agents."""

    def register(self, agent: AgentDefinition) -> None:
        """Register an agent definition."""

    def get(self, agent_id: str) -> AgentDefinition | None:
        """Retrieve agent by ID."""

    def list(self, category: str | None = None) -> list[AgentMetadata]:
        """List available agents, optionally filtered by category."""

    def search(self, query: str, capabilities: list[str] = None) -> list[AgentMetadata]:
        """Search agents by name, description, or capabilities."""

    def get_dependencies(self, agent_id: str) -> DependencyGraph:
        """Resolve agent dependencies for orchestration."""
```

### 4. Agent Template System

Support for customizable agent variants:

```yaml
# Base template
template:
  id: "tdd-builder-template"
  base_agent: "tdd-driven-builder"

  # Customizable parameters
  parameters:
    - name: "coverage_threshold"
      type: "integer"
      default: 90
      range: [50, 100]
    - name: "test_framework"
      type: "enum"
      options: ["pytest", "unittest", "jest", "mocha"]
      default: "pytest"

  # Variable substitution in prompts
  prompt_variables:
    coverage_requirement: "{{ coverage_threshold }}%"
    framework: "{{ test_framework }}"
```

---

## Implementation Notes

### Markdown-Based Definitions

Agent definitions are stored as markdown files with YAML frontmatter:

```markdown
---
agent:
  id: gopher-scout
  version: 1.0.0
  category: discovery
  ...
---

# Gopher Scout

## System Prompt

You are Gopher Scout...

## Capabilities

### Codebase Exploration

...
```

### File Organization

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

### Validation Rules

1. **Required Fields**: id, version, name, category, prompts.system
2. **ID Format**: lowercase alphanumeric with hyphens
3. **Version Format**: Semantic versioning (MAJOR.MINOR.PATCH)
4. **Category Validation**: Must match predefined categories
5. **Capability Uniqueness**: Capability IDs unique within agent
6. **Dependency Resolution**: All referenced agents must exist

---

## Success Criteria

1. **Agent Coverage**: All 45 documented agents have valid definitions
2. **Schema Compliance**: 100% of definitions pass validation
3. **Loader Performance**: Agent discovery <100ms for typical project
4. **Registry Accuracy**: Search returns relevant agents with >90% precision
5. **Template Flexibility**: Custom variants load without errors
6. **Documentation**: Each agent has usage examples and capability descriptions

---

## Testing Strategy

### Unit Tests
- Schema validation for all agent definition fields
- Loader path resolution across all hierarchy levels
- Registry search and filter operations

### Integration Tests
- Multi-agent dependency resolution
- Template instantiation with variable substitution
- Cross-category agent discovery

### E2E Tests
- Full agent loading workflow from discovery to instantiation
- Orchestration patterns using loaded agents
- Performance under realistic agent counts (45+)

---

## Legacy Reference

- **Core Agents**: `.tmp/docs/agents/summary.brief.md`
- **Additional Agents**: `.tmp/docs/additional-agents/summary.brief.md`
- **Agent README**: `.tmp/docs/agents/README.brief.md`
