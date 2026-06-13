---
id: US-086
title: "Archive Space"
slug: "archive-space"
personas: [P-003, P-007]
epic: "Spaces - Advanced"
priority: "could-have"
complexity: "M"
tags: [spaces, archival, lifecycle]
---

# US-086: Archive Space

## User Story

**As a** Startup Founder (P-007),
**I want to** archive spaces that are no longer active instead of deleting them permanently,
**So that** historical content is preserved but the space doesn't clutter the active space directory.

## Acceptance Criteria

- [ ] Given I am a space owner, when I access space settings, then I see an "Archive Space" option
- [ ] Given I click "Archive Space" and confirm, when the process completes, then the space is hidden from the space directory but existing members can still view all historical content
- [ ] Given I try to post a new thread in an archived space, when I attempt to post, then I see an error message "This space is archived and no longer accepts new posts"
- [ ] Given an archived space appears in my spaces list, when I view it, then it shows an "(Archived)" badge and a banner "This space is read-only"
- [ ] Given I archive a space in error, when I access settings, then I see an "Unarchive Space" option to restore it

## Notes

Archived spaces should still appear in user's "Your Spaces" list but be visually distinguished. Search excludes archived spaces by default.