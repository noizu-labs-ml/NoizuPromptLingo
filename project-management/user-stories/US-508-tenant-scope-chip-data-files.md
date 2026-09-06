---
id: US-508
title: "See the active tenant scope on every Data and Files screen"
slug: "tenant-scope-chip-data-files"
personas: [P-004, P-006]
epic: "UX Foundations"
priority: "must-have"
complexity: "S"
tags: [ux, multi-tenancy, tenant-scoping, data, vfs, component-library]
---

# US-508: See the active tenant scope on every Data and Files screen

## User Story

**As an** Org Owner (P-004) whose rows sit alongside other organizations', with a Platform Administrator (P-006) enforcing the boundary,
**I want** a persistent scope chip on every Data and Files screen naming the org, project, and service or mount a result set came from,
**So that** nobody reads a query result or a file tree without knowing which tenant produced it.

## Acceptance Criteria

- [ ] Given any Data screen (services index, schema browser, SQL console, vector search, approvals, audit), when it renders, then the scope chip is visible in the page header showing the active org, project, and DB service.
- [ ] Given any Files screen (mount picker, tree browser, editor), when it renders, then the scope chip shows the active org, project, and VFS mount.
- [ ] Given the active scope changes (org switch, project filter, service or mount selection), when the change applies, then the chip updates in the same render as the results it labels — never a stale scope beside fresh data.
- [ ] Given a caller operating under an audited cross-tenant elevation, when results render, then the chip presents the elevated scope distinctly so the wider visibility is unmistakable.
- [ ] Given a screen-reader user, when the chip is read, then it announces the full scope as text rather than relying on color or position alone.

## Notes

The chip displays the boundary; it is not the boundary. Enforcement belongs to **US-403** (tenant-scoped DB tool results), which defines the scoping contract this chip reports and is therefore a hard dependency, and on the Files side to **US-303** (per-operation VFS scope). Plan sections: UX-PLAN §3.2 screen 57 ("Every Data screen carries the scope chip", backend **M**), §4 (`ScopeChip`: tenant / mount / db-service scope, always visible in Data and Files), §7 Phase 3 (whole Database Access Services epic is the gate).
