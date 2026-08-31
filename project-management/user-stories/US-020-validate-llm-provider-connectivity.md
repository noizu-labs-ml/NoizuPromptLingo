---
id: US-020
title: "Validate LLM provider connectivity"
slug: validate-llm-provider-connectivity
personas: [P-008]
epic: "Settings & LLM Provider Config"
priority: should-have
complexity: low
tags: [settings, validation]
---

# US-020: Validate LLM Provider Connectivity

## User Story

**As a** multi-provider agent tinkerer configuring alternate LLM endpoints
**I want to** click a "Test connection" action in Settings that sends a lightweight request to the configured provider
**So that** I know immediately whether my base URL, API key, and model name are correct before relying on them mid-workflow during a convert or simplify operation

## Acceptance Criteria

- **Given** the user has entered a base URL, API key, and model name in the LLM provider section
  **When** they click "Test connection"
  **Then** a lightweight request (e.g. a minimal completion or models-list call) is sent to the configured endpoint and the result is shown within the Settings page without navigating away

- **Given** the test succeeds
  **When** the result returns
  **Then** the UI shows a clear success indicator (e.g. green check with response latency)

- **Given** the test fails
  **When** the result returns
  **Then** the UI shows a specific error category — authentication failure (401/403), timeout, or unreachable host — rather than a generic "connection failed" message

- **Given** the test is run against a per-operation override (per US-019) rather than the global default
  **When** the user triggers "Test connection" from that override's row
  **Then** it validates that specific override's credentials, not the global default's

## Notes
Directly supports Yusuf's (P-008) habit of checking configuration before enabling/relying on it, mirroring how he checks context-budget reports before enabling skills in `skill-manage`. Low complexity: a single lightweight round-trip call plus error categorization, no persistent state changes.
