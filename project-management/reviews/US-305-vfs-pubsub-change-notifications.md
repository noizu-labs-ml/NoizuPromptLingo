# Review: Receive VFS pubsub change notifications on an open VFSWS connection

- **Story**: `project-management/user-stories/US-305-vfs-pubsub-change-notifications.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The substrate exists and is wired: `Noizu.MCP.Server.VFSPubSub` (Elixir backend, `deps/noizu_mcp/lib/noizu/mcp/server/vfs_pubsub.ex`) provides subtree watches over `{backend, path}` keys with 50 ms burst coalescing, a 10_000-watch per-subscriber cap (`:ewouldwatch` → `-32047`), metadata-only events, and process-monitored cleanup of dead subscribers (moduledoc + `watch/3` at :84, cap at :170-185). The transport exposes `vfs/subscribe` / `vfs/unsubscribe` and pushes `vfs/event` frames (op/path/version/by/at) (`deps/noizu_mcp/lib/noizu/mcp/transport/vfs_ws.ex:263-321, 333-347`); NPL asserts the hub runs in its supervision tree and registers a wire-level subscribe/unsubscribe round-trip (`test/noizu_prompt_lingua/mcp/vfs/vfs_ws_transport_test.exs:41-45, 192-203`) plus `pubsub_test.exs` at the unit level. But two load-bearing pieces are missing: **scope filtering** — watch registration takes no principal and event delivery runs no receiver-side gate, so any authenticated connection can watch (and receive metadata events for) paths outside its visible orgs/groups; and **reconnect catch-up** — no replay, seq-gap detection, or explicit "stale, re-read" signal exists (the moduledoc's contract is pull-based re-read, which is only safe if the consumer knows to do it). Additionally, on the current backend, publishes fire only from write/create/remove — so until US-304's wire path is exercised, no real mutation events flow in production.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Subscribed client receives a change notification with path and change nature when another client mutates a watched node | Partially Met | Mechanism complete end-to-end (subscribe → `VFSPubSub.watch` → debounced `vfs/event` frame with `op`/`path`/`version`, `vfs_ws.ex:263-310, 333-347`; publish hooked into Features.VFS mutation path per vfs_pubsub.ex moduledoc) — but events are **metadata-only** ("nature of the change" = op name only, no content), and no wire-level test asserts actual event delivery after a mutation |
| Change outside the receiving principal's scope is not delivered to that principal | Not Met | `VFSPubSub.watch(backend, paths, depth:)` takes no ctx/principal (`vfs_ws.ex:284-310`) and `handle_info({:vfs_event, ...})` pushes unconditionally (`vfs_ws.ex:333-347`); no scope check anywhere in vfs_pubsub.ex |
| Notification burst delivered without duplicates or unbounded queuing | Met | Per-`{backend, path}` coalescing: N writes in the 50 ms window produce one event carrying the final version; per-subscriber watch cap 10_000 → `-32047` (`vfs_pubsub.ex:46-49, 170-185`; vfs_ws.ex:300-302) |
| Reconnect applies documented catch-up behavior (replay or explicit stale signal) — never silent loss presented as freshness | Not Met | No replay buffer, seq-gap response, or stale signal; the only contract is "version is the pull trigger, subscribers re-read" (vfs_pubsub.ex moduledoc) with nothing that tells a reconnecting consumer it missed events |
| No spurious notifications on an idle connection | Met | Events are published only from actual write/create/remove bumps (`vfs_pubsub.ex:132-150`); keepalive uses WebSocket-level pings, not event frames (`vfs_ws.ex:349-363`) |

## Gaps / Risks

- **Security (cross-cuts US-303)**: `vfs/subscribe` is not gated against the connection principal — a connection whose key scope excludes a group can still watch that subtree and receive path/version/op metadata for mutations it could never read. Delivery-side filtering or a watch-time scope check is required before the surface is agent-facing.
- Contract ambiguity: events are at-most-once, metadata-only, and unsubscribed on disconnect (process monitor drops watches on DOWN) — fine if documented, but nothing today tells an agent that a gap occurred across a reconnect. A `seq`-based gap signal (client sees seq jump) is the cheap fix.
- On the read-only-effective backend no production mutations publish, so event delivery is currently test-only; story completion should include a wire-level mutation→notification test (depends on US-304's transport round-trip work).

## BDD Scenario

```gherkin
Feature: VFS pubsub change notifications over VFSWS

  Scenario: Subscribe and receive mutation event (mechanism implemented; delivery test missing)
    Given a connected, authenticated client subscribed to /tobor/<org> at depth infinity
    When a mutation under that subtree succeeds
    Then within ~50 ms the client receives one vfs/event frame
    And the frame carries seq, op ("write"), path, version, by, at — and no content

  Scenario: Burst and idle (implemented)
    When 20 rapid writes hit the same node inside one debounce window
    Then exactly one event with the final version is delivered
    And an idle connection receives no event frames, only keepalive pings

  Scenario: Scope-filtered delivery (not implemented — aspirational)
    Given a principal whose scope excludes the "chat" group
    When it subscribes to /tobor/<org>/chat
    Then the subscribe is denied (or events for that subtree are never delivered)
```
