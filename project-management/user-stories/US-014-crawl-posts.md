---
id: US-014
title: "Crawl and Index Blog Posts"
slug: "crawl-posts"
personas: [P-001, P-002, P-007]
epic: "Blog Indexing & Scoring"
priority: "must-have"
complexity: "L"
tags: [indexing, crawl, posts, content-extraction]
---

# US-014: Crawl and Index Blog Posts

## User Story

**As a** blogger (P-001),
**I want to** have my blog posts crawled and indexed by the platform,
**So that** an accurate and up-to-date picture of my content is used when computing my score.

## Acceptance Criteria

- [ ] Given a feed or blog URL is available, when the crawler runs, then it collects up to 50 most recent posts (by publish date) for initial indexing, respecting the blog's robots.txt directives
- [ ] Given the crawler fetches a post URL, when extracting content, then it strips navigation, ads, footers, and sidebar HTML using readability heuristics, retaining: title, body text, images (count + alt text), publish date, word count, headings structure, and internal/external link count
- [ ] Given a post is successfully extracted, when the data is stored, then each post record includes: url, title, published_at, word_count, image_count, has_alt_text (bool), heading_count, reading_time_minutes, and raw_text for AI scoring
- [ ] Given the crawler encounters a URL returning a non-200 status, when the error is logged, then the post is marked "unavailable" and skipped without failing the entire crawl job
- [ ] Given the crawl is complete, when the job finishes, then a crawl_completed event is emitted to trigger AI scoring (US-015) and the user's dashboard shows "Scoring in progress"

## Notes

Crawl rate must be polite: max 1 request/second per domain. User-agent should identify the crawler as "BloggersCompete-Bot/1.0". Crawler must honor Crawl-delay in robots.txt. For paid tiers, crawl depth and frequency can be increased. Related: US-012, US-013, US-015 (AI scoring), US-015 (progress indicator).
