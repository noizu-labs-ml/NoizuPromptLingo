---
id: story-001
title: "Capture memory with emotional metadata"
persona: persona-the-archivist
priority: must-have
complexity: L
status: draft
---

# Capture memory with emotional metadata

**As** The Archivist,
**I want to** extract and attach emotional metadata (mood valence, arousal level, simulated hormone state) to each incoming memory at formation time,
**So that** memories are stored with the affective context needed for emotionally-weighted recall later.

## Acceptance Criteria
- [ ] Each memory record includes a `mood` object with valence (-1.0 to 1.0), arousal (0.0 to 1.0), and dominance (0.0 to 1.0)
- [ ] Simulated hormone levels (cortisol, dopamine, oxytocin, serotonin) are captured as normalized floats (0.0 to 1.0) at formation time
- [ ] A frustration index (0.0 to 1.0) is computed from recent interaction history and attached to the memory
- [ ] Metadata extraction completes within 200ms per memory for real-time ingestion
- [ ] Missing or ambiguous emotional signals default to neutral baselines with a `confidence: low` flag

## Scenario: Standard memory capture with clear emotional signal
- **Given** an agent interaction where the user expresses frustration about a recurring bug
- **When** The Archivist processes the interaction into a memory
- **Then** the memory is stored with negative valence (-0.6), high arousal (0.7), elevated cortisol (0.8), low serotonin (0.3), and frustration index (0.75)

## Scenario: Ambiguous emotional context
- **Given** an agent interaction with no clear emotional indicators (e.g., a factual lookup)
- **When** The Archivist processes the interaction
- **Then** the memory is stored with neutral baseline values (valence: 0.0, arousal: 0.3) and `confidence: low` on all emotional fields

## Technical Notes
- The emotional metadata schema should be versioned (start at v1) to allow future expansion (e.g., adding "curiosity" or "surprise" dimensions)
- Hormone simulation is a simplified model — not biologically accurate, but useful as recall weighting signals
- Depends on a shared `EmotionalMetadata` type definition used across Archivist, Weaver, and Recall Agent
- Consider using a sliding window of recent interactions (last 5-10) to compute frustration index

## Related Stories
- story-002: Attach contextual metadata enriches the same memory record with non-emotional context
- story-005: Guardian contradiction detection needs access to emotional metadata to detect mood-inconsistent memories
- story-022: Emotional recall by Recall Agent depends on this metadata existing
