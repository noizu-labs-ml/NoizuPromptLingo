# Review: Assign a Custom Role to a Member

- **Story**: `project-management/user-stories/US-049-assign-a-custom-role-to-a-member.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No member→custom-role assignment exists. The membership surfaces only accept the fixed built-in ladder: `ScopedMemberships.add_member/update_role` validate roles against the canonical enum `owner|admin|lead|member|viewer` (`[Elixir backend] backend/lib/noizu_prompt_lingua/entities/authz/scoped_memberships.ex:24-58`), and `membership_controller.ex:36-54` passes caller-supplied roles through that same validation; the legacy `memberships` schema similarly restricts `role` to `owner|admin|editor|viewer` (`schema/organizations/membership.ex:17`). Grep across `backend/lib` finds no endpoint, schema field, or join linking a member to a `custom_roles` row — the only custom-role references are the two schema files and the role-CRUD controller (see US-048). Even if assignment existed, custom-role permissions are never consulted by the authz engine, so "permissions take effect immediately" has no enforcement path. The departed-member guard is likewise moot: there is no assignment flow in which it could fire. ([Elixir backend] = NoizuPromptLingo/backend.)

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Select a custom role on a member's detail page → assigned, permissions take effect immediately | Not Met | no assignment endpoint or UI: grep for custom-role assignment across `backend/lib` and `frontend/src` returns nothing; member roles restricted to the fixed enum (`scoped_memberships.ex:24`, `membership.ex:17`) |
| Assigning a different role replaces the prior role's permissions | Not Met | no prior custom-role assignment can exist; `update_role` handles only enum ladder roles (`scoped_memberships.ex:55-58`) |
| Assigning a role to a departed member is blocked with an explanatory error | Not Met | no assignment flow exists for the guard to attach to; `add_member` validates role enum only (`scoped_memberships.ex:28-30`) |

## Gaps / Risks

- Blocked on the missing join model: US-048's data model (roles + permissions) exists but has no member-assignment side; this story needs a `member_custom_roles` (or equivalent) table plus endpoints before any criterion can be attempted.
- Enforcement is the deeper gap: even with assignment, `Authz.check_permission/4` (`entities/authz.ex:51-72`) would need to union custom-role permissions into its verdict — otherwise assignment would be cosmetic.
- Departure semantics need a decision when designed: "left the org" maps to scoped-membership deletion, so the guard is naturally expressible then, but today no such check exists for any role type.

## BDD Scenario

```gherkin
Feature: Assign a custom role to a member

  Scenario: Assign a custom role (not implemented)
    Given Marcus views a member's detail page in his org
    When he selects the "Release Captain" custom role and confirms
    Then no such control or endpoint exists — member roles are limited to
    the built-in ladder (owner/admin/lead/member/viewer)
    And even a successful assignment could not affect permissions because
    the authz engine never reads custom-role permissions

  Scenario: Assign to a departed member (not implemented)
    When Marcus attempts to assign a custom role to a former member
    Then no assignment flow exists, so no blocking error can occur
```

(Scenario describes target behavior — none of it is executable today.)
