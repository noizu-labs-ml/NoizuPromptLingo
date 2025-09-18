# Practical Multi-Agent Orchestration Examples

Real-world examples of coordinating multiple NPL agents for complex tasks.

## Example 1: Complete NPL Agent Development Lifecycle

**Scenario**: Create a new NPL agent for code review with full documentation and testing.

### Orchestration Flow

```bash
# Phase 1: Requirements and Research (Parallel)
@npl-gopher-scout research "code review agent patterns" --output=research.md &
@npl-system-analyzer analyze existing-agents/ --focus="code-review-capabilities" --output=analysis.md &
wait

# Phase 2: Synthesis and Planning
@npl-thinker synthesize research.md analysis.md --goal="agent requirements" --output=requirements.md

# Phase 3: Design with Validation Loop
@npl-author create agent-spec --name="code-reviewer" --requirements=requirements.md --output=spec-v1.md
@npl-grader validate spec-v1.md --criteria="npl-compliance,completeness" || {
    @npl-author revise spec-v1.md --feedback="$(npl-grader output)" --output=spec-v2.md
}

# Phase 4: Implementation (TDD approach)
@npl-qa-tester generate test-plan spec-v2.md --output=test-plan.md
@tdd-driven-builder implement spec-v2.md --test-plan=test-plan.md --output=agent-implementation/

# Phase 5: Documentation (Multi-perspective)
@npl-technical-writer create user-guide --agent=code-reviewer --output=docs/user-guide.md &
@npl-marketing-writer create overview --agent=code-reviewer --output=docs/overview.md &
@npl-technical-writer create api-reference --agent=code-reviewer --output=docs/api.md &
wait

# Phase 6: Quality Assurance and Integration
@npl-grader comprehensive-review agent-implementation/ docs/ --criteria="production-ready"
@npl-system-analyzer integration-test --new-agent=code-reviewer --existing-system=.claude/agents/
```

**Benefits**: Systematic development, multiple quality gates, comprehensive documentation
**Timeline**: ~2-3 hours for complete agent development

## Example 2: NPL Framework Documentation Overhaul

**Scenario**: Improve and reorganize the entire NPL framework documentation.

### Orchestration Flow

```bash
# Phase 1: Current State Analysis (Hierarchical)
@npl-system-analyzer audit docs/ --comprehensive --output=audit-report.md
@npl-gopher-scout identify gaps --docs=docs/ --code=src/ --output=gaps-analysis.md

# Phase 2: User Research and Requirements
@npl-persona simulate user-research --personas="new-developer,experienced-user,contributor" --output=user-needs.md
@npl-marketing-writer analyze audience --focus="documentation consumers" --output=audience-analysis.md

# Phase 3: Content Strategy (Consensus Building)
@npl-technical-writer propose structure --based-on="audit-report.md,gaps-analysis.md" --output=tech-proposal.md
@npl-marketing-writer propose structure --based-on="user-needs.md,audience-analysis.md" --output=marketing-proposal.md
@npl-thinker synthesize tech-proposal.md marketing-proposal.md --output=unified-strategy.md

# Phase 4: Content Creation (Pipeline with Checkpoints)
for section in $(cat unified-strategy.md | grep "^- " | cut -d' ' -f2); do
    @npl-gopher-scout research $section --output=research-$section.md
    @npl-technical-writer draft $section --research=research-$section.md --output=draft-$section.md
    @npl-grader validate draft-$section.md --criteria="accuracy,clarity" || continue
    @npl-marketing-writer enhance-readability draft-$section.md --output=final-$section.md
done

# Phase 5: Integration and Cross-Referencing
@npl-system-analyzer integrate final-*.md --create-navigation --output=integrated-docs/
@npl-technical-writer add cross-references integrated-docs/ --with-code=src/

# Phase 6: Quality Assurance (Multi-Agent Review)
@npl-grader final-review integrated-docs/ --comprehensive
@npl-persona simulate user-testing --docs=integrated-docs/ --personas="developer,user" --output=usability-report.md
@npl-technical-writer implement-feedback usability-report.md --docs=integrated-docs/
```

**Benefits**: Comprehensive coverage, user-focused content, systematic quality assurance
**Timeline**: ~1-2 days for complete documentation overhaul

