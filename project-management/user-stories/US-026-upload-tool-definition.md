---
id: US-026
title: "Upload tool definition for MCP deployment"
slug: "upload-tool-definition"
personas: [P-001, P-007]
epic: "JustMCP Deployment"
priority: "must-have"
complexity: "M"
tags: [justmcp, tool-upload, onboarding]
---

# US-026: Upload Tool Definition for MCP Deployment

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** upload a tool definition file (OpenAPI, JSON Schema, or MCP native format),
**So that** I can deploy my MCP server through the JustMCP.it one-click pipeline without manual configuration.

## Acceptance Criteria

- [ ] Given the user is on the JustMCP.it deploy page, when they click "Upload Tool Definition," then a file picker accepts `.json`, `.yaml`, and `.yml` files up to 5MB.
- [ ] Given a valid OpenAPI 3.x specification is uploaded, when the system parses it, then it extracts all tool names, parameter schemas, and endpoint definitions and displays them in a confirmation preview.
- [ ] Given a valid JSON Schema document is uploaded, when the system parses it, then it maps each schema to an MCP tool definition with inferred input/output types.
- [ ] Given a native MCP tool definition (conforming to the MCP specification) is uploaded, when the system parses it, then it validates against the MCP schema and extracts tool metadata, transports, and handler references.
- [ ] Given an invalid or malformed file is uploaded, when the system attempts to parse it, then it displays a clear error message identifying the validation failure and the line/field at fault.
- [ ] Given a successfully parsed tool definition, when the user confirms, then the system stages the definition for deployment configuration and advances to the auth setup step (US-027).

## Notes

This is the primary entry point for the JustMCP.it deployment flow. The system should auto-detect the definition format (OpenAPI vs JSON Schema vs MCP native) to minimize friction. Related: US-028 (deploy), US-037 (security scan runs on upload).
