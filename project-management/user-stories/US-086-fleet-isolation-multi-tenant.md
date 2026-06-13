---
id: US-086
title: "Fleet Isolation (Multi-Tenant)"
slug: "fleet-isolation-multi-tenant"
personas: [P-005, P-001]
epic: "Security & Compliance"
priority: "should-have"
complexity: "XL"
tags: [multi-tenant, isolation, security, fleet]
---

# US-086: Fleet Isolation (Multi-Tenant)

## User Story

**As an** IT Security Director (P-005),
**I want to** enforce strict data isolation between organizational tenants or business units,
**So that** fleet data, agent configurations, and telemetry from one tenant are never accessible to users of another tenant.

## Acceptance Criteria

- [ ] Given two separate tenant organizations exist, when a user from Tenant A authenticates, then all API responses, dashboards, and reports return only data scoped to Tenant A
- [ ] Given a tenant admin creates a fleet group, when it is saved, then the fleet group is invisible to all other tenants and does not appear in cross-tenant API queries
- [ ] Given platform admins require cross-tenant visibility, when they access the admin console, then they see an explicit tenant-selector that must be set before any tenant-scoped data is displayed
- [ ] Given I attempt to access another tenant's resource by guessing a resource UUID, when the API request is made, then the system returns 404 (not 403) to avoid information disclosure
- [ ] Given isolation is enforced, when I run the tenant isolation compliance check, then it reports zero cross-tenant data leakage events in the audit log

## Notes

Tenant isolation must be enforced at the database query level, not only at the API layer. Relates to US-085 (RBAC) and US-089 (compliance reports). This story covers the infrastructure requirement; UI-level tenant switching for MSP/reseller accounts is a separate story.
