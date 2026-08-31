---
id: US-015
title: "Fully local indexing and search"
slug: fully-local-indexing-and-search
personas: [P-001, P-005]
epic: "Privacy & Local-only"
priority: must-have
complexity: medium
tags: [privacy, local-only, security]
---

# US-015: Fully Local Indexing And Search

## User Story

**As a** power-user handling sensitive client code (Marcus) or an engineering lead responsible for the team's AI usage posture (Daniel)
**I want to** have indexing, keyword search, and semantic search all execute against local files/models with zero outbound network calls
**So that** I can trust that my (or my team's) conversation history never leaves the machine unless I explicitly configure an LLM provider for a specific operation

## Acceptance Criteria

- **Given** the background watcher, indexer, keyword search, and semantic search are all running
  **When** network traffic is monitored (e.g. via `lsof`/packet capture) during normal indexing and search usage
  **Then** zero outbound connections are observed for these operations

- **Given** no LLM provider has been configured in Settings
  **When** the user performs keyword search, semantic search, or browses threads
  **Then** all functionality works fully offline with no degraded state or network-dependent fallback

- **Given** the default MiniLM embedding model is used
  **When** semantic search runs
  **Then** embedding generation happens via the locally-run model, not a remote embeddings API call

- **Given** Daniel wants to verify this claim as part of his audit process
  **When** he runs the app with network access blocked at the OS/firewall level
  **Then** indexing and search continue to function normally, demonstrating no hidden dependency on connectivity

## Notes
This is the load-bearing privacy guarantee referenced by Settings' local-only statement (US-016) — Daniel (P-005) specifically watches for this as part of auditing team AI usage, and it should be independently verifiable, not just asserted in copy.
