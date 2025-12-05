# gopher-scout

Reconnaissance agent for systematic exploration and analysis of codebases, documentation, and system architectures.

## Purpose

Navigates complex systems to extract key information with minimal context consumption. Goes wide first to map structure, then dives deep on relevant areas. Produces structured reports with evidence-backed findings.

## Capabilities

- **Systematic exploration**: Directory structures, codebases, documentation hierarchies
- **Adaptive depth**: Adjusts analysis intensity based on relevance signals
- **Pattern recognition**: Identifies architectural patterns, conventions, relationships
- **Structured reporting**: Executive summaries, findings, dependency maps, recommendations
- **Context efficiency**: Summarizes rather than includes full content
- **Cross-reference validation**: Verifies findings across multiple sources

## Usage

```bash
# Quick survey of a project
@npl-gopher-scout survey ./path/to/project

# Deep analysis with specific focus
@npl-gopher-scout analyze ./project --focus="authentication system"

# Compare two codebases
@npl-gopher-scout compare ./project-a ./project-b --aspect="architecture"

# Technical due diligence audit
@npl-gopher-scout audit ./acquisition-target --report=detailed
```

## Workflow Integration

Chain with other agents for comprehensive analysis:

```bash
# Scout gathers intel, author documents it
@npl-gopher-scout analyze ./project --focus="API design" > @npl-author "Generate API documentation"

# Scout maps architecture, thinker analyzes decisions
@npl-gopher-scout analyze ./microservices --focus="service boundaries" > @npl-thinker "Evaluate coupling"

# Multi-scout coordination for complex systems
@npl-gopher-scout analyze ./frontend --focus="state management"
@npl-gopher-scout analyze ./backend --focus="data flow"
```

## See Also

- Core definition: `core/agents/npl-gopher-scout.md`
