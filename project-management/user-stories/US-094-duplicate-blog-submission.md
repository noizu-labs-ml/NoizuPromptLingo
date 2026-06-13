---
id: US-094
title: "Handle Duplicate Blog Submission"
slug: "duplicate-blog-submission"
personas: [P-001, P-004]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [edge-case, error-handling, blog-submission, duplicate, validation]
---

# US-094: Handle Duplicate Blog Submission

## User Story

**As a** blogger attempting to submit a blog (P-004),
**I want to** be told immediately if a blog URL I'm submitting already exists on the platform,
**So that** I don't waste time on a submission that will be rejected, and I can find the existing listing.

## Acceptance Criteria

- [ ] Given I submit a blog URL that is already registered by another user, when the submission is validated, then I receive an error: "This blog is already registered on BloggersCompete. If you believe this is your blog, contact support."
- [ ] Given I submit a blog URL that I myself previously submitted, when the submission is validated, then I receive an error: "You've already submitted this blog. View it in your dashboard." with a link to the existing blog entry.
- [ ] Given URL normalization, when checking for duplicates, then the comparison is case-insensitive and strips trailing slashes (e.g., `https://myblog.com/`, `https://myblog.com`, and `HTTPS://MYBLOG.COM` are treated as identical).
- [ ] Given a blog URL that is a subdomain variant (e.g., `www.myblog.com` vs `myblog.com`), when submitted, then both variants are matched as duplicates if either is already registered.
- [ ] Given a removed/soft-deleted blog's URL is re-submitted by its owner, when the submission is validated, then the system restores the existing record rather than creating a duplicate, and informs the user: "Your blog was previously removed. It has been re-activated."
- [ ] Given a duplicate check, when performed, then it completes within 200ms using a database index on the normalized URL field.

## Notes

URL normalization function: lowercase, strip trailing slash, resolve `www.` prefix to canonical form. Implement as a unique index in the database on the normalized URL column. Relates to US-091 (unreachable URL), US-084 (admin manage blogs).
