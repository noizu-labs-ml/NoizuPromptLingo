# Additional Agents Library

## Overview

The Additional Agents Library extends the core NPL framework with 23 specialized agents organized across six functional categories. These agents provide domain-specific expertise for infrastructure management, project coordination, quality assurance, user experience optimization, marketing automation, and research validation.

Each agent is built on the NPL@1.0 framework and includes:
- Full templaterized customization support via `.npl-template.md` variants
- Integration with Claude Code's file system and git capabilities
- Context-aware pump system (intent, critique, rubric, reflection)
- Dynamic configuration through template variables
- Seamless handoff capabilities between agents

## Agent Categories

### [Infrastructure](./infrastructure/)
System architecture, deployment, and code management specialists.

- **npl-build-manager** - Automated build pipeline orchestration and optimization
- **npl-code-reviewer** - Advanced code review with git integration and quality metrics
- **npl-prototyper** - Rapid prototyping and POC development specialist

### [Project Management](./project-management/)
Coordination, risk assessment, and project health monitoring.

- **npl-project-coordinator** - Cross-agent dependency management and workflow orchestration
- **npl-risk-monitor** - Real-time risk identification and mitigation planning
- **npl-technical-reality-checker** - Feasibility assessment and technical debt evaluation
- **npl-user-impact-assessor** - Change impact analysis and user experience prediction

### [Quality Assurance](./quality-assurance/)
Testing, validation, and performance optimization.

- **npl-benchmarker** - Performance benchmarking and optimization recommendations
- **npl-integrator** - System integration testing and API compatibility verification
- **npl-tester** - Comprehensive test suite generation and execution
- **npl-validator** - Input validation, schema verification, and data integrity checking

### [User Experience](./user-experience/)
UX optimization, accessibility, and user research.

- **npl-accessibility** - WCAG compliance and accessibility optimization
- **npl-onboarding** - User onboarding flow design and optimization
- **npl-performance** - Frontend performance optimization and monitoring
- **npl-user-researcher** - User behavior analysis and research synthesis

### [Marketing](./marketing/)
Content creation, positioning, and conversion optimization.

- **npl-community** - Community engagement and developer relations
- **npl-conversion** - Conversion funnel optimization and A/B testing
- **npl-marketing-copy** - Marketing content generation and optimization
- **npl-positioning** - Product positioning and competitive analysis

### [Research](./research/)
Analysis, validation, and optimization research.

- **npl-claude-optimizer** - Claude-specific prompt optimization and performance tuning
- **npl-cognitive-load-assessor** - Cognitive complexity analysis and simplification
- **npl-performance-monitor** - System performance tracking and anomaly detection
- **npl-research-validator** - Research methodology validation and statistical analysis

## Using Additional Agents with Claude Code

### Basic Usage

Invoke any additional agent using the standard NPL agent syntax:

```bash
# Basic invocation
@npl-code-reviewer Review the authentication module for security issues

# With specific focus areas
@npl-tester Generate comprehensive test suite for the payment processor

# Multi-agent coordination
@npl-project-coordinator Orchestrate deployment workflow with risk assessment
```

### Template Customization

Each agent supports templaterized customization through environment variables and configuration files:

```bash
# Set custom rubric for code review
export CODE_REVIEW_RUBRIC="./custom-rubrics/security-focused.md"
@npl-code-reviewer Apply security-focused review to API endpoints

# Configure project dependencies for coordinator
export PROJECT_DEPENDENCIES="./project-deps.yaml"
@npl-project-coordinator Plan sprint with dependency analysis
```

### Template Variables

Common template variables supported across agents:

- `{{project_context}}` - Project-specific context and requirements
- `{{workflow_definition}}` - Custom workflow specifications
- `{{evaluation_rubric}}` - Domain-specific evaluation criteria
- `{{output_format}}` - Preferred output structure (markdown, json, yaml)
- `{{integration_points}}` - External system integration requirements

### Agent Handoffs

Agents support seamless handoffs for complex workflows:

```bash
# Risk assessment → mitigation planning
@npl-risk-monitor Identify deployment risks | @npl-project-coordinator Create mitigation plan

# Code review → test generation
@npl-code-reviewer Review changes | @npl-tester Generate tests for identified edge cases

# Performance monitoring → optimization
@npl-performance-monitor Analyze bottlenecks | @npl-performance Optimize identified issues
```

## Template Files

All agents include `.npl-template.md` variants for advanced customization:

### Template Structure
```markdown
---
name: {{agent_name}}
customizations:
  - {{custom_parameter_1}}
  - {{custom_parameter_2}}
---

load {{custom_context}} into context.
{{#if specialized_pumps}}
load {{specialized_pump}} into context.
{{/if}}
```

### Hydrating Templates

Use `@npl-templater` to create customized agent instances:

```bash
# Create specialized code reviewer for security audits
@npl-templater Hydrate npl-code-reviewer template with security audit configuration

# Generate project-specific test agent
@npl-templater Create custom tester from template with integration test focus
```

