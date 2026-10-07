# Review: Configure an Org-Level Media-Provider Config as Admin

- **Story**: `project-management/user-stories/US-061-configure-org-level-media-provider-as-admin.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements org-scoped media-provider (genai) config CRUD that an admin can perform on any org's behalf: `backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:1104-1166` (`list_media_providers/2`, `create_media_provider/2`, `update_media_provider/2`, `delete_media_provider/2`) over `backend/lib/noizu_prompt_lingua/domains/assets/media_providers.ex` and `schema/media_provider_config.ex:16-23` (organization_id/provider/modality/enabled/api_key/endpoint/default_model/settings). API keys are masked on output — `media_config_json/1` exposes only `api_key_set` (admin_controller.ex:1104-1106, ~1121). The missing piece is provenance: the schema has no updated-by/admin-audit field and `media_config_json` returns only `inserted_at`, so an org owner cannot see that a platform admin last changed the config. Frontend: `frontend/src/app/app/admin/media-providers/page.tsx`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Admin saves provider API key for the org → org's media-provider status shows "connected" same as owner-configured | Met | `create_media_provider` (`admin_controller.ex:1126-1137`) writes the same org-scoped config row the owner flow uses; `media_config_json` reports `api_key_set`/`enabled` as the connection status surface |
| Admin viewing an org's config sees the key masked, not plaintext | Met | `media_config_json/1` returns `api_key_set: c.api_key not in [nil, ""]` only; raw `api_key` never serialized (`admin_controller.ex:1104-1106` comment + body) |
| Org owner sees config was last updated by a platform admin, which admin, and when | Not Met | `schema/media_provider_config.ex:16-23` has no updated-by/actor field; `media_config_json` returns only `inserted_at` (no `updated_at`, no actor) |

## Gaps / Risks

- No actor attribution on admin-on-behalf-of writes: silent admin edits are indistinguishable from owner edits and from each other.
- Unlike US-057, no live "test key" action on media configs — a saved key's validity is only discoverable at generation time.

## BDD Scenario

```gherkin
Feature: Admin configures a media provider on an org's behalf

  Scenario: Admin saves an org's provider key
    Given Ilya is on the target org's media-provider admin page
    When he saves a provider API key for that org
    Then the org's config reports api_key_set = true / enabled, same as owner setup

  Scenario: Key masking
    When any admin lists the org's media-provider configs
    Then only api_key_set (boolean) is returned — never the key value

  Scenario: Update provenance
    When Ilya updates the org's key on their behalf
    Then no record of the acting admin or update time is exposed to the org owner (gap)
```
