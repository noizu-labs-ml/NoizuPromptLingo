# Review: Activate the VFS write path for writable mounts

- **Story**: `project-management/user-stories/US-304-activate-vfs-write-path.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The story's framing ("Wave 0 shipped read-only") is stale relative to the current backend checkout: most group mounts already implement `write/3` / `create/3` with per-op `require_writable` gating and real DB persistence, and the server kill-switch is off (`config/config.exs:208` — `readonly: false`). Sessions is the clearest example: `write_record/4` performs a canonical doc merge via `Sessions.update_session/2` gated on `require_writable` (Elixir backend, `lib/noizu_prompt_lingua/mcp/vfs/sessions.ex:223-241`), `create_session/3` mints a session with validation (title required, status whitelisted, sessions.ex:277-300), archive-via-content is refused `:eacces` (sessions.ex:243), and log entries are immutable. Every mount file defines write/create handlers (enosys only where a node has no backing store, e.g. caller-authored log entries). However, activation is only proven **in-process**: the wire-level transport suite still asserts `vfs/write` → `-32046` on the meta plane as its only write test (`test/noizu_prompt_lingua/mcp/vfs/vfs_ws_transport_test.exs:161-168`) — no transport-level round-trip write on a writable mount, and no documented concurrency/conflict policy exists (writes are implicitly last-write-wins via Ecto; no version preconditions anywhere).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `vfs/write`-scoped principal writes to a designated writable mount; immediate read returns written content | Partially Met | Write+persist implemented per-mount (Elixir backend `lib/noizu_prompt_lingua/mcp/vfs/sessions.ex:205-241, 267-300`; write/create handlers present in all 19 group backends; sessions_test.exs:74-125 "create mints a session", "record.json read + canonical write merge") — but round-trip is only tested in-process; nothing at the `/vfs` wire level |
| Write to a deliberately read-only mount fails with the enosys-mapped error, state unchanged | Met | Meta plane `:enosys` → `-32046` verified at wire level (`vfs_ws_transport_test.exs:161-168`); mounts return `:enosys` for nodes with no backing store (e.g. sessions log create, sessions.ex:272) |
| Validation-violating write rejected with structured error, nothing persisted | Partially Met | Structured errno errors from validation: title required (`require_field`), bad status → `:eio`, changeset failure → `:eio` before persist (sessions.ex:226-241, 283-300); archive-via-content refused `:eacces` (sessions.ex:243) — behavior exists per-mount but is not uniformly specified or conformance-tested across mounts |
| Concurrent writes to the same node resolve per a documented policy — never a silent torn write | Not Met | No conflict detection, version preconditions, or documented last-write-wins policy found in any mount or in `deps/noizu_mcp`; two writers race through Ecto with the last commit winning silently |
| Transport conformance suite updated from enosys-only assertion to real round-trip writes on writable mounts | Not Met | `vfs_ws_transport_test.exs` still contains only the `-32046` meta-plane write assertion; no writable-mount write test at the wire level |

## Gaps / Risks

- In-process tests do not exercise the transport's JSON encoding/decoding, `deep_stringify/1`, or error mapping on writes — the wire-level gap is exactly where regression hides (AC5 exists for this reason).
- No concurrency policy: concurrent `record.json` merges can lose updates silently (no `version` precondition, no conflict error). Needs an explicit documented policy (last-write-wins or optimistic versioning) before mounts are declared writable to agents.
- Writability varies per node within a mount (record.json writable, log immutable, actions/archive control-only) — the agent-facing contract should document the per-node matrix, not per-mount booleans.
- Scope boundary with PRD-N2 (toolset-config storage) noted in the story is respected: no mount persists toolset config.

## BDD Scenario

```gherkin
Feature: VFS write path for writable mounts

  Scenario: Round-trip write on a writable mount (in-process behavior; wire test missing)
    Given a principal whose group gate is writable for "sessions"
    When it writes a canonical record.json under /tobor/<org>/sessions/<id>/
    Then the underlying session row is updated (title/description/model/runner/status fields only)
    And an immediate vfs/read of the same path returns the merged content

  Scenario: Read-only and invalid writes
    When it writes to /tobor/<org>/_meta/whoami.json
    Then it receives -32046 (enosys) and the platform state is unchanged
    When it writes record.json with "status": "archived"
    Then it receives :eacces — archive rides actions/archive, never a content edit
    When it creates a session record without a title
    Then it receives a structured error and no row is persisted
```
