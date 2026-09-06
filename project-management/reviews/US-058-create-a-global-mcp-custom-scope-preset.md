# Review: Create and Curate a Global MCP Custom-Scope Preset

- **Story**: `project-management/user-stories/US-058-create-a-global-mcp-custom-scope-preset.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements global custom-scope presets end to end: admin REST handlers in `backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex` — create (:1194-1208), clone ("duplicate", :1210-1230), update (:1232-1263), delete (:1265-1278) — over `NoizuPromptLingua.MCPCustomScopes` (`backend/lib/noizu_prompt_lingua/mcp_custom_scopes.ex`: `create` :737, `copy` :596-617, `update` :756-787 with cache bump, `delete` :813-847, catalog :1022, org/user exposure :565-590). Updates propagate to consumers because keys/projects resolve scope configs at request time and `update/3` bumps the cache; the delete path protects the default package and core variant from deletion. Frontend: `frontend/src/app/app/admin/mcp-custom-scopes/page.tsx`. Confidence: high — delete/update bodies read in full. The one gap is delete-time reference counting.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create preset (name, description, tool groups/tools), selectable by org owners | Met | `admin_controller.ex:1194-1204`; `mcp_custom_scopes.ex:565-590` (`list_for_user/1`, `list_for_organizations/1`) expose presets to org/user surfaces |
| Editing a preset's tool selection propagates to referencing projects going forward | Met | `admin_controller.ex:1232-1259` → `MCPCustomScopes.update/3` (`mcp_custom_scopes.ex:756-787`) mutates the single stored scope and bumps the cache; consumers resolve configs live (resolution cascade documented in `backend/lib/noizu_prompt_lingua/schema/mcp_api_key.ex`) |
| Deleting a referenced preset shows how many projects reference it before finalize | Partially Met | `MCPCustomScopes.delete/1` (`mcp_custom_scopes.ex:813-842`) guards default/core/default-per-org slugs with `{:error, :protected}`, but performs no reference count and asks no confirmation for freely deletable scopes |
| Duplicating a preset yields two independent presets | Met | `admin_controller.ex:1215-1230` → `MCPCustomScopes.copy/2` (`mcp_custom_scopes.ex:596-617`) inserts a new row copied verbatim; subsequent edits touch separate rows |

## Gaps / Risks

- No "N projects reference this preset" confirmation on delete — an in-use preset can be removed with only the default-scope guard in place.
- `update/3` carries an `actor_id` audit thread (confirmation for disabling core groups, `admin_controller.ex:1232-1238`), but delete has no equivalent actor stamping.

## BDD Scenario

```gherkin
Feature: Admin curates global MCP custom-scope presets

  Scenario: Create a preset
    Given Ilya is on the admin MCP custom scopes page
    When he creates a preset named "readonly-review" with selected tool groups
    Then the preset is stored and appears in org owners' selectable scope lists

  Scenario: Edit a referenced preset
    Given a project references preset "readonly-review"
    When Ilya adds a tool group to the preset and saves
    Then the project's next scope resolution picks up the updated tool set

  Scenario: Delete a referenced preset
    When Ilya deletes a preset referenced by projects
    Then deletion succeeds without showing a reference count (gap: story requires it)

  Scenario: Duplicate a preset
    When Ilya clones "readonly-review" into "readonly-review-v2"
    Then both presets exist independently and editing one leaves the other unchanged
```
