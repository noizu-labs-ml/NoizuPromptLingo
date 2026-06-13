---
id: US-083
title: "Retrieve Scan Results via API"
slug: "retrieve-scan-results-via-api"
personas: [P-001, P-002, P-007]
epic: "API & Integration"
priority: "could-have"
complexity: "M"
tags: [api, defender, scan-results, automation, reporting]
---

# US-083: Retrieve Scan Results via API

## User Story

**As a** security engineer consuming scan data in downstream tooling (P-001, P-002, P-007),
**I want to** retrieve completed Defender scan results via the API in structured JSON,
**So that** I can ingest findings into SIEMs, ticketing systems, and compliance dashboards programmatically.

## Acceptance Criteria

- [ ] Given a completed scan, when I `GET /v1/scans/{scan_id}/results`, then I receive a structured JSON object with scan summary, per-finding details (technique ID, severity, evidence snippet, mitigation), and scan metadata
- [ ] Given scan results, when I inspect the findings array, then each finding references a catalog technique ID (linkable to `/v1/techniques/{id}`)
- [ ] Given I want a portable format, when I `GET /v1/scans/{scan_id}/results?format=sarif`, then a SARIF 2.1.0-compliant JSON document is returned for import into GitHub Advanced Security or other SARIF consumers
- [ ] Given a scan in `queued` or `running` status, when I request results, then a 202 is returned with a `Retry-After` header indicating when to check back
- [ ] Given a scan that failed, when I request results, then the response includes `error.reason` and any partial findings collected before failure
- [ ] Given scan results, when they are older than 90 days, then a `results_expiry` warning is included in the response envelope

## Notes

SARIF format output enables native integration with GitHub PRs, Azure DevOps, and IDE security overlays. Evidence snippets in findings must be truncated to avoid leaking full model responses in API logs. Depends on US-082.
