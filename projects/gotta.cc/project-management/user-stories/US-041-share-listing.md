---
id: US-041
title: "Share a Listing via Link or Social"
slug: "share-listing"
personas: [P-001, P-003, P-004]
epic: "Community & Social"
priority: "should-have"
complexity: "S"
tags: [community, sharing, social, virality]
---

# US-041: Share a Listing via Link or Social

## User Story

**As a** casual link-follower (P-004),
**I want to** share an impressive directory listing with friends or on social media,
**So that** I can introduce people to great sites I found through gotta.cc.

## Acceptance Criteria

- [ ] Given I am viewing a listing, when I click the Share button, then I see options for: Copy Link, share to Mastodon/Fediverse, share to Bluesky, and share to Twitter/X
- [ ] Given I choose Copy Link, when the action completes, then the URL copied is a canonical permalink for the listing (not the raw site URL) so recipients land on the gotta.cc listing page
- [ ] Given I share to a social platform, when the share sheet opens, then it pre-fills a message including the site's title, its composite score, and the gotta.cc listing URL
- [ ] Given the listing has an Open Graph image or site screenshot, when shared, then social platforms render a rich preview card

## Notes

Canonical listing URLs must be stable and not change if a site is re-categorized. Rich previews require a screenshot/OG image generation step in the listing pipeline. Sharing a collection is a separate but related action covered in the Collections epic.
