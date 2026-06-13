---
id: story-007
title: "Run periodic integrity validation on memory web"
persona: persona-the-guardian
priority: should-have
complexity: L
status: draft
---

# Run periodic integrity validation on memory web

**As** The Guardian,
**I want to** periodically scan the entire memory web for integrity violations — contradictions, orphaned links, metadata corruption, and unauthorized modifications,
**So that** degradation and attacks that bypass real-time checks are caught and remediated before they compound.

## Acceptance Criteria
- [ ] A scheduled integrity scan runs at configurable intervals (default: every 6 hours)
- [ ] Scan checks include: contradiction detection across all memories, orphaned association links, metadata schema compliance, checksum validation on memory content
- [ ] Each scan produces an `IntegrityReport` with violation counts by category, severity, and affected memory IDs
- [ ] Critical violations (>N contradictions, checksum failures) trigger immediate alerts to The Monitor and Human Operator
- [ ] Scans are incremental where possible — only re-checking memories modified since the last scan, with periodic full scans (default: weekly)
- [ ] Scan performance scales linearly — a 100K memory web completes incremental scan within 10 minutes

## Scenario: Clean incremental scan
- **Given** 500 memories were added or modified since the last scan, no integrity issues exist
- **When** The Guardian runs an incremental integrity scan
- **Then** an `IntegrityReport` is produced with zero violations, scan duration, and coverage statistics

## Scenario: Detecting post-hoc contradiction cluster
- **Given** a batch import (story-004) introduced 50 memories, 3 of which softly contradict existing memories missed during ingestion
- **When** The Guardian runs an integrity scan
- **Then** the 3 soft contradictions are identified, tagged with `contradiction_ref` links, and included in the `IntegrityReport` with severity `soft`

## Technical Notes
- Incremental scans track a `last_validated_at` timestamp per memory; full scans reset all timestamps
- Checksum validation catches bit-rot or unauthorized direct database modifications
- Consider a bloom filter for efficient "has this pair been checked" tracking during contradiction scans
- The integrity report should be stored as an artifact for historical trending (The Monitor uses these)

## Related Stories
- story-005: Real-time contradiction detection is the first line; integrity validation is the sweep
- story-006: Injection blocking is real-time; integrity validation catches what slipped through
- story-009: Monitor anomaly detection consumes integrity reports as a health signal
- story-010: Monitor health reporting includes integrity scan results in system dashboards
