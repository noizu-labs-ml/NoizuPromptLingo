---
id: US-035
title: "Delete or decommission an MCP server deployment"
slug: "delete-deployment"
personas: [P-002, P-005]
epic: "JustMCP Deployment"
priority: "must-have"
complexity: "S"
tags: [justmcp, deployment, lifecycle]
---

# US-035: Delete or Decommission an MCP Server Deployment

## User Story

**As a** Platform Engineer (P-002),
**I want to** delete or decommission an MCP server deployment,
**So that** I can remove unused or obsolete servers and stop incurring resource costs.

## Acceptance Criteria

- [ ] Given the user selects a deployed MCP server, when they click "Delete Deployment," then the system displays a confirmation dialog requiring the deployment name to be typed as confirmation.
- [ ] Given the user confirms deletion, when the system processes the request, then it gracefully drains active connections over a configurable grace period (default: 30 seconds) before terminating.
- [ ] Given the deletion completes, when the Kubernetes resources are removed, then the deployment no longer appears in the dashboard (US-029) and the endpoint URL returns a 410 Gone status.
- [ ] Given the user selects "Decommission" instead of delete, when the operation completes, then the deployment stops accepting new connections but maintains the endpoint URL as a tombstone page showing a custom message.
- [ ] Given a deployment has active invocations, when the user attempts deletion, then the system warns about active connections and offers the decommission option as a safer alternative.
- [ ] Given a deployment is deleted, when the deletion is recorded in the Audit Store, then the audit log retains the deployment metadata, policy, and invocation history for compliance purposes.

## Notes

Deletion is destructive and requires explicit confirmation. Decommission is a softer alternative that preserves the endpoint for graceful migration. Audit records are retained even after deletion. Related: US-029 (dashboard), US-038 (activity log).
