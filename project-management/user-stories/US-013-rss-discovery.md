---
id: US-013
title: "RSS Feed Discovery and Parsing"
slug: "rss-discovery"
personas: [P-001, P-002, P-007]
epic: "Blog Indexing & Scoring"
priority: "must-have"
complexity: "M"
tags: [rss, atom, feed, indexing, crawl]
---

# US-013: RSS Feed Discovery and Parsing

## User Story

**As a** blogger (P-002),
**I want to** have my RSS or Atom feed automatically discovered and used for indexing,
**So that** the platform accurately reflects my published posts without requiring manual configuration.

## Acceptance Criteria

- [ ] Given my blog URL is submitted, when the indexer attempts feed discovery, then it checks in order: HTML `<link rel="alternate">` tags, common paths (/feed, /rss, /atom.xml, /feed.xml, /rss.xml, /index.xml), and WordPress-specific /feed/ endpoint
- [ ] Given a valid RSS 2.0 or Atom 1.0 feed is discovered, when the feed is parsed, then the indexer extracts: post title, publish date, URL, summary/content (if present), author, and categories/tags
- [ ] Given the feed contains full post content, when the indexer processes the feed, then it uses the feed content directly without fetching individual post pages (reduces load on the blog server)
- [ ] Given the feed contains only summaries, when the indexer processes posts for scoring, then it fetches the full post HTML from each post URL to extract the complete content
- [ ] Given no feed is discovered after all checks, when the indexer falls back, then it logs "No feed found" and proceeds with HTML crawling from the blog root, paginating through up to 10 index pages

## Notes

Feed discovery should be completed within 30 seconds of blog submission. The discovered feed URL should be stored and used for subsequent re-indexing. Feed entries should be de-duplicated by post URL. Related: US-012 (platform detection may shortcut to API), US-014 (crawl posts), US-018 (re-index request).
