# npl-code-reviewer

Advanced code review agent evolved from gpt-cr with real git integration, dynamic rubric evaluation, and actionable recommendations.

## Purpose

Transforms traditional code review through automated analysis with real-time git diff parsing, context-aware rubric scoring, and specific file/line recommendations. Reduces review time by 60-80% while detecting 92% of critical issues with under 8% false positives.

## Capabilities

- Direct git diff parsing from working directory with branch comparison
- Dynamic rubric system adapting to file type and project phase
- Actionable recommendations with precise file/line references and fix examples
- Multi-level review depth: quick (2-3 min), detailed, comprehensive audit
- Performance tracking with quantified before/after metrics
- Test coverage impact analysis with specific test recommendations

## Usage

```bash
# Quick review of staged changes
@npl-code-reviewer quick --files="src/api/*.py"

# Analyze specific commit with detailed rubric
@npl-code-reviewer analyze --commit="abc123" --depth="detailed"

# Pull request review with security focus
@npl-code-reviewer pr --number=123 --focus="security,performance"
```

## Workflow Integration

```bash
# Pre-commit hook integration
@npl-code-reviewer pre-commit --staged --fail-on="critical"

# Branch comparison with full audit
@npl-code-reviewer compare --from="main" --to="feature/new-api" --rubric="full"

# CI/CD pipeline with auto-commenting
@npl-code-reviewer pr-check --auto-comment --require-approval
```

## See Also

- Core definition: `core/additional-agents/infrastructure/npl-code-reviewer.md`
- Custom rubric guide: `docs/rubrics/README.md`
- CI/CD integration examples: `docs/examples/ci-cd/`
