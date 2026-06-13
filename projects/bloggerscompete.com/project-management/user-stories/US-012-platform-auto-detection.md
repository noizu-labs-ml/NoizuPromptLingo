---
id: US-012
title: "Auto-Detect Blog Platform"
slug: "platform-auto-detection"
personas: [P-001, P-004]
epic: "Blog Indexing & Scoring"
priority: "should-have"
complexity: "M"
tags: [blog, indexing, platform-detection, wordpress, substack, ghost]
---

# US-012: Auto-Detect Blog Platform

## User Story

**As a** blogger (P-004),
**I want to** have the platform automatically detect what blogging software I use,
**So that** the indexer can use the optimal strategy to crawl my content without manual configuration.

## Acceptance Criteria

- [ ] Given my blog URL is submitted, when the indexer fetches the page HTML, then it checks for platform fingerprints in order: WordPress (wp-content/wp-json), Substack (substack.com domain or meta tags), Ghost (ghost.io domain or /ghost/api), Medium, Blogger, Squarespace, Wix, and Webflow
- [ ] Given a platform is positively identified, when the blog profile is created, then it displays the detected platform name and logo badge (e.g., "WordPress" badge) on my dashboard
- [ ] Given no known platform is detected, when the indexer completes the check, then the platform is recorded as "Custom/Unknown" and the indexer falls back to standard HTML crawling and RSS discovery (US-013)
- [ ] Given a WordPress blog is detected, when the indexer runs, then it uses the WordPress REST API (/wp-json/wp/v2/posts) to fetch posts rather than scraping HTML
- [ ] Given the platform is detected incorrectly, when I view my blog settings, then I can manually override the detected platform from a dropdown list of supported platforms

## Notes

Detection logic should be lightweight (inspect headers, HTML meta tags, known URL patterns) — do not download full page assets for detection. Substack and Ghost have well-documented APIs that should be prioritized. Related: US-011 (submission triggers detection), US-013 (RSS discovery), US-014 (crawl posts).
