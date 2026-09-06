# Review: Operate platform data through the VFS file tree over the VFSWS transport

- **Story**: `project-management/user-stories/US-301-operate-platform-vfs-tree-over-vfsws.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The `/vfs` VFSWS transport is implemented and wire-level conformance-tested in the Elixir backend. `Noizu.MCP.Transport.VFSWS` (Elixir backend, `deps/noizu_mcp/lib/noizu/mcp/transport/vfs_ws.ex`) enforces bearer auth on the upgrade with 401 rejection before the socket exists (vfs_ws.ex:106-127), binds verified claims via the first-frame `vfs/auth` handshake into `Ctx.assigns.auth_claims` (vfs_ws.ex:188-239, 388-402), and dispatches `vfs/stat|list|read|write|create|remove|search|xattr` (vfs_ws.ex:274-282). NPL wiring is `vfs_plug_opts/0` (Elixir backend, `lib/noizu_prompt_lingua_web/mcp_config.ex:74-91`) mounting `NoizuPromptLingua.MCP.VFSServer` with the same `DualTokenVerifier` pipeline as the MCP surface. The per-domain mount tree is served by `NoizuPromptLingua.MCP.VFS.Root` prefix-dispatching 19 registered group backends (`lib/noizu_prompt_lingua/mcp/vfs/root.ex:58-78`). End-to-end tests cover 401 on missing/bad token, handshake binding, JSON read round-trip, `vfs/write` → `-32046` on the read-only meta plane, excluded-subtree `:enoent`, and structured errors leaving the connection usable (`test/noizu_prompt_lingua/mcp/vfs/vfs_ws_transport_test.exs:108-203`). Confidence high. Remaining gap (also flagged in the story Notes): no agent/harness consumer exercises the tree outside the test suite.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Valid bearer token + `vfs/auth` handshake establishes connection; root listing shows per-domain mounts | Met | Elixir backend `deps/noizu_mcp/lib/noizu/mcp/transport/vfs_ws.ex:188-239` (handshake binds ctx); `lib/noizu_prompt_lingua/mcp/vfs/root.ex:58-78` (19 group backends registered); transport test `vfs_ws_transport_test.exs:119-180` asserts `_meta` + `wiki` listed on `/tobor/{org}` — listing is per-principal gated (a fully-scoped principal sees all mounts), which matches the security model |
| `vfs/read` on a JSON-backed node round-trips valid JSON matching the entity | Met | `vfs_ws_transport_test.exs:153-159` (whoami.json decoded, orgs match); sessions `record.json` read backed by local DB in Elixir backend `lib/noizu_prompt_lingua/mcp/vfs/sessions.ex` |
| Upgrade without valid token rejected 401 before any VFS operation | Met | `vfs_ws.ex:106-127` (bearer verify before `upgrade_adapter`); tests `vfs_ws_transport_test.exs:108-115` |
| Path outside mounted tree → structured error, connection remains usable | Met | `Scope.split_segments/1` rejects `.`/`..` traversal as `:enoent` (`lib/noizu_prompt_lingua/mcp/vfs/scope.ex:25-31`); wire maps to `-32002` with `errno_atom`; `dispatch/4` pushes the error frame without stopping (`vfs_ws.ex:242-272`) — test performs further ops after errors (`vfs_ws_transport_test.exs:161-179`) |

## Gaps / Risks

- No real agent/harness consumer exists outside tests (story Notes acknowledge this); the "agent-facing consumer story" remains open work.
- Root listing is per-principal: a principal whose key scope omits a domain never sees that mount. Correct by design, but the AC's "shows the per-domain mounts" only holds for a fully-scoped principal — consumer docs should state this.
- `vfs/auth` handshake re-verifies the token independently of the upgrade bearer token; a client could upgrade with token A and handshake with token B (both must verify). Intentional dual bind, worth documenting.

## BDD Scenario

```gherkin
Feature: Operate platform data through the VFS file tree over the VFSWS transport

  Scenario: Authenticated agent browses and reads the platform tree
    Given an MCP API key minted for an active user with a toolset scope including "wiki"
    When the agent opens a WebSocket to /vfs with "Authorization: Bearer <token>"
    And sends {"method": "vfs/auth", "params": {"token": "<token>"}} as the first frame
    Then the response is {"authenticated": true, "session_id": <sid>}
    And "vfs/list" on "/tobor/<org>" returns the gated per-domain mounts (_meta, wiki, ...)
    And "vfs/read" on "/tobor/<org>/_meta/whoami.json" returns JSON whose orgs equal [<org>]

  Scenario: Unauthenticated and out-of-tree access
    When a client requests the WebSocket upgrade without a bearer token
    Then the upgrade is rejected with 401 and no socket exists
    When an authenticated client requests "/tobor/<org>/<excluded-group>" or a traversal path
    Then it receives a structured error (-32002 enoent) and the connection stays open for further ops
```
