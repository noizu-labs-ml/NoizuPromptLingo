---
id: story-011
title: "Create associative links between memories"
persona: persona-the-weaver
priority: must-have
complexity: L
status: draft
---

# Create associative links between memories

**As** The Weaver,
**I want to** automatically discover and create weighted associative links between memories based on semantic similarity, emotional resonance, temporal proximity, and shared context,
**So that** the memory web forms a navigable free-association graph rather than a flat list of isolated records.

## Acceptance Criteria
- [ ] Links are created between memories that exceed a configurable similarity threshold across any of: semantic embedding distance (<0.3), emotional metadata cosine similarity (>0.7), temporal proximity (<1 hour same session), shared topic/domain tags
- [ ] Each link has a `weight` (0.0 to 1.0) representing association strength, a `type` enum (semantic, emotional, temporal, contextual, causal), and a `formation_reason` description
- [ ] Links are bidirectional but may have asymmetric weights (A→B strength may differ from B→A)
- [ ] New memories trigger link discovery against the K nearest neighbors in embedding space (default K=50)
- [ ] Link creation is eventually consistent — may lag ingestion by up to 30 seconds under normal load
- [ ] The association graph maintains statistics: total links, average degree, clustering coefficient

## Scenario: Semantically related memories across sessions
- **Given** memory A from Monday discusses "Redis cache invalidation causing stale data" and memory B from Thursday discusses "cache TTL misconfiguration in the API layer"
- **When** The Weaver runs link discovery on memory B
- **Then** a link is created with type: "semantic", weight: 0.82, formation_reason: "both discuss cache invalidation patterns in infrastructure context"

## Scenario: Emotionally resonant memories with different topics
- **Given** memory A (frustration: 0.9, topic: "deploy failure") and memory B (frustration: 0.85, topic: "CI pipeline timeout") have very different semantic content but similar emotional signatures
- **When** The Weaver runs link discovery
- **Then** a link is created with type: "emotional", weight: 0.65, formation_reason: "high frustration co-occurrence across infrastructure operations"

## Technical Notes
- The K-nearest-neighbor search should use a vector database (Weaviate, Qdrant) for efficient similarity search at scale
- Link types are not mutually exclusive — two memories can have multiple links of different types
- Consider a minimum link weight threshold (e.g., 0.3) to avoid creating noise links
- The asymmetric weight feature is important: "I remembered X because of Y" doesn't imply "I'd remember Y because of X" with equal strength
- Link creation is the foundation of free-association recall — this is a critical-path story

## Related Stories
- story-001: Emotional metadata enables emotional-type links
- story-002: Contextual metadata enables temporal and contextual-type links
- story-003: Context windows help discover adjacency-based associations
- story-012: Weight adjustment refines link weights over time based on recall patterns
- story-022: Recall Agent traverses the association graph built by this story
