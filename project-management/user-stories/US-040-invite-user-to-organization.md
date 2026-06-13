---
id: US-040
title: Invite a user as a member of an organization
issue_type: story
slug: invite-user-to-organization
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: tenancy-and-admin
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - tenancy
  - membership
assignee: null
reporter: null
epic: mvp-tenancy
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-039
dependencies:
  - US-039
blocks: []
duplicates: []
schema_refs:
  - memberships
  - organizations
  - users
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Invite a user as a member of an organization

## Story

As an **org Owner**,
I want to **add a user by email to my org with a role**
so that **my team can collaborate on scripts, runs, and reviews**.

## Acceptance Criteria

- [ ] Owner/admin can enter an email and pick a role: `:owner`, `:admin`, `:editor`, `:viewer`
- [ ] If the email matches an existing user, a `memberships` row is created immediately
- [ ] If no user matches, a pending invite is recorded; on signup with that email, membership is auto-created
- [ ] Only owners can grant the `:owner` role
- [ ] Attempting to add a duplicate member (same user + org) is rejected with a clear error

## Notes

- Invite-acceptance email flow is Wave 2 (for MVP, membership is created immediately on matching email)
- Role change and removal are Wave 2

## Out of Scope

- Email-based invite with accept link (Wave 2)
- SSO / SCIM provisioning (Wave 3 — Enterprise)
- Role change / member removal UI (Wave 2)