## Example 3: Security Assessment and Hardening

**Scenario**: Perform comprehensive security analysis of NPL framework and implement improvements.

### Orchestration Flow

```bash
# Phase 1: Multi-Domain Threat Analysis
@npl-threat-modeler analyze architecture --framework="NPL" --output=threat-model.md
@npl-gopher-scout inventory attack-surface --codebase=src/ --configs=./ --output=attack-surface.md
@npl-system-analyzer dependency-analysis --security-focus --output=dependency-report.md

# Phase 2: Risk Assessment (Consensus Building)
@npl-threat-modeler assess-risks threat-model.md --priority-ranking --output=risk-assessment.md
@npl-technical-writer technical-impact attack-surface.md --output=technical-impact.md
@npl-thinker synthesize risk-assessment.md technical-impact.md dependency-report.md --output=consolidated-risks.md

# Phase 3: Mitigation Strategy Development
@npl-threat-modeler design-controls consolidated-risks.md --output=security-controls.md
@npl-tool-creator security-tooling security-controls.md --output=security-tools/
@npl-technical-writer security-procedures security-controls.md --output=security-procedures.md

# Phase 4: Implementation (Iterative with Validation)
for control in $(extract-controls security-controls.md); do
    @tdd-driven-builder implement-control $control --test-first --output=implementations/$control/
    @npl-threat-modeler validate-control implementations/$control/ --effectiveness
    @npl-grader integration-test implementations/$control/ --with-existing-system
done

# Phase 5: Documentation and Training
@npl-technical-writer security-guide implementations/ --audience="developers" --output=docs/security-guide.md
@npl-marketing-writer security-overview --audience="management" --output=docs/security-overview.md
@npl-knowledge-base create-training security-guide.md --interactive --output=training/

# Phase 6: Verification and Monitoring
@npl-threat-modeler final-assessment --post-implementation --output=final-security-report.md
@npl-tool-creator monitoring-tools final-security-report.md --continuous --output=monitoring/
```

**Benefits**: Comprehensive security coverage, systematic implementation, ongoing monitoring
**Timeline**: ~3-5 days for complete security hardening

## Example 4: NPL Tool Ecosystem Development

**Scenario**: Create a suite of complementary CLI tools for NPL development workflows.

### Orchestration Flow

```bash
# Phase 1: Ecosystem Analysis and Planning
@npl-system-analyzer current-tooling ./ --gaps-analysis --output=tooling-gaps.md
@npl-persona workflow-analysis --user-types="developer,prompt-engineer,admin" --output=workflow-needs.md
@nimps project-planning "NPL tool ecosystem" --based-on="tooling-gaps.md,workflow-needs.md" --output=project-plan.md

# Phase 2: Tool Specification (Parallel Development Teams)
# Team A: Core Tools
@npl-tool-creator spec "npl-validator" --requirements=project-plan.md --output=specs/validator.md &
@npl-tool-creator spec "npl-builder" --requirements=project-plan.md --output=specs/builder.md &

# Team B: Developer Tools
@npl-tool-creator spec "npl-debug" --requirements=project-plan.md --output=specs/debug.md &
@npl-tool-creator spec "npl-test" --requirements=project-plan.md --output=specs/test.md &

# Team C: Productivity Tools
@npl-tool-creator spec "npl-deploy" --requirements=project-plan.md --output=specs/deploy.md &
@npl-tool-creator spec "npl-monitor" --requirements=project-plan.md --output=specs/monitor.md &
wait

# Phase 3: Cross-Tool Integration Design
@npl-system-analyzer integration-design specs/ --ecosystem-coherence --output=integration-plan.md
@npl-technical-writer api-standards integration-plan.md --consistent-interfaces --output=api-standards.md

# Phase 4: Implementation (Coordinated Development)
for tool in validator builder debug test deploy monitor; do
    (
        @tdd-driven-builder implement specs/$tool.md --api-standards=api-standards.md --output=tools/$tool/ &
        @npl-technical-writer docs specs/$tool.md --output=docs/$tool.md &
    ) &
done
wait

# Phase 5: Integration Testing and Ecosystem Validation
@npl-grader ecosystem-test tools/ --integration-scenarios --output=integration-report.md
@npl-qa-tester workflow-testing tools/ --user-scenarios=workflow-needs.md --output=workflow-tests.md

# Phase 6: Package and Distribution
@npl-tool-creator package-ecosystem tools/ docs/ --distribution-ready --output=dist/
@npl-marketing-writer ecosystem-announcement dist/ --community --output=announcement.md
@npl-technical-writer installation-guide dist/ --multi-platform --output=INSTALL.md
```

