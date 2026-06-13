---
id: US-071
title: "Profile Setup: Display Name, Bio, Avatar"
slug: "profile-setup"
personas: [P-008, P-001, P-002]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "S"
tags: [profile, onboarding, avatar, bio, settings]
---

# US-071: Profile Setup: Display Name, Bio, Avatar

## User Story

**As a** community curator (P-008),
**I want to** set up my public profile with a display name, short bio, and avatar,
**So that** people who discover my collections can learn who I am and follow my curation.

## Acceptance Criteria

- [ ] Given I am in the onboarding flow or account settings, when I access the profile setup step, then I can set a display name (max 50 characters), a short bio (max 200 characters), and upload an avatar image
- [ ] Given I upload an avatar, when the image is processed, then it is cropped/resized to a square and stored at multiple sizes (32px, 64px, 128px)
- [ ] Given I do not upload an avatar, when my profile or collections are displayed, then a generated avatar (initials-based or identicon) is used as a fallback
- [ ] Given my profile is public, when another user visits my profile page, then they see my display name, bio, avatar, and a list of my public collections with follow counts
- [ ] Given I update my display name, when the change is saved, then it is reflected across all my collections and site submissions within the same session

## Notes

Profile URLs should be based on username/handle set at signup, not display name, to keep URLs stable even if display name changes. Gravatar could be offered as an avatar source alongside direct upload. Related: US-068 (email signup), US-062 (public collection), US-064 (follow collection).
