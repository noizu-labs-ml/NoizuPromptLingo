---
id: US-005
title: "Profile Setup with Bio, Avatar, and Expertise Tags"
slug: "profile-setup"
personas: [P-001, P-003, P-006, P-008]
epic: "Onboarding & Auth"
priority: "should-have"
complexity: "M"
tags: [profile, onboarding, avatar, tags, personalization]
---

# US-005: Profile Setup with Bio, Avatar, and Expertise Tags

## User Story

**As a** Content Creator (P-006),
**I want to** set up my profile with a bio, avatar image, and expertise tags,
**So that** other community members can understand my background and find my contributions relevant to their interests.

## Acceptance Criteria

- [ ] Given I have completed registration or OAuth login for the first time, when I am directed to profile setup, then I see fields for display name, bio (max 280 characters), avatar upload, and an expertise tag multi-select.
- [ ] Given I upload an avatar image, when the file is a JPEG, PNG, or WebP under 5MB, then the image is cropped to a square via an in-browser cropper tool and saved as my profile picture.
- [ ] Given I am selecting expertise tags, when I type in the tag search field, then I see filtered suggestions from a predefined list (e.g., "Prompt Engineering", "LLM Fine-tuning", "Image Generation", "RAG", "Agents") and can select up to 8 tags.
- [ ] Given I am on the profile setup page, when I click "Skip for now", then my profile is saved with defaults and I am taken to the main feed; I can return to edit my profile at any time.
- [ ] Given I save my completed profile, when all required fields (display name) are valid, then my profile is saved and I am redirected to the first-run tutorial (US-006) or the main feed if tutorial is skipped.

## Notes

Display name is the only required field; all others are optional to reduce onboarding friction for P-008. Expertise tags influence the personalized feed algorithm and improve content discovery for P-001 and P-003.
