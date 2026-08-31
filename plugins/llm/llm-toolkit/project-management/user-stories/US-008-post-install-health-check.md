---
id: US-008
title: "Post-install health check"
slug: post-install-health-check
personas: [P-001, P-008]
epic: "Onboarding & Install"
priority: should-have
complexity: medium
tags: [onboarding, diagnostics]
---

# US-008: Post-Install Health Check

## User Story

**As a** power-user who relies on the tool working correctly across multiple providers/setups
**I want to** run a `llm-toolkit doctor`-style command that checks the index DB, background watcher, and local API
**So that** I can quickly confirm everything is wired up correctly after install or diagnose what's broken when search results seem stale

## Acceptance Criteria

- **Given** a working installation
  **When** the user runs `llm-toolkit doctor`
  **Then** it reports pass/fail for each of: index DB reachable, background watcher process running, local API responding — each on its own line with a clear PASS/FAIL marker

- **Given** the background watcher is not running
  **When** `llm-toolkit doctor` runs
  **Then** the watcher line reports FAIL with a specific reason (e.g. "process not found" vs. "running but not responding") and a suggested fix command

- **Given** all components pass
  **When** the command completes
  **Then** it exits with status code 0; if any component fails, it exits with a non-zero status code so it can be used in scripts/CI-style checks

## Notes
Yusuf (P-008) checks context-budget reports and cross-harness parity as part of his workflow — a doctor command extends that same "verify before trusting" habit to the core indexing pipeline; Marcus (P-001) would use it when search results seem out of date to rule out a stalled watcher.
