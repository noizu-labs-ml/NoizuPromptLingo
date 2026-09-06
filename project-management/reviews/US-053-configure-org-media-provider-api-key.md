# Review: Configure a Media-Provider API Key for an Org

- **Story**: `project-management/user-stories/US-053-configure-org-media-provider-api-key.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Elixir backend. Org-scoped media-provider configs are full CRUD: admin endpoints list/create/update/delete per org (`backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:1108-1168`, routes at `router.ex:647-650`), backed by per-org provider config rows (`backend/lib/noizu_prompt_lingua/schema/media_provider_config.ex` — api_key stored verbatim with a unique constraint on org+provider) and the provider registry in `domains/assets/media_providers.ex:96-200` (`generate_opts(org_id, asset_type)` resolves the org's config into per-request provider options). Masking is done right: `media_config_json` never returns the raw key — it returns `api_key_set: c.api_key not in [nil, ""]` plus masked metadata (`admin_controller.ex:1940-1952`) — and the update path accepts an api_key replacement (`media_attrs`, `:1927-1938`), which `generate_opts` immediately uses for subsequent generation calls (`asset_controller.ex:98-108`). The one gap is validation: `media_attrs` performs no format check on the key, so a malformed key saves without error.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Valid key saves; provider shows "connected" for the org | Met | create/update persist per-org config (`admin_controller.ex:1126-1155`); `api_key_set` surfaces connected state (`:1940-1952`) |
| Invalid/malformed key rejected before persisting | Not Met | no evidence found — `media_attrs` (`admin_controller.ex:1927-1938`) applies no key format validation; any non-empty string saves |
| Key displayed masked, never plaintext, with replace option | Met | `media_config_json` returns `api_key_set` only, never the raw key (`admin_controller.ex:1940-1952`); update endpoint accepts a replacement key (`:1139-1154`) |
| Replacement key used by all subsequent generation calls; prior key unusable | Met | `generate_opts(org_id, asset_type)` reads the current config per generation request (`media_providers.ex:96-200`), wired into asset generation (`asset_controller.ex:98-108`) — old value is overwritten, not retained |

## Gaps / Risks

- No validation gate means a typo'd key persists and only surfaces as runtime generation failures; a cheap format/prefix check (or a live provider ping on save) would close the story fully.
- Storing keys verbatim in the `media_provider_config` table is acceptable given the masking discipline, but the table is a plaintext-at-rest credential store — encryption or a secrets-manager indirection would be the hardening step.
- Platform-admin equivalent (US-061) was out of scope here; the admin surface found is in fact an admin route, so the story's "self-service settings page" framing maps to admin-controller endpoints today, not an org-owner-facing page.

## BDD Scenario

```gherkin
Feature: Org-level media-provider API keys

  Scenario: Configure and use a key
    Given Renee saves a provider key for her org
    Then the config row persists with a unique org+provider slot
    And asset generation resolves options from that org's config per request

  Scenario: View settings
    When Marcus views the provider config
    Then he sees api_key_set=true and masked metadata, never the raw key
    And he can submit a replacement key

  Scenario: Malformed key
    Given Renee enters a malformed API key
    When she saves
    Then the story expects rejection before persistence
    But no validation exists, so the bad key is stored
```
