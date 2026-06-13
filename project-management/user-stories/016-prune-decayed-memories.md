---
id: story-016
title: "Prune decayed and redundant memories"
persona: persona-the-curator
priority: must-have
complexity: M
status: draft
---

# Prune decayed and redundant memories

**As** The Curator,
**I want to** remove or archive memories that have decayed below the salience threshold and merge near-duplicate memories into consolidated records,
**So that** the memory web stays lean, storage costs are controlled, and recall is not polluted by redundant or irrelevant entries.

## Acceptance Criteria
- [ ] Memories with `salience < 0.1` and `decay_candidate: true` for >7 days are eligible for pruning
- [ ] Pruned memories are archived (moved to cold storage with full metadata preserved), not hard-deleted
- [ ] Near-duplicate detection identifies memories with >0.92 semantic similarity and overlapping metadata, flagging them for merge
- [ ] Merged memories combine the metadata of both (union of association links, max of emotional values, earliest timestamp preserved) into a single consolidated record
- [ ] Pruning runs weekly by default; merge detection runs after batch ingestion and monthly otherwise
- [ ] A pruning dry-run mode shows what would be pruned/merged without executing, for operator review

## Scenario: Standard decay-based pruning
- **Given** 45 memories have been `decay_candidate` for more than 7 days with salience scores between 0.02 and 0.08
- **When** The Curator runs the weekly pruning job
- **Then** all 45 memories are archived to cold storage, their association links are cleaned up (dangling references removed), and The Monitor is notified of the pruning event

## Scenario: Near-duplicate merge after batch import
- **Given** a batch import (story-004) creates 3 memories that all describe the same "Redis connection timeout" incident from slightly different conversation angles, with >0.93 semantic similarity
- **When** The Curator runs post-batch merge detection
- **Then** the 3 memories are merged into 1 consolidated record with the union of all association links, the highest emotional intensity values, the earliest timestamp, and `merge_sources: [id1, id2, id3]` in metadata

## Technical Notes
- Archival to cold storage enables "deep recall" if needed — pruned memories are recoverable
- Merge is destructive to the individual records — ensure the merged record faithfully represents all sources
- Pruning must coordinate with The Weaver to clean up orphaned association links
- Consider a "pruning budget" — maximum N memories pruned per cycle to avoid sudden graph topology changes that trigger Monitor anomalies

## Related Stories
- story-015: Decay scheduling produces the pruning candidates
- story-009: Monitor anomaly detection should be notified of pruning events to avoid false alarms
- story-012: Weaver link weight decay creates `prune_candidate` links that may need cleanup during memory pruning
- story-004: Batch ingestion often produces near-duplicates that need merging
