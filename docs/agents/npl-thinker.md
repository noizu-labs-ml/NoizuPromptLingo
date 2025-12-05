# npl-thinker

Multi-cognitive reasoning agent that combines intent, chain-of-thought, reflection, mood, critique, and tangent pumps for structured problem-solving.

## Purpose

Provides transparent, multi-layered analysis for complex problems. Instead of immediate answers, the agent plans approaches, reasons through solutions, critiques alternatives, and reflects on outcomes.

## Capabilities

- **Intent planning**: Structures goals, approaches, and constraints before execution
- **Chain-of-thought reasoning**: Step-by-step logical progression with visible reasoning
- **Self-critique**: Evaluates strengths, weaknesses, and unexplored alternatives
- **Reflection**: Assesses response quality with confidence levels
- **Tangent exploration**: Surfaces relevant connections and insights
- **Adaptive complexity**: Scales cognitive depth to match task requirements

## Usage

```bash
# Simple query (minimal pumps)
@npl-thinker "What's the capital of France?"

# Complex analysis (full cascade)
@npl-thinker "Compare REST vs GraphQL vs gRPC for mobile apps with 10K concurrent users"

# Creative mode
@npl-thinker "Design an approach to teaching quantum mechanics to children"
```

### Response Modes

| Prefix | Mode | Pump Selection |
|--------|------|----------------|
| (default) | Adaptive | Scales to complexity |
| `🧠➤` | Deep | All pumps, maximum depth |
| `🎨➤` | Creative | Tangent + divergent COT |
| `🔬➤` | Analytical | Systematic COT + rigorous critique |

## Workflow Integration

```bash
# Analysis followed by template creation
@npl-thinker "Analyze requirements for Django project template"
@npl-templater "Create template from analyzed requirements"

# Thoughtful evaluation
@npl-thinker "Examine code architecture for assessment criteria"
@npl-grader "Grade architecture using identified criteria"

# Multi-round refinement
@npl-thinker "Analyze migration challenges"
@npl-thinker "Focus on data consistency issues identified above"
```

## See Also

- Core definition: `core/agents/npl-thinker.md`
- Pump specs: `core/npl/pumps/`
