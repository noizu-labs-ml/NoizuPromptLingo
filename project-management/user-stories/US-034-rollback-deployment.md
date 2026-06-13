---
id: US-034
title: "Roll back a deployment to a previous version"
slug: "rollback-deployment"
personas: [P-002, P-005]
epic: "JustMCP Deployment"
priority: "should-have"
complexity: "M"
tags: [justmcp, deployment, rollback, versioning]
---

# US-034: Roll Back a Deployment to a Previous Version

## User Story

**As a** Platform Engineer (P-002),
**I want to** roll back an MCP server deployment to a previous version,
**So that** I can quickly recover from a bad deployment without downtime or data loss.

## Acceptance Criteria

- [ ] Given the user selects a deployed MCP server, when they navigate to the "Version History" tab, then the system displays a chronological list of deployments with version label, timestamp, deployer, and status (current/previous/failed).
- [ ] Given the user selects a previous version, when they click "Roll back to this version," then the system displays a confirmation dialog showing the current version and target version with a summary of differences.
- [ ] Given the user confirms the rollback, when the system executes it, then it redeploys the target version using a Kubernetes rolling update strategy with zero-downtime.
- [ ] Given the rollback completes, when the new pods pass health checks, then the system updates the deployment status to "healthy" and records the rollback event in the activity log (US-038).
- [ ] Given the rollback fails, when health checks do not pass for the target version, then the system automatically reverts to the previous (pre-rollback) version and notifies the user of the failure.
- [ ] Given a rollback has occurred, when the user views the version history, then the rollback is clearly marked with a "Rollback" badge and the reason chain is preserved.

## Notes

Rollback relies on Kubernetes deployment revision history. The number of retained revisions should be configurable (default: 10). Related: US-028 (deploy), US-038 (activity log).
