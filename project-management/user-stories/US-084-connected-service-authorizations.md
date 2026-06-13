---
id: US-084
title: "User manages connected downstream service authorizations"
slug: "connected-service-authorizations"
personas: [P-004, P-002]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "L"
tags: [settings, oauth, authorizations, downstream-services, credentials]
---

# US-084: User Manages Connected Downstream Service Authorizations

## User Story

**As an** AI/ML Engineer (P-004),
**I want to** view, add, and revoke authorizations for downstream services (Gmail, Slack, databases) that MCP tools can access on my behalf,
**So that** I maintain explicit control over which external services the platform can interact with using my credentials.

## Acceptance Criteria

- [ ] Given a user navigates to Settings > Connected Services, when the page loads, then all currently authorized downstream services are listed with the service name, authorization scope, date granted, and last used timestamp
- [ ] Given a user clicks "Connect Service" and selects a supported service (e.g., Gmail), when the OAuth flow completes, then the authorization appears in the connected services list with the granted scopes visible
- [ ] Given a user clicks "Revoke" on a connected service, when the revocation is confirmed, then the platform immediately invalidates the stored token and any subsequent tool invocation attempting to use that service returns a clear "authorization revoked" error
- [ ] Given a user has multiple connected services, when they filter by service type or sort by last used, then the list updates to reflect the filter or sort selection

## Notes

This is a critical trust feature -- users must be able to see and revoke exactly what the platform can access on their behalf. The platform stores only scoped, narrowed OAuth tokens (never raw credentials) per the dual-principal security model. Related to US-079 (sealed secret injection at runtime) and US-085 (default policy templates).
