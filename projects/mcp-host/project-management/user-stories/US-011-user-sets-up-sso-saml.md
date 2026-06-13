---
id: US-011
title: "User sets up SSO/SAML for organization"
slug: "user-sets-up-sso-saml"
personas: [P-006, P-005]
epic: "Auth & Onboarding"
priority: "should-have"
complexity: "L"
tags: [auth, sso, saml, enterprise, organization]
---

# US-011: User Sets Up SSO/SAML for Organization

## User Story

**As a** Enterprise IT Admin (P-006) or Engineering Manager (P-005),
**I want to** configure SAML-based Single Sign-On for my organization on MCP Host,
**So that** team members authenticate through our corporate identity provider and access is governed by existing directory group memberships.

## Acceptance Criteria

- [ ] Given the organization admin settings, when the user navigates to "SSO/SAML Configuration" and uploads the identity provider metadata XML, then the system parses the metadata, validates the endpoints and certificate, and saves the SAML configuration for the organization.
- [ ] Given a configured SAML identity provider, when a user with an email address matching the organization's domain attempts to log in, then the system redirects to the identity provider's SSO page instead of showing the MCP Host login form.
- [ ] Given a successful SAML authentication, when the assertion contains group memberships, then the system maps SAML groups to MCP Host roles (admin, developer, viewer) and applies the corresponding role-based policies.
- [ ] Given SAML is enforced for an organization, when a user in that organization attempts to log in with email/password or a social OAuth provider, then the system redirects them to the SAML identity provider and does not allow alternative login methods.
- [ ] Given the SSO configuration is active, when the identity provider sends a SAML logout request, then MCP Host terminates all active sessions for the affected user across all devices within 60 seconds.

## Notes

SAML/SSO is an enterprise feature targeting organizations with existing identity providers (Okta, Azure AD, OneLogin). Once SAML is enforced, it overrides other login methods for users in the organization's domain. Group-to-role mapping must be configurable. This is a Phase 3 (Scale) feature. Related to US-001, US-002.
