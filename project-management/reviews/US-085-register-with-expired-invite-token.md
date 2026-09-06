# Review: Block Registration on Expired or Exhausted Invite Tokens

- **Story**: `project-management/user-stories/US-085-register-with-expired-invite-token.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Only the data model exists. `InviteToken` schema/entities carry `max_uses` and `uses` fields (`lib/noizu_prompt_lingua/entities/organizations/invite_token.ex:23-24`, schema at `lib/noizu_prompt_lingua/schema/organizations/invite_token.ex`) and a bare repo module (`entities/organizations/invite_tokens.ex`, def_repo only). No code path redeems or validates an invite token: grep for `InviteToken`/`invite_token` finds no consumers outside the schema/entity modules; the registration flow (`OAuthController.register`) has no invite references; `membership_controller.ex` adds members directly via `ScopedMemberships.add_member` without tokens. There is consequently no expired-vs-exhausted messaging, no distinct error page copy, and no guarantee about partial records (nothing is created because redemption doesn't exist). Confidence: high (thorough grep of `lib/`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Expired token shows distinct "this invite has expired" message with guidance | Not Met | no evidence found — no redemption path exists |
| Exhausted token shows distinct "already been used" message, separate from expiry | Not Met | `max_uses`/`uses` fields exist (`entities/organizations/invite_token.ex:23-24`) but nothing reads them |
| No partial account/org-membership record created on failed attempt | Not Met | vacuous today — registration never consults invites; the guarantee is untested/unimplemented rather than satisfied |
| Non-English locale renders error copy without mojibake | Not Met | no error copy exists to render |

## Gaps / Risks

- The whole invite lifecycle (create → share → redeem → expire/exhaust) is missing a redemption endpoint; schema-first work stalled before any flow consumer.
- When implemented, wire the copy through the same i18n-safe rendering as US-093 to satisfy AC4 for free.

## BDD Scenario

```gherkin
Feature: Registration with an invalid invite link

  Scenario: Newcomer opens an expired invite link
    Given Tomás received an invite token whose expiry has passed
    When he opens the registration link
    Then no invite redemption path exists today; the token is never validated and no guidance message can be shown
```
