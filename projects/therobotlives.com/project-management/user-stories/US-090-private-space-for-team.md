---
id: US-090
title: "Private Space for Team"
slug: "private-team-space"
personas: [P-003]
epic: "Team & Org Features"
priority: "could-have"
complexity: "M"
tags: [teams, privacy, spaces]
---

# US-090: Private Space for Team

## User Story

**As an** Engineering Team Lead (P-003),
**I want to** create private spaces only accessible to organization members,
**So that** my team can discuss confidential topics and share internal resources.

## Acceptance Criteria

- [ ] Given I am an organization admin, when I create a new space, then I can select visibility options: Public, Unlisted, or Private (Organization Only)
- [ ] Given I create a space with "Private (Organization Only)" visibility, when the space is created, then only organization members can find and join it
- [ ] Given a team member tries to invite a non-organization user to a private space, when they attempt to invite, then they see an error message "This space is private to your organization"
- [ ] Given an organization is dissolved, when the organization is deleted, then all private spaces are converted to "Unlisted" and team members become individual owners
- [ ] Given I'm viewing a private space, when I check the space URL, then I see no indication of it being private (security through obscurity protection)

## Notes

Private spaces don't appear in public search or space directory. Only org members can share direct links. Organization admins control who can create private spaces.