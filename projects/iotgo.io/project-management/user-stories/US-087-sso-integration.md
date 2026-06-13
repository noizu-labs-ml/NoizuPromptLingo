---
id: US-087
title: "SSO Integration"
slug: "sso-integration"
personas: [P-005, P-001]
epic: "Security & Compliance"
priority: "should-have"
complexity: "M"
tags: [sso, saml, oidc, authentication, security]
---

# US-087: SSO Integration

## User Story

**As an** IT Security Director (P-005),
**I want to** configure single sign-on (SSO) via SAML 2.0 or OIDC so that users log in through our corporate identity provider,
**So that** IoTGo authentication is governed by our existing access policies, MFA requirements, and offboarding processes.

## Acceptance Criteria

- [ ] Given I am an org admin, when I navigate to Security Settings, then I can configure an SSO provider by entering IdP metadata URL (SAML) or discovery URL (OIDC) and downloading the IoTGo service provider metadata
- [ ] Given SSO is configured, when a user visits the IoTGo login page, then they are redirected to the corporate IdP and returned to IoTGo upon successful authentication
- [ ] Given SSO is enforced, when a user attempts to log in with username/password, then the attempt is blocked and they are redirected to the SSO flow
- [ ] Given a user is deprovisioned in the IdP, when they attempt to use an existing IoTGo session, then the session is invalidated within the configured session TTL (default 1 hour)
- [ ] Given SSO group claims are provided, when a user authenticates, then their IoTGo role is automatically mapped from the IdP group claim per the configured group-to-role mapping

## Notes

JIT (just-in-time) user provisioning should auto-create IoTGo accounts on first SSO login. Relates to US-085 (RBAC) and US-088 (session management). SCIM provisioning is deferred to a future story.
