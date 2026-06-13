---
id: US-042
title: "Generated project includes transport configuration"
slug: "transport-configuration"
personas: [P-001, P-004]
epic: "MCP Jumpstart"
priority: "must-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, transport]
---

# US-042: Generated Project Includes Transport Configuration

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** the generated project to include pre-configured transport settings (stdio, SSE, or WebSocket),
**So that** my MCP server can communicate with MCP clients using the appropriate transport protocol without manual configuration.

## Acceptance Criteria

- [ ] Given a project is generated (US-041), when the user selects transport options during customization (US-048), then the system includes configuration for each selected transport in the generated project.
- [ ] Given stdio transport is selected, when the generated project is examined, then it includes stdio transport setup with proper stdin/stdout handling, message framing, and a launcher script for local development.
- [ ] Given SSE (Server-Sent Events) transport is selected, when the generated project is examined, then it includes an HTTP server with SSE endpoint, CORS configuration, and connection lifecycle management.
- [ ] Given WebSocket transport is selected, when the generated project is examined, then it includes a WebSocket server with connection handling, message serialization, and heartbeat/ping-pong configuration.
- [ ] Given multiple transports are selected, when the generated project starts, then it listens on all configured transports simultaneously and routes messages to the same handler layer.
- [ ] Given the generated project's transport configuration, when the user changes the transport mode, then a documented environment variable or config file allows switching transports without code changes.

## Notes

Transport selection is critical for deployment targets: stdio for local/CLI, SSE for web clients, WebSocket for persistent connections. The default recommendation should be stdio for development and SSE for production. Related: US-041 (generation), US-044 (Docker/K8s manifests).
