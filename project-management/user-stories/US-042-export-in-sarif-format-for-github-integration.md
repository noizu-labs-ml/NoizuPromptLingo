---
id: US-042
title: "Export in SARIF format for GitHub integration"
slug: "export-in-sarif-format-for-github-integration"
personas: [P-007, P-003]
epic: "Defender — Results & Reporting"
priority: "could-have"
complexity: "M"
tags: [defender, results, export, sarif, github, devops]
---

# US-042: Export in SARIF Format for GitHub Integration

## User Story

**As a** DevSecOps engineer in a regulated industry (P-007),
**I want to** export scan results as a SARIF 2.1.0 file,
**So that** I can upload findings to GitHub Advanced Security and view LLM vulnerability annotations directly on pull request diffs alongside SAST and dependency scan results.

## Acceptance Criteria

- [ ] Given a completed scan, when I select "Export SARIF" or call the API with `format=sarif`, then I receive a valid SARIF 2.1.0 JSON file that passes GitHub's schema validation.
- [ ] Given the SARIF file, when it is uploaded to GitHub Code Scanning, then each finding appears as a code scanning alert with the technique name as the rule ID, severity mapped to GitHub severity levels, and the mitigation guidance in the alert description.
- [ ] Given findings do not have file/line associations (since LLM probes are not code), when the SARIF is generated, then findings are attached to a placeholder file (e.g., `llm-scan-target.txt`) with line 1 as location, which is standard practice for non-code scanners.
- [ ] Given I upload the SARIF to a GitHub Actions workflow, when the upload step runs, then alerts are visible in the Security tab within 60 seconds of upload.
- [ ] Given false positives are marked in Defender, when I export SARIF, then those findings are suppressed in the output (omitted, not `suppressed: true`) by default.

## Notes

SARIF rule definitions should map to catalog technique IDs to enable deduplication across scans. This story assumes familiarity with the GitHub Code Scanning SARIF upload action (`github/codeql-action/upload-sarif`). Built on top of the JSON export model from US-041.
