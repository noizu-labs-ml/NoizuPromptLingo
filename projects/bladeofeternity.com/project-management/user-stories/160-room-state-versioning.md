# US-160: Room State Versioning

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P0
**Epic:** Mutable World & Environment

## Story
As Dave, I want rooms to maintain a complete versioned history of their state changes in the GenServer so that I can audit what happened, compute diffs for returning players, support rollback for administrative purposes, and understand the causal chain of environmental events in any room.

## Acceptance Criteria
- [ ] Every room GenServer maintains a `versions` list of `%RoomVersion{version: integer, timestamp: datetime, actor_id: string | :system, change_type: atom, change_description: string, state_snapshot: map}` appended on every mutation
- [ ] `Room.current_version(room_id)` returns the current version integer; `Room.state_at(room_id, version)` returns the full state snapshot at that version
- [ ] `Room.diff(room_id, version_a, version_b)` returns a structured list of changes between two versions, grouped by category (objects, passages, environmental, structural)
- [ ] Version history is durably persisted: survives GenServer crashes and restarts; old versions are loaded on demand from storage rather than held in memory indefinitely
- [ ] Administrative interface exposes: `list_versions(room_id, limit, offset)`, `rollback(room_id, target_version, admin_id, reason)` — rollback creates a new version rather than rewriting history
- [ ] The `diff` function output is consumable by the AI narration system to generate "what changed since your last visit" prose (drives US-175)
- [ ] Change attribution is complete: every version records whether the actor was a player (with player_id), an NPC (with npc_id), or the simulation system (fire spread, decay, weather)
- [ ] Version compaction: rooms accumulate versions indefinitely; compaction merges old versions into summary snapshots at configurable intervals, preserving full history for the last N days and summaries beyond

## Notes
Dave will immediately recognize this pattern as event sourcing. The implementation should commit to event sourcing fully rather than a hybrid: the canonical room state is always derived from applying versions in sequence to the base state. This means `state_snapshot` in each version can be either a full snapshot (expensive but fast to access) or a delta (compact but requires replay). Recommend hybrid: full snapshot every N versions, delta in between, with configurable N.

The rollback mechanic deserves careful thought. In a shared world, rolling back a room to version 50 when it's currently at version 200 would erase 150 versions of legitimate player modifications. The correct behavior is: rollback creates a new version (201) whose state matches version 50's snapshot, with the audit reason recorded. History is immutable; rollback is a forward operation.

Change attribution is operationally valuable: when investigating a griefing incident ("someone burned down my shop"), Dave wants to see exactly which player set the fire, when, and what sequence of environmental events followed. Actor attribution at every version makes this possible.

For the LLM narration integration (US-175), the diff output needs to be structured for prompt consumption — not raw Elixir structs but a clean natural language intermediate: `[{:object_removed, "the mahogany bookcase"}, {:scorch_marks_added, "north wall"}, {:passage_blocked, :west, "collapsed rubble"}]`. The LLM receives this list and generates natural narrative. This is cleaner than giving the LLM raw state diffs.
