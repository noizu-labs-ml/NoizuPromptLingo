---
id: US-005
title: "Create a Space"
slug: "create-space"
personas: [P-001, P-002, P-003, P-005]
epic: "Spaces"
priority: "must-have"
complexity: "M"
tags: [spaces, creation, moderation]
---

# US-005: Create a Space

## User Story

**As a** Engineering Team Lead (P-003),
**I want to** create a space focused on a specific topic or technology,
**So that** I can build a community around shared interests and connect with other builders.

## Acceptance Criteria

- [ ] Given an authenticated user, when they click "Create Space" and enter a name (3-50 characters), description (10-500 characters), and visibility setting, then a new space is created with them as the owner
- [ ] Given a user is creating a space, when they select "Public" visibility, then the space is visible to all users and can be joined without approval
- [ ] Given a user is creating a space, when they select "Restricted" visibility, then the space is visible to all users but requires approval to join
- [ ] Given a user is creating a space, when they select "Private" visibility, then the space is hidden and only accessible via invite link
- [ ] Given a space is created, when the user is redirected to the space's home page, then they see options to create the first thread and invite members

## Notes

Depends on US-003 for user profile. Space names must be unique globally. Owner has full moderation permissions.