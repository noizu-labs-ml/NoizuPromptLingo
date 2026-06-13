# US-152: Persistent World State Changes

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P0
**Epic:** Mutable World & Environment

## Story
As Dave, I want every environmental modification I make — kicking down doors, starting fires, blocking passages with debris — to persist across sessions and be immediately visible to all other players in the same zone, so that the world feels genuinely shared and my actions have lasting consequence.

## Acceptance Criteria
- [ ] Room GenServer maintains authoritative world state; all connected clients receive state-change broadcasts via Phoenix PubSub within 100ms of modification
- [ ] Environmental changes survive server restarts: GenServer state is checkpointed to durable storage (Mnesia or Postgres) on every mutation, and restored on init
- [ ] A versioned change log is maintained per room (`%RoomVersion{version: integer, changes: [ChangeEvent], timestamp, actor_id}`); version counter increments on every mutation
- [ ] Players entering a room for the first time in a session receive the current canonical state, not a stale cached description
- [ ] The "what changed since I was last here" diff is computable from version log: `Room.diff(room_id, last_seen_version, current_version)` returns a structured list of changes
- [ ] Environmental changes made by one player are visible in room descriptions for all other players immediately, with no client refresh required
- [ ] Zone administrators can view the full mutation history for a room: actor, action, timestamp, state before/after
- [ ] Changes to passageways (blocked, destroyed, opened) propagate to the room graph so pathfinding reflects current world topology

## Notes
Dave has deep MUD administration experience and will immediately notice if world state is inconsistent across clients or fails to survive restarts. The GenServer-per-room architecture is ideal here: each room process is the single source of truth for its state, eliminating race conditions by design.

The versioning scheme is critical for the "returning player diff" feature (US-175) and for administrative tooling. Design the `RoomVersion` struct to be forward-compatible — it will accumulate change types as new environment systems are added. Store the full before/after snapshot at each version point, not just a delta, so diffs can be computed without replaying history.

PubSub broadcast should use a typed message format: `{:room_state_change, room_id, version, %ChangeEvent{type, description, affected_objects, affected_passages}}`. Clients subscribe to room channels and apply change events to their local view incrementally, avoiding full-room re-renders on every change.

Consider the operational concern: a room that has been heavily modified over thousands of sessions will accumulate a large version history. Implement configurable history compaction: preserve the last N versions at full fidelity, archive older versions to cold storage, and maintain a "canonical baseline" snapshot that represents the compacted history for new player onboarding.
