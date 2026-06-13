---
id: US-003
title: "User Profile Creation"
slug: "profile-creation"
personas: [P-001, P-002, P-003, P-005]
epic: "Authentication & Signup"
priority: "must-have"
complexity: "M"
tags: [authentication, profile, onboarding]
---

# US-003: User Profile Creation

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** create a display name and upload an avatar after OAuth signup,
**So that** other users can identify me and recognize my contributions across spaces.

## Acceptance Criteria

- [ ] Given a user completes OAuth signup, when they are redirected to profile creation, then they can enter a display name (3-30 characters, alphanumeric + spaces)
- [ ] Given a user is creating their profile, when they upload an avatar image (max 2MB, JPG/PNG/WebP), then the image is resized to 256x256 and stored
- [ ] Given a user is creating their profile, when they enter an invalid display name (too short, special characters), then they receive an inline validation error
- [ ] Given a user is creating their profile, when they submit a valid form, then they are redirected to the onboarding flow
- [ ] Given a user skips profile creation, when they attempt to interact with the platform, then they are prompted to complete their profile first

## Notes

Profile can be edited later. Avatar upload uses CDN for delivery. Display names must be unique per space, not globally.