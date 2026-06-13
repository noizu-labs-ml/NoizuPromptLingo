---
id: US-054
title: "Branching Quest Paths Based on Choices"
slug: "branching-quests"
personas: [P-002, P-001]
epic: "Quest Engine"
priority: "should-have"
complexity: "L"
tags: [quest-engine, branching, narrative, choices]
---

# US-054: Branching Quest Paths Based on Choices

## User Story

**As an** interactive fiction author (P-002),
**I want to** define quests where player choices at stage boundaries route to different subsequent stages,
**So that** quests have meaningful narrative consequences rather than a single linear path.

## Acceptance Criteria

- [ ] Given a quest definition where a stage includes a `branches` list, each branch specifying `condition` and `next_stage_id`, when `instance.advance_stage(choice="betray_lord")` is called, then the instance transitions to the stage whose branch condition matches `"betray_lord"`.
- [ ] Given a stage with branches but no matching condition for the supplied choice, when `instance.advance_stage(choice="unknown_choice")` is called, then the instance follows the branch marked `default: true` if one exists.
- [ ] Given a stage with branches and no `default` branch, when `instance.advance_stage(choice="unknown_choice")` is called, then a `BranchResolutionError` is raised identifying the unmatched choice.
- [ ] Given a quest with a diamond-shaped branch (two paths converging on a final stage), when either path's last stage calls `advance_stage()`, then the instance correctly transitions to the shared final stage.
- [ ] Given a quest definition with a circular stage reference (stage A branches to stage B which branches back to A), when `QuestEngine.register(quest_def)` is called, then a `QuestDefinitionError` is raised identifying the cycle.
- [ ] Given a branched quest instance, when `instance.branch_history` is accessed, then it returns an ordered list of `(stage_id, choice)` tuples representing every branch decision taken.

## Notes

Depends on US-051 and US-053. Branch conditions can be string keys (matched literally) or callable predicates for code-driven evaluation. Relates to US-058 (inter-quest dependencies) where branch outcomes can unlock other quests.
