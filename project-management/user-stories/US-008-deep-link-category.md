---
id: US-008
title: "Deep-Link to Any Category"
slug: "deep-link-category"
personas: [P-001, P-002, P-003, P-007]
epic: "Category Browsing"
priority: "must-have"
complexity: "S"
tags: [deep-linking, urls, seo, sharing]
---

# US-008: Deep-Link to Any Category

## User Story

**As an** Indie Web Developer (P-002),
**I want to** share a direct URL to a specific category page,
**So that** people I link to land exactly where I intend without having to navigate from the homepage.

## Acceptance Criteria

- [ ] Given any category at any depth, when I copy its URL and open it in a fresh browser, then the page loads correctly with full context (breadcrumbs, description, listings).
- [ ] Given a category URL is shared on social media, when a link previewer fetches it, then it returns appropriate Open Graph meta tags (title, description, image).
- [ ] Given an invalid or deleted category slug is requested, when the server responds, then it returns a 404 page with suggestions for similar or parent categories.

## Notes

Every category must have a stable, human-readable slug (e.g., `/c/technology/web-development`). Slug changes should issue 301 redirects from old paths. Supports API Developer (P-007) use cases for linking into the directory.
