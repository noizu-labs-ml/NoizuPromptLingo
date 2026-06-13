---
id: US-007
title: "SEO Metadata & Core Web Vitals"
slug: "seo-metadata-core-web-vitals"
personas: [P-001, P-002, P-003]
epic: "Public Portfolio"
priority: "must-have"
complexity: "M"
tags: [seo, metadata, core-web-vitals, structured-data, performance]
---

# US-007: SEO Metadata & Core Web Vitals

## User Story

**As a** potential client searching Google for "fractional CTO consulting" (P-002),
**I want to** find noizu.com in search results with a compelling title and description,
**So that** I click through to evaluate Keith rather than a competitor.

## Acceptance Criteria

- [ ] Given any public page, when the HTML head is inspected, then a unique `<title>`, `<meta name="description">`, and canonical URL tag are present.
- [ ] Given the homepage, when rendered and measured with Lighthouse, then LCP is under 2.5s, CLS is under 0.1, and FID/INP is under 200ms on desktop.
- [ ] Given a page is shared to Slack or Twitter, when the link unfurls, then an OpenGraph image, title, and description are displayed.
- [ ] Given the homepage and About page, when crawled, then JSON-LD structured data is present (Person for About, ProfessionalService for homepage).
- [ ] Given a sitemap is requested at `/sitemap.xml`, when fetched, then all public pages are listed with lastmod dates.
- [ ] Given a robots.txt is requested at `/robots.txt`, when fetched, then it permits crawling of public pages and references the sitemap.

## Notes

Next.js Metadata API handles most of this natively. OG image can be statically exported or generated via `@vercel/og` / `next/og`. Sitemap generation should be automated at build time. Related: US-005 (Person schema), US-004 (citation meta).
