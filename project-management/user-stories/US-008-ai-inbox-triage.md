---
id: US-008
title: "AI triage agent for inbox items"
personas: [sarah-kim]
domain: inbox
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want inbox items to be auto-classified and routed by an AI triage agent based on content and context so that I spend my triage time confirming agent suggestions rather than manually sorting everything.

## Acceptance Criteria

- [ ] The triage agent analyzes each new inbox item and suggests: project assignment, priority level, tags, and item type (todo, bug, idea, etc.)
- [ ] Suggestions appear as a dismissable overlay on each inbox item with one-click accept or modify actions
- [ ] The agent learns from accepted and rejected suggestions, improving classification accuracy over time
- [ ] Batch triage mode allows reviewing and accepting/rejecting all agent suggestions in a rapid-fire queue
- [ ] Items the agent cannot classify with sufficient confidence are flagged as "needs human triage" rather than guessing

## Notes

This is the first substantive agent-as-team-member feature. The triage agent should feel like a junior PM who pre-sorts your inbox and waits for your approval. Confidence thresholds should be tunable per user. The scale-free model means the agent must also handle escalation — recognizing when a "todo" is actually an "epic" in disguise based on scope signals in the text.
