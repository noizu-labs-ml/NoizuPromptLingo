# npl-system-digest

Multi-source intelligence aggregator for cross-referenced system documentation with IDE-compatible navigation.

**Detailed reference**: [npl-system-digest.detailed.md](npl-system-digest.detailed.md)

## Purpose

Aggregates documentation, code, and external sources into navigable, attributed output. Solves scattered documentation and missing cross-references in complex codebases.

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| Aggregation | Local files, external APIs, standards | [Intelligence Gathering](npl-system-digest.detailed.md#intelligence-gathering) |
| Cross-referencing | File:line attribution, symbol resolution | [Reference Patterns](npl-system-digest.detailed.md#reference-patterns) |
| Navigation | IDE-compatible `file://` links | [IDE Compatibility](npl-system-digest.detailed.md#ide-compatibility) |
| Output modes | Executive, technical, implementation | [Delivery Modes](npl-system-digest.detailed.md#delivery-modes) |
| Anchoring | Insert/modify documentation anchors | [Anchor Management](npl-system-digest.detailed.md#anchor-management) |

## Quick Start

```bash
# Basic analysis
@npl-system-digest analyze

# Executive summary (1 page)
@npl-system-digest analyze --mode=executive

# Incremental update
@npl-system-digest update --since-commit=HEAD~10

# IDE workspace navigation
@npl-system-digest generate-nav --format=vscode-workspace
```

See [Commands Reference](npl-system-digest.detailed.md#commands-reference) for all options.

## Configuration

| Option | Values | Default |
|:-------|:-------|:--------|
| `--mode` | executive, technical, implementation | technical |
| `--focus` | architecture, api, security, all | all |
| `--format` | markdown, html, json | markdown |

See [Configuration Options](npl-system-digest.detailed.md#configuration-options) for complete list.

## Integration

```bash
# Chain with grader
@npl-system-digest analyze && @npl-grader evaluate generated-docs/

# Transform for audience
@npl-system-digest analyze > system.md && @npl-technical-writer transform system.md --audience=onboarding
```

See [Integration Patterns](npl-system-digest.detailed.md#integration-patterns) for CI/CD and template examples.

## See Also

- [Best Practices](npl-system-digest.detailed.md#best-practices)
- [Limitations](npl-system-digest.detailed.md#limitations)
- [Digest Structure](npl-system-digest.detailed.md#digest-structure)
- Template: `skeleton/agents/npl-system-digest.npl-template.md`
