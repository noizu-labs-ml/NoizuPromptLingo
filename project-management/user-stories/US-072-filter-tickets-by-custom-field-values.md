---
id: US-072
title: "Filter Tickets by Custom Field Values"
slug: "filter-tickets-by-custom-field-values"
personas: [P-003]
epic: "Search & Discovery"
priority: "should-have"
complexity: "M"
tags: [tickets, custom-fields, search, filtering]
---

# US-072: Filter Tickets by Custom Field Values

## User Story

**As a** Delivery Lead (Priya Anand, P-003),
**I want to** filter and search tickets by the values of their custom fields, not just built-in fields like status or assignee,
**So that** I can build views like "all tickets where Component = billing and Risk = high" for sprint planning and triage.

## Acceptance Criteria

- [ ] Given a project with one or more custom fields defined on its tickets (select, text, and number types), when a filter specifies a custom field name and value, then only tickets matching that value are returned.
- [ ] Given multiple custom-field filters combined with a built-in filter (e.g. status=open AND Component=billing), when the combined filter is applied, then results satisfy all conditions simultaneously (AND semantics), not just the last one applied.
- [ ] Given a custom field of select/enum type, when filtered with a value not in that field's allowed options, then a validation error is returned instead of a silently empty result set.
- [ ] Given a free-text custom field, when searched with a partial-text query, then tickets whose field value contains that substring are returned.

## Notes

Complexity M because it spans multiple custom-field types (select/text/number) combined with AND-semantics across built-in and custom filters, rather than a single-field lookup.
