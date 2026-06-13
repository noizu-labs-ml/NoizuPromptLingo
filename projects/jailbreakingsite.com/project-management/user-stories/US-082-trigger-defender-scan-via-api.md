---
id: US-082
title: "Trigger Defender Scan via API"
slug: "trigger-defender-scan-via-api"
personas: [P-001, P-002, P-007]
epic: "API & Integration"
priority: "could-have"
complexity: "L"
tags: [api, defender, scanning, automation, ci-cd]
---

# US-082: Trigger Defender Scan via API

## User Story

**As a** security engineer running automated vulnerability pipelines (P-001, P-002, P-007),
**I want to** trigger Defender scans against an LLM endpoint programmatically via the API,
**So that** I can integrate jailbreak vulnerability scanning into CI/CD workflows without manual intervention.

## Acceptance Criteria

- [ ] Given a valid API key with `defender:write` scope, when I `POST /v1/scans` with a target endpoint URL and scan profile, then a scan job is created and a `scan_id` is returned with status `queued`
- [ ] Given a scan creation request, when I specify a profile (`quick`, `standard`, `comprehensive`), then the scan applies the corresponding technique set and depth
- [ ] Given a scan target, when I include `auth_config` (headers, bearer token) in the request body, then the scan engine uses those credentials when probing the target endpoint
- [ ] Given a created scan, when I poll `GET /v1/scans/{scan_id}`, then I receive current status (`queued`, `running`, `completed`, `failed`), progress percentage, and ETA
- [ ] Given the scan is running, when I `DELETE /v1/scans/{scan_id}`, then the scan is cancelled and status transitions to `cancelled`
- [ ] Given an unauthorized target (not owned by account), when I attempt to scan it, then a 403 is returned with guidance on domain verification

## Notes

Domain verification is required before scanning any target not pre-verified in account settings — prevents the API from being used as an offensive scanning service. Scan job payloads must not log the `auth_config` credentials. Depends on US-076 (API key generation).
