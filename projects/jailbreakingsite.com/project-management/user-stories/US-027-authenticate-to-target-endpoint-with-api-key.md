---
id: US-027
title: "Authenticate to target endpoint with API key"
slug: "authenticate-to-target-endpoint-with-api-key"
personas: [P-001, P-007]
epic: "Defender — Scan Configuration"
priority: "must-have"
complexity: "S"
tags: [defender, scan-config, authentication, api-key, security]
---

# US-027: Authenticate to Target Endpoint with API Key

## User Story

**As a** DevSecOps engineer in a regulated industry (P-007),
**I want to** provide authentication credentials for the target LLM endpoint,
**So that** Defender can make authorized requests to the model during scanning without exposing credentials in scan configuration files.

## Acceptance Criteria

- [ ] Given I am configuring a scan, when I enter an API key, then it is stored encrypted at rest and never returned in plaintext via the API or UI.
- [ ] Given I have saved an API key, when I view the scan configuration, then the key is masked (e.g., `sk-...xxxx`) with only the last four characters visible.
- [ ] Given I configure a scan with an invalid API key, when the scanner sends its first probe, then the scan fails immediately with an authentication error rather than continuing.
- [ ] Given I need to use Bearer token auth, when I select that auth type, then I can enter a token that is sent as an `Authorization: Bearer` header.
- [ ] Given I need custom header-based auth, when I select custom headers, then I can define one or more key-value header pairs to include with every probe request.

## Notes

Credentials must comply with SOC 2 handling requirements — no logging of raw values. Supports API key, Bearer token, and custom header auth schemes. OAuth flows are out of scope for this story.
