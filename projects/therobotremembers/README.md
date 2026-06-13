# therobotremembers

**Project ID:** therobotremembers
**Domain:** therobotremembers.com
**Status:** Design Phase
**Value Prop:** Associative memory service for AI agents — recall driven by emotional resonance, not just semantic similarity.

## What This Is

An advanced agent memory service that goes beyond conventional RAG. Memories are stored with rich emotional and contextual metadata — simulated mood, arousal, valence, hormonal analogues (cortisol/dopamine-like signals), temporal context, collaborator identity, frustration level — creating a **free-association web** modeled after human episodic memory.

Retrieval isn't just "find the closest vector." It's multi-path: semantic similarity *and* emotional resonance *and* temporal proximity *and* relational weight. A memory of being frustrated debugging a Postgres connection pool might surface when the agent is frustrated with a broken time server — because the *emotional signature* matches, even though the *content* doesn't.

## How It Works

1. **Formation** — The Archivist observes conversations and events, extracts salient memories, attaches emotional/contextual metadata
2. **Enrichment** — Metadata is analyzed: mood spectrum, arousal level, valence, simulated hormones, context (who, what, when, why)
3. **Storage** — Memories are vector-embedded AND stored with relational metadata in a graph structure
4. **Association** — The Weaver builds weighted links between memories based on shared attributes, temporal proximity, emotional similarity
5. **Decay** — Short-term memories fade over time unless reinforced; the Curator manages lifecycle transitions
6. **Recall** — Multi-path retrieval: attributes + embeddings traced to related memories, winnowed, ranked, presented
7. **Reinforcement** — Successfully recalled memories and their association paths are strengthened; unused paths decay
8. **Consolidation** — The Dreamer runs background synthesis, finding unexpected cross-domain connections

## The Agent Ensemble

Eight synthetic agents operate the memory service as an ensemble, each with a biological analogue:

| Agent | Role | Analogue |
|-------|------|----------|
| **The Archivist** | Memory formation and enrichment | Sensory cortex |
| **The Guardian** | Integrity validation, contradiction detection | Immune system |
| **The Monitor** | Behavioral observation, mood tracking, health metrics | Nervous system |
| **The Weaver** | Association building, weight dynamics | Hippocampus |
| **The Curator** | Lifecycle management, decay, pruning, promotion | Prefrontal cortex |
| **The Dreamer** | Background synthesis, novel associations | Default mode network |
| **The Sentinel** | Access control, privacy, compartmentalization | Blood-brain barrier |
| **The Recall Agent** | Multi-path retrieval, ranking, winnowing | Conscious recall |

## Key Concepts

- **Emotional Metadata** — Mood, arousal, valence, hormonal analogues attached to every memory
- **Relational Weight** — Edge weights in the association graph that strengthen with use and decay with time
- **Emotional Resonance** — Recall boost when current agent state matches a memory's emotional signature
- **Denforcement** — Active weakening of memory links (opposite of reinforcement)
- **Consolidation** — Background process that merges, strengthens, and discovers patterns across memories
- **Winnowing** — Narrowing candidate memories to the most relevant subset before context injection

## Architecture

See `docs/ARCHITECTURE.md` for full system design.
See `docs/CONCEPTS.md` for the concept glossary.
See `design/SITEMAP.md` for the web UI structure.
See `assets/diagram.png` for the original whiteboard sketch.

## Project Structure

```
therobotremembers/
├── README.md                          # This file
├── assets/
│   └── diagram.png                    # Original system sketch
├── docs/
│   ├── ARCHITECTURE.md                # System architecture
│   └── CONCEPTS.md                    # Concept glossary
├── design/
│   └── SITEMAP.md                     # Web UI site map
├── project-management/
│   ├── personas/                      # 10 persona definitions
│   │   ├── index.yaml
│   │   ├── the-archivist.md
│   │   ├── the-guardian.md
│   │   ├── the-monitor.md
│   │   ├── the-weaver.md
│   │   ├── the-curator.md
│   │   ├── the-dreamer.md
│   │   ├── the-sentinel.md
│   │   ├── the-recall-agent.md
│   │   ├── human-operator.md
│   │   └── human-developer.md
│   ├── user-stories/                  # 30 user stories
│   │   ├── index.yaml
│   │   └── {NNN}-{slug}.md
│   ├── screens/                       # UX screen definitions
│   │   ├── memory-explorer.md
│   │   ├── memory-graph.md
│   │   ├── memory-timeline.md
│   │   ├── agent-dashboard.md
│   │   ├── agent-detail.md
│   │   ├── recall-console.md
│   │   ├── guardian-alerts.md
│   │   └── weight-tuner.md
│   └── components/                    # Reusable UI components
│       ├── emotion-badge.md
│       ├── memory-card.md
│       ├── agent-status-tile.md
│       ├── association-edge.md
│       └── weight-slider.md
└── app/                               # (future) Full-stack implementation
```
