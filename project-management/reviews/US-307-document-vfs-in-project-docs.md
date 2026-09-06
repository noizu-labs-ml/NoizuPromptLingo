# Review: Document the VFS substrate in PROJ-ARCH, PROJ-LAYOUT, and PROJ-SCHEMA

- **Story**: `project-management/user-stories/US-307-document-vfs-in-project-docs.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Verified gap, exactly as the story Notes state: a recursive grep for "VFS" across both documentation trees returns zero hits — the Python repo's `docs/` (PROJ-ARCH.md, PROJ-LAYOUT.md, PROJ-SCHEMA.md and their `.summary.md` companions) and the Elixir backend's own `docs/` directory contain no VFS coverage at all, despite Wave 0/Wave 1 substrate being implemented and conformance-tested in `backend/lib/noizu_prompt_lingua/mcp/vfs/` (server, router, root, scope, principal, pubsub, overview + 19 group backends) with transport wiring in `backend/lib/noizu_prompt_lingua_web/mcp_config.ex:74-91`. No other VFS documentation artifact (design MD, README section) was found that the PROJ docs could simply link; the design references cited in module moduledocs (`MCP-VFS-GROUP-MOUNTS.md`, design §-numbers) live outside both trees. Note this story's surface is documentation in this Python repo's `docs/`, but the substance to document is Elixir-backend code — the doc-update commands (`/update-layout-doc`, `/update-arch-doc`) operate here, so the story needs a dual-codebase approach when executed.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| PROJ-LAYOUT.md covers `backend/lib/noizu_prompt_lingua/mcp/vfs/` (server, router, root, scope, principal, pubsub, mounts) and the `/vfs` wiring in mcp_config.ex | Not Met | `grep -r "VFS" docs/` → no hits in either `docs/` tree (Python repo and Elixir backend `docs/`) |
| PROJ-ARCH.md describes VFSWS transport, vfs/auth handshake + DualTokenVerifier pipeline, per-op scope enforcement, read-only Wave 0 / write-path boundary | Not Met | No VFS content in PROJ-ARCH.md or `docs/arch/*`; only in-code documentation exists (module moduledocs, e.g. `vfs/server.ex`, `mcp_config.ex:64-91`) |
| PROJ-SCHEMA.md documents VFS node→entity mapping or explicitly documents VFS as a projection with no own schema | Not Met | No VFS content in PROJ-SCHEMA.md or `docs/schema/*` |
| `.summary.md` companions regenerated consistently via doc-maintenance commands | Not Met | Companion files unchanged; no VFS entries |
| Grep of `docs/` for "VFS" goes from zero to the entries above | Not Met | Currently zero hits in both trees — the AC's baseline holds but the delta has not happened |

## Gaps / Risks

- Dual-codebase trap: the docs commands maintain this Python repo's `docs/`, while everything to document lives in the Elixir backend — executing the story requires either adding backend coverage to these PROJ docs or creating backend-side docs and cross-linking; decide before running the generators or they will emit nothing.
- One stale-premise risk when writing the docs: the "read-only Wave 0" framing in sibling stories (US-304's notes) no longer matches the code — group mounts already implement gated writes with `readonly: false` in `config/config.exs:208`. Docs should describe the actual per-node writability matrix, not a blanket read-only statement.
- Rich in-code moduledocs exist and are high quality; the docs pass is largely distillation + cross-linking, not new research — low effort, but it will drift unless the doc-update commands are run after VFS changes (CLAUDE.md maintenance note applies).

## BDD Scenario

```gherkin
Feature: VFS substrate documented in project reference docs

  Scenario: Reviewer onboards from the docs (aspirational — zero coverage today)
    Given a reviewer opens docs/PROJ-LAYOUT.md
    When they search for the VFS substrate
    Then they find the mcp/vfs/ module inventory and the /vfs transport wiring
    And PROJ-ARCH.md explains VFSWS, the vfs/auth handshake, the DualTokenVerifier pipeline, and per-op gating
    And PROJ-SCHEMA.md states that VFS nodes are projections of domain entities with no schema of their own
    And each claim's .summary.md companion carries the condensed entry

  Scenario: Today
    When a reviewer greps docs/ for "VFS"
    Then there are zero hits in both the Python repo docs and the Elixir backend docs
```
