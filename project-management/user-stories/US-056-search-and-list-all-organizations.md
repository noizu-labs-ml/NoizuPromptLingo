---
id: US-056
title: "List and Search All Organizations"
slug: "search-and-list-all-organizations"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "should-have"
complexity: "S"
tags: [admin, org-oversight, search]
---

# US-056: List and Search All Organizations

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** list and search across all organizations on the platform,
**So that** I can quickly locate a specific org for support, oversight, or investigation without needing membership in it.

## Acceptance Criteria

- [ ] Given Ilya is on the admin organizations page, when the page loads, then he sees a paginated list of all orgs on the platform regardless of his own org memberships.
- [ ] Given Ilya types a partial org name or key prefix into the search box, when results filter, then only orgs matching the query (case-insensitive substring) are shown.
- [ ] Given Ilya selects an org from the list, when he opens its detail view, then he sees org metadata (name, key prefix, member count, creation date) without being a member of that org.

## Notes

Read/oversight only. Taking action on a found org (e.g., configuring its media provider or GitHub grants) is covered by US-060/US-061.
