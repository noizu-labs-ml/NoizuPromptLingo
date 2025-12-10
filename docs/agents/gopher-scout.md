# gopher-scout

Reconnaissance agent for systematic exploration and analysis of codebases, documentation, and system architectures.

## Purpose

Navigates complex systems to extract key information with minimal context consumption. Goes wide first to map structure, then dives deep on relevant areas. Produces structured reports with evidence-backed findings.

See [Detailed Documentation](gopher-scout.detailed.md) for complete reference.

## Capabilities

- **Systematic exploration**: Directory structures, codebases, documentation hierarchies
- **Adaptive depth**: Adjusts analysis intensity based on relevance signals ([details](gopher-scout.detailed.md#operational-framework))
- **Pattern recognition**: Identifies architectural patterns, conventions, relationships
- **Structured reporting**: Executive summaries, findings, dependency maps, recommendations ([format](gopher-scout.detailed.md#report-structure))
- **Context efficiency**: Summarizes rather than includes full content
- **Cross-reference validation**: Verifies findings across multiple sources

## Commands

| Command | Purpose | Details |
|:--------|:--------|:--------|
| `survey` | Quick structural overview | [survey](gopher-scout.detailed.md#survey) |
| `analyze` | Full reconnaissance with optional focus | [analyze](gopher-scout.detailed.md#analyze) |
| `compare` | Side-by-side codebase comparison | [compare](gopher-scout.detailed.md#compare) |
| `audit` | Technical due diligence assessment | [audit](gopher-scout.detailed.md#audit) |

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

Chain with other agents for comprehensive analysis. See [Integration Patterns](gopher-scout.detailed.md#integration-patterns) for details.

```bash
# Scout gathers intel, author documents it
@npl-gopher-scout analyze ./project --focus="API design" > @npl-author "Generate API documentation"

# Scout maps architecture, thinker analyzes decisions
@npl-gopher-scout analyze ./microservices --focus="service boundaries" > @npl-thinker "Evaluate coupling"

# Multi-scout coordination for complex systems
@npl-gopher-scout analyze ./frontend --focus="state management"
@npl-gopher-scout analyze ./backend --focus="data flow"
```

## Directives

Control exploration behavior inline:

| Directive | Purpose |
|:----------|:--------|
| `exploration-path` | Define exploration trajectory |
| `focus-area` | Narrow investigation scope |
| `depth-level` | Set analysis intensity: `survey`, `summary`, `deep`, `exhaustive` |
| `report-format` | Output structure: `brief`, `standard`, `detailed`, `technical` |

See [Directives](gopher-scout.detailed.md#directives) for usage examples.

## Limitations

- Static analysis only; cannot execute code
- Large codebases require scope narrowing
- Confidence varies with code quality and documentation

See [Limitations](gopher-scout.detailed.md#limitations) and [Best Practices](gopher-scout.detailed.md#best-practices) for guidance.

## See Also

- [Detailed Documentation](gopher-scout.detailed.md) - Complete reference
- Core definition: `core/agents/npl-gopher-scout.md`
- Related: `@npl-author`, `@npl-thinker`, `@npl-system-digest`
