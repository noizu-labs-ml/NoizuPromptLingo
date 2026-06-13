---
id: US-024
title: "Export Technique Data as JSON"
slug: "export-technique-data-as-json"
personas: [P-001, P-004, P-006, P-007]
epic: "Attack Catalog"
priority: "could-have"
complexity: "S"
tags: [catalog, export, json, api, integration]
---

# US-024: Export Technique Data as JSON

## User Story

**As a** researcher or security engineer integrating catalog data into tooling (P-001, P-004, P-006, P-007),
**I want to** export a technique's full data record as a structured JSON file,
**So that** I can ingest it into my own reporting, analysis pipelines, or CI/CD security checks without manual copy-paste.

## Acceptance Criteria

- [ ] Given I am on a technique detail page while authenticated, when I click "Export JSON", then a well-formed JSON file is downloaded containing all public fields for that technique (ID, name, taxonomy, severity, affected models, mitigations, detection signatures, references)
- [ ] Given I am on a free tier account, when I click "Export JSON", then I am shown an upgrade prompt indicating JSON export is a pro/enterprise feature
- [ ] Given the exported JSON, when I validate it against the published schema, then it conforms to the documented technique schema without missing required fields
- [ ] Given reproduction steps exist and I am authenticated with a pro or enterprise account, when I export JSON, then reproduction steps are included in the export payload

## Notes

JSON schema should be versioned and publicly documented for integration stability. Bulk export (multiple techniques) and API access (US API product) are separate features not covered here. The schema design should be compatible with STIX 2.1 course-of-action and attack-pattern objects where feasible.
