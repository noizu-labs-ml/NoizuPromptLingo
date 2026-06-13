# FR-007: npl-check Health Utility

**Status**: Draft

## Description

Implement `npl-check` CLI utility for verifying NPL installation and configuration health.

## Interface

```bash
# Full health check
npl-check

# Check specific component
npl-check paths
npl-check agents
npl-check server

# Verbose output
npl-check --verbose

# JSON output
npl-check --format json
```

## Behavior

- **Given** component to check (or all if none specified)
- **When** npl-check is invoked
- **Then** all relevant checks are performed
- **And** results are reported with status indicators
- **And** actionable suggestions provided for failures
- **And** appropriate exit code returned

## Check Categories

| Category | Checks |
|----------|--------|
| `paths` | Verify all path resolution levels exist and are readable |
| `agents` | Validate agent definitions load correctly |
| `server` | Check MCP server health and tool registration |
| `syntax` | Verify syntax element patterns compile |
| `personas` | Check persona storage is accessible |
| `sessions` | Verify session directory structure |

## Output Format (text)

```
NPL Health Check
================

Paths:
  [OK] Project: ./.npl/
  [OK] User: ~/.npl/
  [WARN] System: /etc/npl/ (not found)

Agents:
  [OK] 45 agent definitions loaded
  [OK] All agents validate

Server:
  [OK] MCP server reachable at localhost:8000
  [OK] 23 tools registered

Overall: HEALTHY (1 warning)
```

## Output Format (json)

```json
{
  "status": "healthy",
  "warnings": 1,
  "errors": 0,
  "checks": {
    "paths": {
      "status": "warning",
      "details": {
        "project": {"status": "ok", "path": "./.npl/"},
        "user": {"status": "ok", "path": "~/.npl/"},
        "system": {"status": "warning", "path": "/etc/npl/", "message": "not found"}
      }
    }
  }
}
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | Warnings present |
| 2 | Errors present |

## Edge Cases

- **MCP server unreachable**: Report error with connection details
- **Missing directories**: Distinguish between optional and required
- **Corrupt agent definitions**: Report which agents fail validation
- **Version mismatches**: Warn if incompatible versions detected
- **Permission issues**: Suggest chmod commands

## Related User Stories

- US-001
- US-002
- US-025
- US-047

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
