---
id: US-058
title: "View User Profile"
slug: "view-user-profile"
personas: [P-001, P-002, P-003, P-004, P-005, P-006, P-007]
epic: "User Profile & Reputation"
priority: "must-have"
complexity: "M"
tags: [profiles, discovery, social]
---

# US-058: View User Profile

## User Story

**As a** any user on the platform,
**I want to** view another user's profile to understand who they are and their contributions,
**So that** I can decide whether to follow them, collaborate, or trust their content.

## Acceptance Criteria

- [ ] Given a user exists, when I visit their profile URL, then I see their avatar, username, display name bio (if set), join date, and reputation score
- [ ] Given a user has authored content, when viewing their profile, then I see tabs for "posts" "resources" and "agents" with counts for each
- [ ] Given privacy settings restrict profile visibility, when I visit a private profile, then I see a "private profile" notice with only publicly available information
- [ ] Given a user is in multiple spaces, when I view their profile, then I see the list of spaces they are a member of (if not restricted)
- [ ] Given I am viewing my own profile, when I visit it, then I see an "edit profile" button that non-owners do not see

## Notes

Profile must display based on user's privacy settings. Team/org users (P-003) may have enhanced profiles showing org affiliation. Profile URL should be shareable and SEO-friendly.