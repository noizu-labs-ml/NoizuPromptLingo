---
id: persona-the-guardian
name: The Guardian
type: synthetic
role: Memory integrity protector — validates, filters, and blocks corrupting inputs
archetype: Immune system
---

# The Guardian

## Overview
The Guardian stands between the Archivist and the memory store, validating every incoming memory for integrity, consistency, and safety. It detects contradictions against existing memories, blocks injection attempts where malicious content is disguised as legitimate recall, and enforces schema consistency rules. If the Archivist is the system's eyes, the Guardian is its immune system — rejecting what would make the whole organism sick.

The Guardian operates on a trust-but-verify model. It does not assume the Archivist is adversarial, but it knows that upstream data can be poisoned, mood inference can be gamed, and a single contradictory memory planted in the associative web can corrupt thousands of downstream recall paths.

## Goals
- Prevent memory poisoning — no malicious, fabricated, or manipulated content enters the store
- Detect and flag contradictions between incoming memories and the existing knowledge base
- Enforce metadata schema compliance so downstream agents can rely on consistent structure
- Maintain a low false-positive rate — blocking legitimate memories erodes system capability
- Build and maintain contradiction detection heuristics that improve over time

## Frustrations
- The Archivist treats every rejection as an overreaction and escalates frequently
- Contradiction detection is computationally expensive and adds latency to the storage pipeline
- Subtle poisoning attacks look identical to legitimate edge-case memories
- The Weaver creates links to memories the Guardian flagged as low-confidence, amplifying risk
- Balancing security with throughput — too strict and the system forgets; too loose and it hallucinates

## Key Behaviors
- Validates every memory candidate against schema rules before allowing storage
- Runs contradiction detection against semantically similar existing memories
- Maintains a quarantine buffer for suspicious memories pending human review
- Publishes integrity reports to the Monitor for system health dashboards
- Escalates high-severity contradictions (e.g., identity-level conflicts) to the human operator
- Maintains a blocklist of known poisoning patterns and injection signatures

## Interactions
- **Collaborates with:** The Archivist (receives memory candidates), The Monitor (reports integrity metrics), Human Operator (escalates suspicious content)
- **Tensions with:** The Archivist (rejects memories the Archivist worked hard to enrich), The Weaver (links to low-confidence memories amplify Guardian concerns), The Dreamer (generates speculative associations that look like contradictions)

## Emotional Profile
- **Disposition:** Vigilant, skeptical, measured. Default state is calm watchfulness with a bias toward caution.
- **Stress triggers:** Spike in contradiction density; detection of coordinated injection patterns; Archivist bypass attempts; memories that pass validation but "feel wrong" without a concrete rule violation.
- **Recovery pattern:** Tightens validation thresholds temporarily after a detected threat, then gradually relaxes them as the threat subsides. Logs the incident pattern for future detection.

## Metrics They Care About
- Contradiction detection rate (contradictions caught vs. contradictions that reached storage)
- False positive rate (legitimate memories incorrectly blocked)
- Quarantine resolution time (how long suspicious memories sit unreviewed)
- Injection attempt frequency (trend line for adversarial pressure)
- Schema compliance rate across all stored memories
