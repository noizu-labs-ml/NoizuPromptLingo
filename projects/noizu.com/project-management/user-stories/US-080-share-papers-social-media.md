---
id: US-080
title: "Share Research Papers on Social Media"
slug: "share-papers-social-media"
personas: [P-008, P-001, P-003]
epic: "Research & Community"
priority: "should-have"
complexity: "S"
tags: [research, sharing, social, og-tags, seo]
---

# US-080: Share Research Papers on Social Media

## User Story

**As an** AI ethics researcher / academic (P-008),
**I want to** share research papers via social media with rich link previews,
**So that** my followers see compelling previews that drive them to read Keith's work.

## Acceptance Criteria

- [ ] Given a research paper page, when its URL is shared on Twitter/X, LinkedIn, or Slack, then an Open Graph card displays with the paper title, abstract excerpt, and a branded preview image
- [ ] Given the paper page, when share buttons for Twitter/X and LinkedIn are clicked, then the native share intent opens pre-populated with the paper title and URL
- [ ] Given the paper page, when the "Copy link" button is clicked, then the canonical URL is copied to clipboard and a toast confirms success
- [ ] Given each paper, then it has unique OG meta tags (og:title, og:description, og:image, og:url) distinct from the site defaults
- [ ] Given the OG image, then it is generated with paper title and author overlaid on a branded template (1200×630px)

## Notes

OG image generation: static pre-generated images stored per paper, or dynamic via Next.js OG image API route (`/api/og?slug=...`). Dynamic is preferred for maintainability. Related to US-076, US-081 (newsletter).
