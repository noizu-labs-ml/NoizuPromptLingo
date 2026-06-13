---
id: US-004
title: "Profile Setup After Registration"
slug: "profile-setup"
personas: [P-001, P-008]
epic: "Onboarding & Authentication"
priority: "must-have"
complexity: "S"
tags: [auth, onboarding, profile, first-run]
---

# US-004: Profile Setup After Registration

## User Story

**As a** webcomic creator (P-008),
**I want to** set my display name, avatar, and creative role during onboarding,
**So that** the platform can tailor its defaults and terminology to how I actually work.

## Acceptance Criteria

- [ ] Given I have just registered (email or OAuth), when the first-run flow begins, then I am presented with a profile step asking for display name, optional avatar upload, and role selection (Novelist, Game Master, Narrative Designer, Podcaster, Worldbuilder, Other).
- [ ] Given I select a role, when I proceed, then my chosen role is stored on my profile and used to pre-select relevant entry templates in US-011.
- [ ] Given I upload an avatar image, when the upload completes, then the image is resized to 256x256 and stored; original is discarded.
- [ ] Given I skip the avatar upload, when setup completes, then a default avatar generated from my initials is displayed.

## Notes

Depends on US-001 and US-003. Feeds into US-007 (onboarding tour) and US-011 (universe creation wizard). Role can be changed later in Settings.
