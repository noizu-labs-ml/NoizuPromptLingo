# Review: Rate-Limit the Unauthenticated Token-Mint Endpoint

- **Story**: `project-management/user-stories/US-087-rate-limit-unauthenticated-token-mint.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The unauthenticated bootstrap endpoint `POST /api/mcp/token` is rate-limited: the route scope pipes through `:rate_limited_auth` (`lib/noizu_prompt_lingua_web/router.ex:46-48,117-119`), implemented by `NoizuPromptLinguaWeb.Plugs.RateLimit` using Hammer with a per-IP rolling window of 10 requests / 60s (`lib/noizu_prompt_lingua_web/plugs/rate_limit.ex:5-8,20-36`). On denial it responds 429 with a `Retry-After` header computed from the window (`rate_limit.ex:28-35`). Source scoping is IP-only (first `x-forwarded-for` entry, else remote_ip — `rate_limit.ex:39-45`). The one unmet criterion is logging: the plug emits no log line at all on rejection, so rejections cannot be distinguished from credential failures in any log/metric pipeline. Related mint surfaces: `POST /auth/mcp/token` (session-authenticated, `router.ex:478`) is a different, authed path — the story targets the unauthenticated bootstrap, which is covered.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Over-threshold source gets 429 + `Retry-After` instead of processing | Met | `lib/noizu_prompt_lingua_web/plugs/rate_limit.ex:28-35`; wired via `router.ex:117-119` |
| After the rolling window elapses, requests process normally without intervention | Met | Hammer `check_rate/3` sliding-window semantics (`rate_limit.ex:24`) |
| Burst from many distinct under-threshold sources is not limited | Met | per-source key `"#{action}:#{ip}"` (`rate_limit.ex:21-22`); 10 req/min per IP is per-source |
| Rate-limit rejections logged distinctly from credential failures | Not Met | no logging in the plug (`rate_limit.ex` has none); rejection is response-only |

## Gaps / Risks

- IP extraction trusts the first `x-forwarded-for` hop (`rate_limit.ex:40-42`) — spoofable header input decides the limit key unless the edge proxy overwrites it; verify deployment proxy config.
- No logging also means no abuse telemetry: a brute-force campaign against the mint endpoint is invisible except via upstream access logs.

## BDD Scenario

```gherkin
Feature: Rate ceiling on the unauthenticated token mint

  Scenario: Brute-force source is throttled
    Given one IP sends its 11th request to POST /api/mcp/token within 60 seconds
    When the request arrives
    Then it is answered 429 with a Retry-After header and the token is not minted

  Scenario: Throttling elapses
    When the same IP waits past the 60-second window and retries
    Then the request is processed normally

  Scenario: Admin reviews rate-limit rejections
    When Ilya filters auth-failure logs for rate-limit events
    Then no such tagged log entries exist (gap) — rejections are only observable upstream
```
