---
id: US-502
title: "Search across tools, tickets, wiki, instructions, and files from one results page"
slug: "global-search-results-page"
personas: [P-001, P-007]
epic: "UX Foundations"
priority: "must-have"
complexity: "M"
tags: [ux, search, federated-search, keyboard, shell]
---

# US-502: Search across tools, tickets, wiki, instructions, and files from one results page

## User Story

**As a** Harness Operator (P-001) supporting a Design & Code Reviewer (P-007) who half-remembers where something lives,
**I want to** press `/` and land on a global search results page that groups matches by source,
**So that** I can find a ticket, a wiki page, an instruction, a tool, or a file without first guessing which section of the app owns it.

## Acceptance Criteria

- [ ] Given any authenticated app screen with no text input focused, when the user presses `/`, then the global search box takes focus, and submitting a query routes to the results page with the query carried in the URL.
- [ ] Given a query with matches, when results render, then they are grouped by source (tools, tickets, wiki, instructions, files), each group is separately keyboard-traversable, and each result deep-links to its record.
- [ ] Given a source whose backend search is unavailable (wiki body search is not yet implemented), when results render, then that group shows an explicit degraded-source notice instead of silently reporting zero matches.
- [ ] Given a query with no matches in any group, when results render, then the page shows zero-results guidance listing what is searchable and offers to clear or broaden the query.
- [ ] Given results the caller may not view, when the search executes, then they are excluded server-side and their absence is indistinguishable from a genuine non-match.

## Notes

Plan sections: UX-PLAN §2.1 (palette and `/` search absorb the secondary destinations), §3.2 screen 51 (backend **P** — wiki body search missing), §4 (`SearchBox` / `GlobalSearch` contract), §6 (shortcut model), §9. Related stories: US-065 through US-071 define the underlying search capabilities this page federates, and US-071 is the wiki-body gap behind the degraded-source case; US-501 shares result ranking and keyboard conventions.
