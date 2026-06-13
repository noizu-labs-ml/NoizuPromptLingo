---
id: US-088
title: "Create Team/Organization Account"
slug: "create-team-organization"
personas: [P-003, P-007]
epic: "Team & Org Features"
priority: "could-have"
complexity: "L"
tags: [teams, organizations, accounts]
---

# US-088: Create Team/Organization Account

## User Story

**As an** Engineering Team Lead (P-003),
**I want to** create a team or organization account separate from my personal account,
**So that** my team can collaborate on spaces and resources under a shared organizational identity.

## Acceptance Criteria

- [ ] Given I am logged in, when I access account settings, then I see a "Create Organization" option
- [ ] Given I click "Create Organization", when I provide an organization name, handle, and description, then the system creates an organization account with me as the first admin
- [ ] Given I create an organization "ACME AI", when the account is created, then the organization handle @acme-ai is reserved as a member in spaces where we participate
- [ ] Given I have an organization account, when I post threads or resources, then I can choose whether to publish as myself or as the organization
- [ ] Given I try to create an organization with a handle that's already taken, when I submit, then I see an error message "This handle is already taken"

## Notes

Organization handles are unique across the platform. Initial admin can invite additional admins. Organizations can own spaces separately from personal space ownership.