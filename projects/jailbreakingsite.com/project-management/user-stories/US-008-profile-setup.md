---
id: US-008
title: "Profile Setup"
slug: "profile-setup"
personas: [P-001, P-004, P-006]
epic: "Onboarding & Authentication"
priority: "should-have"
complexity: "S"
tags: [profile, account, identity, community]
---

# US-008: Profile Setup

## User Story

**As a** researcher or consultant who contributes to the community (P-001, P-004, P-006),
**I want to** set my display name, avatar, bio, and organization on my profile,
**So that** my contributions and researcher profile are attributed correctly and I build credibility in the community.

## Acceptance Criteria

- [ ] Given I navigate to my profile settings, when I update my display name, avatar (upload or URL), bio (up to 280 chars), and organization, then changes are saved and reflected in my public researcher profile
- [ ] Given I upload an avatar image, when the file exceeds 2MB or is not a supported format (JPG, PNG, WebP), then an inline error message is shown and the upload is rejected
- [ ] Given I set my organization field, when I save, then my profile card shows the organization name alongside my display name in catalog attribution and community posts
- [ ] Given I leave my profile public (default), when another user views a technique I contributed annotations to, then my display name and avatar link to my researcher profile

## Notes

Profile visibility can be set to private (hides from public researcher directory). Relates to community features and technique attribution. Display name must be unique across the platform.
