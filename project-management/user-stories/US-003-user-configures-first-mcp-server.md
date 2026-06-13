---
id: US-003
title: "User configures first MCP server during onboarding"
slug: "user-configures-first-mcp-server"
personas: [P-001, P-007]
epic: "Auth & Onboarding"
priority: "should-have"
complexity: "M"
tags: [onboarding, mcp-server, justmcp, deployment]
---

# US-003: User Configures First MCP Server During Onboarding

## User Story

**As a** MCP Tool Developer (P-001) or Solo AI Hobbyist (P-007),
**I want to** configure and deploy my first MCP server as part of the onboarding flow,
**So that** I can immediately see the platform in action and validate that my setup works end-to-end.

## Acceptance Criteria

- [ ] Given the onboarding wizard after account verification, when the user reaches the "Deploy your first MCP server" step, then the system presents options: deploy from a template (MCP Jumpstart), upload a tool definition (JustMCP.it), or skip.
- [ ] Given the user selects a template, when they choose a language and use case (e.g., TypeScript CRUD API wrapper), then the system generates the project scaffold and deploys it to a live endpoint at `https://{name}.justmcp.it`.
- [ ] Given the user uploads a tool definition (JSON Schema or MCP native format), when the definition is valid, then the system creates the MCP server configuration, applies a default permissive policy, and deploys it.
- [ ] Given a deployed onboarding MCP server, when the user clicks "Test it," then the system invokes a sample tool call through the Auth Gateway and displays the result, confirming end-to-end functionality.
- [ ] Given the user selects "Skip for now," when they proceed past this step, then the system saves progress and the user can access the server configuration wizard later from the dashboard.

## Notes

This is the "aha moment" of onboarding. The goal is to get the user from sign-up to a working MCP endpoint in under five minutes. Default policy applied here is permissive (allow all for the owner); the user will tighten policies later via SafeMCP. Related to US-001, US-012, and the MCP Jumpstart surface.
