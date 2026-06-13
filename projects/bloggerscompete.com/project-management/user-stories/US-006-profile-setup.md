---
id: US-006
title: "User Profile Setup"
slug: "profile-setup"
personas: [P-001, P-002, P-003]
epic: "Onboarding & Auth"
priority: "must-have"
complexity: "M"
tags: [profile, onboarding, avatar, bio]
---

# US-006: User Profile Setup

## User Story

**As a** blogger (P-001),
**I want to** set up my public profile with a display name, avatar, and short bio,
**So that** other users can identify me on leaderboards and competition pages.

## Acceptance Criteria

- [ ] Given I am on the profile setup page (Step 4 of onboarding or via Settings), when I enter a display name (3–50 characters, alphanumeric + spaces), then it is saved and shown on my public profile
- [ ] Given I upload an avatar image, when the upload is accepted (JPG/PNG/WebP, max 2MB), then the image is cropped to a square and displayed as my avatar across the platform
- [ ] Given I do not upload an avatar, when my profile is viewed, then a generated avatar (initials or identicon) is shown as a fallback
- [ ] Given I enter a bio, when the character count exceeds 280, then the input is blocked and a character counter in red indicates the limit
- [ ] Given I save my profile, when the save succeeds, then I see a confirmation toast "Profile updated" and my new display name appears in the site header immediately

## Notes

Display names must be unique across the platform. If a chosen name is taken, suggest alternatives with a numeric suffix (e.g., "MiaChen2"). Related: US-005 (onboarding wizard, Step 4), US-021 (public blog profile).
