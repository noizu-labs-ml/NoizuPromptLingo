---
id: US-011
title: "Add a new provider by implementing the trait"
slug: add-new-provider
personas: [P-005]
epic: "Provider Management"
priority: must-have
complexity: medium
tags: [provider, extensibility, rust, trait]
---

# US-011: Add a new provider by implementing the trait

## User Story

**As an** open-source contributor
**I want to** implement a new provider by following the `MediaProvider` trait pattern
**So that** I can add support for a new generation API

## Acceptance Criteria

- **Given** the `MediaProvider` trait with a clear interface
  **When** I implement the trait for a new provider
  **Then** I only need to write the generation function and register it in `mod.rs`

- **Given** a reference implementation (`gemini.rs`)
  **When** I read it
  **Then** I understand the full request/response lifecycle including error handling and retries

## Notes
Reference: `src/providers/gemini.rs`. Trait is defined in `src/providers/mod.rs`.
