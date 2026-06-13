---
id: US-011
title: "Submit Blog URL"
slug: "submit-blog-url"
personas: [P-001, P-002, P-004]
epic: "Blog Indexing & Scoring"
priority: "must-have"
complexity: "M"
tags: [blog, submission, indexing, url]
---

# US-011: Submit Blog URL

## User Story

**As a** blogger (P-001),
**I want to** submit my blog's URL to the platform,
**So that** it can be indexed and scored so I can participate in competitions.

## Acceptance Criteria

- [ ] Given I am on the "Add Blog" page, when I enter a URL and click "Submit", then the system validates the URL format (must be a valid http/https URL with a resolvable domain) and rejects invalid formats with an inline error
- [ ] Given I submit a valid URL, when the system sends an HTTP HEAD request to the URL, then if the domain responds with a non-error status (2xx or 3xx), the submission is accepted and queued for indexing
- [ ] Given I submit a URL for a domain that is already registered to another user, when the submission is processed, then I am shown an error "This blog is already registered" with a link to the existing blog profile (US-021)
- [ ] Given my submission is accepted, when I am redirected to my blog dashboard, then I see an "Indexing in progress" status indicator (US-015) and an estimated time to completion
- [ ] Given I am on the Free tier, when I attempt to submit a second blog URL, then I see a prompt to upgrade to Pro to manage multiple blogs

## Notes

Free tier allows 1 blog. Pro allows up to 5 blogs. Team allows unlimited. URL ownership verification should be explored in a future story (e.g., DNS TXT record or meta tag). Related: US-005 (Step 1 of onboarding wizard), US-012 (platform auto-detection), US-015 (indexing progress).
