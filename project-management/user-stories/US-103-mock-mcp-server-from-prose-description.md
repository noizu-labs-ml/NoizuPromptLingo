---
id: US-103
title: "Build a Mock MCP Server from a Prose Description"
slug: "mock-mcp-server-from-prose-description"
personas: [P-002, P-001]
epic: "Integration & External APIs"
priority: "could-have"
complexity: "L"
tags: [mock-mcp, llm-generation, testing, integration]
---

# US-103: Build a Mock MCP Server from a Prose Description

## User Story

**As** Jordan Vance, the Harness Operator (P-001),
**I want to** describe a fake MCP server in plain prose and have the platform generate and serve a working mock MCP server from that description,
**So that** Sable (P-002) can be tested against realistic tool-call patterns without a real third-party integration set up first.

## Acceptance Criteria

- [ ] Given Jordan submits a prose description of a desired mock MCP server, when the platform processes it, then it generates a tool catalog with names, parameter schemas, and example responses consistent with the description and shows it to Jordan for review before serving it live.
- [ ] Given a generated mock server is approved, when Jordan connects the Autonomous Coding Agent (P-002) to it, then the agent can discover and call its tools exactly as it would a real MCP server, using the same protocol surface.
- [ ] Given a mock server is live, when its tools are listed anywhere in the platform such as catalogs or search, then it is clearly labeled as a mock/test server and never merged into or confused with the production tool catalog.
- [ ] Given Jordan edits the prose description after initial generation, when he regenerates it, then the mock server's tool catalog updates without requiring the agent to reconnect using a different endpoint or identifier.

## Notes

Sized L — spans LLM-driven schema generation, a live-serving MCP endpoint, and catalog isolation from production tools; likely needs decomposition once groomed. The "never confused with production catalog" criterion is a hard boundary called out explicitly in the epic context.
