---
id: US-064
title: "Audit MCP API Key Usage Across Organizations"
slug: "audit-mcp-api-key-usage-across-orgs"
personas: [P-006]
epic: "Admin & Platform Operations"
priority: "could-have"
complexity: "M"
tags: [admin, audit, mcp, api-keys]
---

# US-064: Audit MCP API Key Usage Across Organizations

## User Story

**As a** Platform Administrator, Ilya Petrov (P-006),
**I want to** audit MCP-related API key usage across all organizations,
**So that** I can detect anomalous usage patterns, stale/unused keys, or potential credential leakage at a platform-wide level.

## Acceptance Criteria

- [ ] Given Ilya is on the admin API key audit page, when the page loads, then he sees usage data — last-used timestamp, request volume, associated org/project — for MCP API keys across all orgs, not just orgs he belongs to.
- [ ] Given Ilya filters the audit view by a specific org or by "unused in the last 90 days," when the filter is applied, then only matching keys are shown.
- [ ] Given Ilya identifies a key with anomalous usage, when he opens that key's detail view, then he sees a request history sufficient to investigate further.

## Notes

Read/investigation-focused. If a key needs to be revoked as a result, that action is out of scope for this story.
