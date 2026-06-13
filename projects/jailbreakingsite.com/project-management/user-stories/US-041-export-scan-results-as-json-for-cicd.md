---
id: US-041
title: "Export scan results as JSON for CI/CD"
slug: "export-scan-results-as-json-for-cicd"
personas: [P-007, P-003]
epic: "Defender — Results & Reporting"
priority: "should-have"
complexity: "M"
tags: [defender, results, export, json, cicd, automation]
---

# US-041: Export Scan Results as JSON for CI/CD

## User Story

**As a** DevSecOps engineer in a regulated industry (P-007),
**I want to** download or retrieve scan results as a structured JSON document,
**So that** I can programmatically process findings in CI/CD pipelines, feed them into internal dashboards, or archive them in my security data lake.

## Acceptance Criteria

- [ ] Given a scan has completed, when I call the API or click "Export JSON" in the UI, then I receive a JSON document following a documented, versioned schema.
- [ ] Given the JSON export, when I parse it, then it contains: scan metadata, configuration snapshot (excluding credentials), summary counts by severity, and an array of findings each with technique ID, severity, probe payload, model response, classifier reasoning, and mitigation references.
- [ ] Given the JSON schema is versioned, when I retrieve results from older scans, then the `schema_version` field in the response reflects the schema version at export time.
- [ ] Given I use the API, when I request JSON export with an `include_false_positives=true` query param, then false-positive findings are included in the output with an `is_false_positive: true` flag.
- [ ] Given I am on a paid plan, when I retrieve JSON via the API, then I can also retrieve in-progress scan results as a partial JSON stream rather than waiting for completion.

## Notes

JSON schema must be published and stable — breaking changes require a major version bump. This export format is the foundation for the SARIF export (US-042) and CI/CD gate integration (US-046). Partial streaming depends on the scan execution architecture.
