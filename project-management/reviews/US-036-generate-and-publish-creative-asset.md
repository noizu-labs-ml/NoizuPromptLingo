# Review: Generate a Creative Asset and Publish Its Active Output

- **Story**: `project-management/user-stories/US-036-generate-and-publish-creative-asset.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The full pipeline exists as MCP tools on the Elixir backend: `Asset.Generate` / `Asset.Regenerate` produce asset outputs (`backend/lib/noizu_prompt_lingua/domains/assets/tools/asset_generate.ex`, `asset_regenerate.ex`; `Assets.generate`, `assets.ex:140`), `Asset.OutputAccept` / `Asset.OutputReject` set output status `accepted`/`rejected` without deleting (`assets.ex:295-296`, schema inclusion list `backend/lib/noizu_prompt_lingua/schema/asset_output.ex:37`), `Asset.SetActive` points the entry's single `active_output_id` at a chosen output (`assets.ex:298-304`; `backend/lib/noizu_prompt_lingua/schema/asset_entry.ex:28`), and `Asset.Publish` sets the asset status to published (`asset_publish.ex`; `assets.ex:99`). Superseded outputs are retained as rows with terminal statuses, satisfying the retention requirement. Minor deviation: outputs are created with status `generated`, and "pending review" is handled by a separate `Asset.RequestReview` flow rather than an initial pending-review status.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Generate from prompt → new asset version in "pending review" status linked to the prompt | Partially Met | generation creates outputs tied to the entry with `eval_status`/`status` defaults (`asset_output.ex:16-17`); status vocabulary is `generated/accepted/rejected`, not "pending review"; prompt linkage via generation request args (`asset_generate.ex`) |
| Reject then regenerate → new version created, rejected version retained | Met | `reject_output` sets status `rejected` (`assets.ex:296`); regenerate creates a new output; no deletion path in the pipeline |
| Publish accepted version → single active output; previous active superseded but retained | Met | `set_active` updates `active_output_id` on the entry (`assets.ex:298-304`, one pointer = single active); `publish` sets entry status published (`assets.ex:99`); old outputs remain as rows |

## Gaps / Risks

- `SetActive` and `Publish` are separate operations; the story treats publish as the act that makes a version active. Confirm callers always pair them or fold set-active into publish.
- Terminology drift ("pending review" vs `generated` + `Asset.RequestReview`) should be reconciled in the story or the tool descriptions.

## BDD Scenario

```gherkin
Feature: Generate a Creative Asset and Publish Its Active Output

  Scenario: Generate, reject, regenerate
    Given a growth operator has a creative brief prompt
    When they call Asset.Generate with that prompt
    Then a new output is created for the asset entry in status "generated"
    When they call Asset.OutputReject on that output and Asset.Regenerate
    Then the rejected output remains in history and a new output exists

  Scenario: Accept and publish
    Given an accepted output for an asset entry
    When the operator calls Asset.SetActive with that output and then Asset.Publish
    Then the entry's active_output_id points at the accepted output
    And the entry status becomes "published"
    And any previously active output remains in history, superseded
```
