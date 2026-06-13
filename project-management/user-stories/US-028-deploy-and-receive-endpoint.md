---
id: US-028
title: "Deploy MCP server and receive live endpoint URL"
slug: "deploy-and-receive-endpoint"
personas: [P-001, P-002, P-007]
epic: "JustMCP Deployment"
priority: "must-have"
complexity: "L"
tags: [justmcp, deployment, core-flow]
---

# US-028: Deploy MCP Server and Receive Live Endpoint URL

## User Story

**As a** Solo AI Hobbyist (P-007),
**I want to** deploy my MCP server with one click and immediately receive a live endpoint URL,
**So that** I can connect my AI agents or applications to the server without manual infrastructure setup.

## Acceptance Criteria

- [ ] Given the user has completed tool definition upload (US-026), auth configuration (US-027), and access policy (US-030), when they click "Deploy," then the system provisions a sandboxed execution environment and deploys the MCP server.
- [ ] Given the deployment is in progress, when the system is provisioning resources, then a progress indicator shows the current stage (provisioning, configuring, starting health checks).
- [ ] Given the deployment succeeds, when the server passes its initial health check, then the system displays a live endpoint URL (e.g., `https://abc123.justmcp.it/mcp`) with a copy-to-clipboard button.
- [ ] Given the deployment fails, when the system encounters an error during provisioning or startup, then it displays a descriptive error message with remediation suggestions and offers a retry action.
- [ ] Given a successful deployment, when the user views the endpoint URL, then the system also provides a connection snippet for common MCP client libraries (JSON config for Claude Desktop, Python, TypeScript).
- [ ] Given a successful deployment, when the MCP server registers with the platform, then it appears in the user's deployment dashboard (US-029) with status "healthy."

## Notes

This is the core "one-click" experience. Deployment should complete in under 60 seconds for standard configurations. The execution sandbox (Firecracker/gVisor) is provisioned during this step. Related: US-026, US-027, US-029, US-033.
