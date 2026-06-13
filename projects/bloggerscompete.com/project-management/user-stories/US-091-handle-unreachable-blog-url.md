---
id: US-091
title: "Handle Unreachable Blog URL"
slug: "handle-unreachable-blog-url"
personas: [P-001, P-004, P-008]
epic: "Edge Cases & Error States"
priority: "must-have"
complexity: "M"
tags: [edge-case, error-handling, blog-submission, url-validation, scraping]
---

# US-091: Handle Unreachable Blog URL

## User Story

**As a** blogger submitting my blog URL (P-004),
**I want to** receive clear feedback if my blog URL cannot be reached during submission or scoring,
**So that** I understand what went wrong and can fix the issue without my submission silently failing.

## Acceptance Criteria

- [ ] Given I submit a blog URL, when the platform attempts to fetch the URL during submission validation, then if the URL returns a non-2xx status code or times out after 10 seconds, I receive an inline error: "We couldn't reach your blog at {url}. Please check the URL and try again."
- [ ] Given a blog URL was reachable at submission time but becomes unreachable during a scheduled AI re-scoring run, when the fetch fails, then the blog's score is not updated, a flag is added to the blog record (`url_unreachable: true`), and the owner receives an email notification.
- [ ] Given a blog is flagged as `url_unreachable`, when the owner views their blog dashboard, then a warning banner displays: "We couldn't reach your blog URL. Your scores may be outdated — please verify your URL is accessible."
- [ ] Given a blog URL redirects (301/302), when the platform follows the redirect, then the final destination URL is validated and stored (up to 3 redirect hops; more than 3 is treated as an error).
- [ ] Given a submitted URL is syntactically invalid (e.g., missing protocol, obvious typo), when I attempt to submit, then client-side validation immediately highlights the field with: "Please enter a valid URL starting with https://".
- [ ] Given a blog has been unreachable for 30 consecutive days, when the scheduled check runs, then the blog is automatically moved to "Inactive" status and the admin moderation queue is notified.

## Notes

URL reachability checks should be performed asynchronously (background job) for both submission and re-scoring. The 10-second timeout should be configurable via environment variable. Relates to US-084 (admin manage blogs), US-094 (duplicate blog submission).
