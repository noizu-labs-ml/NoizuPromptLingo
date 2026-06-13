---
id: US-093
title: "Annotate prompts with effectiveness notes and failure modes"
personas: [lin-zhao]
domain: prompt-archival
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to annotate prompts with effectiveness notes, failure modes, and recommended contexts so that my team builds shared understanding of what works, what breaks, and when to use each prompt configuration.

## Acceptance Criteria

- [ ] Each prompt version supports structured annotations with fields: effectiveness summary, known failure modes, recommended contexts, and contraindicated contexts
- [ ] Annotations are authored with attribution and timestamped — multiple team members can annotate the same version
- [ ] A "failure mode" annotation type links to specific eval results or incident reports that demonstrate the failure
- [ ] Annotations are searchable and appear in prompt comparison views alongside diff and performance data
- [ ] An annotation summary is auto-surfaced when a user selects a prompt version for restoration or cloning

## Notes

Annotations transform prompts from raw text into documented institutional knowledge. The failure mode documentation is especially valuable — knowing that "this code review prompt hallucinates false positives on Rust lifetime issues" saves the next person from rediscovering that the hard way. The structured format matters: free-text notes are useful but structured fields (failure modes, contexts) enable automated suggestions like "you're configuring a Rust project agent — note that prompt v3 has known issues with lifetime analysis." This feature is most valuable in team contexts but solo devs benefit too — future-you is a different person from present-you.
