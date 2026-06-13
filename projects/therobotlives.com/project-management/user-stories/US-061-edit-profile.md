---
id: US-061
title: "Edit Own Profile"
slug: "edit-profile"
personas: [P-001, P-002, P-003, P-006, P-007]
epic: "User Profile & Reputation"
priority: "must-have"
complexity: "M"
tags: [profiles, account, self-service]
---

# US-061: Edit Own Profile

## User Story

**As a** Prompt Engineer Power User (P-001), AI/ML Engineer (P-002), Engineering Team Lead (P-003), Content Creator (P-006), or Startup Founder (P-007),
**I want to** edit my profile information including bio, avatar, and display name,
**So that** my profile accurately represents my identity and expertise on the platform.

## Acceptance Criteria

- [ ] Given I am logged in, when I click "edit profile", then I see a form with fields for display name, username (username change requires confirmation and uniqueness check), bio (markdown supported), avatar upload, and location/website links
- [ ] Given I upload an avatar, when the image is processed, then it is resized to consistent dimensions and compressed, with crop/rotate tools available
- [ ] Given I update my bio, when content is submitted, then markdown is rendered with sanitization to prevent XSS attacks
- [ ] Given I change my username, when the change is processed, then old username redirects to new profile for 30 days before being released for reuse
- [ ] Given a user is part of an organization (P-003 use case), when editing profile, then they can optionally display org badge/affiliation on their profile

## Notes

Username changes should be rate-limited (e.g., once per 30 days) to prevent impersonation or confusion. Avatar uploads should support common formats (JPG, PNG, WebP) with reasonable file size limits. Org affiliation display requires org verification.