---
id: US-060
title: "Grant GitHub Token/Repo Access at the Org Level"
slug: "grant-org-level-github-access"
personas: [P-006, P-004]
epic: "Admin & Platform Operations"
priority: "should-have"
complexity: "M"
tags: [admin, github, org-access]
---

# US-060: Grant GitHub Token/Repo Access at the Org Level

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006), working with Org Owner Marcus Chen (P-004),
**I want to** grant and administer GitHub token/repo access for an org,
**So that** that org's coding-agent harnesses can authenticate against the correct repos without oversharing platform-wide GitHub credentials.

## Acceptance Criteria

- [ ] Given Ilya is on an org's GitHub access admin page, when he grants access to a specific repo using a scoped token, then the org's projects can reference that repo and the grant appears in the org's GitHub access list.
- [ ] Given Marcus, as org owner, views his own org's GitHub grants, when he checks the grants list, then he sees which repos are authorized without being able to view the underlying token value in plaintext.
- [ ] Given Ilya revokes a previously granted repo/token, when he confirms revocation, then any coding-agent session attempting to use that grant afterward fails authentication against GitHub.
- [ ] Given Ilya attempts to grant access to a repo the configured token cannot actually reach, when he tests the grant, then the system reports the permission failure rather than silently saving an unusable grant.

## Notes

Mirrors the live-verification pattern from US-057 — grants should be verifiable, not just stored.
