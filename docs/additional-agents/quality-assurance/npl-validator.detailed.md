# npl-validator - Detailed Reference

NPL syntax and semantic validation specialist that ensures correctness of prompts, agent definitions, and workflows through comprehensive validation and actionable error reporting.

## Overview

The npl-validator agent provides three validation layers:

1. **Lexical Analysis** - Character-level validation of NPL tokens
2. **Syntax Parsing** - Structure and nesting verification
3. **Semantic Analysis** - Reference resolution and logical consistency

## Validation Layers

### Lexical Analysis

Validates raw tokens before parsing:

| Check | Description |
|:------|:------------|
| Unicode Symbols | Verifies NPL markers (`⌜`, `⌝`, `⌞`, `⌟`, etc.) are valid UTF-8 |
| Encoding | Detects mixed encodings, BOM issues, invisible characters |
| Structure Markers | Validates fence delimiters, code blocks, YAML frontmatter |
| Whitespace | Identifies problematic whitespace (tabs in YAML, trailing spaces) |

```bash
@npl-validator validate prompt.md --mode=lexical
```

### Syntax Parsing

Validates NPL structure and grammar:

| Check | Description |
|:------|:------------|
| Declaration Matching | Ensures `⌜name⌝` has corresponding `⌞name⌟` |
| Nesting Depth | Validates nested declarations do not exceed limits |
| Directive Format | Verifies `⟪prefix: content⟫` structure |
| Fence Pairing | Matches opening/closing code fences |
| Placeholder Syntax | Validates `<term>`, `{term}`, `<<qualifier>:term>` |

```bash
@npl-validator validate prompt.md --mode=syntax
```

### Semantic Analysis

Validates logical correctness and references:

| Check | Description |
|:------|:------------|
| Reference Resolution | Verifies agent, template, and file references exist |
| Flag Scoping | Validates runtime flag declarations and precedence |
| Template Bindings | Checks handlebar variable definitions and usage |
| Agent Invocations | Verifies `@agent-name` references valid agents |
| Circular Dependencies | Detects circular template/agent references |

```bash
@npl-validator validate prompt.md --mode=semantic
```

## Validation Modes

### Standard Mode (Default)

Runs all three validation layers sequentially:

```bash
@npl-validator validate prompt.md
```

Output:
```
[PASS] Lexical analysis: 0 issues
[WARN] Syntax parsing: 2 warnings
  - Line 45: Unclosed fence block (opened at line 42)
  - Line 78: Directive missing closing delimiter
[FAIL] Semantic analysis: 1 error
  - Line 23: Reference to undefined agent '@npl-missing'
```

### Strict Mode

Treats warnings as errors, enforces all conventions:

```bash
@npl-validator validate prompt.md --strict
```

Strict mode enforces:
- No deprecated syntax
- Required sections present (Purpose, Usage, etc.)
- Style guide compliance
- Documentation completeness

### Fix Mode

Automatically corrects fixable issues:

```bash
@npl-validator validate prompt.md --fix
```

Auto-fixable issues:
- Whitespace normalization
- Fence delimiter alignment
- Declaration closing tags
- Unicode normalization

Non-fixable issues require manual intervention:
- Missing references
- Semantic errors
- Circular dependencies

## Custom Validation Rules

### Rule File Format

Define project-specific rules in YAML:

```yaml
# .claude/validation-rules.yaml
version: "1.0"
rules:
  required-sections:
    - Purpose
    - Usage
    - See Also

  forbidden-patterns:
    - pattern: "TODO|FIXME"
      severity: warning
      message: "Unresolved TODO found"

  naming-conventions:
    agents: "^npl-[a-z-]+$"
    templates: "^[a-z-]+-template$"

  max-nesting-depth: 3
  max-line-length: 120
  require-version: true
```

### Applying Custom Rules

```bash
@npl-validator validate src/ --rules=.claude/validation-rules.yaml
```

### Built-in Rule Sets

| Rule Set | Description |
|:---------|:------------|
| `npl-core` | Core NPL syntax rules (default) |
| `npl-strict` | Strict compliance with all conventions |
| `npl-agent` | Agent definition requirements |
| `npl-template` | Template structure validation |
| `npl-ci` | CI/CD-focused quick validation |

```bash
@npl-validator validate . --ruleset=npl-strict
```

## Output Formats

### Console (Default)

Human-readable terminal output with colors and line context.

### JSON

Machine-parseable validation results:

```bash
@npl-validator validate src/ --format=json
```

```json
{
  "summary": {
    "files_scanned": 15,
    "errors": 2,
    "warnings": 5,
    "passed": true
  },
  "issues": [
    {
      "file": "src/prompts/agent.md",
      "line": 45,
      "column": 12,
      "severity": "error",
      "rule": "syntax/unclosed-fence",
      "message": "Unclosed code fence",
      "suggestion": "Add closing ``` at line 50"
    }
  ]
}
```

### JUnit XML

CI/CD integration format:

```bash
@npl-validator validate . --format=junit-xml --output=validation-results.xml
```

### SARIF

GitHub Code Scanning compatible:

```bash
@npl-validator validate . --format=sarif --output=results.sarif
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/npl-validate.yml
name: NPL Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate NPL
        run: |
          @npl-validator validate . \
            --format=sarif \
            --output=results.sarif \
            --strict
      - name: Upload Results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif
