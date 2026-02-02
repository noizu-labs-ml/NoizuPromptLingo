# Additional Agents Summary

**Location**: `worktrees/main/core/additional-agents/`

## Overview
Extended agent library organized by functional domain. These agents handle specialized concerns beyond core TDD workflow, including infrastructure, quality assurance, marketing, user experience, and research.

## Infrastructure Agents
`infrastructure/`

- **npl-build-manager** - Build pipeline orchestration and CI/CD management
- **npl-code-reviewer** - Automated code review with quality standards enforcement
- **npl-prototyper** - Rapid prototyping and proof-of-concept development
- **npl-incident-responder** - Production incident analysis and response coordination
- **npl-proxy-tuner** - Network proxy and configuration optimization

## Quality Assurance Agents
`quality-assurance/`

- **npl-validator** - Schema and specification validation
- **npl-tester** - Comprehensive testing strategy and test coverage analysis
- **npl-integrator** - Integration testing and cross-system validation
- **npl-benchmarker** - Performance benchmarking and regression detection

## Marketing Agents
`marketing/`

- **npl-community** - Community engagement and ecosystem building
- **npl-conversion** - Conversion optimization and user funnel analysis
- **npl-marketing-copy** - Marketing messaging and copywriting
- **npl-positioning** - Product positioning and market differentiation

## User Experience Agents
`user-experience/`

- **npl-accessibility** - WCAG compliance and accessibility auditing
- **npl-onboarding** - User onboarding experience design and optimization
- **npl-performance** - User-facing performance optimization
- **npl-user-researcher** - User research and usability testing

## Project Management Agents
`project-management/`

- **npl-technical-reality-checker** - Feasibility assessment and technical constraints validation
- **npl-risk-monitor** - Risk identification, tracking, and mitigation planning
- **npl-user-impact-assessor** - Impact analysis on end-users and stakeholders

## Research Agents
`research/`

- **npl-research-validator** - Research methodology and validity assessment
- **npl-performance-monitor** - Continuous performance monitoring and analysis
- **npl-claude-optimizer** - Claude model optimization and prompt tuning
- **npl-cognitive-load-assessor** - Cognitive load analysis and UX complexity evaluation

## Miscellaneous Agents
`misc/`

- **npl-incident-responder** - Emergency response and issue management
- **npl-proxy-tuner** - System tuning and optimization

## Organization Pattern

### Directory Structure
```
additional-agents/
├── infrastructure/         # Build, deployment, infrastructure
├── quality-assurance/      # Testing, validation, integration
├── marketing/              # Product positioning, community
├── user-experience/        # UX, accessibility, performance, research
├── project-management/     # Planning, risk, feasibility
├── research/               # Analysis, monitoring, optimization
└── misc/                   # Utility and specialized agents
```

### Agent Definition Format
Each agent file includes:
- **Purpose**: Core responsibility and use cases
- **Triggers**: When this agent should be invoked
- **Inputs**: Expected context and parameters
- **Outputs**: Deliverables and format
- **Tools**: Available capabilities
- **Constraints**: Limitations and dependencies

## Integration Points
- **With Core Agents**: Additional agents extend core workflow with specialized capabilities
- **With CI/CD**: Infrastructure agents connect to build/deployment systems
- **With Analytics**: Research agents connect to monitoring and performance systems
- **With User Management**: UX agents connect to user feedback and research systems

## Usage Patterns

### Single Agent Invocation
```bash
Task(
  description="Assess accessibility compliance for new UI",
  subagent_type="npl-accessibility"
)
```

### Parallel Agent Orchestration
```bash
# Multiple agents working independently on same feature
Task(..., subagent_type="npl-tester")           # Create tests
Task(..., subagent_type="npl-code-reviewer")    # Review implementation
Task(..., subagent_type="npl-performance")      # Optimize performance
Task(..., subagent_type="npl-accessibility")    # Audit accessibility
```

## Key Characteristics
- **Domain-Specific**: Each agent has deep expertise in their domain
- **Specialized Tools**: Access to domain-specific tools and integrations
- **Composable**: Can be combined to create comprehensive workflows
- **Measurable**: Output quality standards and success criteria defined
- **Extensible**: New agents can be added following the same pattern

## Workflow Integration

These agents typically activate:
1. **Post-Implementation**: Quality assurance, performance, accessibility
2. **Pre-Release**: Marketing prep, risk assessment, final validation
3. **Post-Release**: Monitoring, user research, incident response
4. **Ongoing**: Community management, performance monitoring, optimization

## Notes
- Additional agents are invoked on-demand, not as part of default TDD flow
- Each agent maintains its own knowledge base and context
- Agents can collaborate through shared session worklogs
- Output quality scales with clear objectives and context provided
