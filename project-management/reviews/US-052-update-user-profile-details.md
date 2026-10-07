# Review: Update User Profile Details

- **Story**: `project-management/user-stories/US-052-update-user-profile-details.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the Elixir backend as a self-service PATCH endpoint: `UserController.update/2` handles `PATCH /users/me` (`backend/lib/noizu_prompt_lingua_web/controllers/user_controller.ex`, route in `router.ex`), applying a self-editable field set to the caller's own user record; `@self_assignable_roles ~w(user other)a` prevents self-service role escalation. Two material gaps. First, updates are applied via `Repo.update_all(set:)` rather than a changeset, so no validation or uniqueness checks run — a malformed email would be persisted, directly violating the validation criterion (and email is the one field the story calls out). Second, avatar is not implemented: the users schema has no avatar field (`backend/lib/noizu_prompt_lingua/schema/users/user.ex`) and `serialize_user` emits no avatar, so uploads have no target. Name propagation is only partially true: display name is a live lookup for member lists, but historical chat posts persist author-name strings at post time, and audit/activity entries are not rewritten, so old surfaces keep the prior name.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Display-name update reflected app-wide without re-login | Partially Met | self PATCH `/users/me` persists name (`user_controller.ex`); member lists read live rows, but historical chat posts embed the old name string and audit entries are not back-filled |
| Avatar upload renders in place of old avatar same-session | Not Met | no evidence found — no avatar field on the user schema (`schema/users/user.ex`), none in `serialize_user`, no upload endpoint |
| Invalid value (e.g. malformed email) → field-level error, nothing persisted | Not Met | updates use `Repo.update_all(set:)` bypassing changeset validation and uniqueness checks (`user_controller.ex`, `apply_updates`) — invalid values persist silently |

## Gaps / Risks

- `Repo.update_all(set:)` in the self-service path is both a correctness gap (no validation) and a security smell: any future field added to the writable set skips all changeset checks. Switch to `User.profile_changeset/2` + `Repo.update`.
- Uniqueness: with no changeset, a duplicate email via self-service edit would not be rejected (no unique-constraint error handling).
- Avatar needs a schema field, storage wiring, and serialization — currently unstarted.

## BDD Scenario

```gherkin
Feature: Self-service profile updates

  Scenario: Display name change
    Given Jordan is authenticated
    When he PATCHes /users/me with a new display name
    Then the change persists and member lists show it immediately
    But his historical chat posts still display the old name

  Scenario: Malformed email
    Given Jordan PATCHes /users/me with email "not-an-email"
    When the update runs
    Then the story expects a field-level validation error and no persistence
    But Repo.update_all applies it without validation, so the invalid value is stored
```
