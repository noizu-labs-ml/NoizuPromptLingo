---
id: US-091
title: "API bound to localhost with no unauthenticated remote access"
slug: api-localhost-no-unauth-remote-access
personas: [P-005, P-008]
epic: "Integration & API"
priority: must-have
complexity: medium
tags: [api, security]
---

# US-091: API Bound To Localhost With No Unauthenticated Remote Access

## User Story

**As an** engineering lead auditing team AI usage
**I want to** the API to bind only to localhost by default and reject unauthenticated remote connections
**So that** the tool's local-only guarantee is actually enforced, not just assumed

## Acceptance Criteria

- **Given** the API server starts with default settings
  **When** Daniel inspects the listening address
  **Then** it is bound to `127.0.0.1` only, not `0.0.0.0`

- **Given** a request arrives from a non-localhost origin without credentials
  **When** it hits any API route
  **Then** the server rejects it (connection refused or 403) rather than serving data

- **Given** Yusuf wants cross-machine access for a legitimate reason
  **When** he checks the config
  **Then** binding beyond localhost requires an explicit opt-in setting, not a default

## Notes
Directly enforces the "everything runs local-only — no data leaves the machine" guarantee from the product context; both Daniel's audit role and Yusuf's tinkering depend on this boundary being verifiable rather than assumed.