```

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
@npl-validator validate --changed-only --fix
if [ $? -ne 0 ]; then
  echo "NPL validation failed. Please fix errors before committing."
  exit 1
fi
```

### Baseline Comparison

Compare against a baseline branch to catch regressions:

```bash
@npl-validator validate . --baseline=main --format=json
```

Reports only new issues introduced since baseline.

## Edge Case Testing

The validator includes specialized edge case detection:

### Boundary Conditions

- Empty files
- Files with only whitespace
- Maximum nesting depth exceeded
- Extremely long lines
- Large file handling

### Circular Reference Detection

```bash
@npl-validator validate . --check=circular-refs
```

Detects:
- Agent A references Agent B which references Agent A
- Template cycles
- Infinite include chains

### Performance Validation

```bash
@npl-validator validate . --check=performance
```

Flags:
- Files exceeding size thresholds
- Complex nesting that may impact parsing
- Large template expansion estimates

## Error Reporting

### Error Format

Each error includes:

```
[SEVERITY] file:line:column - rule-id
  Message describing the issue

  Context:
    42 | ⌜agent-name|type|NPL@1.0⌝
    43 | # Agent Name
    44 |
  > 45 | ⌞wrong-name⌟
       |  ^^^^^^^^^^

  Suggestion: Change 'wrong-name' to 'agent-name' to match declaration
```

### Severity Levels

| Level | Description | Exit Code |
|:------|:------------|:----------|
| `error` | Must fix before use | 1 |
| `warning` | Should fix, may cause issues | 0 |
| `info` | Suggestion for improvement | 0 |
| `hint` | Style preference | 0 |

### Suppressing Warnings

Inline suppression:

```markdown
<!-- npl-validator-disable unclosed-fence -->
```code
Intentionally unclosed for documentation purposes
<!-- npl-validator-enable unclosed-fence -->
```

File-level suppression:

```yaml
# .npl-validator-ignore
ignore:
  - path: "examples/broken-syntax.md"
    rules: ["*"]
  - path: "drafts/**"
    rules: ["required-sections"]
```

## Integration Examples

### With npl-grader

Validate syntax before grading content quality:

```bash
@npl-validator validate src/prompts/ --mode=syntax && \
@npl-grader evaluate src/prompts/ --rubric=quality.md
```

### With npl-tester

Generate tests for validation rules:

```bash
@npl-tester generate --focus=edge-cases --output=test-prompts/
@npl-validator validate test-prompts/ --strict
```

### With npl-templater

Validate generated templates:

```bash
@npl-templater generate validation-rules --type=project-specific && \
@npl-validator validate . --rules=generated-rules.yaml
```

### With npl-thinker

Analyze complex validation issues:

```bash
@npl-validator validate src/ --format=json --output=report.json
@npl-thinker analyze report.json --focus=semantic-issues
```

## Configuration Reference

### Environment Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `NPL_VALIDATOR_RULES` | Path to custom rules file | `.claude/validation-rules.yaml` |
| `NPL_VALIDATOR_STRICT` | Enable strict mode | `false` |
| `NPL_VALIDATOR_FIX` | Enable auto-fix | `false` |
| `NPL_VALIDATOR_FORMAT` | Output format | `console` |

### CLI Options

| Option | Description |
|:-------|:------------|
| `--version=<ver>` | NPL version to validate against |
| `--mode=<mode>` | Validation mode: `lexical`, `syntax`, `semantic`, `all` |
| `--strict` | Treat warnings as errors |
| `--fix` | Auto-fix correctable issues |
| `--format=<fmt>` | Output: `console`, `json`, `junit-xml`, `sarif` |
| `--output=<file>` | Write results to file |
| `--rules=<file>` | Custom rules file |
| `--ruleset=<name>` | Built-in rule set |
| `--baseline=<ref>` | Git ref for baseline comparison |
| `--changed-only` | Validate only changed files |
| `--check=<type>` | Specific check: `circular-refs`, `performance` |

## Troubleshooting

### Common Issues

**Issue**: Validator reports encoding errors
**Solution**: Ensure files are UTF-8 without BOM

**Issue**: False positives on intentional syntax
**Solution**: Use inline suppression comments

**Issue**: Slow validation on large projects
**Solution**: Use `--changed-only` or scope to specific directories

### Debug Mode

```bash
@npl-validator validate . --debug
```

Outputs detailed parsing steps for diagnosis.

## See Also

- [npl-tester](./npl-tester.md) - Test generation and execution
- [npl-integrator](./npl-integrator.md) - Multi-agent workflow testing
- [npl-benchmarker](./npl-benchmarker.md) - Performance measurement
- [Quality Assurance Overview](./README.md) - Category documentation
