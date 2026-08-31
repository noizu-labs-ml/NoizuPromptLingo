---
id: US-027
title: "Similarity score on semantic results"
slug: similarity-score-semantic-results
personas: [P-003]
epic: "Search & Discovery"
priority: should-have
complexity: medium
tags: [search, semantic, ux]
---

# US-027: Similarity Score on Semantic Results

## User Story

**As an** ML fine-tuning engineer
**I want to** see a similarity score or percentage on each semantic search result
**So that** I can judge relevance at a glance and decide whether it's worth opening the thread before triaging it into my dataset

## Acceptance Criteria

- **Given** I run a semantic search
  **When** results render
  **Then** each result row displays a similarity score (e.g. "87% match") derived from the embedding cosine similarity

- **Given** results span a wide similarity range
  **When** the list renders
  **Then** results are sorted descending by similarity score and the score is visually de-emphasized (not overriding the snippet) for low-relevance matches below a reasonable threshold

- **Given** I hover/inspect a result's score
  **When** I want more precision
  **Then** the exact underlying similarity value is available (not just a rounded label), so Elena can consistently apply her own cutoff when triaging

## Notes
Elena needs this to efficiently triage large semantic result sets into gold/silver/bronze quality tiers — a bare ranked list without a visible score forces her to open every thread to judge relevance. Medium complexity: requires exposing the raw similarity metric from the vector search layer through to the UI consistently.
