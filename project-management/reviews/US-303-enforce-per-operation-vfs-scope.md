# Review: Enforce per-operation vfs/read and vfs/write scope on every VFS operation

- **Story**: `project-management/user-stories/US-303-enforce-per-operation-vfs-scope.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Per-operation authorization is enforced end-to-end, but the model is **group-gate based** (EffectiveToolset cascade → per-group `included/visible/writable`), not literal `vfs/read` / `vfs/write` scope strings — no `vfs/read`/`vfs/write` scope tokens exist anywhere in the Elixir backend (grep: zero hits). Every dispatched op re-resolves the principal view (`Principal.view/1`, memoized per connection with 45s TTL + toolset-change invalidation, `lib/noizu_prompt_lingua/mcp/vfs/principal.ex:60-67`) and gates group subtrees (`Scope.gate/3`, scope.ex:45-54) and mutations (`require_writable`, scope.ex:58-59; per-mount copies e.g. sessions.ex:429-435). Deny-wins is real: an unresolvable principal fails closed with no group subtrees (principal.ex:59-66; gating_test.exs:171 "unresolvable principal fails closed"). What is read-only comes from the backend/meta plane returning `:enosys` and disabled-group mounts returning `:eacces` — not from a `vfs/write` scope claim. Coverage spans every mount via per-mount test files plus `gating_test.exs`, but there is no single shared per-mount allow/deny sweep.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Principal holding only `vfs/read` attempting `vfs/write` gets enosys `-32046` on the read-only backend, no data change | Partially Met | `vfs/write` on the read-only meta plane maps `:enosys` → `-32046` (`deps/noizu_mcp/lib/noizu/mcp/transport/vfs_ws.ex:277, 429-439`; test `vfs_ws_transport_test.exs:161-168`) — but this is the read-only *backend*, not a scope verdict; on group mounts a disabled-group write is `:eacces` (different code), and no `vfs/read`-only token kind exists |
| Principal without read access to a domain denied with error naming the missing scope | Not Met | Denied/unvisible groups return `:enoent` `-32002`, deliberately indistinguishable from absent (principal.ex:92-98 moduledoc; test `vfs_ws_transport_test.exs:170-173`) — denial exists but never names a missing scope (existence-leak avoidance by design; story premise conflicts with the design) |
| Allowed operations succeed without extra prompts/round trips | Met | Single dispatch path, gate resolution memoized (principal.ex:60-67); transport test chains 7 ops on one connection (`vfs_ws_transport_test.exs:119-180`) |
| Gating suite covers a denial and an allow path per mounted domain, not just one sample | Partially Met | Per-mount test files exist for every backend and assert `eacces`/`enoent`/`writable` behavior (spot-verified market/customers/artifacts/memory/github: 8-33 gate assertions each; sessions_test.exs:192-224 covers foreign-org :enoent + disabled-group :eacces), plus `gating_test.exs` (8 principal-level cases) — but coverage is per-file, not one uniform shared scenario set, so a mount can drift without a cross-mount regression sweep |
| Malformed/missing scope claim → deny-wins, never full access | Met | `Principal.view/1` fails closed — no resolvable client/scope yields no group subtrees (principal.ex:59-66, 124-142); `tool_gate/3` unknown tools fail closed (principal.ex:107-113); tested (`gating_test.exs:171, 191`) |

## Gaps / Risks

- Story premise mismatch: the implemented authorization currency is group gates from the EffectiveToolset cascade, not per-op `vfs/read`/`vfs/write` scope claims. Either the story should be reworded to the group-gate model, or scope-string support must be added to `DualTokenVerifier`/`Principal`.
- AC2's "error naming the missing scope" contradicts the deliberate `:enoent` existence-leak protection — recommend amending the criterion to accept indistinguishable absence.
- No single CI sweep asserting allow+deny uniformly across all 19 mounts; per-mount files can silently drift (this overlaps US-306's conformance-suite criterion).
- Denial code varies by mount state (`-32046` enosys on meta plane, `:eacces` on disabled groups, `-32002` enoent for excluded) — consumers need this documented to avoid misreading denials.

## BDD Scenario

```gherkin
Feature: Per-operation authorization on every VFS operation

  Scenario: Write denied on read-only plane (implemented today)
    Given an authenticated principal on the Wave 0 /vfs mount
    When it sends vfs/write against /tobor/<org>/_meta/whoami.json
    Then it receives error -32046 with errno_atom "enosys"
    And a following vfs/read confirms the content is unchanged

  Scenario: Excluded group is invisible; unresolvable principal fails closed (implemented today)
    Given a principal whose key scope excludes the "chat" group
    When it stats /tobor/<org>/chat
    Then it receives -32002 enoent, identical to a nonexistent path
    Given a token with no resolvable client/scope
    When it lists /tobor/<org>
    Then only the _meta plane is served and no group subtree appears
```
