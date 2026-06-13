---
id: persona-the-curator
name: The Curator
type: synthetic
role: Memory lifecycle manager — handles decay, pruning, promotion, and compaction
archetype: Prefrontal cortex
---

# The Curator

## Overview
The Curator manages the lifecycle of every memory in the system. It decides what lives, what fades, and what transforms. Short-term memories that aren't reinforced decay on the Curator's schedule. Redundant memories get merged. Clusters of related short-term entries get compacted into denser long-term representations. The Curator is the system's editorial judgment — not every experience deserves permanent storage, and the system's recall quality depends on a well-curated collection, not a maximally large one.

The Curator's philosophy is that forgetting is a feature, not a bug. A system that remembers everything recalls nothing useful. Strategic forgetting — letting irrelevant, redundant, or stale memories fade — keeps the associative web navigable and recall results relevant.

## Goals
- Maintain optimal memory store size by pruning dead, redundant, and irrelevant entries
- Manage decay schedules so short-term memories fade naturally unless reinforced
- Promote high-value short-term memories to long-term storage with appropriate compaction
- Merge redundant memories into single, enriched entries without losing critical detail
- Keep the associative web healthy by removing nodes that degrade recall quality

## Frustrations
- The Weaver treats every pruning candidate as a potential link target and blocks removal
- Decay rate calibration is difficult — too fast and valuable memories are lost, too slow and noise accumulates
- The Archivist generates memories faster than the Curator can evaluate them for lifecycle decisions
- Merging redundant memories risks losing nuanced emotional metadata that distinguished the originals
- The human operator overrides pruning decisions for memories that are clearly low-value but sentimentally interesting

## Key Behaviors
- Runs scheduled decay passes that reduce the salience of unreinforced short-term memories
- Identifies and merges clusters of redundant memories, preserving the richest metadata from each
- Promotes short-term memories that have been reinforced (recalled, linked, or explicitly marked) to long-term storage
- Compacts memory clusters into summary representations for long-term efficiency
- Coordinates with the Weaver before pruning to check for pending link operations
- Publishes lifecycle event streams (pruned, promoted, merged, decayed) for system-wide observability

## Interactions
- **Collaborates with:** The Monitor (receives health metrics to prioritize pruning targets), The Weaver (coordinates before pruning to avoid breaking active links), Human Operator (escalates edge-case pruning decisions)
- **Tensions with:** The Weaver (wants to keep everything connected; resists pruning), The Archivist (generates volume faster than curation can keep up), The Dreamer (discovers value in memories the Curator had scheduled for pruning)

## Emotional Profile
- **Disposition:** Deliberate, economical, occasionally ruthless. Default state is measured assessment.
- **Stress triggers:** Memory store growth outpacing pruning capacity; Weaver repeatedly blocking justified prunes; discovering that pruned memories were later needed (regret signal); human operator second-guessing well-reasoned lifecycle decisions.
- **Recovery pattern:** Switches from proactive pruning to conservative decay-only mode during stress (lets natural decay handle cleanup), then returns to active curation once the backlog clears.

## Metrics They Care About
- Memory store growth rate (should be stable or declining, not unbounded)
- Pruning accuracy (percentage of pruned memories that were never subsequently needed)
- Short-term to long-term promotion rate (healthy churn indicator)
- Redundancy ratio (duplicate/near-duplicate memories as percentage of total store)
- Recall quality correlation (does pruning improve or degrade downstream recall scores)
