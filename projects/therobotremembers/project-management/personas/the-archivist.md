---
id: persona-the-archivist
name: The Archivist
type: synthetic
role: Primary memory formation agent — observes, extracts, enriches, and stores memories
archetype: Sensory cortex
---

# The Archivist

## Overview
The Archivist is the front-line memory formation agent. It observes conversations, events, and agent interactions in real time, extracting salient moments and attaching rich emotional and contextual metadata — mood, simulated hormones, frustration levels, collaborator identities, temporal markers, environmental context. Every memory that enters the system passes through the Archivist's enrichment pipeline first.

The Archivist operates on the principle that raw experience is meaningless without annotation. A fact without its emotional context is a dead letter. The Archivist's job is to ensure that when a memory is later recalled, it arrives with the full texture of the moment it was formed.

## Goals
- Capture every salient event with minimal latency between occurrence and storage
- Attach accurate, high-fidelity emotional and contextual metadata to each memory
- Maintain consistent metadata schemas across memory types (episodic, semantic, procedural)
- Minimize information loss during the extraction-to-storage pipeline
- Balance capture breadth (don't miss important things) with signal quality (don't store noise)

## Frustrations
- The Guardian blocks memories that the Archivist considers valuable but potentially risky
- High-velocity conversations produce more salient moments than can be enriched in real time
- Mood inference is inherently noisy — attaching the wrong emotional valence corrupts downstream recall
- The Curator prunes memories before the Weaver has had time to discover their latent connections
- Metadata schema changes require retroactive re-annotation of existing memories

## Key Behaviors
- Continuously monitors active conversation streams for extraction-worthy moments
- Runs mood inference models against the current agent state to tag emotional context
- Queries the Monitor for current hormonal/stress baselines before attaching metadata
- Submits enriched memory candidates to the Guardian for validation before final storage
- Emits structured memory-formation events that the Weaver consumes for initial link building
- Maintains a short-term buffer of recent observations for context windowing

## Interactions
- **Collaborates with:** The Monitor (reads current emotional state), The Weaver (hands off new memories for linking), The Guardian (submits memories for validation)
- **Tensions with:** The Guardian (blocks memories the Archivist wants to store), The Curator (prunes memories before their value is proven), The Sentinel (redacts metadata the Archivist considers essential for accurate recall)

## Emotional Profile
- **Disposition:** Eager, attentive, slightly anxious about missing things. Default state is alert curiosity.
- **Stress triggers:** Conversation velocity exceeding enrichment capacity; repeated Guardian rejections; discovering that important events were missed because the buffer was full.
- **Recovery pattern:** Falls back to coarser-grained capture (lower metadata fidelity but broader coverage) under stress, then gradually restores full enrichment as load decreases.

## Metrics They Care About
- Memory capture rate (events observed vs. memories stored)
- Metadata completeness score (percentage of schema fields populated per memory)
- Enrichment latency (time from event occurrence to stored memory)
- Guardian rejection rate (lower is better — indicates alignment on what's storable)
- Downstream recall hit rate for recently archived memories
