---
id: US-061
title: "User Profile Page with Stats"
slug: "user-profile-page"
personas: [P-001, P-002, P-003, P-006, P-008]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "M"
tags: [profile, stats, reputation, public-page]
---

# US-061: User Profile Page with Stats

## User Story

**As an** AI hobbyist (P-002),
**I want to** view any user's public profile page,
**So that** I can evaluate their expertise, see their contribution history, and decide whether to follow them.

## Acceptance Criteria

- [ ] Given any registered user, when I navigate to their profile URL, then I see their display name, avatar, bio, and join date
- [ ] Given a profile page, when I view the stats section, then I see total prompts submitted, total upvotes received, comment count, and follower/following counts
- [ ] Given a profile page, when I scroll to contributions, then I see a paginated list of their published prompts sorted by top votes by default
- [ ] Given I am the profile owner, when I view my own profile, then I see an "Edit Profile" button linking to account settings
- [ ] Given a user has been suspended, when I visit their profile, then a notice indicates the account is suspended and their content is hidden

## Notes

Profile URLs should be human-readable (e.g., /u/username). Stats should update in near-real-time or with a short cache window. The profile page is a key trust signal for the community and should be polished at launch.
