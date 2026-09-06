# Review: Fall Back to Read-Only When Operating on an Archived Project

- **Story**: `project-management/user-stories/US-088-archived-project-read-only-fallback.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The data model has an archive signal — `Project.archived_at` (`lib/noizu_prompt_lingua/schema/projects/project.ex:19`) and TRP-shaped rows carry it (`lib/noizu_prompt_lingua/trp/shapes.ex:73`) — but no read-only behavior attaches to it anywhere. No ticket, comment, or board code path checks `archived_at`/archived status before mutating; grep for `archived` across `lib/` finds only unrelated statuses (personas, memory, campaigns, ACL groups). Archive/unarchive themselves are explicit stubs returning `{:error, :trp_unsupported_shared_key}` (`lib/noizu_prompt_lingua/entities/projects.ex:87-89`), since project lifecycle lives on the external TRP service. There is no read-only mode, no banner/disable surface in the API responses, and critically no server-side enforcement for agent (P-002) writes — which the story itself flags as the spoofable hole.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Archived project's board renders read-only (banner + disabled controls) | Not Met | no read-only mode or response flag found; `archived_at` is exposed (`project_controller.ex:290`) but nothing consumes it |
| Mutating actions blocked client- and server-side with "project is archived" error | Not Met | no archived check in ticket/comment mutation paths (`lib/noizu_prompt_lingua/domains/tickets/`); no such error string exists |
| API/agent writes enforced read-only server-side | Not Met | MCP ticket tools perform no archived-project guard |
| Unarchive restores full access immediately | Not Met | `unarchive/1` is a stub returning `:trp_unsupported_shared_key` (`entities/projects.ex:88-89`) |

## Gaps / Risks

- Enforcement point matters: because projects live on TRP while tickets live locally, a guard must bridge both planes — a shared "ensure project mutable" helper called by ticket/comment mutations (and the MCP tools) is the natural seam.
- Status field vs `archived_at`: TRP exposes a status enum (`active|archived|deleted`, `mcp/projects/tools/project_update.ex:15`); pick one source of truth before implementing.

## BDD Scenario

```gherkin
Feature: Archived projects become read-only

  Scenario: Priya opens an archived project's board
    Given a project with archived_at set
    When Priya opens the ticket board
    Then no read-only mode exists today; the board renders and mutations are not blocked

  Scenario: Agent writes to an archived project via MCP
    When P-002 attempts a ticket update through the MCP tool
    Then the server performs no archived-project check and the write would proceed (server-side gap the story exists to close)
```
