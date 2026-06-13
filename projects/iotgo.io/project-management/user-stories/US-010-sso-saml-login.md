---
id: US-010
title: "SSO / SAML Login for Enterprise"
slug: "sso-saml-login"
personas: [P-004, P-005]
epic: "Onboarding & Fleet Connection"
priority: "should-have"
complexity: "L"
tags: [onboarding, auth, sso, saml, enterprise, security]
---

# US-010: SSO / SAML Login for Enterprise

## User Story

**As a** DevOps/SRE Lead (P-004),
**I want to** configure SAML 2.0 SSO so my team authenticates via our corporate identity provider,
**So that** we eliminate password sprawl, enforce MFA policies, and satisfy our security director's access control requirements.

## Acceptance Criteria

- [ ] Given I navigate to Settings → Security → SSO, when I select "Configure SAML 2.0," then I am shown the IoTGo service provider metadata (entity ID, ACS URL, metadata XML) to enter into my IdP.
- [ ] Given I enter my IdP metadata URL or upload an XML file, when I save the configuration, then IoTGo validates the metadata and displays a "Test SSO Login" button.
- [ ] Given SSO is configured and tested, when a user whose email domain matches the SSO domain attempts to log in, then they are redirected to the IdP for authentication and returned to IoTGo upon success.
- [ ] Given SSO is enabled, when an SSO-authenticated user's IdP session expires, then IoTGo terminates their session and redirects to the IdP login page rather than prompting for a password.
- [ ] Given SSO is active, when a new user authenticates via SSO for the first time, then an IoTGo account is auto-provisioned with the default role configured in the SSO settings.

## Notes

SCIM provisioning for automated user lifecycle management is a follow-on capability beyond this batch. P-005 (Security Director) will require audit logs of SSO events — see audit logging epic.
