---
id: US-051
title: "Define Quest with Objectives and Stages"
slug: "define-quest"
personas: [P-001, P-002]
epic: "Quest Engine"
priority: "must-have"
complexity: "M"
tags: [quest-engine, quest-definition, objectives, stages]
---

# US-051: Define Quest with Objectives and Stages

## User Story

**As an** indie AI game developer (P-001),
**I want to** define quests declaratively with named objectives and ordered stages,
**So that** I can structure game progression without manually wiring state transitions in application code.

## Acceptance Criteria

- [ ] Given a quest definition dict with `id`, `title`, and a `stages` list, when `QuestEngine.register(quest_def)` is called, then the quest is stored and retrievable by ID without error.
- [ ] Given a registered quest with three stages, when `quest.current_stage` is accessed on a freshly started quest instance, then it returns the first stage in definition order.
- [ ] Given a stage definition with an `objectives` list, when each objective specifies `id`, `description`, and `required: true|false`, then `quest.objectives` returns all objectives with their required flag preserved.
- [ ] Given a quest definition missing a required field (`id` or `stages`), when `QuestEngine.register(quest_def)` is called, then a `QuestDefinitionError` is raised with a message identifying the missing field.
- [ ] Given a quest with mixed required and optional objectives, when `quest.required_objectives_complete()` is called, then it returns `True` only when all `required: true` objectives are marked complete.

## Notes

Foundation story for the Quest Engine epic. US-053 (quest state machine) and US-054 (branching quests) build on the data model introduced here. Elena Vasquez (P-002) requires that stage descriptions support rich narrative text, not just IDs.
