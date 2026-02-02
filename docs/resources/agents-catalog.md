# NPL Agent Catalog (Legacy Documentation)

## Introduction

This catalog lists 45+ agents documented in the previous NPL iteration. These agents span discovery, content creation, quality assurance, planning, security, collaboration, and specialized domains.

**Current implementation status**: **Documented only** (0 implemented as full agents)

> **Note**: Current agent personas in `docs/personas/` and `docs/personas/index.yaml` are authoritative. This catalog is reference material only.

See [PRD-010](../prds/PRD-010-agent-library.md) for implementation plan.

---

## Core Agents (16 Total)

### Discovery & Analysis Layer

#### 1. gopher-scout

- **Category**: Discovery & Analysis
- **Purpose**: Reconnaissance agent for systematic codebase exploration with adaptive depth analysis. Maps structures, identifies patterns, and generates evidence-backed findings.
- **Key Capabilities**:
  - Systematic codebase exploration
  - Adaptive depth analysis
  - Pattern identification
  - Evidence-backed findings
  - Minimal context consumption
- **Primary Use Cases**: Initial codebase assessment, architecture discovery, pattern mining
- **Legacy Reference**: `.tmp/docs/agents/gopher-scout.md`

#### 2. npl-system-digest

- **Category**: Discovery & Analysis
- **Purpose**: Multi-source intelligence aggregator combining local documentation, code, and external sources into navigable, cross-referenced outputs.
- **Key Capabilities**:
  - Multi-source aggregation
  - Cross-referenced output
  - IDE-compatible navigation
  - Documentation synthesis
- **Primary Use Cases**: Knowledge consolidation, documentation aggregation, system understanding
- **Legacy Reference**: `.tmp/docs/agents/npl-system-digest.md`

#### 3. npl-thinker

- **Category**: Discovery & Analysis
- **Purpose**: Multi-cognitive reasoning engine combining intent planning, chain-of-thought, critique, reflection, and tangent exploration for transparent analysis.
- **Key Capabilities**:
  - Intent planning
  - Chain-of-thought reasoning
  - Self-critique and reflection
  - Tangent exploration
  - Transparent analysis
- **Primary Use Cases**: Complex problem analysis, strategic planning, decision support
- **Legacy Reference**: `.tmp/docs/agents/npl-thinker.md`

### Content Creation Layer

#### 4. npl-technical-writer

- **Category**: Content Creation
- **Purpose**: Produces clear, actionable technical documentation without marketing fluff or LLM verbosity using anti-pattern filtering.
- **Key Capabilities**:
  - Technical specification writing
  - API documentation
  - README generation
  - PR/issue descriptions
  - Anti-fluff filtering
- **Primary Use Cases**: Documentation, specifications, technical communications
- **Legacy Reference**: `.tmp/docs/agents/npl-technical-writer.md`

#### 5. npl-marketing-writer

- **Category**: Content Creation
- **Purpose**: High-converting marketing specialist using AIDA/PAS/BAB conversion frameworks for landing pages and campaigns.
- **Key Capabilities**:
  - Landing page copy
  - Product descriptions
  - Campaign content
  - Conversion optimization
  - A/B test variants
- **Primary Use Cases**: Product launches, marketing campaigns, conversion optimization
- **Legacy Reference**: `.tmp/docs/agents/npl-marketing-writer.md`

#### 6. npl-author

- **Category**: Content Creation
- **Purpose**: NPL-compliant prompt and agent definition generator applying semantic boundaries, attention anchors, and optimal component loading.
- **Key Capabilities**:
  - Agent definition generation
  - Prompt engineering
  - Semantic boundary application
  - Component loading optimization
- **Primary Use Cases**: Agent creation, prompt development, NPL syntax authoring
- **Legacy Reference**: `.tmp/docs/agents/npl-author.md`

### Implementation & Quality Layer

#### 7. tdd-driven-builder

- **Category**: Implementation & Quality
- **Purpose**: Test-Driven Development agent enforcing Red-Green-Refactor cycles with strict >90% coverage targets.
- **Key Capabilities**:
  - TDD cycle enforcement
  - Coverage tracking (>90% target)
  - Convention detection
  - Testable implementation patterns
- **Primary Use Cases**: Feature implementation, code development, test-first coding
- **Legacy Reference**: `.tmp/docs/agents/tdd-driven-builder.md`

