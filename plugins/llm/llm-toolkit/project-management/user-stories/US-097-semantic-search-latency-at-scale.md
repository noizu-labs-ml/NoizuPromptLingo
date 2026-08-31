---
id: US-097
title: "Semantic search latency at scale"
slug: semantic-search-latency-at-scale
personas: [P-003, P-001]
epic: "Performance & Scale"
priority: must-have
complexity: high
tags: [performance, semantic-search, scale]
---

# US-097: Semantic Search Latency At Scale

## User Story

**As an** ML fine-tuning engineer
**I want to** get ranked semantic search results within about a second even against a huge corpus
**So that** mining the whole corpus for training examples stays practical rather than stalling my workflow

## Acceptance Criteria

- **Given** a corpus of 50,000+ indexed messages with MiniLM embeddings generated
  **When** Elena runs a semantic search query
  **Then** ranked results return in under approximately 1 second

- **Given** Marcus runs a semantic search across his combined 4-6 client repos' history
  **When** the corpus is large
  **Then** the UI shows a loading state for less than 1s before results render

- **Given** the corpus grows during an active indexing run
  **When** a semantic search is issued concurrently
  **Then** latency does not degrade beyond the ~1s budget (indexing writes don't block reads)

## Notes
High complexity — touches the vector/embedding index, the FTS5 keyword layer, and concurrent read/write access simultaneously. Elena's whole-corpus mining workflow is the primary stress case; Marcus's cross-client recall is the secondary one.
