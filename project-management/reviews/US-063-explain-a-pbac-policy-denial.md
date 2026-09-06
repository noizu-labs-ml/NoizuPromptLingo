# Review: Explain a PBAC Policy Denial

- **Story**: `project-management/user-stories/US-063-explain-a-pbac-policy-denial.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements `POST /policies/explain` (`backend/lib/noizu_prompt_lingua_web/router.ex:709`) via `Authz.explain_permission/4` (`backend/lib/noizu_prompt_lingua/entities/authz.ex:143-176`), which returns `{allowed, reason, matching_statements}` with reasons `:explicit_deny`, `:explicit_allow`, `:implicit_deny`, `:role_allow`, `:not_a_member`, evaluated by the same `PolicyEvaluator` engine as `check` so the two endpoints cannot diverge (deny-wins ordering, `backend/lib/noizu_prompt_lingua/authz/policy_evaluator.ex:44-50`; consistency is an explicit design ruling in the `authz.ex:137-144` moduledoc). Limitations: the response lists only the *matching* (decisive) statements — policies evaluated but not decisive are not enumerated — and, like `check`, the subject is fixed to the authenticated caller. Note this story names Ilya (P-006) as actor, but explain explains Ilya's own access, not an arbitrary user's denial.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Returns the specific policy rule(s) that caused the deny | Met | `explain_permission/4` returns `matching_statements` with `:explicit_deny` reason (`authz.ex:143-176`; `policy_evaluator.ex:44`) |
| Distinguishes the deciding policy from ones evaluated but not decisive | Partially Met | deny-wins precedence means the returned reason identifies the decisive class (`policy_evaluator.ex:44-50`), but only matching statements are returned — non-matching/evaluated-but-ignored policies are not listed, so "evaluated but not decisive" items are not distinguishable individually |
| Explains "allow" results too, not only denials | Met | `:explicit_allow` (`policy_evaluator.ex:47`) and `:role_allow` fallback (`authz.ex:163-170`) both return the deciding basis for allows |

## Gaps / Risks

- Cannot explain another user's denial: no user-id parameter; admin diagnosing "why can't user X do Y" must impersonate or reproduce.
- Not-a-member case returns `matching_statements: []` with `:not_a_member` — correct but minimal diagnostics.
- Statement-level matching is all-or-nothing per response; no per-statement evaluated/rejected trace.

## BDD Scenario

```gherkin
Feature: Explain a PBAC decision

  Scenario: Deny with explicit policy
    Given a group policy with an explicit deny statement applies to Ilya
    When Ilya POSTs /policies/explain for that action/resource
    Then the response has allowed=false, reason=:explicit_deny, and the matching deny statement(s)

  Scenario: Deny with no matching policy
    Given no policy statement matches
    When Ilya requests an explanation
    Then the response distinguishes :implicit_deny (and :role_allow if the role ladder allows)

  Scenario: Allow result
    Given a policy explicitly allows the action
    When Ilya requests an explanation
    Then the response has allowed=true, reason=:explicit_allow, and the matching allow statement(s)
```