#### 8. npl-grader

- **Category**: Implementation & Quality
- **Purpose**: Quality assurance and validation agent combining syntax checking, edge case testing, integration verification, and rubric-based scoring.
- **Key Capabilities**:
  - Syntax validation
  - Edge case testing
  - Integration verification
  - Rubric-based scoring
  - Custom weightings
- **Primary Use Cases**: Quality gates, validation checkpoints, scoring
- **Legacy Reference**: `.tmp/docs/agents/npl-grader.md`

#### 9. npl-qa

- **Category**: Implementation & Quality
- **Purpose**: Test case generation engine using equivalency partitioning, boundary analysis, and multi-category testing.
- **Key Capabilities**:
  - Equivalency partitioning
  - Boundary analysis
  - Happy path testing
  - Negative testing
  - Security/performance testing
  - Glyph-based visualization
- **Primary Use Cases**: Test suite generation, coverage analysis, quality assurance
- **Legacy Reference**: `.tmp/docs/agents/npl-qa.md`

### Data & Visualization Layer

#### 10. npl-fim

- **Category**: Data & Visualization
- **Purpose**: Fill-in-the-middle visualization specialist supporting 150+ frameworks for data visualizations, diagrams, 3D graphics, and animations.
- **Key Capabilities**:
  - 150+ framework support (D3.js, Chart.js, Plotly, Three.js, Mermaid, etc.)
  - Data visualizations
  - Diagrams and charts
  - 3D graphics
  - Creative animations
- **Primary Use Cases**: Dashboard creation, data presentation, visual documentation
- **Legacy Reference**: `.tmp/docs/agents/npl-fim.md`

### Planning & Architecture Layer

#### 11. nimps (Noizu Idea-to-MVP Service)

- **Category**: Planning & Architecture
- **Purpose**: Transforms conceptual ideas into comprehensive MVP specifications through 8-phase yield-driven iteration.
- **Key Capabilities**:
  - Persona generation
  - Epic and story creation
  - SWOT analysis
  - Revenue modeling
  - Mockup generation
  - Architecture planning
  - Documentation synthesis
- **Primary Use Cases**: MVP planning, product ideation, project initialization
- **Legacy Reference**: `.tmp/docs/agents/nimps.md`

#### 12. npl-prd-manager

- **Category**: Planning & Architecture
- **Purpose**: PRD lifecycle manager validating requirements against SMART criteria with requirement traceability chains.
- **Key Capabilities**:
  - SMART validation
  - Requirement traceability (story → requirement → acceptance criteria)
  - Implementation progress tracking
  - Codebase-to-requirement mapping
- **Primary Use Cases**: PRD management, requirement tracking, progress monitoring
- **Legacy Reference**: `.tmp/docs/agents/npl-prd-manager.md`

#### 13. npl-templater

- **Category**: Planning & Architecture
- **Purpose**: Template creation and hydration agent with 4 complexity tiers for standardizing project scaffolding.
- **Key Capabilities**:
  - 4 complexity tiers (zero-config → advanced)
  - Smart fill detection
  - Project scaffolding
  - Template customization
- **Primary Use Cases**: Project initialization, boilerplate generation, standardization
- **Legacy Reference**: `.tmp/docs/agents/npl-templater.md`

### Security & Risk Layer

#### 14. npl-threat-modeler

- **Category**: Security & Risk
- **Purpose**: Defensive security specialist applying STRIDE methodology for vulnerability identification and compliance documentation.
- **Key Capabilities**:
  - STRIDE methodology
  - Vulnerability identification
  - Risk assessment
  - Compliance documentation (SOC2, ISO27001, NIST, GDPR, HIPAA, PCI-DSS)
- **Primary Use Cases**: Security assessment, threat modeling, compliance auditing
- **Legacy Reference**: `.tmp/docs/agents/npl-threat-modeler.md`

### Collaboration & Orchestration Layer

#### 15. npl-persona

- **Category**: Collaboration & Orchestration
- **Purpose**: Multi-perspective collaboration agent with persistent file-backed state for role-playing authentic character interactions.
- **Key Capabilities**:
  - Persistent state (journal, tasks, knowledge base)
  - Role-playing interactions
  - Team discussions
  - Character authenticity
