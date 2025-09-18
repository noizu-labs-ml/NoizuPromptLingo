# NPL Documentation

This directory contains comprehensive documentation for the Noizu Prompt Lingua (NPL) framework.

## Documentation Overview

### Core Framework
- **[NPL Syntax Reference](../npl.md)** - Complete NPL syntax and conventions
- **[Agent Definitions](../.claude/agents/)** - Available NPL agents and their capabilities

### Multi-Agent Orchestration
- **[Orchestration Patterns](multi-agent-orchestration.md)** - Theoretical patterns and generic approaches for coordinating multiple agents
- **[Practical Examples](orchestration-examples.md)** - Real-world examples using specific NPL agents in complex workflows

## Multi-Agent Coordination

The NPL framework excels at coordinating multiple specialized agents for complex tasks. Two key documents explain this capability:

### [Multi-Agent Orchestration Patterns](multi-agent-orchestration.md)
Describes the theoretical foundations and generic patterns:
- **Consensus-Driven Analysis** - Multiple perspectives synthesized into unified decisions
- **Pipeline with Quality Gates** - Sequential processing with validation checkpoints
- **Hierarchical Task Decomposition** - Breaking complex problems into manageable subproblems
- **Iterative Refinement Spiral** - Cyclical improvement through multiple rounds
- **Multi-Perspective Synthesis Matrix** - Simultaneous analysis from different viewpoints

### [Practical Orchestration Examples](orchestration-examples.md)
Shows real implementations using actual NPL agents:
- **Complete Agent Development Lifecycle** - From research to deployment
- **Documentation Overhaul** - Systematic improvement of framework docs
- **Security Assessment** - Comprehensive security analysis and hardening
- **Tool Ecosystem Development** - Creating suites of complementary tools
- **Knowledge Base Creation** - Building searchable community resources

## Key NPL Agents

The framework includes 22 specialized agents for different domains:

**Development & Creation**
- `@npl-author` - NPL prompt and agent creation
- `@npl-tool-creator` - CLI and utility development
- `@npl-fim` - Visualization and code generation
- `@tdd-driven-builder` - Test-driven development

**Analysis & Research**
- `@npl-gopher-scout` - NPL framework exploration
- `@npl-system-analyzer` - System documentation synthesis
- `@npl-thinker` - Multi-cognitive reasoning

**Quality & Validation**
- `@npl-grader` - NPL validation and QA
- `@npl-qa-tester` - Test case generation
- `@npl-threat-modeler` - Security analysis

**Documentation & Communication**
- `@npl-technical-writer` - Technical documentation
- `@npl-marketing-writer` - Marketing content
- `@npl-knowledge-base` - Interactive knowledge management

## Getting Started with Multi-Agent Workflows

1. **Start Simple**: Begin with 2-3 agents before scaling to complex networks
2. **Use Concrete Examples**: Reference the practical examples for proven patterns
3. **Validate at Checkpoints**: Use `@npl-grader` for quality gates
4. **Document Workflows**: Create reusable patterns for your common scenarios
5. **Monitor Performance**: Track success rates and identify bottlenecks

## Common Orchestration Patterns

### Research → Analysis → Implementation
```bash
@npl-gopher-scout research "topic"
@npl-thinker analyze research.md --synthesize
@npl-author implement analysis.md --create-agent
```

### Multi-Perspective Validation
```bash
@npl-technical-writer assess --perspective="technical"
@npl-marketing-writer assess --perspective="user-value"
@npl-threat-modeler assess --perspective="security"
@npl-thinker synthesize perspectives --decision
```

### Quality-Gated Pipeline
```bash
@agent1 process | @npl-grader validate || @agent1 revise
@agent2 enhance | @npl-grader verify || @agent2 fix
@agent3 finalize | @npl-grader approve
```

## Advanced Coordination

For complex scenarios involving 5+ agents, error recovery, or dynamic routing, see the detailed examples in [orchestration-examples.md](orchestration-examples.md).

## Contributing

When adding new orchestration patterns:
1. Test with actual NPL agents (not hypothetical ones)
2. Include concrete examples with expected outputs
3. Document error handling and recovery strategies
4. Provide timing estimates and resource requirements
5. Add quality metrics and success criteria