**Benefits**: Coherent tool ecosystem, coordinated development, comprehensive testing
**Timeline**: ~1-2 weeks for complete tool suite development

## Example 5: Community Knowledge Base Creation

**Scenario**: Build a comprehensive, searchable knowledge base for the NPL community.

### Orchestration Flow

```bash
# Phase 1: Content Inventory and Analysis
@npl-gopher-scout inventory existing-content --sources="docs/,examples/,community-posts/" --output=content-inventory.md
@npl-system-analyzer knowledge-gaps content-inventory.md --user-needs-analysis --output=knowledge-gaps.md
@npl-persona user-research --focus="knowledge-seeking-behavior" --output=user-research.md

# Phase 2: Knowledge Architecture Design
@npl-knowledge-base design-structure knowledge-gaps.md user-research.md --output=kb-architecture.md
@npl-technical-writer information-architecture kb-architecture.md --navigation-design --output=ia-spec.md
@npl-marketing-writer content-strategy ia-spec.md --audience-focused --output=content-strategy.md

# Phase 3: Content Creation (Swarm Approach)
@npl-knowledge-base create-articles content-strategy.md --batch=fundamentals --output=articles/fundamentals/ &
@npl-technical-writer create-tutorials content-strategy.md --step-by-step --output=articles/tutorials/ &
@npl-gopher-scout research-topics content-strategy.md --deep-dive --output=articles/advanced/ &
@npl-marketing-writer create-examples content-strategy.md --practical --output=articles/examples/ &
wait

# Phase 4: Content Enhancement and Cross-Linking
@npl-system-analyzer cross-reference articles/ --semantic-linking --output=cross-ref-map.md
@npl-technical-writer enhance-navigation articles/ --based-on=cross-ref-map.md
@npl-fim generate-diagrams articles/ --explanatory-visuals --output=articles/assets/

# Phase 5: Interactive Features and Search
@npl-tool-creator search-engine articles/ --semantic-search --output=search-system/
@npl-knowledge-base interactive-features articles/ --quizzes-examples --output=interactive/
@npl-technical-writer api-documentation search-system/ interactive/ --output=kb-api.md

# Phase 6: Quality Assurance and Launch Preparation
@npl-grader content-review articles/ --comprehensive-qa --output=qa-report.md
@npl-persona user-testing articles/ interactive/ --usability-study --output=usability-report.md
@npl-marketing-writer launch-materials articles/ --community-announcement --output=launch/
```

**Benefits**: Comprehensive knowledge coverage, interactive learning, community-focused
**Timeline**: ~2-3 weeks for complete knowledge base

## Coordination Best Practices from Examples

### Effective Patterns Observed

1. **Parallel Research Phase**: Multiple agents gather information simultaneously
2. **Synthesis Checkpoints**: Use @npl-thinker to combine diverse inputs
3. **Validation Gates**: @npl-grader validates quality at each major milestone
4. **Iterative Refinement**: Feedback loops improve quality progressively
5. **Multi-Perspective Review**: Different agents review from their expertise areas

### Resource Management

- **Parallel Execution**: Use `&` and `wait` for concurrent agent operations
- **Pipeline Coordination**: Clear handoffs between sequential stages
- **Error Handling**: Conditional flows with `||` for failure recovery
- **Progress Tracking**: Intermediate outputs for monitoring and debugging

### Quality Assurance

- **Multiple Validation Points**: Not just final review, but checkpoint validations
- **Cross-Functional Review**: Technical, user experience, and quality perspectives
- **User-Centered Testing**: Persona-based validation of outputs
- **Integration Testing**: Ensure components work together effectively

### Scalability Considerations

- **Modular Design**: Break complex tasks into manageable agent-sized pieces
- **Reusable Patterns**: Standard orchestration flows for common scenarios
- **Monitoring and Metrics**: Track performance and identify bottlenecks
- **Documentation**: Clear workflows for team adoption and maintenance