- **Primary Use Cases**: Team simulations, stakeholder perspectives, collaborative design
- **Legacy Reference**: `.tmp/docs/agents/npl-persona.md`

#### 16. npl-tool-forge

- **Category**: Development Tools
- **Purpose**: Development tool creation agent for CLI and utility generation (template only, minimal documentation).
- **Key Capabilities**:
  - CLI tool generation
  - Utility scaffolding
  - Framework-aware creation
- **Primary Use Cases**: Tool development, CLI creation, utility generation
- **Legacy Reference**: (Template reference in README)

---

## Infrastructure Agents (3 Total)

#### 17. npl-build-manager

- **Category**: Infrastructure
- **Purpose**: Automated build orchestration with dependency resolution and deployment pipeline configuration.
- **Key Capabilities**:
  - Build orchestration
  - Dependency resolution
  - Pipeline configuration
  - CI/CD integration
- **Primary Use Cases**: Build automation, deployment pipelines, dependency management
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-build-manager.md`

#### 18. npl-code-reviewer

- **Category**: Infrastructure
- **Purpose**: Multi-lens code review covering security, performance, and style with inline annotations.
- **Key Capabilities**:
  - Security review
  - Performance analysis
  - Style checking
  - Inline annotations
  - PR-ready feedback
- **Primary Use Cases**: Code reviews, PR assessment, quality gates
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-code-reviewer.md`

#### 19. npl-prototyper

- **Category**: Infrastructure
- **Purpose**: Specification-to-code generation with framework-aware scaffolding and API stubs.
- **Key Capabilities**:
  - Spec-to-code generation
  - Framework-aware scaffolding
  - Boilerplate creation
  - API stub generation
- **Primary Use Cases**: Rapid prototyping, proof-of-concept, scaffolding
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-prototyper.md`

---

## Project Management Agents (4 Total)

#### 20. npl-project-coordinator

- **Category**: Project Management
- **Purpose**: Sprint planning, resource allocation, dependency management, and progress reporting.
- **Key Capabilities**:
  - Sprint planning
  - Resource allocation
  - Dependency management
  - Progress reporting
- **Primary Use Cases**: Sprint ceremonies, project coordination, status reporting
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-project-coordinator.md`

#### 21. npl-risk-monitor

- **Category**: Project Management
- **Purpose**: Technical debt tracking, schedule/budget risk evaluation, and security/compliance monitoring.
- **Key Capabilities**:
  - Technical debt tracking
  - Schedule risk evaluation
  - Budget monitoring
  - Compliance checking
- **Primary Use Cases**: Risk assessment, debt tracking, health monitoring
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-risk-monitor.md`

#### 22. npl-user-impact-assessor

- **Category**: Project Management
- **Purpose**: Feature adoption prediction, stakeholder satisfaction analysis, and change impact assessment.
- **Key Capabilities**:
  - Adoption prediction
  - Satisfaction analysis
  - Impact assessment
  - Stakeholder analysis
- **Primary Use Cases**: Feature evaluation, change impact, stakeholder management
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-user-impact-assessor.md`

#### 23. npl-technical-reality-checker

- **Category**: Project Management
- **Purpose**: Architecture decision validation, complexity analysis, and best practices compliance.
- **Key Capabilities**:
  - Decision validation
  - Complexity analysis
  - Best practices audit
  - Feasibility assessment
- **Primary Use Cases**: Technical reviews, reality checks, decision validation
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-technical-reality-checker.md`

---

## QA Agents (4 Total)

#### 24. npl-tester

- **Category**: Quality Assurance
- **Purpose**: Test suite generation, coverage analysis, mock/stub creation, and regression test maintenance.
- **Key Capabilities**:
  - Test suite generation
  - Coverage analysis
  - Mock/stub creation
  - Regression maintenance
- **Primary Use Cases**: Testing pipelines, coverage improvement, test maintenance
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-tester.md`

#### 25. npl-benchmarker

- **Category**: Quality Assurance
- **Purpose**: Performance profiling, comparative benchmarking, load testing, and optimization recommendations.
- **Key Capabilities**:
  - Performance profiling
  - Comparative benchmarking
  - Load testing
  - Optimization recommendations
