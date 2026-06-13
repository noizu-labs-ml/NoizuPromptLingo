# Self-Audit Prompt: {{SERVER_NAME}} {{VERSION}}

Fill in the bracketed sections below to create a self-audit prompt for your Virtual MCP.

## Interface Contract

**Version:** {{VERSION}}
**Effective Date:** {{DATE}}

Published tools:

{{FOR EACH TOOL}}
### {{TOOL_NUMBER}}. {{TOOL_NAME}}

- **Parameters:**
  {{LIST PARAMETERS WITH TYPES AND REQUIRED/OPTIONAL}}
- **Expected Response Schema:**
  ```json
  {{RESPONSE SCHEMA}}
  ```
- **Backing Tools:** {{LIST BACKING TOOL CALLS}}

{{END FOR EACH}}

## Test Scenarios

{{FOR EACH TOOL, AT LEAST 2 SCENARIOS}}

### {{TOOL_NAME}} / {{SCENARIO_NAME}}

- **Input:**
  ```json
  {{INPUT ARGUMENTS}}
  ```
- **Expected Output (key fields):**
  ```json
  {{EXPECTED OUTPUT OR PATTERN TO MATCH}}
  ```
- **Tolerance:** {{EXACT | CONTAINS_FIELDS | PATTERN_MATCH}}
- **Verify:** {{WHAT BACKING CALLS SHOULD HAVE BEEN MADE}}

{{END FOR EACH}}

## Consistency Checks

Cross-tool consistency rules that must hold:

1. {{RULE 1: e.g., "After deploy_service succeeds, check_health should show the service"}}
2. {{RULE 2: e.g., "view_logs for a running service should return non-empty output"}}
3. {{RULE 3}}

## Regression Flags

Known sensitive areas that have broken in the past or are likely to drift:

1. {{FLAG 1: e.g., "Status value normalization between backing tools"}}
2. {{FLAG 2: e.g., "Parameter name mapping between published and backing tools"}}
3. {{FLAG 3}}

## Audit Result Format

For each tool, report:

```markdown
### {{TOOL_NAME}}

| Check | Result | Details |
|-------|--------|---------|
| Contract (callable, schema valid) | PASS / FAIL | {{details}} |
| Scenario: {{scenario_1}} | PASS / FAIL | {{details}} |
| Scenario: {{scenario_2}} | PASS / FAIL | {{details}} |
| Drift (backing tool schema) | STABLE / DRIFT | {{details}} |
| **Overall** | **PASS / WARNING / FAIL** | |
```

## Summary Format

```markdown
## Audit Summary

- **Server:** {{SERVER_NAME}}
- **Version:** {{VERSION}}
- **Date:** {{AUDIT_DATE}}
- **Total Tools:** {{COUNT}}
- **Passed:** {{PASS_COUNT}}
- **Warnings:** {{WARN_COUNT}}
- **Failed:** {{FAIL_COUNT}}

### Drift Warnings
{{LIST ANY DETECTED DRIFT}}

### Recommendations
{{LIST RECOMMENDED ACTIONS}}
```
