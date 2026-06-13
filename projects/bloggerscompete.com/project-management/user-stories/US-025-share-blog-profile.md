---
id: US-025
title: "Share Blog Profile"
slug: "share-blog-profile"
personas: [P-001, P-002, P-007]
epic: "Blog Profile"
priority: "could-have"
complexity: "S"
tags: [sharing, social, profile, og-tags, viral]
---

# US-025: Share Blog Profile

## User Story

**As a** blogger (P-001),
**I want to** share my blog's profile page and score card on social media,
**So that** I can showcase my scores and achievements to my audience and attract new readers to the platform.

## Acceptance Criteria

- [ ] Given I am viewing my own blog profile, when I click the "Share" button, then I see options to share via: copy link, Twitter/X, LinkedIn, and download as image
- [ ] Given I choose "Download as image", when the image is generated, then I receive a PNG (1200×630) showing: blog name, composite score, radar chart of all 6 dimensions, niche tags, and the BloggersCompete.com logo
- [ ] Given any blog profile URL is shared to social media, when the link is unfurled, then the Open Graph tags render: og:title as "{Blog Name} on BloggersCompete", og:description as a one-sentence summary with composite score and niche, and og:image as the dynamically generated score card image
- [ ] Given I click "Copy link", when the action is performed, then the blog's public profile URL is copied to clipboard and a toast "Link copied!" is shown for 3 seconds
- [ ] Given the blog profile is private (owner has disabled public visibility), when another user attempts to access the shared URL, then they see a 404 (not the private profile content)

## Notes

The score card image should be generated server-side (e.g., using headless browser or canvas rendering) and cached with a TTL of 1 hour per blog. Sharing options for competition results (e.g., "I placed #2 in the Lifestyle Challenge!") should be a separate future story. Related: US-021 (public blog profile), US-016 (score breakdown is the basis for the share image).
