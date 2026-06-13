---
id: US-070
title: "Privacy Settings (Public/Private Profile)"
slug: "privacy-settings"
personas: [P-001, P-002, P-007]
epic: "Settings & Account"
priority: "should-have"
complexity: "M"
tags: [settings, privacy, profile, visibility, account]
---

# US-070: Privacy Settings (Public/Private Profile)

## User Story

**As a** indie lifestyle blogger (P-001),
**I want to** control whether my blog profile is publicly visible,
**So that** I can use the platform to track my own progress privately before I'm ready to be discovered.

## Acceptance Criteria

- [ ] Given I navigate to /settings/privacy, when the page loads, then I see a "Profile visibility" toggle with options: Public (appears in explore, leaderboards) and Private (hidden from explore, leaderboards, search)
- [ ] Given I set my profile to Private, when the change saves, then my blog is immediately removed from explore results (US-051), all leaderboards, and the public profile URL returns a 404
- [ ] Given my profile is Private, when I view my own dashboard, then a banner reminds me my profile is hidden and provides a quick link to make it public
- [ ] Given I set my profile to Public, when the change saves, then my blog reappears in explore results within 5 minutes (next index refresh)
- [ ] Given I am entered in an active competition, when I switch to Private, then I am shown a warning: "Setting your profile to private will withdraw you from active competitions. Continue?" and the change only applies if I confirm

## Notes

Private profiles still generate AI scores and analytics — privacy only affects public visibility. Competition withdrawal on privacy change must be handled gracefully (not penalize ranking). See US-051 for explore, US-067 for profile edit.
