# Review: Register a New Organization

- **Story**: `project-management/user-stories/US-037-register-new-organization.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend. `Organizations.create_organization_with_owner/2` inserts the org, adds the creating user as an `owner` scoped member (rolling back the org if membership insert fails), and provisions the TRP counterpart with a logged, non-fatal fallback (`backend/lib/noizu_prompt_lingua/entities/organizations.ex:169-207`). Slug uniqueness is enforced by DB-backed constraints mapped to changeset errors (both the base-table unique and the named index are declared, `backend/lib/noizu_prompt_lingua/schema/organizations/organization.ex:25-30`), and the web layer exposes creation via `organization_controller.ex:19`. Owner membership is queryable through `list_members` / `list_user_organizations` (`entities/organizations.ex:250-252, 209+`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Authenticated user submits unique name + slug → org created with them as owner | Met | `entities/organizations.ex:169-207` (insert + `ScopedMemberships.add_member(..., "owner", ...)`); web entry `backend/lib/noizu_prompt_lingua_web/controllers/organization_controller.ex:19` |
| Duplicate slug → validation error naming the conflict, no duplicate created | Met | `unique_constraint(:slug, name: :organizations_slug_key)` and `:idx_organizations_slug` both declared so violations become changeset errors rather than 500s (`schema/organizations/organization.ex:25-30`); slug is citext case-insensitive (`entities/organizations.ex:81-88`) |
| New org lists creator as sole member with owner-level permissions | Met | creator added with role "owner" (`entities/organizations.ex:177-183`); `list_members` returns scoped memberships (`entities/organizations.ex:250-252`) |

## Gaps / Risks

- Failure inside owner-membership creation deletes the org row but the story does not require transactional atomicity; a hard crash between insert and delete would orphan an org without an owner. Low probability, worth a constraint or status flag.
- TRP provisioning failure only logs a warning ("ops re-run required") — org exists locally but is unprovisioned upstream; ensure ops runbook exists.

## BDD Scenario

```gherkin
Feature: Register a New Organization

  Scenario: Successful registration
    Given an authenticated user with no existing org named "acme"
    When they submit the create-organization form with name "Acme" and slug "acme"
    Then an organization row is created with a fresh UUID
    And the user is recorded as the org's sole "owner" member

  Scenario: Slug conflict
    Given an organization with slug "acme" already exists
    When the user attempts to create another org with slug "acme" (any case)
    Then the unique constraint is surfaced as a changeset validation error
    And no second organization is created

  Scenario: Owner verification
    Given the org "acme" was just created by the user
    When they view the members settings
    Then list_members returns exactly one member: the creator, with role "owner"
```
