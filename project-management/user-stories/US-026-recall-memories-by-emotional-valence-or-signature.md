---
id: US-026
title: "Recall memories by emotional valence or signature"
slug: "recall-memories-by-emotional-valence-or-signature"
personas: [P-002]
epic: "Agent Personas & Memory"
priority: "could-have"
complexity: "M"
tags: [memory, emotion, recall, affective]
---

# US-026: Recall memories by emotional valence or signature

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** query my memory store for entries matching a particular emotional signature,
**So that** I can specifically surface experiences like "what went wrong under pressure" rather than just topically similar ones.

## Acceptance Criteria

- [ ] Given Sable's memories each carry an emotional vector (valence/arousal/dominance plus cortisol/dopamine/oxytocin/serotonin markers), when it queries with a target signature such as low valence plus high cortisol, then the system returns memories ranked by proximity to that signature.
- [ ] Given a query that combines an emotional signature with a topic or keyword filter, when Sable runs the recall, then results satisfy both constraints, not just the emotional one.
- [ ] Given no memories fall within a reasonable distance of the requested signature, when the recall runs, then Sable receives an empty result rather than the nearest unrelated memories presented with no indication of poor fit.
- [ ] Given a returned memory, when Sable inspects the result, then the full emotional vector for that memory is included, not just an aggregate proximity score.

## Notes

Complements US-025 — same memory store, a different retrieval axis (affective vs. semantic). A future composite-query story could combine both axes in one call.
