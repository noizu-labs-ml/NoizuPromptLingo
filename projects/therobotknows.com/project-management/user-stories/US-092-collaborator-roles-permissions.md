---
id: US-092
title: "Collaborator Roles & Permissions"
slug: "collaborator-roles-permissions"
personas: [P-001, P-003, P-008]
epic: "Collaboration & Sharing"
priority: "must-have"
complexity: "M"
tags: [collaboration, roles, permissions, access-control, team]
---

# US-092: Collaborator Roles & Permissions

## User Story

**As a** universe owner working with a team (P-001, P-003, P-008),
**I want to** assign specific roles to collaborators that control what they can read, write, and delete,
**So that** I maintain creative control while allowing targeted contributions from my team.

## Acceptance Criteria

- [ ] Given a collaborator has the "Viewer" role, when they open the universe, then they can read all canon entries and the knowledge graph but cannot create, edit, or delete any content.
- [ ] Given a collaborator has the "Editor" role, when they use the platform, then they can create and edit canon entries, run consistency checks, and use the generation studio, but cannot delete entries or modify universe settings.
- [ ] Given a collaborator has the "Co-owner" role, when they use the platform, then they have all editor permissions plus the ability to invite others, change universe settings, and delete entries, but cannot delete the universe itself.
- [ ] Given I change a collaborator's role from Editor to Viewer, when the change is saved, then their access is downgraded immediately and any active editing sessions show a "read-only" banner.
- [ ] Given a collaborator is removed from a universe, when removal is confirmed, then all their active sessions are invalidated and they are redirected from any universe pages they have open.

## Notes

Depends on US-091 (invite collaborators). Role definitions must be enforced at the API level, not just the UI level. Related: US-093 (public sharing) — public access implicitly grants a Viewer-equivalent role to anonymous users.
