# Review: Activate and conformance-test all per-domain VFS mounts

- **Story**: `project-management/user-stories/US-306-activate-and-conformance-test-domain-mounts.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

All 19 group backends are implemented, registered, and individually tested: `@group_backends` in `Root` maps artifacts, browser, campaigns, chat, clients, customers, github, instructions, market, markdown, memory, notifications, projects, pubsub, review, sessions, tickets, unicode, wiki (`lib/noizu_prompt_lingua/mcp/vfs/root.ex:58-78`), plus the `_npl` plane and `_meta`/overview nodes — and every backend has a per-mount test file under `test/noizu_prompt_lingua/mcp/vfs/` (19 `*_test.exs` files plus gating/dispatch/root/pubsub/transport suites), each asserting read, gate denials (`:enoent`/`:eacces`), and writable-state behavior (spot-verified: market 9, customers 15, artifacts 17, memory 8, github 33 gate-related assertions; sessions_test.exs:192-224 covers foreign-org :enoent + disabled-group :eacces). Stub-only surfaces consistently return `:enosys` rather than fabricating data (per-mount enosys counts 1-11, e.g. caller-authored log entries → `:enosys`, sessions.ex:272). What is missing is exactly the story's ask: **no explicit active/stub status anywhere** — the registry is a bare module map with no status metadata; there is no single shared conformance sweep that runs the same scenario set across all mounts (coverage is per-file with varying depth), and no maintained activation checklist on the delivery board (CI runs the per-mount files, so a regression does fail the build and name the failing test, but "mount activation state" is only inferable by reading 19 test files).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Mount registry carries an explicit active/stub status per mount | Not Met | `@group_backends` is a plain `%{"group" => module}` map (`root.ex:58-78`); no status field, annotation, or metadata exists for any mount |
| Each active mount passes a shared scenario set (listing, scoped read, denied read, write denial/round-trip) | Partially Met | Every mount has a test file exercising list/read/gates/writability, but scenarios are bespoke per file — no shared `Conformance` case template or macro runs a uniform set across all 19 backends; write round-trips are in-process only (see US-304) and no wire-level write test exists |
| Stubbed mounts return a consistent not-implemented error, never partial/fabricated data | Partially Met | Unimplemented nodes return `:enosys` consistently (e.g. sessions log create, sessions.ex:272) → `-32046` on the wire (`vfs_ws.ex:429-439`); however "stubbed" is nowhere enumerated, so consistency is spot-verified, not registry-guaranteed |
| Conformance sweep in CI fails the build naming the failing mount | Partially Met | Per-mount test files run in the backend test suite, so a regression fails CI and the test name identifies the mount — but there is no dedicated conformance sweep; naming depends on each file's test naming discipline |
| Mount activation state reported as a checklist on the delivery board, not inferred from file presence | Not Met | No registry, checklist, or report exists; activation state is only inferable by reading the map + test files |

## Gaps / Risks

- The gap the story was written to close is open: 19 mounts × bespoke test depth means "works on sessions, silently weaker on market" is still possible; a shared `ExUnit` case template (describe per mount, scenario list: readdir / gated read / denied read / write-denial-or-round-trip) over `@group_backends` would close most of it mechanically.
- Explicit status could ride the existing registry cheaply (e.g. `%{"group" => {module, status: :active | :stub}}`) and even surface in the `_meta/groups` descriptor plane (`root.ex:126-146` already stats/list a groups descriptor node).
- Wire-level coverage is transport-thin: only the transport suite drives `/vfs` over a real socket, and only for `_meta` + wiki listing + subscribe — per-mount wire conformance is none.

## BDD Scenario

```gherkin
Feature: Per-domain mount activation and uniform conformance

  Scenario: Registry-audited mount status (aspirational — current state is inference)
    Given the mount registry @group_backends with 19 entries
    When the conformance sweep runs per mount
    Then each mount executes the shared scenario set: readdir, scoped read, denied read (:enoent/:eacces), write denial (-32046) or round-trip
    And the report lists each mount as active or stub with the scenarios passed

  Scenario: Regression names the failing mount (partially true today)
    When a mount's gate or node behavior regresses
    Then that mount's test file fails in CI, identifying the mount — but no uniform sweep guarantees the other mounts still conform
```
