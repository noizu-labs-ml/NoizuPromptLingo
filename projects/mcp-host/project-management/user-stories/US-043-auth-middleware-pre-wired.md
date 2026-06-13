---
id: US-043
title: "Generated project includes auth middleware pre-wired"
slug: "auth-middleware-pre-wired"
personas: [P-001, P-003]
epic: "MCP Jumpstart"
priority: "should-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, auth, security]
---

# US-043: Generated Project Includes Auth Middleware Pre-Wired

## User Story

**As a** Security Engineer (P-003),
**I want to** generated MCP projects to include pre-wired authentication middleware,
**So that** developers start with a secure-by-default foundation and do not have to manually implement auth integration with the MCP Host platform.

## Acceptance Criteria

- [ ] Given a project is generated (US-041), when the user examines the middleware layer, then it includes an authentication middleware module that validates incoming requests against the configured auth method (API key, OAuth, mTLS).
- [ ] Given the auth middleware is included, when the user configures an API key auth method, then the middleware extracts and validates the `Authorization: Bearer` header and rejects requests with invalid or missing keys.
- [ ] Given the auth middleware is included, when the user configures OAuth 2.1, then the middleware includes JWT validation with issuer check, audience verification, and token expiry enforcement.
- [ ] Given the auth middleware is included, when a request fails authentication, then the middleware returns a structured MCP error response with an appropriate error code and descriptive message.
- [ ] Given the auth middleware is pre-wired, when the user wants to add custom authorization logic (e.g., role-based access), then the middleware provides extension points (hooks/callbacks) documented with examples.
- [ ] Given the generated project README, when the user reads the auth section, then it explains the dual-principal model, how to configure auth methods, and how to test auth locally.

## Notes

The auth middleware should be framework-idiomatic for the target language (e.g., Express middleware for TypeScript, decorator-based for Python). It should be possible to disable auth for local development. Related: US-027 (auth configuration in JustMCP), US-041 (project generation).
