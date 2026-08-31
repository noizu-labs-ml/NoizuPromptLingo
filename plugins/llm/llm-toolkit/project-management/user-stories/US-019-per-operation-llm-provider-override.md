---
id: US-019
title: "Per-operation LLM provider override"
slug: per-operation-llm-provider-override
personas: [P-008]
epic: "Settings & LLM Provider Config"
priority: could-have
complexity: medium
tags: [settings, llm-config]
---

# US-019: Per-Operation LLM Provider Override

## User Story

**As a** multi-provider agent tinkerer optimizing cost and quality per task
**I want to** set a different LLM provider for simplify versus convert operations rather than one global default
**So that** I can use a cheap/fast model for lightweight simplify calls and a stronger model for convert operations that produce durable artifacts

## Acceptance Criteria

- **Given** a global default LLM provider is already configured (per US-017)
  **When** the user opens the per-operation override section in Settings
  **Then** they can independently set a provider (base URL, API key, model name) for "simplify/summarize" and for "convert" operations, each defaulting to "use global default" if left unset

- **Given** an operation-specific override is set for convert but not for simplify
  **When** the user triggers a simplify operation
  **Then** it uses the global default provider, while convert uses its overridden provider

- **Given** the user removes an operation-specific override
  **When** they save
  **Then** that operation reverts to using the global default provider without affecting the other operation's override

## Notes
Could-have — deferred because the global provider setting (US-017) already unblocks Yusuf's (P-008) core cost-control need; this is a refinement for users who want finer-grained per-operation tuning, which is a smaller subset of the persona's workflow.
