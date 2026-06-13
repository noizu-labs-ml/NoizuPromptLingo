# Deploy Summary

| Field | Value |
|-------|-------|
| **ID** | `deploy-summary` |
| **Category** | Domain-Specific |
| **Used In** | 28-Environment Dashboard, 29-Deploy Changelog, 30-Deploy Approval Modal, 31-Rollback Confirmation |

## Description

Compact summary of a deployment showing target environment, included changes, test results, and approval status

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Environment + version + status badge |
| **Expanded** | Full summary with changelog and test results |

## Props / Configuration

- `environment` — string
- `version` — string
- `changes` — changelog summary
- `testResults` — pass|fail counts
- `approvalStatus` — status

## Interactions

- click for full changelog
- navigate to test results
- approve/reject from summary
