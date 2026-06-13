---
id: story-004
title: "Batch process historical interactions into memories"
persona: persona-the-archivist
priority: should-have
complexity: L
status: draft
---

# Batch process historical interactions into memories

**As** The Archivist,
**I want to** ingest a batch of historical interactions and extract memories with retroactively computed emotional and contextual metadata,
**So that** agents can bootstrap their memory web from prior conversation logs without requiring real-time processing.

## Acceptance Criteria
- [ ] A batch endpoint accepts a chronologically ordered list of interactions with timestamps
- [ ] Emotional metadata is retroactively inferred from interaction content (text sentiment, topic shifts, session patterns)
- [ ] Contextual metadata (time-of-day, season, session boundaries) is computed from provided timestamps
- [ ] Batch processing produces progress callbacks (percentage complete, memories formed so far, errors)
- [ ] Duplicate detection prevents re-ingesting interactions that already have memories
- [ ] Batch jobs are resumable — a failed job can be restarted from the last checkpoint

## Scenario: Bootstrapping from 6 months of chat logs
- **Given** a batch of 10,000 interactions spanning 6 months, submitted via the batch API
- **When** The Archivist processes the batch
- **Then** memories are formed with retroactively computed emotional metadata, contextual metadata derived from timestamps, and context windows built from adjacent interactions in the batch

## Scenario: Batch job interrupted mid-processing
- **Given** a batch job processing 5,000 interactions fails at interaction 3,200 due to a transient error
- **When** the operator restarts the batch job with the same job ID
- **Then** processing resumes from interaction 3,201, and the final output includes all 5,000 interactions

## Technical Notes
- Retroactive emotional inference will be less accurate than real-time capture — tag these memories with `source: batch` and `emotional_confidence: inferred`
- Batch processing should throttle to avoid overwhelming The Guardian's validation pipeline
- Consider chunking large batches into sub-batches of 500 for checkpoint granularity
- The Weaver should be notified after batch completion to run association discovery on the new memory set

## Related Stories
- story-001: Real-time emotional metadata capture is the companion to retroactive batch inference
- story-003: Context windows in batch mode use adjacent interactions in the batch rather than real-time following turns
- story-005: Guardian validation must run on batch-ingested memories too, potentially with relaxed timing
- story-011: Weaver link creation should run a bulk pass after batch ingestion completes
