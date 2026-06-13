---
id: US-089
title: "Embeddable Quality Score Badge for Site Owners"
slug: "embeddable-quality-score-badge"
personas: [P-002, P-007]
epic: "API & Integration"
priority: "could-have"
complexity: "M"
tags: [api, badge, embed, site-owners, distribution]
---

# US-089: Embeddable Quality Score Badge for Site Owners

## User Story

**As an** Indie Web Developer (P-002),
**I want to** embed a gotta.cc quality score badge on my own website,
**So that** I can display my site's curation status as a trust signal to my visitors.

## Acceptance Criteria

- [ ] Given my site is listed on gotta.cc, when I visit my listing's settings page, then I see an embed code section with an `<img>` tag and an `<a>` link wrapping it, pre-configured with my site's URL
- [ ] Given the badge embed code is copied and pasted onto an external site, when the external page loads, then the badge image is served from gotta.cc's CDN showing the current composite score and an "on gotta.cc" label
- [ ] Given my site's score changes after recalculation, when the badge is subsequently requested, then it reflects the updated score (cache TTL of 24 hours is acceptable)
- [ ] Given a visitor clicks the badge on my site, when they are redirected, then they land on my site's detail page on gotta.cc
- [ ] Given the badge endpoint is called without a valid, listed URL, when the request is processed, then it returns a generic "not listed" badge image rather than an error

## Notes

The embeddable badge is a viral distribution mechanism — every site that embeds it is a billboard for gotta.cc. Design multiple badge styles (full score with bar, compact icon-only, text-only) to suit different site aesthetics. Badge image generation uses the same score data as US-085 (single-site score lookup).
