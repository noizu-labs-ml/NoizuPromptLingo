---
id: US-073
title: "Manage Privacy Settings"
slug: "manage-privacy-settings"
personas: [P-001, P-002, P-003, P-004, P-005, P-006, P-007]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, privacy, data]
---

# US-073: Manage Privacy Settings

## User Story

**As a** any user on the platform,
**I want to** control what information about me is visible to others,
**So that** I can protect my privacy while still participating meaningfully in the community.

## Acceptance Criteria

- [ ] Given I am in settings, when I click "Privacy", then I see toggles for: "Show my profile to logged-in users only" vs "public", "Display my join date", "Display my reputation score", "Show my spaces list", and "Allow following"
- [ ] Given my profile is public, when someone views it, then they see information based on my privacy toggles (private fields are hidden or replaced with "hidden")
- [ ] Given I disable "Allow following", when someone tries to follow me, then they receive a message that this user does not accept followers and the follow button is disabled
- [ ] Given I am viewing another user's profile, when their privacy settings restrict visibility, then I see only publicly available information or a "restricted profile" notice
- [ ] Given I change privacy settings, when I save, then changes apply immediately and cached profile data for other users is invalidated within 5 minutes

## Notes

Default privacy settings should be moderate (profile visible to logged-in users, join date shown, reputation shown). Organization accounts (P-003) may require additional privacy controls for employee profiles. Consider "discoverability" toggle to appear in user search as separate setting. Privacy settings must respect GDPR right to be forgotten.