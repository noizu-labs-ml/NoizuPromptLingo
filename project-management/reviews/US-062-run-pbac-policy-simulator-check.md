# Review: Check a PBAC Policy Decision with the Simulator

- **Story**: `project-management/user-stories/US-062-run-pbac-policy-simulator-check.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend exposes `POST /policies/check` (`backend/lib/noizu_prompt_lingua_web/router.ex:708`) returning a clear allow/deny decision with action/resource echo (`backend/lib/noizu_prompt_lingua_web/controllers/policy_controller.ex:59-72`), evaluated by the shared PBAC engine (`NoizuPromptLingua.Authz.check_permission/4` → `Authz.PolicyEvaluator.evaluate/6`, deny-wins with implicit default-deny, `backend/lib/noizu_prompt_lingua/authz/policy_evaluator.ex:44-50`). But this is a live self-check, not a simulator: the actor is always the authenticated caller (`get_user_id/1` from the Guardian session, `policy_controller.ex`) — an admin cannot simulate another user or a role; and there is no mechanism to evaluate a hypothetical/unsaved policy. The "no matching policy" case is distinguishable only via the explain endpoint's `:implicit_deny` reason; `check` returns a bare `allowed: false`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Specify an actor (user or role), action, and resource → clear allow/deny decision | Partially Met | `check/2` returns `{allowed, action, resource_type, resource_id}` (`policy_controller.ex:59-72`) but the actor is fixed to the calling session (`get_user_id/1`) — no actor/role parameter, so no true simulation |
| Decision reflects a hypothetical/unsaved policy change | Not Met | `Authz.check_permission/4` evaluates only persisted policies (via `get_effective_policies/3` in `backend/lib/noizu_prompt_lingua/entities/authz.ex`); no draft-policy input path exists |
| No matching policy → explicit "no matching policy"/default-deny result rather than error | Partially Met | no-match yields `allowed: false` without erroring (`policy_evaluator.ex:50` `:implicit_deny`), but the `check` response omits the reason — the explicit label is only visible through `/policies/explain` (US-063) |

## Gaps / Risks

- The core "simulator" premise (evaluate as someone else, evaluate against draft policies) is absent; what exists is a self-service "why can't I do X" probe endpoint.
- `check` and `explain` share one engine (deliberately, per `entities/authz.ex:137-144` moduledoc), so consistency between them is solid.

## BDD Scenario

```gherkin
Feature: Admin simulates a PBAC decision

  Scenario: Check own access
    Given Ilya is authenticated
    When he POSTs /policies/check with action and resource
    Then he receives a JSON allow/deny decision for himself

  Scenario: Simulate another actor
    When Ilya attempts to check access as a different user or role
    Then the API accepts no actor parameter — simulation of others is unsupported (gap)

  Scenario: Simulate a draft policy
    When Ilya supplies a hypothetical policy document
    Then the API has no such input — only stored policies are evaluated (gap)
```
