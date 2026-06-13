---
id: US-027
title: "Configure auth method for deployed MCP server"
slug: "configure-auth-method"
personas: [P-001, P-002]
epic: "JustMCP Deployment"
priority: "must-have"
complexity: "M"
tags: [justmcp, auth, deployment-config]
---

# US-027: Configure Auth Method for Deployed MCP Server

## User Story

**As a** Platform Engineer (P-002),
**I want to** configure the authentication method for a deployed MCP server,
**So that** only authorized callers and users can invoke tools through the dual-principal auth gateway.

## Acceptance Criteria

- [ ] Given the user has staged a tool definition (US-026), when they reach the auth configuration step, then the system presents supported auth methods: API key, OAuth 2.1/OIDC, mTLS, and no-auth (public).
- [ ] Given the user selects "API key," when they confirm, then the system generates a unique API key and displays it once with a copy-to-clipboard action and a warning that it will not be shown again.
- [ ] Given the user selects "OAuth 2.1/OIDC," when they provide the issuer URL and client credentials, then the system validates the OIDC discovery endpoint and stores the configuration for token validation.
- [ ] Given the user selects "mTLS," when they upload a CA certificate, then the system configures the deployment to require client certificate verification against the provided CA.
- [ ] Given the user selects "no-auth (public)," when the tool definition contains write or destructive operations, then the system displays a warning about exposing unauthenticated write endpoints.
- [ ] Given an auth method is configured, when the user proceeds, then the configuration is saved to the deployment spec and the flow advances to access policy configuration (US-030).

## Notes

Auth configuration is mandatory before deployment. The dual-principal model requires that every deployment have at least a caller auth method defined. "No-auth" still requires user-level auth for non-read operations. Related: US-028 (deploy), US-030 (access policy).
