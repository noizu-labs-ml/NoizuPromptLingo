# Review: Update Organization Name and Key Prefix

- **Story**: `project-management/user-stories/US-047-update-org-name-and-key-prefix.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Name updates work end-to-end; key-prefix updates exist only as an API-level capability with no UI and a format rule that contradicts the story. The org settings page saves `name` (+ `slug`) via `api.updateOrganization` and refreshes the org context so the switcher/header reflect the change (`frontend/src/app/app/[orgId]/settings/page.tsx:44-60`). The backend PATCH accepts `key_prefix` among its allowed attrs (`[Elixir backend] backend/lib/noizu_prompt_lingua_web/controllers/organization_controller.ex:91`) with schema validation `^[A-Z0-9]{2,16}$` and a uniqueness constraint (`schema/organizations/organization.ex:16-29`), but the settings UI exposes no key-prefix field at all (only Name + Slug, `page.tsx:90-104`), and the backend format *requires* uppercase — the story demands uppercase be *rejected*. Additionally, nothing generates resource keys from `org.key_prefix`: MCP API-key prefixes are derived from the raw key at mint time (`entities/mcp_api_keys.ex:35`) and ticket keys from the project slug (`domains/tickets/ticket_key.ex:20-31`), so the story's key-generation contract has no implementation to satisfy. ([Elixir backend] = NoizuPromptLingo/backend.)

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Owner changes display name → persisted and immediately reflected in org switcher/page header | Met | `frontend/src/app/app/[orgId]/settings/page.tsx:44-60` (save + `refresh` + `switchOrg`); backend update `[Elixir backend] organization_controller.ex:85-104`, `entities/organizations.ex:106-124` |
| Duplicate key prefix blocked inline with "prefix already taken", nothing persisted | Partially Met | DB-level uniqueness exists (`organization.ex:29` unique_constraint) and controller returns changeset errors (`organization_controller.ex:109-110`), but the settings UI has no prefix field to trigger the flow, and the message is generic "has already been taken" |
| Invalid prefix characters (spaces, uppercase, symbols) rejected with format error | Partially Met | Format validation exists (`organization.ex:19` `^[A-Z0-9]{2,16}$`) but is INVERTED vs the story — uppercase is mandatory, not invalid; no client-side pre-validation and no UI field |
| After prefix change, new resource keys use the updated prefix; old keys unchanged | Not Met | No key generation derives from `org.key_prefix`: MCP key prefixes from raw key (`entities/mcp_api_keys.ex:35`), ticket prefixes from slug (`ticket_key.ex:20-31`) |

## Gaps / Risks

- Spec conflict to resolve first: story says reject uppercase; schema says require `A-Z0-9`. One of them is wrong — decide before wiring any UI.
- The key-prefix story conflates the org's `key_prefix` field with per-entity key namespaces (MCP keys, tickets, projects each derive prefixes independently); the acceptance criterion as written cannot be satisfied by editing `organizations.key_prefix`.
- Authz floor for the update is `admin` (`organization_controller.ex:90`), not strictly owner — owners pass (rank 0 ≤ admin), but admins can also rename/re-prefix, which may or may not be intended for a "branding" story.

## BDD Scenario

```gherkin
Feature: Update organization name and key prefix

  Scenario: Rename the organization
    Given Marcus is an org owner on the org settings page
    When he changes the display name and saves
    Then the new name is persisted and the org context (switcher, header) refreshes with it

  Scenario: Edit the key prefix (not possible in the UI today)
    When Marcus opens org settings
    Then there is no key-prefix field — only Name and Slug are editable
    And the API would enforce ^[A-Z0-9]{2,16}$ (uppercase required), the opposite
    of the story's character rules

  Scenario: New keys adopt the prefix (no evidence found)
    When existing projects generate new resource keys after a prefix change
    Then nothing reads organizations.key_prefix — key prefixes come from raw keys
    and slugs, so the criterion has no implementing path
```
