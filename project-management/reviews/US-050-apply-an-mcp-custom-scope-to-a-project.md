# Review: Apply an MCP Custom Scope to a Project

- **Story**: `project-management/user-stories/US-050-apply-an-mcp-custom-scope-to-a-project.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Elixir backend, with one granularity deviation: scopes are applied at the account/org/client layer, not per-project. `MCPCustomScope` rows carry `user_id`/`organization_id` (deletion guards at `backend/lib/noizu_prompt_lingua/mcp_custom_scopes.ex:813-831` reference these; no `project_id` exists) and clients (MCP API keys / OAuth clients) each carry a `toolset_config` jsonb permission surface (`admin_controller.ex:1280-1293`). The enforcement machinery the story targets is real: `EffectiveToolset.resolve/4` cascades scope config → client config → per-user ACL deny layer (`backend/lib/noizu_prompt_lingua/mcp/effective_toolset.ex:9-21,130-146`); with a scope present, the include set is exactly the scope's groups (`effective_toolset.ex:149-157`); `MCP.ToolGuard.before_call` denies execution of `disabled: true` tools at call time in both shadow and enforce modes (`backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex:76-96`); and every scope write bumps the ToolsetCache and broadcasts `tools/list_changed` so in-flight sessions re-list (`mcp_custom_scopes.ex:834-842`). Custom per-group/per-tool selections persist as the scope's own config rather than a preset reference (`MCPCustomScopes.create/normalize_config`, `mcp_custom_scopes.ex:855+`). Tests exist (`backend/test/noizu_prompt_lingua/mcp/effective_toolset_test.exs`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Selecting a preset for a project updates the exposed tool list to exactly that preset | Partially Met | scope selection drives the include set exactly (`effective_toolset.ex:149-157`), but scoping attaches to account/org/client — no project-level scope application surface exists |
| Custom group/tool selection persists as its own selection, not a preset reference | Met | `MCPCustomScopes.create/update` persist normalized custom configs (`mcp_custom_scopes.ex:855+`); kind `custom` vs preset slugs are independent rows |
| Agent listing tools for the scoped project sees only permitted tools | Met | include-set resolution (`effective_toolset.ex:149-157`) + `tools/list_changed` broadcast on scope writes (`mcp_custom_scopes.ex:834-842`) |
| Removing a tool blocks an in-flight session on its next request | Met | `tool_guard.ex:76-96` — `disabled: true` denies execution (`:tool_disabled_forbidden`) regardless of authz mode, checked per call; cache bump propagates the new config |

## Gaps / Risks

- Project-level granularity is the story's premise and is not modeled: to restrict one project, an operator would scope a client/key or an org, not the project. Story should be re-scoped or a project→scope binding added.
- Cascade semantics are inverted by design ("a tool absent from every layer is ENABLED + VISIBLE", `effective_toolset.ex:10`) — safe only because a present scope constrains the include set; worth remembering when editing.
- Enforcement depends on the authz mode flip (`tool_guard.ex:25` mentions shadow vs enforce); verifying `:enforce` is active in production is a deployment concern, not a code guarantee.

## BDD Scenario

```gherkin
Feature: Restrict project MCP tools via a custom scope

  Scenario: Apply a preset selection
    Given an owner selects a scope for their account/client surface
    When an agent lists tools
    Then the include set is exactly the scope's configured groups and tools

  Scenario: Build a custom selection
    When the owner saves an individual group/tool selection
    Then it persists as the scope's own normalized config, independent of any preset

  Scenario: In-flight session loses a removed tool
    Given an agent session already connected
    When a tool is disabled in the scope and the write lands
    Then the toolset cache bumps and clients re-list (tools/list_changed)
    And a subsequent call to the removed tool is denied with :tool_disabled_for_key
```
