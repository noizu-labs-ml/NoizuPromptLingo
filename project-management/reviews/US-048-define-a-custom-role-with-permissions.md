# Review: Define a Custom Role with Named Permissions

- **Story**: `project-management/user-stories/US-048-define-a-custom-role-with-permissions.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Custom-role CRUD and permission management exist as a well-guarded REST surface, but the defined permissions are inert — nothing in the authorization engine reads them. `[Elixir backend] backend/lib/noizu_prompt_lingua/schema/organizations/custom_role.ex:6-24` defines org-scoped roles (`custom_roles` with a per-org name uniqueness constraint) and `custom_role_permission.ex` stores free-form named permission strings; `custom_role_controller.ex` provides index/create/show/update/delete plus add/remove-permission endpoints (`router.ex:963-968`), gated by viewer/read floors and an `organization:manage_settings` check (`custom_role_controller.ex:201-214`). However, the actual authorization facade `NoizuPromptLingua.Authz` (`entities/authz.ex`) evaluates a fixed role ladder (owner/admin/lead/member/viewer over `scoped_memberships`) plus policy documents — it contains zero references to custom roles or custom-role permissions (grep across `backend/lib`: custom_role appears only in the two schema files and the controller). So a role can be defined and edited, but editing its permissions changes nothing for anyone. ([Elixir backend] = NoizuPromptLingo/backend.)

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create role with unique name + named permissions; appears in org role list | Met | `[Elixir backend] custom_role_controller.ex:42-60` (create, `manage_settings`-gated), `:25-40` (index), permissions via `:145-172` (`add_permission`); org-scoped uniqueness `custom_role.ex:23` |
| Case-insensitive duplicate role name blocked with "role name already exists" | Not Met | uniqueness is DB-default case-sensitive (`custom_role.ex:23` unique_constraint, no citext/downcase index); error message is generic ("has already been taken" via `format_errors`, `custom_role_controller.ex:235-241`) |
| Editing a role's permissions immediately reflected for assigned members | Not Met | `custom_role_permissions` is never consulted by the authz engine — `entities/authz.ex:51-72` (`check_permission/4`) evaluates only the role ladder + policy overlay; grep: zero `custom_role` references in `backend/lib/noizu_prompt_lingua/authz/` or `entities/authz.ex` |
| Deleting a role assigned to members shows affected member count before finalize | Not Met | delete is a soft-deactivate with no member analysis (`custom_role_controller.ex:115-137` returns "Role deactivated"); no member-count lookup exists anywhere |

## Gaps / Risks

- The permission data is a decoy: an owner can grant a custom role permissions that have zero effect, which is worse than not having the feature — enforcement wiring (Authz consulting `custom_role_permissions` for members holding the role) is the missing half.
- Case-sensitivity gap means "Manager" and "manager" can coexist in one org, contradicting the story's dedupe rule.
- No member→custom-role assignment linkage exists at all (see US-049), so "members currently assigned that role" has no data model behind it — criterion 3 and 4 both block on that missing join.
- A schema-side delete cascade exists (`entities/organizations.ex:129-130` org delete cascades custom roles) but no member-impact reporting.

## BDD Scenario

```gherkin
Feature: Define a custom role with named permissions

  Scenario: Create a custom role
    Given Marcus is an org owner with manage_settings permission
    When he creates role "Release Captain" and adds permission "project:deploy"
    Then the role is saved org-scoped and appears in the org's role list

  Scenario: Duplicate name (partially enforced)
    When he creates another role named "release captain" (different case)
    Then the database accepts it — uniqueness is case-sensitive, contrary to the story

  Scenario: Permissions take effect (not implemented)
    Given a member holds the "Release Captain" role
    When Marcus removes the "project:deploy" permission
    Then nothing changes for that member — the authz engine never reads
    custom_role_permissions, so the updated set has no effect

  Scenario: Delete with member impact (not implemented)
    When Marcus deletes a role assigned to members
    Then the role is soft-deactivated with no affected-member count shown
```
