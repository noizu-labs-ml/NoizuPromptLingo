# npl-marketing-copy

Benefits-first documentation specialist that transforms technical features into developer-focused copy with clear value propositions.

**Type**: `service` | **Alias**: `@marketing-copy`, `@mcopy`

## Capabilities

- Feature-to-benefit transformation with quantified impact
- A/B testable messaging variants for different personas
- Conversion-optimized landing pages and documentation
- Value proposition matrices by developer segment
- Proof point integration (benchmarks, testimonials, comparisons)

See [Capabilities](./npl-marketing-copy.detailed.md#capabilities) for implementation details.

## Copy Types

| Type | Use Case |
|:-----|:---------|
| Landing page | Product/feature introductions |
| Doc headers | Scannable benefit-oriented titles |
| Release notes | User-facing changelog entries |
| Feature announcements | Blog/email announcements |
| Email sequences | Onboarding, adoption, re-engagement |

See [Copy Types](./npl-marketing-copy.detailed.md#copy-types) for templates and examples.

## Usage

```bash
@npl-marketing-copy convert technical-doc.md --benefits-focus
@npl-marketing-copy create value-prop --feature="code-review" --a-b-variants=3
@npl-marketing-copy optimize landing-page.md --conversion-focus --proof-points
```

See [Usage](./npl-marketing-copy.detailed.md#usage) for full parameter reference.

## Integration

```bash
# Verify claims with technical writer
@npl-marketing-copy generate claims > claims.md && @npl-technical-writer verify claims.md

# Extract value props from success stories
@npl-community generate success-stories > wins.md && @npl-marketing-copy extract value-props wins.md
```

See [Integration Patterns](./npl-marketing-copy.detailed.md#integration-patterns) for pipeline workflows.

## Limitations

- Cannot verify technical accuracy (pair with `@npl-technical-writer`)
- Quantified benefits require source benchmark data
- A/B testing suggestions only; actual testing needs external tools

See [Limitations](./npl-marketing-copy.detailed.md#limitations) for full details.

## See Also

- **Detailed reference**: [npl-marketing-copy.detailed.md](./npl-marketing-copy.detailed.md)
- Core definition: `core/additional-agents/marketing/npl-marketing-copy.md`
- Style guide: `.claude/npl-m/house-style/marketing-copy-style.md`
