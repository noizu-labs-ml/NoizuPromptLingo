---
id: US-067
title: "Set workspace-level default permissions"
slug: "set-workspace-default-permissions"
personas: [P-004, P-002]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [workspace, permissions, settings, collaboration, admin]
---

# US-067: Set Workspace-Level Default Permissions

## User Story

**As a** Startup Founder (P-004),
**I want to** configure workspace-wide defaults for who can view and comment on shared mockups,
**So that** new team members and shared links have appropriate access without per-item configuration.

## Acceptance Criteria

- [ ] Given the workspace settings page, when I set default viewer permissions to "anyone with link", then newly shared mockups are accessible to anyone with the link without requiring a login
- [ ] Given the workspace settings page, when I set default commenter permissions to "workspace members only", then only authenticated workspace members can submit feedback on shared mockups
- [ ] Given workspace defaults are set, when a user shares a mockup without specifying permissions, then the workspace defaults are applied to that share
- [ ] Given a user overrides permissions on an individual share, when viewed, then the individual override takes precedence over workspace defaults for that specific mockup

## Notes

Workspace permissions interact with individual share settings (related to US-026). Admin users can view and override workspace settings via the admin dashboard (US-070). Defaults apply only to new shares, not retroactively.
