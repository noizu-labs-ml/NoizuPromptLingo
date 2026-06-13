---
id: US-058
title: "Follow a Structured Learning Path"
slug: "follow-structured-learning-path"
personas: [P-008, P-003, P-002]
epic: "Academy — Labs"
priority: "should-have"
complexity: "L"
tags: [academy, learning-paths, curriculum, progression, onboarding]
---

# US-058: Follow a Structured Learning Path

## User Story

**As an** ML engineer building agents (P-003),
**I want to** follow a curated learning path that sequences labs from foundational to advanced,
**So that** I build skills systematically rather than picking labs at random and encountering gaps in my knowledge.

## Acceptance Criteria

- [ ] Given I visit the Academy section, when I view the Learning Paths tab, then I see curated paths (e.g., "LLM Red Team Fundamentals," "Prompt Injection Defense," "Agent Security") each showing: description, lab count, estimated hours, difficulty progression, and prerequisite paths
- [ ] Given I enroll in a learning path, when I view the path detail, then I see a sequential list of labs with my completion status, with the next uncompleted lab highlighted and a "Continue Path" CTA
- [ ] Given I complete a lab that is part of my enrolled path, when the completion is recorded, then my path progress percentage updates and the next lab in sequence is surfaced
- [ ] Given a learning path has a final capstone lab, when I complete all prerequisite labs, then the capstone unlocks and I am notified
- [ ] Given I am enrolled in multiple paths, when I view my dashboard, then each path shows independent progress and I can switch between them without losing progress on either

## Notes

Learning paths are curator-authored, not algorithmically generated — quality and pedagogical coherence matter. Initial launch paths should cover at minimum: attacker fundamentals, defender fundamentals, and one intermediate path. Path enrollment is additive; users should not need to "choose" a single path.
