---
id: US-037
title: "Register a New Organization"
slug: "register-new-organization"
personas: [P-004]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "S"
tags: [organizations, onboarding, tenancy]
---

# US-037: Register a New Organization

## User Story

**As the** Org Owner (P-004),
**I want to** register a brand-new organization,
**So that** I have a tenant-scoped workspace I can invite my team into and configure projects under.

## Acceptance Criteria

- [ ] Given I am an authenticated user, when I submit the "create organization" form with a unique organization name and slug, then a new organization is created with me set as its owner.
- [ ] Given I submit an organization name whose slug is already taken, when I try to create it, then I see a validation error naming the conflict and no duplicate organization is created.
- [ ] Given a new organization was just created, when I view its members settings, then I am listed as its sole member with owner-level permissions.

## Notes

First step of org-level onboarding; enables inviting members via US-038.
