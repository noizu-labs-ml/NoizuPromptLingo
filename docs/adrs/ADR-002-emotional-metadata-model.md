---
id: ADR-002
title: "Emotional Metadata Model (VAD + Simulated Hormones)"
status: accepted
date: 2026-05-27
---

# ADR-002: Emotional Metadata Model (VAD + Simulated Hormones)

## Context

The Robot Remembers treats emotional state as a first-class retrieval coordinate. When the system computes "emotional resonance" between the agent's current state and a stored memory, it needs a structured representation that is:

1. **Computable** — Distances and similarities must be calculable (no free-text sentiment).
2. **Comparable** — Two emotional states must be mappable to a common space for cosine/Euclidean distance.
3. **Expressive enough** — Must distinguish "frustrated and stuck" from "frustrated and energized" from "calm and bored."
4. **Assignable by LLM** — The Archivist (an LLM-powered agent) must be able to reliably assign values from conversation context.

The emotional metadata is not cosmetic. It is used in three critical paths:

- **Recall scoring:** Emotional resonance boosts candidate memories during winnowing (see ADR-004).
- **Hot index keying:** The Redis hot index is bucketed by emotional state regions (see ADR-001).
- **Dreamer clustering:** The Dreamer finds consolidation candidates partly by emotional similarity.

## Decision

Adopt a **7-dimensional emotional vector** combining two established models:

### Valence-Arousal-Dominance (VAD) — 3 dimensions

Based on Russell's circumplex model of affect, extended with Mehrabian's dominance axis:

| Dimension | Range | Captures |
|-----------|-------|----------|
| **Valence** | -1.0 to 1.0 | Positive/negative affect |
| **Arousal** | 0.0 to 1.0 | Activation/calm |
| **Dominance** | 0.0 to 1.0 | Control/helplessness |

### Simulated Hormonal Signals — 4 dimensions

Simplified proxies for affective states that the VAD model alone does not capture well:

| Signal | Range | Models |
|--------|-------|--------|
| **Cortisol** | 0.0 to 1.0 | Stress, urgency, alarm |
| **Dopamine** | 0.0 to 1.0 | Reward, breakthrough, satisfaction |
| **Oxytocin** | 0.0 to 1.0 | Trust, collaboration, bonding |
| **Serotonin** | 0.0 to 1.0 | Stability, steady-state contentment |

### Additional Derived Signals

- **Frustration index** (0.0 to 1.0): Computed from a sliding window over recent interactions, not a point-in-time reading. Captures sustained frustration that a single negative valence reading would miss.
- **Confidence** (high | medium | low): How certain the Archivist was about its emotional assessment. Ambiguous contexts default to neutral baselines with `confidence: low`.

### Emotional Resonance Computation

```
resonance = 1 - (cosine_distance(current_state_7d, memory_state_7d) / 2)
```

Where both vectors are `[valence, arousal, dominance, cortisol, dopamine, oxytocin, serotonin]`. The division by 2 normalizes cosine distance (range 0-2) to a 0-1 resonance score.

## Alternatives Considered

### Discrete Emotion Labels (Ekman's Basic Emotions)
- **Pros:** Simple to assign ("happy," "angry," "surprised"). Human-readable. Well-studied in NLP sentiment analysis.
- **Cons:** Cannot compute meaningful distances — is "angry" closer to "frustrated" or "disgusted"? Requires arbitrary similarity matrices. Missing composites (frustrated-but-energized). Only 6-8 labels lack the granularity needed for a retrieval coordinate system.

### Circumplex Model Only (Valence + Arousal, 2D)
- **Pros:** Simpler — two dimensions. Well-established in psychology. Easy to visualize.
- **Cons:** Cannot distinguish "stressed and overwhelmed" from "stressed and in control" (missing dominance). Cannot distinguish "frustrated alone" from "frustrated with a trusted collaborator" (missing social/hormonal dimensions). The Recall Agent needs more axes for useful emotional matching.

### Free-Form Tags
- **Pros:** Maximum flexibility. No schema constraints. New emotional concepts can be added without migration.
- **Cons:** Cannot compute distances or similarities. Tags like "a bit annoyed" vs "somewhat frustrated" vs "irritated" are synonyms that the system cannot relate. Defeats the purpose of emotional metadata as a retrieval coordinate.

## Consequences

- **Positive:** The 7-dimensional vector supports meaningful distance computation for retrieval. The hormonal signals capture states (urgency, trust, reward) that VAD alone misses. The model is simple enough for an LLM to reliably assign values — the Archivist just needs to output 7 floats + 1 float (frustration) + 1 enum (confidence). The fixed schema enables indexing and bucketing.
- **Negative:** The model is a simplification — real emotions are richer than 7 floats. The hormonal metaphor may mislead developers into thinking these model actual biochemistry (they are proxies). Assigning precise float values to emotional states is inherently noisy — the confidence field mitigates but does not solve this.
- **Risks:** If the Archivist's emotional readings are consistently inaccurate (e.g., always assigns neutral baselines), the emotional retrieval path degrades to noise. Calibration of the Archivist's emotional assessment prompts will be critical. Consider a feedback loop where the operator can correct emotional readings, which adjusts the Archivist's calibration over time.

## Related

- ADR-001: Three-Layer Storage Architecture — emotional vectors are stored in PostgreSQL (JSONB) and used for Redis hot index bucketing
- ADR-004: Dual Retrieval Modes — emotional resonance is the primary scoring mechanism for tangential insertion
- ADR-005: Hebbian-Like Weight Dynamics — emotional similarity is one of the edge weight factors
