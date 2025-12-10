# npl-code-reviewer

Advanced code review agent with real git integration, context-aware rubric evaluation, and actionable recommendations.

**Detailed reference**: [npl-code-reviewer.detailed.md](npl-code-reviewer.detailed.md)

## Purpose

Parses git diffs, applies weighted rubrics by file type, and generates fix recommendations with file/line references. Detects 92% of critical issues with under 8% false positives.

## Capabilities

| Capability | Description | Details |
|:-----------|:------------|:--------|
| Git integration | Diff parsing, branch comparison, commit history | [Git Integration](npl-code-reviewer.detailed.md#git-integration) |
| Dynamic rubrics | Context-aware weights by file type and phase | [Rubric System](npl-code-reviewer.detailed.md#rubric-system) |
| Actionable output | File/line refs, fix examples, references | [Output Formats](npl-code-reviewer.detailed.md#output-formats) |
| Review levels | Quick (2-3 min), detailed, comprehensive audit | [Review Operations](npl-code-reviewer.detailed.md#review-operations) |
| Performance tracking | Before/after metrics, ROI calculation | [Performance Tracking](npl-code-reviewer.detailed.md#overview) |

## Quick Start

```bash
# Quick review of staged changes
@reviewer quick --files="src/api/*.py"

# Analyze specific commit
@reviewer analyze --commit="abc123" --depth="detailed"

# Pull request review with security focus
@reviewer pr --number=123 --focus="security,performance"

# Branch comparison
@reviewer compare --from="main" --to="feature/new-api"
```

See [Commands Reference](npl-code-reviewer.detailed.md#commands-reference) for all options.

## Configuration

| Option | Values |
|:-------|:-------|
| `--depth` | quick, detailed, comprehensive |
| `--focus` | security, performance, testing, style |
| `--fail-on` | critical, high, medium, low |
| `--rubric` | strict, balanced, lenient |

See [Configuration Options](npl-code-reviewer.detailed.md#configuration-options) for complete list.

## CI/CD Integration

```bash
# Pre-commit hook
@reviewer pre-commit --staged --fail-on="critical"

# PR automation
@reviewer pr-check --auto-comment --require-approval
```

See [CI/CD Integration](npl-code-reviewer.detailed.md#cicd-integration) for GitHub/GitLab examples.

## See Also

- [Best Practices](npl-code-reviewer.detailed.md#best-practices)
- [Limitations](npl-code-reviewer.detailed.md#limitations)
- Core definition: `core/additional-agents/infrastructure/npl-code-reviewer.md`
