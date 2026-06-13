---
id: US-058
title: "Inter-Quest Dependencies"
slug: "quest-dependencies"
personas: [P-001, P-006]
epic: "Quest Engine"
priority: "could-have"
complexity: "L"
tags: [quest-engine, dependencies, unlock, prerequisites]
---

# US-058: Inter-Quest Dependencies

## User Story

**As an** indie AI game developer (P-001),
**I want to** declare prerequisite relationships between quests so some quests only unlock after others are completed,
**So that** I can construct layered quest chains and story arcs without gating logic scattered throughout my codebase.

## Acceptance Criteria

- [ ] Given quest B declared with `prerequisites: ["quest_a"]`, when `quest_engine.start("quest_b", player_id)` is called and `quest_a` is not yet completed for that player, then a `PrerequisiteNotMetError` is raised listing the blocking quest IDs.
- [ ] Given quest B with `prerequisites: ["quest_a"]`, when `quest_a` transitions to `"completed"` for a player, then `quest_engine.newly_unlocked(player_id)` returns a list containing `"quest_b"`.
- [ ] Given quest C declared with `prerequisites: ["quest_a", "quest_b"]`, when only `quest_a` is completed, then `quest_c` does not appear in `newly_unlocked()` results.
- [ ] Given a dependency graph where quest A requires quest B and quest B requires quest A, when `QuestEngine.register()` is called for either, then a `CircularDependencyError` is raised.
- [ ] Given quest B with `prerequisites: [{quest_id: "quest_a", require_branch: "hero_path"}]`, when `quest_a` completes on a different branch, then `quest_b` does not unlock.
- [ ] Given a player whose `quest_a` failed (not completed), when `quest_b` checks prerequisites, then the prerequisite is not satisfied and `quest_b` cannot be started.

## Notes

Aisha Patel (P-006) uses dependency chains to structure multi-act studio game narratives. Dependency validation runs at registration time for static deps and at start-time for player-specific state. Relates to US-054 for branch-conditional unlocking.
