# INTEGRATION-NOTES.md — F5 underscore-names (branch feat/underscore-names)

Contract: staging/TOBOR-CONTRACTS.md §4 (naming) + §2 (EffectiveToolset keyed by
canonical underscore name — consumed as-is by F2).

## What F5 changed (backend)

| File | Change |
|------|--------|
| `backend/lib/noizu_prompt_lingua/mcp/tool_names.ex` | NEW. `canonical/1`, `alias?/1`, `dotted/1`, `canonical_spec/1`, `canonical_specs/1`. Canonical = underscore; dotted = alias. |
| `backend/lib/noizu_prompt_lingua/mcp/server.ex` | `list_tools/3` normalizes specs to canonical names BEFORE hidden/disabled filtering + pagination — the wire `tools/list` payload never contains dots. |
| `backend/lib/noizu_prompt_lingua/mcp/dispatch.ex` | Name matching via `ToolNames.canonical/1` both sides; matched spec canonicalized so ToolGuard + KeyToolsets + error text see the underscore name. Dotted dispatch works. |
| `backend/lib/noizu_prompt_lingua/tools/catalog.ex` | `resolve_alias/1` now canonicalizes (was identity); `build/2` emits canonical names; `call_hidden_tool/4` canonicalizes specs before find — ToolCall hidden dispatch accepts dotted input. |
| `backend/lib/noizu_prompt_lingua/tools/tool_summary.ex` | `get_tool` resolves alias before catalog match. |
| `backend/lib/noizu_prompt_lingua/tools/tool_search.ex` | text search canonicalizes query so dotted queries match canonical names. |
| `backend/lib/noizu_prompt_lingua/tools/tool_call.ex` | description + `tool` arg description document underscore canonical form; dotted accepted. |
| `backend/lib/noizu_prompt_lingua/mcp/key_toolsets.ex` | `state_from_config` + `overlay_tools` probe tool keys in BOTH spellings (legacy dotted configs keep working against canonical lookups and vice versa). MINIMAL touch only — F2 is restructuring this module; reconcile at merge. |
| `backend/lib/noizu_prompt_lingua/mcp/custom.ex` | `group_specs` config lookups probe both spellings via new `tool_config_entry/2`. MINIMAL touch only — F2 restructures; reconcile at merge. |

## Key design facts for integrators

1. **Tool declarations stay dotted** (27 `use Noizu.MCP.Server.Tool` modules, e.g.
   `name: "Session.Create"`). The dotted registry name is the ALIAS SOURCE;
   canonicalization happens at the emission/dispatch seam, not per-module. Do not
   mass-rename tool modules at integration.
2. **DB config jsonb keys** (`mcp_custom_scopes.config`, `mcp_api_keys.toolset_config`)
   may hold either spelling; both are accepted at lookup. Existing dotted keys need
   no migration. W9/W2 should WRITE canonical underscore keys going forward
   (contract §7: overrides keyed by canonical name).
3. `Catalog.specs/2` intentionally returns RAW specs (dotted names) — it is the
   registry view (`Custom.catalog_specs/1` likewise). Canonical emission is in
   `Catalog.build/2` + `Server.list_tools/3` + `Dispatch.call/4`.

## F5's contract surface for later branches

- W5 Session.Manifest: tool names in the manifest payload MUST be canonical
  (`ToolNames.canonical/1` on whatever EffectiveToolset returns — contract §2
  already keys resolve/2 by canonical name, so pass-through).
- W9 name_override: overrides apply AFTER canonicalization; `name_override` value
  is emitted verbatim (author may pick any legal name), lookups still canonical.
- W8 per-client list_tools: route through `Server.list_tools/3` or re-apply
  `ToolNames.canonical_specs/1` after client-specific filtering.

## Tests

- NEW `backend/test/noizu_prompt_lingua/mcp/tool_names_test.exs` — mapping table
  (canonical/alias?), spec canonicalization, list_tools emits underscore-only,
  dispatch normalization (dotted ≡ canonical, unknown-tool still errors, dotted
  config keys honored).
- Updated emission assertions in `custom_key_toolset_test.exs` +
  `custom_scope_test.exs` (listing/discovery now canonical; dotted input proven
  still accepted at ToolDefinition/ToolHelp).
- Gate: `mix test test/noizu_prompt_lingua/mcp test/noizu_prompt_lingua/tools`
  → 115 + 3 passed (2026-08-31, this worktree).

## Submodule doc updates done

- `docs/arch/mcp-tools.md` — all tool-name tables swept to underscore; naming
  note added at top. (This was the only NPL-repo doc referencing dotted names.)

## Monorepo-level doc updates NEEDED (NOT done here — outside worktree)

Verified by grep 2026-08-31. Dotted NPL tool names ARE present:

1. `/Users/keithbrings/Work/Space/Noizu/CLAUDE.md` line ~30 — `ToolCall(tool: "Session.Create", arguments: {` in the FIRST-ACTION session-registration snippet → change to `"Session_Create"`.
2. `/Users/keithbrings/Work/Space/Noizu/AGENTS.md` line ~35 — same snippet, same change.
3. `Portfolio/skills/` (skills submodule — sweep to underscore form):
   - `foreman/` (12 files), `team-member/` (6), `persona-session/` (6), `qa-engineer/` (2), `agentic-project-manager/` (2), `prompt-optimizer/` (2), `pubsub-monitor/` (1).
   - Grep: `\b(Session|Project|Organization|Ticket|Task|Key|Client|Wiki|Chat)\.[A-Z][a-z]`.
   - Skills keep working pre-sweep (dotted = alias at dispatch).
4. `staging/TOBOR-CONTRACTS.md` — already canonical; no change.
5. Memory files under `~/.claude/.../memory/` quoting dotted NPL tool names — low priority, aliases keep resolving.