- **Primary Use Cases**: Performance testing, benchmarking, optimization
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-benchmarker.md`

#### 26. npl-integrator

- **Category**: Quality Assurance
- **Purpose**: CI/CD pipeline configuration, build automation, deployment strategies, and release coordination.
- **Key Capabilities**:
  - CI/CD configuration
  - Build automation
  - Deployment strategies
  - Release coordination
- **Primary Use Cases**: Pipeline setup, deployment automation, release management
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-integrator.md`

#### 27. npl-validator

- **Category**: Quality Assurance
- **Purpose**: Schema validation, API contract testing, data integrity verification, and compliance checking.
- **Key Capabilities**:
  - Schema validation
  - API contract testing
  - Data integrity verification
  - Compliance checking
- **Primary Use Cases**: Validation pipelines, contract testing, compliance
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-validator.md`

---

## User Experience Agents (4 Total)

#### 28. npl-user-researcher

- **Category**: User Experience
- **Purpose**: User research studies, behavioral data analysis, persona creation, and research-backed recommendations.
- **Key Capabilities**:
  - Research study design
  - Behavioral analysis
  - Persona creation
  - Research recommendations
- **Primary Use Cases**: User research, persona development, UX insights
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-user-researcher.md`

#### 29. npl-accessibility

- **Category**: User Experience
- **Purpose**: WCAG/ADA compliance audits, accessible component alternatives, and screen reader optimization.
- **Key Capabilities**:
  - WCAG/ADA audits
  - Accessible alternatives
  - Screen reader optimization
  - Compliance reporting
- **Primary Use Cases**: Accessibility audits, compliance, inclusive design
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-accessibility.md`

#### 30. npl-performance

- **Category**: User Experience
- **Purpose**: Performance bottleneck analysis, load time optimization, lazy loading/caching, and Core Web Vitals monitoring.
- **Key Capabilities**:
  - Bottleneck analysis
  - Load time optimization
  - Caching strategies
  - Core Web Vitals
- **Primary Use Cases**: Performance optimization, speed improvement, monitoring
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-performance.md`

#### 31. npl-onboarding

- **Category**: User Experience
- **Purpose**: Progressive disclosure design, interactive tutorials, contextual help systems, and activation rate optimization.
- **Key Capabilities**:
  - Progressive disclosure
  - Interactive tutorials
  - Contextual help
  - Activation optimization
- **Primary Use Cases**: Onboarding flows, user activation, tutorial design
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-onboarding.md`

---

## Marketing Agents (4 Total)

#### 32. npl-positioning

- **Category**: Marketing
- **Purpose**: Unique value propositions, competitive analysis through feature matrices and benchmarks.
- **Key Capabilities**:
  - Value proposition development
  - Competitive analysis
  - Feature matrices
  - Market positioning
- **Primary Use Cases**: Product positioning, competitive intelligence, messaging
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-positioning.md`

#### 33. npl-marketing-copy

- **Category**: Marketing
- **Purpose**: Developer-friendly technical content, documentation-style materials, and code examples.
- **Key Capabilities**:
  - Developer content
  - Technical marketing
  - Code examples
  - Documentation-style copy
- **Primary Use Cases**: Developer marketing, technical content, documentation
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-marketing-copy.md`

#### 34. npl-conversion

- **Category**: Marketing
- **Purpose**: Developer journey mapping, frictionless onboarding, trial-to-paid optimization, and time-to-first-value.
- **Key Capabilities**:
  - Journey mapping
  - Onboarding optimization
  - Conversion optimization
  - TTFV improvement
- **Primary Use Cases**: Conversion optimization, funnel analysis, growth
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-conversion.md`

#### 35. npl-community

- **Category**: Marketing
- **Purpose**: Community engagement strategies, contributor programs, ecosystem building, and recognition systems.
- **Key Capabilities**:
  - Community strategy
  - Contributor programs
  - Ecosystem building
  - Recognition systems
- **Primary Use Cases**: Community building, open-source growth, engagement
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-community.md`

---

## Research Agents (4 Total)

#### 36. npl-research-validator

- **Category**: Research
- **Purpose**: Empirical hypothesis testing, A/B testing of prompts, and statistical significance analysis.
- **Key Capabilities**:
  - Hypothesis testing
  - A/B testing
  - Statistical analysis
  - Prompt validation
- **Primary Use Cases**: Research validation, A/B testing, statistical analysis
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-research-validator.md`

#### 37. npl-performance-monitor

