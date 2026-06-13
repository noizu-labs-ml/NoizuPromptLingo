---
id: US-008
title: "Space Visibility Settings"
slug: "space-visibility"
personas: [P-003, P-001]
epic: "Spaces"
priority: "should-have"
complexity: "M"
tags: [spaces, settings, privacy]
---

# US-008: Space Visibility Settings

## User Story

**As a** Engineering Team Lead (P-003),
**I want to** modify the visibility settings of a space I own,
**So that** I can control discoverability and membership access as the community evolves.

## Acceptance Criteria

- [ ] Given a space owner, when they visit space settings, then they see a visibility dropdown with Public, Restricted, and Private options
- [ ] Given a space owner changes visibility to Public, when they save, then the space appears in the public directory and any pending join requests are auto-approved
- [ ] Given a space owner changes visibility to Restricted, when they save, then existing members remain but new users must request to join
- [ ] Given a space owner changes visibility to Private, when they save, then the space is removed from public directory and invite links are required for access
- [ ] Given a space owner changes visibility settings, when they navigate away without saving, then changes are not persisted

## Notes

Depends on US-005 for space creation. Only owners can modify visibility. Existing members are never removed by visibility changes.