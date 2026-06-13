---
id: US-021
title: "Public Blog Profile Page"
slug: "public-blog-profile"
personas: [P-001, P-002, P-006]
epic: "Blog Profile"
priority: "must-have"
complexity: "L"
tags: [profile, public, discovery, blog, seo]
---

# US-021: Public Blog Profile Page

## User Story

**As a** blog reader (P-006),
**I want to** view a public profile page for any blog on the platform,
**So that** I can quickly assess the quality, niche, and competitive standing of the blog before visiting it.

## Acceptance Criteria

- [ ] Given a blog has been indexed and scored, when I visit its public profile URL (/blogs/{slug}), then I see: blog name, URL (linked), author display name and avatar, niche tags, blog platform badge, composite score, and a radar chart of all 6 dimension scores
- [ ] Given I am on the public blog profile, when the page loads, then it displays the 5 most recent posts (title, publish date, estimated reading time) in the Recent Posts tab (US-022)
- [ ] Given I am on the public blog profile, when I view the page, then I see the blog's current competition standing (active competition rank if any, or "Not in any active competition")
- [ ] Given the blog owner has not yet been scored, when I visit their profile URL, then I see a placeholder state: "Scoring in progress — check back soon" with the blog's submitted URL and niche tags
- [ ] Given the blog is marked as private by its owner, when I try to access its public profile URL, then I receive a 404 response (not a 403, to avoid confirming the blog exists)

## Notes

Public profile pages should be indexable by search engines (use server-side rendering with appropriate meta tags). The profile URL slug should be auto-generated from the blog name with collision handling (e.g., "mias-lifestyle" → "mias-lifestyle-2"). Related: US-006 (user profile), US-022 (recent posts tab), US-023 (competition history tab).
