---
id: US-404
title: "Provision least-privilege scoped DB credentials via Infisical for DB-access services"
slug: "least-privilege-db-credentials-infisical"
personas: [P-006]
epic: "Database Access Services"
priority: "must-have"
complexity: "M"
tags: [db, secrets, infisical, least-privilege, k8s]
---

# US-404: Provision least-privilege scoped DB credentials via Infisical for DB-access services

## User Story

**As a** Platform Administrator (P-006),
**I want to** give each DB-access MCP service its own narrowly-scoped Postgres role — read-only where possible — with credentials flowing through Infisical into Kubernetes Secrets,
**So that** a compromise or bug in one service cannot write, migrate, or read beyond its mandate, and rotation never requires a code change.

## Acceptance Criteria

- [ ] Given a DB-access service (read-only query tool, introspection tool, write path), when deployed, then it connects with a dedicated Postgres role whose grants cover exactly its operations (SELECT-only for the read tools).
- [ ] Given the secrets flow, when the service boots, then credentials come from Infisical via the InfisicalSecret → k8s Secret pipeline — no credentials in env files, images, or source.
- [ ] Given a credential rotation, when performed in Infisical, then the service picks up the new credentials per the documented restart/sync behavior without code or chart edits.
- [ ] Given the read-only tool's role, when audited, then an actual write attempt under that role fails at the Postgres layer (defense in depth beyond tool-level checks in US-401).
- [ ] Given the legacy Python fleet's single `NPL_DB_*` credential, when the audit is done, then shared or over-privileged credentials are identified for replacement with per-service roles.

## Notes

The existing Python pool uses one env-configured credential (`NPL_DB_USER`/`NPL_DB_PASSWORD`, defaults "npl"/"npl") — acceptable for local dev, not for the MCP-facing surface. Follow the established flow: declarative `.infisical-secrets.yaml` → `infisical-populate-secrets` → Infisical → InfisicalSecret CRDs → k8s Secrets → Helm (per monorepo docs/secret-management.md). Liquibase retains its own migration role; agent-facing roles must never hold DDL rights.
