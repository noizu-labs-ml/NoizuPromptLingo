---
id: US-085
title: "Single-Site Quality Score Lookup via API"
slug: "single-site-score-lookup"
personas: [P-007, P-002]
epic: "API & Integration"
priority: "should-have"
complexity: "M"
tags: [api, scoring, lookup, developer, site-owners]
---

# US-085: Single-Site Quality Score Lookup via API

## User Story

**As an** API Developer (P-007),
**I want to** look up the quality score for any specific URL in the directory,
**So that** I can integrate gotta.cc quality signals into my own tools without building a full directory browser.

## Acceptance Criteria

- [ ] Given I have a valid API key, when I send a GET request to `/api/v1/sites/score?url={encoded_url}`, then I receive the site's composite score and all five dimension scores in a JSON response
- [ ] Given I query a URL that is not in the gotta.cc directory, when the endpoint responds, then it returns HTTP 404 with a JSON body indicating the site is not indexed
- [ ] Given I query a URL that is in the directory but currently being rescored, when the endpoint responds, then it returns the last known scores along with a `score_status: "updating"` field
- [ ] Given a valid response is returned, when I inspect the JSON, then it includes `url`, `composite_score`, `dimension_scores`, `last_scored_at`, `editors_pick`, and `listing_url` (deep link back to the gotta.cc detail page)

## Notes

The `listing_url` field in the response enables P-007's applications to drive referral traffic back to gotta.cc, creating a mutual value loop. This endpoint is also the backend for the embeddable score badge (US-089). URL normalization must handle trailing slashes, www/non-www variants, and https/http consistently.
