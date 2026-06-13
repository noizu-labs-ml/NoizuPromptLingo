---
id: US-045
title: "View Global Leaderboard"
slug: "view-global-leaderboard"
personas: [P-001, P-002, P-004, P-006]
epic: "Leaderboards"
priority: "must-have"
complexity: "M"
tags: [leaderboard, discovery, rankings, global, social-proof]
---

# US-045: View Global Leaderboard

## User Story

**As a** blogger wanting to benchmark my blog's performance (P-002),
**I want to** view the global leaderboard of all ranked blogs on the platform,
**So that** I can see where I stand among all competitors and discover top-performing blogs in my niche.

## Acceptance Criteria

- [ ] Given I navigate to the Leaderboard page, when it loads, then I see a ranked list of blogs with: rank position, blog name, blog avatar/thumbnail, blogger username, overall AI score, and primary niche
- [ ] Given I am a logged-in user with a registered blog, when I view the global leaderboard, then my blog's row is highlighted and my rank is shown even if I am not on the current visible page
- [ ] Given I am not logged in, when I view the global leaderboard, then I can see all rankings but my position is not highlighted and a CTA invites me to register my blog
- [ ] Given the leaderboard has more than 50 entries, when it renders, then it is paginated with 25 blogs per page and pagination controls at the bottom
- [ ] Given a blog's score updates after a new AI scoring run, when the leaderboard is next rendered, then the new score and recalculated rank are reflected
- [ ] Given I click on a blog entry in the leaderboard, when the click is registered, then I am taken to that blog's public profile page showing its full score breakdown

## Notes

The global leaderboard is one of the highest-traffic pages and a primary discovery mechanism for P-006 (blog readers). It doubles as social proof for the platform itself. Blog reader P-006 uses this to find quality blogs across all niches. Related to US-046 (period filter), US-047 (niche filter), US-049 (podium display), US-050 (pagination).
