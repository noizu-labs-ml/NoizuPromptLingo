---
id: US-042
title: "Comment on Why a Site Is Great"
slug: "comment-on-listing"
personas: [P-001, P-003, P-008]
epic: "Community & Social"
priority: "could-have"
complexity: "L"
tags: [community, comments, discussion, context]
---

# US-042: Comment on Why a Site Is Great

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** leave a short comment on a listing explaining what makes it special,
**So that** future visitors have human context beyond the AI score to understand the site's value.

## Acceptance Criteria

- [ ] Given I am logged in and viewing a listing, when I open the comment section, then I can type a comment up to 500 characters explaining why I recommend the site
- [ ] Given I post a comment, when it is submitted, then it appears immediately in the listing's comment thread with my display name, avatar, and timestamp
- [ ] Given a comment contains a URL, when it is submitted, then the URL is rendered as a plain text link — no embeds — to prevent spam vectors
- [ ] Given I want to remove my comment, when I click the delete option on my own comment, then it is removed and replaced with a "[deleted]" placeholder to preserve thread continuity
- [ ] Given a comment receives multiple flags from other users, when the flag threshold is crossed, then the comment is hidden pending moderator review

## Notes

Comments are deliberately simple — no threading, no reactions — to preserve the directory's low-noise aesthetic. Comment moderation ties into the general flag and review system (US-047). This feature is deprioritized to avoid becoming a forum; the focus is brief contextual notes.
