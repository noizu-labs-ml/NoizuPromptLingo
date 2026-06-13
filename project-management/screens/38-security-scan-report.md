# Security Scan Report

| Field | Value |
|-------|-------|
| **ID** | `security-scan-report` |
| **Type** | Modal |
| **Category** | JustMCP Deployment |
| **User Stories** | US-037 |

## Description

Security scan results after tool definition upload: severity breakdown, affected tools, remediation suggestions. Blocks deployment on critical findings.

## Key Components

- **SeverityBreakdownCard**
- **FindingsList**
- **RemediationSuggestions**
- **DeployBlockBanner**

## Interactions

- Review findings
- Acknowledge risks
- Override with Security Engineer role
- Fix and re-upload

## Navigation

- Deploy Wizard -> Security Scan Report
