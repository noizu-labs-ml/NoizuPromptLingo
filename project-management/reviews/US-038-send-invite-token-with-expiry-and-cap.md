# Review: Send an Invite Token with Expiry and Use Cap

- **Story**: `project-management/user-stories/US-038-send-invite-token-with-expiry-and-cap.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The token mechanics are fully implemented at the entity level on the Elixir backend: `create_invite_token/1` generates a random raw token, stores only its Bcrypt hash plus an 8-char `key_prefix`, and returns the raw token exactly once to the caller (`backend/lib/noizu_prompt_lingua/entities/organizations.ex:254-277`); `find_active_invite_by_raw_token/1` looks up by prefix and enforces `revoked == false`, `expires_at > now`, and `uses < max_uses` before constant-checking the hash (`entities/organizations.ex:280-297`); `increment_invite_uses/1` bumps the counter (`entities/organizations.ex:299-302`). The schema carries `token_hash`, `key_prefix`, `max_uses`, `uses`, `expires_at`, `revoked` (`backend/lib/noizu_prompt_lingua/schema/organizations/invite_token.ex:10-33`). However, no product surface exposes generation or redemption: the only invite reference in the web layer is `membership_controller.ex`, which adds members directly by email and never touches invite tokens, and no MCP tool wraps the entity functions.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Generate invite with expiry + use cap → hashed token stored, raw token shown exactly once | Partially Met | logic complete and correct (`entities/organizations.ex:254-277`: rand token, Bcrypt hash, raw returned by `create_invite_token`), but no UI/controller/MCP tool calls it, so no member-facing generation flow exists |
| Redeeming an exhausted token → clear "invite exhausted" error, no member added | Partially Met | exhausted tokens fail lookup and return `{:error, :invalid_token}` (`entities/organizations.ex:287-296`); redemption is correctly blocked, but the error is generic — the story's distinct "invite exhausted" vs "invite expired" messages are not differentiated |
| Redeeming an expired token → clear "invite expired" error even with capacity left | Partially Met | expiry enforced in the same lookup (`entities/organizations.ex:286`); same generic `:invalid_token` collapse of expired/exhausted/revoked/unknown |

## Gaps / Risks

- Security core is right (hashed storage, prefix-scoped lookup, bcrypt verify): no plaintext token ever persists. Good.
- `increment_invite_uses` is a separate call from redemption verification — a crash between verification and increment could over-issue; consider a conditional atomic update (`WHERE uses < max_uses`).
- Both error-distinction criteria hinge on redemption UX that does not exist yet; the redeeming side (US-039) will need `find_active_invite_by_raw_token` to return *why* a token failed.

## BDD Scenario

```gherkin
Feature: Send an Invite Token with Expiry and Use Cap

  Scenario: Generate a capped, expiring invite (entity level)
    Given an org owner calls create_invite_token with expires_at in 7 days and max_uses 5
    Then only token_hash and key_prefix are persisted
    And the raw token is returned exactly once in the result tuple

  Scenario: Exhausted invite
    Given an invite whose uses counter has reached max_uses
    When find_active_invite_by_raw_token is called with its raw token
    Then the lookup filters it out and returns {:error, :invalid_token}
    And no member is added

  Scenario: Member-facing generation and redemption (not available)
    Given the org owner is on the members page
    When they attempt to generate an invite through the app or MCP
    Then no controller action or MCP tool exposes invite generation
    And redemption flows remain unimplemented (US-039)
```
