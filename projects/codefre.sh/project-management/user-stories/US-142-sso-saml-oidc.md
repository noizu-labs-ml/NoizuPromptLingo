---
id: US-142
title: SSO via SAML / OIDC
issue_type: story
slug: sso-saml-oidc
status: in-progress
priority: P2
story_points: 8
estimated_scope: L
category: tenancy-and-admin
components:
  - backend
  - frontend
labels:
  - wave-3
  - tenancy
  - auth
  - enterprise
assignee: null
reporter: null
epic: mvp-tenancy
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
secondary_personas: [] 
related_stories:
  - US-039
  - US-040
dependencies:
  - US-039
blocks: []
duplicates: []
schema_refs:
  - memberships
  - organizations
  - sso_config
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# SSO via SAML / OIDC

## Story

As a **QA Lead at an enterprise**,
I want to **configure SAML or OIDC SSO for my org so team members sign in via our IdP**
so that **user lifecycle management (hire, offboard) propagates automatically and our SOC2 auditors stop asking about access control**.

## Acceptance Criteria

- [ ] Org settings: SSO configuration for SAML (IdP metadata URL, ACS URL) or OIDC (issuer, client id, client secret)
- [ ] SSO-mandated orgs disallow password login for all members
- [ ] JIT user provisioning on first SSO login
- [ ] SSO role mapping from IdP groups to org roles (owner/admin/editor/viewer)
- [ ] Fallback admin bypass for break-glass scenarios (org owner recovery)

## Notes

- Tier-gated to Enterprise per README monetization model

## Out of Scope

- SCIM for push provisioning (Wave 3+)
- Multi-IdP per org (Wave 3+)
