---
id: US-075
title: "Discussion Thread on Competitions"
slug: "competition-discussion-thread"
personas: [P-001, P-005, P-006]
epic: "Social & Sharing"
priority: "could-have"
complexity: "L"
tags: [social, discussion, competition, community, comments]
---

# US-075: Discussion Thread on Competitions

## User Story

**As a** competition host (P-005),
**I want to** have a discussion thread on each competition page,
**So that** participants can ask questions, share tips, and build community energy around the competition, increasing engagement and completion rates.

## Acceptance Criteria

- [ ] Given I navigate to an active or completed competition page, when I view the page, then I see a "Discussion" tab alongside "Leaderboard" and "Details" tabs
- [ ] Given I open the Discussion tab, when the thread loads, then I see all comments in chronological order with author avatar, display name, timestamp, and comment body
- [ ] Given I am a logged-in user, when I click "Add comment," then a text input appears (max 500 chars) and I can submit my comment which appears immediately in the thread
- [ ] Given a comment is submitted, when it renders, then it shows a character count and the submit button is disabled until at least 1 character is entered
- [ ] Given I am the competition host (P-005), when I comment in the thread, then my comment is marked with a "Host" badge so participants can identify official responses
- [ ] Given a comment contains prohibited content (per platform moderation rules), when the admin reviews it (US-008 admin flag), then the admin can delete the comment and the comment is replaced with "[Removed by moderator]"
- [ ] Given I am not logged in, when I view the Discussion tab, then I can read all comments but the comment input is replaced by a "Log in to join the discussion" prompt

## Notes

Discussion threads are per-competition, not per-blog. Initial implementation is a simple chronological thread — no threading/replies. Moderation hooks must be in place from launch (no edit by user after posting). Spam prevention: rate limit 5 comments per user per hour per competition. See US-008 for admin moderation, US-073 and US-074 for social sharing.
