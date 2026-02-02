# NPL Core Agent Ecosystem - Summary Brief

## 16 Core Agents

The NPL Agent Ecosystem provides 16 specialized agents organized into strategic functional areas:

### Discovery & Analysis Layer
1. **gopher-scout** - Reconnaissance agent for systematic codebase exploration with adaptive depth analysis. Maps structures, identifies patterns, and generates evidence-backed findings with minimal context consumption.
2. **npl-system-digest** - Multi-source intelligence aggregator combining local documentation, code, and external sources into navigable, cross-referenced outputs with IDE-compatible navigation.
3. **npl-thinker** - Multi-cognitive reasoning engine combining intent planning, chain-of-thought, critique, reflection, and tangent exploration for transparent analysis of complex problems.

### Content Creation Layer
4. **npl-technical-writer** - Produces clear, actionable technical documentation (specs, PRs, issues, APIs, READMEs) without marketing fluff or LLM verbosity using anti-pattern filtering.
5. **npl-marketing-writer** - High-converting marketing specialist creating landing pages, product descriptions, and campaigns using AIDA/PAS/BAB conversion frameworks.
6. **npl-author** - NPL-compliant prompt and agent definition generator that applies semantic boundaries, attention anchors, and in-fill patterns with optimal component loading.

### Implementation & Quality Layer
7. **tdd-driven-builder** - Test-Driven Development agent enforcing Red-Green-Refactor cycles with strict >90% coverage targets and convention detection for testable implementations.
8. **npl-grader** - Quality assurance and validation agent combining syntax checking, edge case testing, integration verification, and rubric-based scoring with custom weightings.
9. **npl-qa** - Test case generation engine using equivalency partitioning, boundary analysis, and multi-category testing (happy path, negative, security, performance, E2E) with glyph-based visualization.

### Data & Visualization Layer
10. **npl-fim** - Fill-in-the-middle visualization specialist supporting 150+ frameworks (D3.js, Chart.js, Plotly, Three.js, Mermaid, etc.) for data visualizations, diagrams, 3D graphics, and creative animations.

### Planning & Architecture Layer
11. **nimps** (Noizu Idea-to-MVP Service) - Transforms conceptual ideas into comprehensive MVP specifications through 8-phase yield-driven iteration (personas → epics → stories → SWOT → revenue → mockups → architecture → docs).
12. **npl-prd-manager** - PRD lifecycle manager validating requirements against SMART criteria with requirement traceability chains (story → requirement → acceptance criteria) and implementation progress tracking.
13. **npl-templater** - Template creation and hydration agent with 4 complexity tiers (zero-config → advanced) for standardizing project scaffolding with smart fill detection.

### Security & Risk Layer
14. **npl-threat-modeler** - Defensive security specialist applying STRIDE methodology for vulnerability identification, risk assessment, and compliance documentation (SOC2, ISO27001, NIST, GDPR, HIPAA, PCI-DSS).

### Collaboration & Orchestration Layer
15. **npl-persona** - Multi-perspective collaboration agent with persistent file-backed state (journal, tasks, knowledge base) for role-playing authentic character interactions and team discussions.

### Enterprise Planning Layer
16. **npl-prd-manager** (Advanced) - Extended enterprise planning agent for complex PRD management with SMART validation, traceability matrices, and codebase-to-requirement mapping.

---

## Orchestration Patterns

### Sequential Workflows
Agents pass outputs to subsequent agents in dependency chains. Example: `@gopher-scout analyze ./project` → `@npl-author document findings` → `@npl-grader validate` → `@npl-technical-writer refine`.

### Parallel Coordination
Multiple agents work simultaneously on related aspects with synthesis at the end. Example: `@persona alice`, `@persona bob`, `@persona charlie` review in parallel, results combined by upstream agent.

### Feedback Loops
Iterative refinement where quality checks trigger re-processing. Example: `@npl-technical-writer generate` → `@npl-grader evaluate` → if <80% score, loop back to writer for improvements.

### Conditional Workflows
Agent selection and execution adapt based on analysis results. Example: `@npl-thinker assess complexity` determines whether to invoke simple or multi-agent deep-analysis path.

### Multi-Stage Orchestration
Complex pipelines combining sequential + parallel patterns. Example: Phase 1 (parallel: `@npl-thinker` + `@npl-persona` analysis) → Phase 2 (sequential: `@tdd-builder` → `@npl-qa` → `@npl-technical-writer`) → Phase 3 (validation: `@npl-grader`).

---

## Agent Dependencies & Integration Points

### Primary Dependencies
- **gopher-scout** → feeds context to: `npl-author`, `npl-thinker`, `npl-system-digest`
- **npl-thinker** → enhances: all agents requiring deep analysis (tdd-builder, threat-modeler, nimps)
- **npl-grader** → validates output from: npl-technical-writer, npl-marketing-writer, npl-qa, tdd-builder, npl-threat-modeler
- **nimps** → feeds project plans to: npl-templater, npl-prd-manager, npl-system-digest
- **tdd-builder** → requires input from: npl-qa (test plans), npl-technical-writer (specs)
- **npl-threat-modeler** → integrates with: npl-thinker (strategic planning), npl-grader (security assessment validation)

### Integration Examples
- Documentation pipeline: `@npl-gopher-scout analyze ./src` → `@npl-technical-writer spec` → `@npl-grader evaluate`
- Feature development: `@nimps plan` → `@npl-qa generate-tests` → `@tdd-builder implement` → `@npl-grader validate`
- Security assessment: `@npl-threat-modeler analyze` → `@npl-fim visualize-risks` → `@npl-grader evaluate` → `@npl-technical-writer document`

---

## Documentation Gaps & Questions

1. **npl-tool-forge** (mentioned in README as template but no dedicated .md file) - Needs complete documentation for development tool creation agent
2. **npl-project-coordinator** (referenced in examples but not documented) - PRD and project planning coordination agent definition missing
3. **Agent Resource Requirements** - No documentation on token costs, execution time, or resource profiles for each agent
4. **Cross-Agent Communication Protocol** - Limited detail on how agents share structured data beyond file I/O and stdout
5. **Error Handling & Rollback Strategies** - Missing guidance for recovering from agent failures in long chains
6. **Custom Agent Creation** - How to create domain-specific agent variants from templates (only tdd-driven-builder documented)
7. **Workflow Performance Optimization** - Limited metrics on optimal agent sequencing to minimize tokens/latency
8. **Agent Versioning** - No clear versioning scheme for agent definitions and backward compatibility handling

---

## Key Capabilities Matrix

| Capability | Agents | Notes |
|---|---|---|
| Code Analysis | gopher-scout, npl-system-digest | Static analysis only; no execution |
| Documentation Gen | npl-technical-writer, npl-author, npl-system-digest | Anti-fluff filtering; house style support |
| Quality Validation | npl-grader, npl-qa | Rubric-based; edge case testing |
| Test Generation | npl-qa, tdd-builder | Equivalency partitioning; TDD cycles |
| Visualization | npl-fim | 150+ frameworks; real-time dashboards |
| Planning | nimps, npl-prd-manager, npl-templater | MVP → PRD → scaffolding pipeline |
| Security Analysis | npl-threat-modeler | STRIDE; compliance frameworks |
| Reasoning/Analysis | npl-thinker | Multi-cognitive; transparent logic |
| Marketing Content | npl-marketing-writer | Conversion-focused; A/B testing |
| Collaboration | npl-persona | Role-playing; team synthesis |

---

Generated from: worktrees/main/docs/agents/ (16 agent definitions reviewed)
