# Additional Agents

Specialized agent personas that extend the core NPL agent ecosystem for domain-specific workflows. These agents operate across six focused categories, each addressing distinct aspects of product development, quality, and user experience.

## Categories

### [Infrastructure](./infrastructure/README.md)
Build systems, code quality, and rapid prototyping agents.
- **npl-build-manager** - Orchestrates CI/CD pipelines and deployment automation
- **npl-code-reviewer** - Enforces code quality standards and best practices
- **npl-prototyper** - Rapid development and experimental feature validation

### [Marketing](./marketing/README.md)
Go-to-market strategy and customer engagement agents.
- **npl-community** - Community building and user advocacy
- **npl-conversion** - Funnel optimization and user activation
- **npl-marketing-copy** - Product messaging and copywriting
- **npl-positioning** - Market positioning and competitive strategy

### [Project Management](./project-management/README.md)
Project coordination, risk, and impact assessment agents.
- **npl-project-coordinator** - Sprint planning and stakeholder coordination
- **npl-risk-monitor** - Multi-dimensional risk tracking and mitigation
- **npl-technical-reality-checker** - Feasibility validation and estimation accuracy
- **npl-user-impact-assessor** - User-centric impact analysis and prioritization

### [Quality Assurance](./quality-assurance/README.md)
Testing, validation, and integration assurance agents.
- **npl-benchmarker** - Performance baseline establishment and regression detection
- **npl-integrator** - End-to-end integration testing and system validation
- **npl-tester** - Test design, execution, and coverage strategies
- **npl-validator** - Acceptance criteria validation and sign-off

### [Research](./research/README.md)
Performance optimization, model tuning, and evidence-based research agents.
- **npl-claude-optimizer** - Claude model tuning and API optimization
- **npl-cognitive-load-assessor** - Cognitive complexity measurement and reduction
- **npl-performance-monitor** - System performance tracking and optimization
- **npl-research-validator** - Evidence gathering and hypothesis validation

### [User Experience](./user-experience/README.md)
UX design, accessibility, and user research agents.
- **npl-accessibility** - Accessibility compliance and inclusive design
- **npl-onboarding** - User onboarding flows and first-time experience
- **npl-performance** - Frontend performance and user perception
- **npl-user-researcher** - User research, interviews, and feedback synthesis

## Integration Model

Additional agents coordinate with core agents to provide specialized expertise:

- **Receives from**: Core agents (idea-to-spec, prd-editor, tdd-coder, etc.)
- **Feeds to**: Core agents, other additional agents in cross-functional workflows
- **Coordinates with**: Domain-specific peers (e.g., all QA agents work together on test strategies)

## Usage Patterns

1. **Sequential workflows** - Task flows through related agents (e.g., project-coordinator → risk-monitor → technical-reality-checker)
2. **Parallel assessment** - Multiple agents evaluate same feature from different angles (marketing + UX + project-mgmt)
3. **Peer review** - Related agents in same category validate each other's outputs (code-reviewer + benchmarker)
4. **Escalation** - Findings from additional agents inform core agent decisions

## See Also

- [Core Agent Personas](../agents/) - Main NPL agents
- [Agent Orchestration](../../arch/agent-orchestration.md) - Orchestration framework
- [Multi-Agent Workflows](../../multi-agent-orchestration.md) - Workflow patterns
