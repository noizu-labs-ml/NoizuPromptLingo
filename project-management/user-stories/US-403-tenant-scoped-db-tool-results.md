---
id: US-403
title: "Scope DB tool results to the caller's org/project tenant"
slug: "tenant-scoped-db-tool-results"
personas: [P-004, P-006]
epic: "Database Access Services"
priority: "must-have"
complexity: "L"
tags: [db, tenant-scoping, security, multi-tenancy]
---

# US-403: Scope DB tool results to the caller's org/project tenant

## User Story

**As an** Org Owner (P-004) whose data sits alongside other organizations' rows in shared Postgres, protected by the Platform Administrator (P-006),
**I want to** have every DB-access MCP call automatically confined to my org/project's rows,
**So that** a tool query — however malformed or adversarial — can never exfiltrate another tenant's data.

## Acceptance Criteria

- [ ] Given a DB tool call under an org-scoped session, when the query executes, then its visible rows are restricted to the caller's org/project (enforced at the query or role layer, not by prompt convention).
- [ ] Given a query that explicitly targets another org's identifiers, when executed, then it returns zero rows or an explicit denial — never the foreign rows.
- [ ] Given an Org Owner (or administrator acting with their authority) who legitimately needs cross-tenant visibility, when the request is made, then there is an explicit, auditable elevation path — never a silent default.
- [ ] Given the shared platform schema, when tenant filtering is implemented, then it composes with user-supplied WHERE clauses rather than being bypassable by them (no "filters are advisory" hole).
- [ ] Given the tenant-scoping tests, when run, then they include adversarial cases: subselects, CTEs, functions, and cross-table joins attempting scope escape.

## Notes

The shared Postgres serves multiple orgs/projects (see docs/PROJ-SCHEMA), so row-level confinement is the load-bearing control of this cluster. Prefer Postgres-native mechanisms (RLS policies or per-tenant roles) over application-side filtering, which is bypassable via SQL text. Statement timeout and row limits (US-401) bound cost; this story bounds visibility.
