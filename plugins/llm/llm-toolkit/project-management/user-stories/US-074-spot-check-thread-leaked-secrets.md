---
id: US-074
title: "Spot-check thread for leaked secrets"
slug: spot-check-thread-leaked-secrets
personas: [P-005]
epic: "Admin & Oversight"
priority: should-have
complexity: medium
tags: [admin, security, safety]
---

# US-074: Spot-Check Thread for Leaked Secrets

## User Story

**As an** engineering lead auditing team AI usage
**I want to** scan a thread's collapsed tool-call blocks for likely credential/secret patterns without expanding every block manually
**So that** I can quickly spot-check a session for leaked API keys or passwords during my audit pass without reading the entire transcript

## Acceptance Criteria

- **Given** I am viewing a thread with collapsed tool-call/tool-result blocks
  **When** I click "Scan for secrets" in the thread viewer toolbar
  **Then** each collapsed block containing a likely credential pattern (e.g. AWS key format, generic API-key-shaped strings, `-----BEGIN PRIVATE KEY-----`) is marked with a warning indicator without auto-expanding the block

- **Given** a block has been flagged by the scan
  **When** I click the warning indicator
  **Then** the block expands and the specific matched substring is highlighted within it

- **Given** a thread has no matches
  **When** the scan completes
  **Then** the toolbar shows a clear "no matches found" state rather than leaving the result ambiguous

- **Given** the scan runs on a very long thread (hundreds of tool-call blocks)
  **When** I trigger it
  **Then** it completes and reports progress without freezing the thread viewer UI

## Notes
Daniel currently has to manually expand tool-call blocks one by one during audits; this pattern-scan closes that gap. Pattern matching should be conservative (flag-for-review, not auto-redact) since false positives are cheaper than missed secrets, and this only spot-checks — it doesn't replace judgment.
