---
id: US-037
title: "System runs automated security scan on uploaded tool definitions"
slug: "automated-security-scan"
personas: [P-003, P-006]
epic: "JustMCP Deployment"
priority: "must-have"
complexity: "L"
tags: [justmcp, security, scanning, upload]
---

# US-037: System Runs Automated Security Scan on Uploaded Tool Definitions

## User Story

**As a** Security Engineer (P-003),
**I want to** the system to automatically run a security scan on uploaded tool definitions,
**So that** potentially dangerous configurations are caught before deployment and I can enforce security standards without manual review.

## Acceptance Criteria

- [ ] Given a tool definition is uploaded (US-026), when the system parses it successfully, then it automatically triggers a security scan that checks for known risk patterns.
- [ ] Given the security scan runs, when it detects a tool with network access to internal IP ranges (RFC 1918), then it flags this as a "network exfiltration risk" with severity "high."
- [ ] Given the security scan runs, when it detects a tool accepting arbitrary filesystem paths without constraints, then it flags this as a "path traversal risk" with severity "critical."
- [ ] Given the security scan runs, when it detects a tool with unbounded resource consumption (no timeout, no memory limit), then it flags this as a "resource exhaustion risk" with severity "medium."
- [ ] Given the scan completes, when there are findings, then the system displays a scan report card with severity breakdown, affected tools, and remediation suggestions before allowing deployment to proceed.
- [ ] Given a "critical" severity finding exists, when the user attempts to proceed with deployment, then the system blocks deployment and requires explicit acknowledgment or policy override from a Security Engineer (P-003) role.
- [ ] Given the scan completes with no findings, when the user views the deployment summary, then a "Security: Passed" badge is displayed on the deployment configuration.

## Notes

The security scan is a gate in the deployment pipeline, not optional. Scanning rules should be extensible to support organization-specific policies. Related: US-026 (upload), US-030 (access policy), SafeMCP security features.
