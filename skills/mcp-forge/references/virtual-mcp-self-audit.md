# Virtual MCP Self-Audit System

The self-audit system enables a Virtual MCP agent to verify its own interface consistency by running structured verification prompts against its version contract.

## What Self-Audit Is

Self-audit is the process by which a Virtual MCP agent:

1. Reads its current version contract
2. Generates or loads verification prompts for each published tool
3. Executes those prompts against the backing tools
4. Compares actual behavior against expected behavior defined in the contract
5. Reports pass/fail per tool with drift warnings

The agent writes prompts that verify **its own** interface consistency. This is not external testing -- it is the agent reflecting on whether it can still fulfill its published contract.

## Audit Prompt Structure

Each audit run follows four phases:

### Phase 1: Contract Check

Verify that each published tool in the version contract is callable.

```markdown
## Contract Check

For each tool in the version contract:

1. Read the tool's schema from the contract
2. Construct a minimal valid request using the schema
3. Execute the request via ToolCall
4. Verify the response matches the expected schema
5. Record: PASS if response matches, FAIL if not

Tools to check:
{{for tool in contract.tools}}
- [ ] {{tool.name}}: callable with valid response schema
{{endfor}}
```

### Phase 2: Regression Check

Run test scenarios and compare actual output against expected output.

```markdown
## Regression Check

For each test scenario in the audit prompt:

1. Read the input and expected output
2. Execute the tool with the given input
3. Compare actual output to expected output
4. Record: PASS if outputs match (within tolerance), FAIL if divergent

Scenarios:
{{for scenario in audit.scenarios}}
- [ ] {{scenario.name}}:
  - Tool: {{scenario.tool}}
  - Input: {{scenario.input}}
  - Expected: {{scenario.expected_output}}
  - Tolerance: {{scenario.tolerance}}
{{endfor}}
```

### Phase 3: Drift Detection

Check if backing tools have changed in ways that affect published behavior.

```markdown
## Drift Detection

For each backing tool dependency:

1. Call the backing tool's schema endpoint (if available)
2. Compare current schema against the schema recorded in the version contract
3. Check for:
   - New required parameters (BREAKING)
   - Removed parameters (BREAKING)
   - Changed parameter types (BREAKING)
   - New optional parameters (COMPATIBLE)
   - Changed descriptions (INFO)
4. Record: DRIFT if breaking changes detected, COMPATIBLE if non-breaking, STABLE if unchanged

Dependencies:
{{for dep in contract.backing_tools}}
- [ ] {{dep.server}}.{{dep.tool}}: schema comparison
{{endfor}}
```

### Phase 4: Report Generation

Produce a structured report.

```markdown
## Audit Report

### Summary
- Total tools: {{count}}
- Passed: {{pass_count}}
- Failed: {{fail_count}}
- Drift warnings: {{drift_count}}

### Per-Tool Results

| Tool | Contract | Regression | Drift | Status |
|------|----------|------------|-------|--------|
{{for tool in results}}
| {{tool.name}} | {{tool.contract_check}} | {{tool.regression_check}} | {{tool.drift_status}} | {{tool.overall}} |
{{endfor}}

### Drift Warnings
{{for warning in drift_warnings}}
- **{{warning.tool}}**: {{warning.description}}
  - Severity: {{warning.severity}}
  - Action: {{warning.recommended_action}}
{{endfor}}

### Recommendations
{{for rec in recommendations}}
- {{rec}}
{{endfor}}
```

## Audit Scheduling

### Claude Code Cron Hooks

Schedule automated audits using Claude Code's scheduling capabilities:

```yaml
# In .claude/settings.json or via /schedule command
routines:
  - name: virtual-mcp-audit
    schedule: "0 9 * * 1"  # Every Monday at 9am
    prompt: |
      Run self-audit for the Virtual DevOps MCP.
      Load the version contract from version-contract-v1.md.
      Load the audit prompt from self-audit-prompt.md.
      Execute all four phases.
      Report results.
```

### Manual Triggers

```
/trl-mcp-forge self-audit-run --contract version-contract-v1.md
```

Or invoke the agent-playbook workflow:

```yaml
workflow: self-audit-run
inputs:
  contract: version-contract-v1.md
  audit_prompt: self-audit-prompt.md
  mode: full
```

