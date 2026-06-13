---
id: US-089
title: "Admin: Create Platform Competition"
slug: "admin-create-competition"
personas: [P-008, P-005]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, competitions, create, platform, featured]
---

# US-089: Admin: Create Platform Competition

## User Story

**As a** platform admin (P-008),
**I want to** create official platform-sponsored competitions with custom rules and prizes,
**So that** BloggersCompete.com can run its own high-visibility events that drive user engagement.

## Acceptance Criteria

- [ ] Given I am on the admin competitions management page, when I click "Create Platform Competition," then I am presented with the competition creation form pre-populated with admin-only fields (e.g., "Platform Official" badge, featured = true by default).
- [ ] Given the creation form, when I fill in Title, Description, Category, Start Date, End Date, Entry Criteria, and Scoring Dimensions, then all fields are validated before submission.
- [ ] Given I set a prize description (text field, e.g., "$500 cash + Pro subscription"), when the competition is published, then the prize is displayed prominently on the competition listing card.
- [ ] Given I submit a valid competition form, when it is saved, then the competition is immediately set to "Active" (bypassing any Draft review process) and appears on the public browse page with an "Official" badge.
- [ ] Given I create a competition with a future start date, when the start date has not yet arrived, then the competition is shown in "Upcoming" status and entry is not yet open.
- [ ] Given an admin-created competition is active, when I click "Close Competition" from the admin panel, then entries are closed, winners are determined by current leaderboard standings, and a notification is sent to all participants.

## Notes

Admin-created competitions are distinct from user-hosted competitions (P-005 flow). They should have a visual "BloggersCompete Official" badge. Consider enabling custom scoring weights per competition (e.g., a "SEO-only" competition that weights SEO dimension at 100%). Relates to US-083, US-085.
