---
id: US-060
title: "CLI Search with JSON Output"
slug: cli-search-json-output
personas: [P-001, P-008]
epic: "CLI (Ink)"
priority: should-have
complexity: medium
tags: [cli, search, automation]
---

# US-060: CLI Search with JSON Output

## User Story

**As a** solo power-user developer (or multi-provider agent tinkerer)
**I want** `llm-toolkit search <query> --json` to return search results as structured JSON
**So that** I can pipe results into scripts or other tools instead of parsing human-readable terminal output

## Acceptance Criteria

- **Given** an indexed corpus
  **When** I run `llm-toolkit search "rate limit retry" --json`
  **Then** stdout contains valid JSON — an array of result objects with fields like thread id, project, snippet, score, and timestamp — and nothing else pollutes stdout

- **Given** the same query without `--json`
  **When** I run `llm-toolkit search "rate limit retry"`
  **Then** output is the existing human-readable formatted result list instead

- **Given** a query that matches zero results
  **When** run with `--json`
  **Then** stdout is a valid empty JSON array (`[]`), not an error or empty string

- **Given** I pipe the JSON output into `jq`
  **When** I run `llm-toolkit search "retry" --json | jq '.[0].thread'`
  **Then** it parses cleanly and extracts the expected field

## Notes

Yusuf pipes this into his own automation for tracking which sessions to feed into cross-harness workflows; Marcus uses it occasionally for scripted cleanup tasks across his client repos.