## Integration with Core NPL Agents

Additional agents work seamlessly with core NPL agents:

### With npl-grader
```bash
# Evaluate code review quality
@npl-code-reviewer Review module | @npl-grader Evaluate review thoroughness

# Assess test coverage
@npl-tester Generate tests | @npl-grader Grade test completeness
```

### With npl-persona
```bash
# Persona-driven user research
@npl-persona Create user archetype | @npl-user-researcher Analyze behavior patterns

# Marketing persona development
@npl-persona Define target audience | @npl-marketing-copy Generate targeted content
```

### With npl-thinker
```bash
# Complex problem analysis
@npl-thinker Analyze architecture | @npl-technical-reality-checker Assess feasibility

# Strategic planning
@npl-thinker Evaluate options | @npl-risk-monitor Identify potential issues
```

## Best Practices

### 1. Agent Selection
- Choose agents based on specific domain expertise
- Combine complementary agents for comprehensive coverage
- Use category-specific agents for focused tasks

### 2. Template Customization
- Define project-specific rubrics and criteria
- Set appropriate context through template variables
- Maintain consistency across agent configurations

### 3. Workflow Orchestration
- Use npl-project-coordinator for complex multi-agent workflows
- Define clear handoff points between agents
- Monitor agent outputs for quality assurance

### 4. Performance Optimization
- Cache common context files for faster loading
- Use targeted agent invocations vs. broad requests
- Leverage parallel agent execution where appropriate

## Quick Reference

### Infrastructure Agents
| Agent | Primary Use | Key Features |
|-------|------------|--------------|
| npl-build-manager | CI/CD orchestration | Pipeline optimization, dependency management |
| npl-code-reviewer | Code quality | Git integration, actionable feedback |
| npl-prototyper | Rapid development | POC generation, feasibility testing |

### Project Management Agents
| Agent | Primary Use | Key Features |
|-------|------------|--------------|
| npl-project-coordinator | Workflow orchestration | Dependency tracking, agent coordination |
| npl-risk-monitor | Risk management | Real-time monitoring, mitigation planning |
| npl-technical-reality-checker | Feasibility analysis | Technical debt assessment, complexity evaluation |
| npl-user-impact-assessor | Impact analysis | User experience prediction, change assessment |

### Quality Assurance Agents
| Agent | Primary Use | Key Features |
|-------|------------|--------------|
| npl-benchmarker | Performance testing | Metric tracking, optimization recommendations |
| npl-integrator | Integration testing | API compatibility, system integration |
| npl-tester | Test generation | Comprehensive coverage, edge case identification |
| npl-validator | Data validation | Schema verification, integrity checking |

### User Experience Agents
| Agent | Primary Use | Key Features |
|-------|------------|--------------|
| npl-accessibility | WCAG compliance | Accessibility audit, remediation guidance |
| npl-onboarding | User onboarding | Flow optimization, friction reduction |
| npl-performance | Frontend optimization | Performance monitoring, improvement strategies |
| npl-user-researcher | User research | Behavior analysis, insight synthesis |

### Marketing Agents
| Agent | Primary Use | Key Features |
|-------|------------|--------------|
| npl-community | Developer relations | Engagement strategies, community building |
| npl-conversion | Funnel optimization | A/B testing, conversion tracking |
| npl-marketing-copy | Content creation | Targeted messaging, brand consistency |
| npl-positioning | Market positioning | Competitive analysis, differentiation |

### Research Agents
| Agent | Primary Use | Key Features |
|-------|------------|--------------|
| npl-claude-optimizer | Claude optimization | Prompt tuning, performance enhancement |
| npl-cognitive-load-assessor | Complexity analysis | Cognitive metrics, simplification strategies |
| npl-performance-monitor | System monitoring | Anomaly detection, trend analysis |
| npl-research-validator | Research validation | Methodology review, statistical analysis |

## File Locations

- **Agent Definitions**: `/agentic/scaffolding/additional-agents/[category]/[agent-name].md`
- **Template Files**: `/agentic/scaffolding/additional-agents/[category]/[agent-name].npl-template.md`
- **Documentation**: `/doc/additional-agents/[category]/[agent-name].md`
- **Custom Configurations**: Project-specific, typically in `.claude/agents/` or project root

## Contributing

To add new agents to the library:

1. Create agent definition in appropriate category
2. Include corresponding `.npl-template.md` file
3. Add documentation in `/doc/additional-agents/`
4. Update this README with agent details
5. Test agent integration with core NPL framework

## Support

For questions about specific agents or integration support:
- Review individual agent documentation in category folders
- Check template files for customization options
- Refer to core NPL documentation for framework details
- Test agents in isolation before complex workflows

---

*The Additional Agents Library is part of the Noizu PromptLingo (NPL) framework, providing specialized expertise for comprehensive AI-assisted development workflows.*