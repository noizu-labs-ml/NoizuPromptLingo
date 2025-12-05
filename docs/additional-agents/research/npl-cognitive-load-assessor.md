# npl-cognitive-load-assessor

UX complexity analysis agent specializing in cognitive load measurement, learning curve assessment, adoption barrier identification, and user experience optimization for NPL systems.

## Purpose

Quantifies and analyzes cognitive burden in NPL systems using cognitive load theory and universal design principles. Measures mental effort requirements, identifies learning barriers, and provides evidence-based recommendations for reducing complexity while preserving NPL's research-validated advantages.

## Capabilities

- Measure cognitive load using NASA-TLX across mental, temporal, and effort dimensions
- Map learning curves with empirical skill acquisition timelines (4-20 hours)
- Identify adoption barriers with impact measurements (35% dropout at Stage 1)
- Assess accessibility compliance against WCAG 2.2 AAA standards
- Generate progressive disclosure scaffolding for complexity management
- Design personalized learning paths based on user background

## Usage

```bash
# Perform comprehensive cognitive load assessment
@npl-cognitive-load-assessor analyze --target=npl-interface

# Evaluate learning curve for user profile
@npl-cognitive-load-assessor learning-curve --user-profile="programmer,no-ai-experience"

# Identify adoption barriers
@npl-cognitive-load-assessor barriers --scope=onboarding --generate-solutions

# Validate accessibility compliance
@npl-cognitive-load-assessor accessibility-audit --standards="WCAG-2.2-AAA"
```

## Workflow Integration

```bash
# Combined UX analysis workflow
@npl-cognitive-load-assessor analyze && @npl-grader evaluate --rubric=cognitive-standards.md

# Optimization with cognitive validation
@npl-claude-optimizer optimize && @npl-cognitive-load-assessor quantify --context=optimization

# Learning path generation
@npl-cognitive-load-assessor learning-path --goal="custom-agent-development" --time-budget="10-hours"
```

## See Also

- Core definition: `core/additional-agents/research/npl-cognitive-load-assessor.md`
- Cognitive analysis pump: `npl/pumps/npl-cognitive.md`
- Accessibility guidelines: `npl/accessibility.md`
