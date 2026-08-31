---
id: US-018
title: "Switch default embedding model"
slug: switch-default-embedding-model
personas: [P-003, P-008]
epic: "Settings & LLM Provider Config"
priority: should-have
complexity: medium
tags: [settings, semantic-search]
---

# US-018: Switch Default Embedding Model

## User Story

**As an** ML fine-tuning engineer mining the corpus for training examples (Elena) or a multi-provider tinkerer optimizing for cost/quality (Yusuf)
**I want to** change the embedding model used for semantic search from Settings, with a clear warning about re-embedding
**So that** I can use a model better suited to my corpus or accuracy needs without accidentally corrupting my existing semantic search results

## Acceptance Criteria

- **Given** the user opens Settings' semantic search section
  **When** they select a different embedding model from the current one
  **Then** a warning is shown explaining that changing the model requires re-embedding all existing indexed content, with an estimate of scope (e.g. number of messages/conversations affected)

- **Given** the user confirms the model change
  **When** they proceed
  **Then** the new model is saved as the active embedding model and a re-embedding job is queued/started, with progress visible (reusing the pattern from US-002's initial index progress indicator)

- **Given** re-embedding is in progress
  **When** the user runs a semantic search before it completes
  **Then** results reflect only content that has been re-embedded so far, and the UI indicates that semantic search coverage is partial until re-embedding finishes (avoiding silently mixing old- and new-model vectors as if equivalent)

## Notes
Elena (P-003) cares about embedding model quality for training data mining accuracy; Yusuf (P-008) cares about resource footprint tradeoffs. Medium complexity because of the re-embedding job and the partial-coverage UX during the transition, not just the settings form itself.