- **Category**: Research
- **Purpose**: Real-time latency tracking, token efficiency, resource utilization, and bottleneck identification.
- **Key Capabilities**:
  - Latency tracking
  - Token efficiency
  - Resource monitoring
  - Bottleneck detection
- **Primary Use Cases**: Performance monitoring, optimization, resource tracking
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-performance-monitor.md`

#### 38. npl-cognitive-load-assessor

- **Category**: Research
- **Purpose**: Cognitive complexity scoring, information density measurement, and task decomposition evaluation.
- **Key Capabilities**:
  - Complexity scoring
  - Density measurement
  - Task decomposition
  - Load assessment
- **Primary Use Cases**: Complexity analysis, prompt optimization, UX evaluation
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-cognitive-load-assessor.md`

#### 39. npl-claude-optimizer

- **Category**: Research
- **Purpose**: Claude-specific prompt tuning, temperature/parameter adjustment, and context optimization.
- **Key Capabilities**:
  - Claude-specific tuning
  - Parameter adjustment
  - Context optimization
  - Performance tuning
- **Primary Use Cases**: Claude optimization, prompt engineering, parameter tuning
- **Legacy Reference**: `.tmp/docs/additional-agents/npl-claude-optimizer.md`

---

## Additional Specialized Agents (6+ More)

The legacy documentation references additional specialized agents across various domains. These include domain-specific variants, experimental agents, and workflow-specific tools.

Agents mentioned in orchestration examples but not fully documented:
- **npl-tool-creator**: CLI and tool implementation
- **npl-system-analyzer**: System architecture analysis
- **npl-qa-tester**: Test case execution
- **npl-project-coordinator**: Referenced in orchestration but limited docs

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total agents documented** | 45+ |
| **Core agents** | 16 |
| **Infrastructure agents** | 3 |
| **Project management agents** | 4 |
| **QA agents** | 4 |
| **UX agents** | 4 |
| **Marketing agents** | 4 |
| **Research agents** | 4 |
| **Additional/specialized** | 6+ |
| **Total implemented** | 0 (as full agents) |
| **Implementation gap** | 100% |

---

## Agent Capabilities Matrix

| Capability | Agents |
|------------|--------|
| Code Analysis | gopher-scout, npl-system-digest, npl-code-reviewer |
| Documentation | npl-technical-writer, npl-author, npl-system-digest |
| Quality Validation | npl-grader, npl-qa, npl-validator, npl-tester |
| Test Generation | npl-qa, tdd-driven-builder, npl-tester |
| Visualization | npl-fim |
| Planning | nimps, npl-prd-manager, npl-templater, npl-project-coordinator |
| Security | npl-threat-modeler, npl-code-reviewer (security lens) |
| Reasoning | npl-thinker |
| Marketing | npl-marketing-writer, npl-positioning, npl-marketing-copy |
| Collaboration | npl-persona |
| Performance | npl-benchmarker, npl-performance, npl-performance-monitor |

---

## Cross-Category Relationships

| Relationship | Description |
|--------------|-------------|
| Infrastructure ↔ QA | Code reviews feed into test generation; pipeline automation enforces quality gates |
| Project Management ↔ Infrastructure | Coordinator orchestrates build-manager and code-reviewer |
| UX ↔ Project Management | User researcher findings inform project priorities |
| Marketing ↔ UX | Positioning leverages performance benchmarks |
| Research ↔ All | Performance-monitor tracks all agent workflows; research-validator tests output quality |

---

## Implementation References

| Resource | Location |
|----------|----------|
| Current personas | `docs/personas/index.yaml` |
| Agent library PRD | [PRD-010](../prds/PRD-010-agent-library.md) |
| Orchestration framework PRD | [PRD-011](../prds/PRD-011-orchestration-framework.md) |
| Legacy core agents | `.tmp/docs/agents/` |
| Legacy additional agents | `.tmp/docs/additional-agents/` |

---

## Legacy References

- **Core agents summary**: `.tmp/docs/agents/summary.brief.md`
- **Additional agents summary**: `.tmp/docs/additional-agents/summary.brief.md`
- **Orchestration patterns**: `.tmp/docs/multi-agent-orchestration.brief.md`

---

*Extracted from legacy agent documentation. Current implementation status and authoritative definitions are in `docs/personas/`. This catalog is reference material only.*