## Audit Prompt Templates

Use `assets/self-audit-prompt-template.md` as the starting point. Fill in:

1. **Interface Contract section** -- list every published tool with its schema
2. **Test Scenarios section** -- at least 2 scenarios per tool (happy path + error case)
3. **Consistency Checks** -- cross-tool rules (e.g., "deploy then check_health should show the deployed service")
4. **Regression Flags** -- known sensitive areas that have broken before

## Automated Audit vs Manual Audit

| Aspect | Automated | Manual |
|---|---|---|
| **Trigger** | Scheduled (cron) or CI hook | User-initiated |
| **Scope** | Full contract (all tools) | Can target specific tools |
| **Depth** | Predefined scenarios only | Can explore edge cases |
| **Action on failure** | Flag for user, log warning | User investigates immediately |
| **Cost** | LLM inference per audit run | Same, but on-demand |

### When to Use Each

- **Automated:** Weekly or after backing tool updates. Catches drift early.
- **Manual:** After making changes to compositions, before version bumps, debugging failures.

## What to Do When an Audit Fails

**Critical rule: Do NOT auto-fix.** The agent flags the failure for user review.

### Failure Response Protocol

1. **Log the failure** with full context (tool, input, expected, actual, diff)
2. **Classify severity:**
   - CRITICAL: Published tool is completely broken (returns errors or wrong schema)
   - WARNING: Published tool works but output has unexpected differences
   - INFO: Backing tool schema changed but published behavior is unaffected
3. **Recommend action:**
   - CRITICAL: "Tool X is broken. Backing tool Y returned error Z. User should investigate."
   - WARNING: "Tool X behavior drifted. Expected field A to be B, got C. User should review."
   - INFO: "Backing tool Y added optional parameter Z. No action required."
4. **Do NOT:**
   - Auto-update the version contract
   - Auto-modify compositions
   - Silently skip the broken tool

## Example Audit Run

### Input

Version contract: v1.0 with 3 published tools (deploy_service, check_health, view_logs)

### Execution

```
=== Virtual DevOps MCP Self-Audit ===
Contract: version-contract-v1.md (v1.0, 2026-05-01)
Audit prompt: self-audit-prompt.md
Mode: full

--- Phase 1: Contract Check ---
[PASS] deploy_service: callable, response matches schema
[PASS] check_health: callable, response matches schema
[PASS] view_logs: callable, response matches schema

--- Phase 2: Regression Check ---
[PASS] deploy_service/happy_path: deployed nginx to default namespace
[PASS] deploy_service/invalid_namespace: returned expected error
[PASS] check_health/healthy_service: returned status=healthy
[WARN] check_health/unhealthy_service: expected status=unhealthy,
       got status=degraded (backing tool kubectl.describe_pod now
       returns "degraded" instead of "unhealthy" for CrashLoopBackOff)
[PASS] view_logs/basic: returned log lines
[PASS] view_logs/tail: returned last N lines

--- Phase 3: Drift Detection ---
[STABLE] kubectl-mcp: no schema changes
[DRIFT]  docker-mcp: docker.build added optional parameter "platform"
         (non-breaking, new optional parameter)
[STABLE] gh-actions-mcp: no schema changes

--- Phase 4: Report ---

Summary: 3 tools, 3 contract checks passed, 5/6 regression checks passed,
         1 drift warning

| Tool           | Contract | Regression | Drift    | Status  |
|----------------|----------|------------|----------|---------|
| deploy_service | PASS     | PASS       | STABLE   | PASS    |
| check_health   | PASS     | WARN       | STABLE   | WARNING |
| view_logs      | PASS     | PASS       | STABLE   | PASS    |

Drift Warnings:
- docker-mcp.docker.build: Added optional parameter "platform"
  - Severity: INFO
  - Action: No action required. Consider exposing platform selection
    in deploy_service in a future version.

Regression Warnings:
- check_health/unhealthy_service: Expected "unhealthy", got "degraded"
  - Severity: WARNING
  - Action: kubectl-mcp now returns "degraded" for CrashLoopBackOff pods.
    Update composition to normalize status values, or update test expectation.

Recommendations:
- Update check_health composition to normalize backing status values
- Consider adding "platform" parameter to deploy_service in v1.1
```
