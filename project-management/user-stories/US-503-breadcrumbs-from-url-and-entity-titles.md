---
id: US-503
title: "Know where I am from breadcrumbs derived from the URL and entity titles"
slug: "breadcrumbs-from-url-and-entity-titles"
personas: [P-001, P-008]
epic: "UX Foundations"
priority: "must-have"
complexity: "S"
tags: [ux, navigation, breadcrumbs, shell, information-architecture]
---

# US-503: Know where I am from breadcrumbs derived from the URL and entity titles

## User Story

**As an** Evaluating Newcomer (P-008) exploring an org that a Harness Operator (P-001) set up,
**I want** a breadcrumb trail on every screen, built from the URL segments with entity names substituted for opaque identifiers,
**So that** I can tell where I am in a deeply nested route such as a ticket detail tab inside a board inside a project, and climb back out in one click.

## Acceptance Criteria

- [ ] Given any app route under an org, when the page renders, then breadcrumbs are derived from the URL segments and every crumb except the last links to that ancestor route.
- [ ] Given a route segment that is an entity identifier, when the entity title resolves, then the crumb shows the title rather than the identifier; while it resolves the crumb shows a shape-matched skeleton, never a raw identifier flashing into a title.
- [ ] Given the deepest route segment, when breadcrumbs render, then the last crumb is the page title, is not a link, and carries the current-page accessible marking.
- [ ] Given an entity the caller may not read or that does not exist, when its crumb resolves, then the crumb degrades to a neutral label and the page renders its permission or not-found state rather than leaking the entity title.
- [ ] Given a right-to-left locale, when breadcrumbs render, then the trail and its separators mirror correctly.

## Notes

Plan sections: UX-PLAN §2.3 (URL scheme — breadcrumbs are a projection of it), §4 (`Breadcrumbs` is new; `PageHeader` takes title plus breadcrumbs), §6 (RTL mirrored rail and breadcrumbs), §9. Related stories: US-093 covers internationalization and RTL mirroring; US-506 supplies the permission state a denied crumb falls back to; US-501 and US-502 are the other two navigation primitives in the Phase 0 shell swap.
