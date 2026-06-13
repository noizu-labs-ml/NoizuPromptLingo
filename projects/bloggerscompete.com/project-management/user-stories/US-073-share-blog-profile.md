---
id: US-073
title: "Share Blog Profile on Social Media"
slug: "share-blog-profile"
personas: [P-001, P-002, P-004]
epic: "Social & Sharing"
priority: "should-have"
complexity: "M"
tags: [social, sharing, profile, og-image, viral]
---

# US-073: Share Blog Profile on Social Media

## User Story

**As a** indie lifestyle blogger (P-001),
**I want to** share my BloggersCompete profile on social media with a rich preview card,
**So that** I can show off my AI scores to my audience and drive credibility and traffic to my blog.

## Acceptance Criteria

- [ ] Given I visit my public blog profile, when I click "Share profile," then I see a share sheet with options: Copy link, Twitter/X, LinkedIn, and Facebook
- [ ] Given my profile page has Open Graph meta tags, when any share link is pasted into Twitter/X, LinkedIn, or Facebook, then a rich preview card renders showing: blog name, overall AI score, niche, and a branded score badge graphic
- [ ] Given I click "Share to Twitter/X," when the action fires, then a pre-composed tweet opens with my blog name, overall score, a link to my profile, and the hashtag #BloggersCompete
- [ ] Given I click "Copy link," when the action fires, then my profile URL is copied to the clipboard and a "Copied!" tooltip confirms the action
- [ ] Given my profile is set to Private (US-070), when I view the share panel, then the share options are disabled with a message "Make your profile public to share it"

## Notes

OG image should be dynamically generated per blog (not static) to include the actual score. Server-side OG image generation (e.g., using Vercel OG or equivalent). Twitter/X share text is pre-filled but editable. Rich cards are a key organic growth driver for the platform. See US-070 for privacy settings.
