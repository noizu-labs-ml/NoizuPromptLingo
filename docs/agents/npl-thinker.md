# npl-thinker

Multi-cognitive reasoning agent combining intent, chain-of-thought, reflection, mood, critique, and tangent pumps for structured problem-solving.

## Purpose

Provides transparent, multi-layered analysis for complex problems. Plans approaches, reasons through solutions, critiques alternatives, and reflects on outcomes.

## Capabilities

| Capability | Pump | Description |
|:-----------|:-----|:------------|
| Intent planning | `npl-intent` | Structures goals, approach, steps, constraints |
| Chain-of-thought | `npl-cot` | Step-by-step reasoning with visible logic |
| Self-critique | `npl-critique` | Evaluates strengths, weaknesses, alternatives |
| Reflection | `npl-reflection` | Assesses response quality with confidence levels |
| Tangent exploration | `npl-tangent` | Surfaces related connections and insights |
| Mood contextualization | `npl-mood` | Tracks emotional arc through analysis |

See [Pump Specifications](npl-thinker.detailed.md#pump-specifications) for syntax and examples.

## Usage

```bash
# Simple query (minimal pumps)
@npl-thinker "What's the capital of France?"

# Complex analysis (full cascade)
@npl-thinker "Compare REST vs GraphQL vs gRPC for mobile apps"

# Mode prefixes
Deep @npl-thinker "Evaluate microservices migration"
Creative @npl-thinker "Design gamified code review"
Analytical @npl-thinker "Analyze A/B test results"
```

## Response Modes

| Prefix | Mode | Pump Selection | Use Case |
|:-------|:-----|:---------------|:---------|
| (default) | Adaptive | Scales to complexity | General queries |
| `Deep` | Deep | All pumps, max depth | Architecture decisions |
| `Creative` | Creative | Tangent + divergent COT | Brainstorming |
| `Analytical` | Analytical | Systematic COT + rigorous critique | Data analysis |

See [Response Modes](npl-thinker.detailed.md#response-modes) for detailed pump flow.

## Processing Pipeline

```
request -> intent.plan() -> cot.reason() -> [tangent.explore()] -> critique.evaluate() -> reflection.assess() -> respond()
```

Complexity detection scales pump usage automatically. See [Processing Pipeline](npl-thinker.detailed.md#processing-pipeline).

## Integration

```bash
# Chain with other agents
@npl-thinker "Analyze requirements" | @npl-templater "Create template"

# Multi-round refinement
@npl-thinker "Analyze migration challenges"
@npl-thinker "Focus on data consistency issues identified above"
```

See [Integration Patterns](npl-thinker.detailed.md#integration-patterns).

## Configuration

```yaml
Runtime flags
@pumps.disable: [tangent]     # Skip specific pumps
@cot.depth: shallow           # Quick reasoning only
@mood.style: formal           # Professional tone
@reflection.verbose: true     # Detailed self-assessment
```

See [Configuration](npl-thinker.detailed.md#configuration).

## When to Use

| Scenario | Recommended |
|:---------|:------------|
| Factual questions | Quick mode (default) |
| Architecture decisions | Deep mode |
| Trade-off analysis | Analytical mode |
| Innovation tasks | Creative mode |
| Simple lookups | Consider simpler agent |

See [Best Practices](npl-thinker.detailed.md#best-practices) and [Limitations](npl-thinker.detailed.md#limitations).

## See Also

- [Detailed documentation](npl-thinker.detailed.md) - Complete reference
- Core definition: `core/agents/npl-thinker.md`
- Pump specifications: `npl/pumps/`
