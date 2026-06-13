---
id: US-032
title: "Set Mockup Access Permissions"
slug: "set-mockup-access-permissions"
personas: [P-002, P-005]
epic: "Stakeholder Feedback"
priority: "must-have"
complexity: "M"
tags: [permissions, access-control, security, sharing]
---

# US-032: Set Mockup Access Permissions

## User Story

**As a** enterprise architect (P-005),
**I want to** configure access permissions per mockup as view-only, can-comment, or can-edit,
**So that** sensitive design artifacts are not inadvertently modified by unauthorized collaborators.

## Acceptance Criteria

- [ ] Given a mockup, when I set a collaborator to "view-only", then they can see the mockup but the annotation and edit controls are disabled
- [ ] Given a mockup, when I set a collaborator to "can-comment", then they can add annotations but cannot modify the mockup content
- [ ] Given a mockup, when I set a collaborator to "can-edit", then they have full access to regenerate and update the mockup
- [ ] Given a share link (US-026), when it is created, then the default permission level is configurable before sharing

## Notes

Permission model should cascade: workspace role provides a floor, per-mockup override can restrict but not elevate beyond workspace role. Relates to US-041 (workspace roles).
