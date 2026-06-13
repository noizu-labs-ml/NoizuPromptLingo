---
id: US-043
title: "Receive Weekly Digest of Community Activity"
slug: "weekly-digest"
personas: [P-001, P-004]
epic: "Community & Social"
priority: "could-have"
complexity: "M"
tags: [community, email, digest, engagement, retention]
---

# US-043: Receive Weekly Digest of Community Activity

## User Story

**As a** casual link-follower (P-004),
**I want to** receive a weekly email summarizing the best community discoveries,
**So that** I stay connected to the directory's best finds without needing to visit every day.

## Acceptance Criteria

- [ ] Given I have opted in to the weekly digest in my account settings, when Monday morning arrives, then I receive an email containing: top 5 upvoted new listings, top submitter of the week, and 3 sites from curators I follow
- [ ] Given the digest email is received, when I click any listing title in it, then I am taken directly to that site's gotta.cc listing page
- [ ] Given I want to unsubscribe, when I click the unsubscribe link at the bottom of any digest email, then I am immediately unsubscribed without needing to log in
- [ ] Given I have no followed curators, when the digest is generated, then the "from curators you follow" section is replaced with top-rated finds from a category I have browsed most

## Notes

Digest is opt-in by default; new users are prompted once to subscribe after their first login. Digest personalization (based on browsing or follows) requires data from US-040. The email template should be minimal and text-forward to match the directory's aesthetic.
