---
id: US-022
title: "Recent Posts Tab on Blog Profile"
slug: "recent-posts-tab"
personas: [P-006, P-001]
epic: "Blog Profile"
priority: "must-have"
complexity: "S"
tags: [profile, posts, discovery, reader]
---

# US-022: Recent Posts Tab on Blog Profile

## User Story

**As a** blog reader (P-006),
**I want to** browse a blogger's recent posts directly on their platform profile,
**So that** I can preview their content style and quality before deciding to follow their blog.

## Acceptance Criteria

- [ ] Given I am on a blog's public profile, when I click the "Recent Posts" tab, then I see a paginated list of up to 20 posts per page, sorted by publish date descending
- [ ] Given I view a post in the list, when the list renders, then each entry shows: post title (linked to original post URL), publish date, estimated reading time, and the post's excerpt (first 160 characters of body text)
- [ ] Given the blog's feed contains images for posts, when the list renders, then a thumbnail is shown for each post that has one, with an appropriate alt attribute
- [ ] Given I click a post title, when the link is followed, then I am taken to the original post URL on the blogger's own site (opens in a new tab)
- [ ] Given the blog has not published any posts or the crawl found no posts, when I view the Recent Posts tab, then I see an empty state: "No posts indexed yet. Check back after the next crawl."

## Notes

Post list should be generated from the indexer's stored post records rather than live-fetching the blog, to ensure consistent performance. Post excerpts should strip HTML tags. Related: US-014 (crawl stores post records), US-021 (public blog profile).
