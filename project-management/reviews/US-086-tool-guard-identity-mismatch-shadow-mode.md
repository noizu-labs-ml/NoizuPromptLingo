# Review: Log tool_guard Identity Mismatches in Shadow Mode

- **Story**: `project-management/user-stories/US-086-tool-guard-identity-mismatch-shadow-mode.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Shadow-first tool_guard exists and is production-wired: `NoizuPromptLingua.MCP.ToolGuard.before_call/3` runs in `:mcp_authz_mode` defaulting to `:shadow`, where every deny decision is logged and the call still proceeds (`lib/noizu_prompt_lingua/mcp/tool_guard.ex:24-27,323-346`), with structured `[mcp-authz]` log lines carrying mode, decision, tool, action, and detail (`tool_guard.ex:388-393`). However the story's specific signal — a *comparison* of caller-supplied identity vs JWT-resolved identity — does not exist, by deliberate design divergence: the module resolves identity ONLY server-side from `ctx.assigns.auth_claims` and never reads identity from args, documenting this as the fix for the f015c5bb spoofing bug (`tool_guard.ex:10-13`). So mismatches cannot be logged because caller-supplied identity is ignored, not compared. Aggregation over a time range relies on plain `Logger.info` lines with no queryable store.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Shadow mode: identity-arg mismatch proceeds normally and logs a structured event | Partially Met | shadow mode + structured logging exist (`tool_guard.ex:24-27,334-336,388-393`); no mismatch *comparison* is performed — caller-supplied identity is never read (`tool_guard.ex:10-13,146-157`) |
| Event includes JWT identity, supplied identity, tool name, timestamp | Partially Met | log line has tool/action/decision/inspect(detail) (`tool_guard.ex:390-392`); detail may carry resolved identity but never the caller-supplied one |
| No mismatch event when identities agree | Met | trivially — no comparison exists, so no mismatch events are emitted; allow decisions do log (`tool_guard.ex:318-321`), which introduces its own noise |
| Shadow logs queryable/filterable into a mismatch count/rate for go/no-go | Not Met | plain Logger output only; no dedicated store, filter, or aggregation surface found |

## Gaps / Risks

- Design divergence should be reconciled in the story: the spoofing hole was closed by removal rather than comparison+logging — arguably stronger, but it deprives Ilya of the measured-mismatch data the story wants before enforcement flips.
- Every call logs an `[mcp-authz]` line (allow and deny) — log volume, not mismatch signal, may dominate; a rate dashboard would need structured ingestion.
- Elevation (`sensitivity: :destructive`) and per-key toolset checks enforce even in shadow (`tool_guard.ex:80-101,160-204`) — worth noting when computing what enforcement flip would actually change.

## BDD Scenario

```gherkin
Feature: Shadow-mode observability for tool_guard identity enforcement

  Scenario: Caller supplies a mismatched identity argument
    Given tool_guard runs in :mcp_authz_mode :shadow
    When a tool call arrives with a caller-supplied identity arg differing from the JWT sub
    Then the argument is ignored (never trusted), the call proceeds, and no comparison event is logged (gap vs story intent)

  Scenario: Admin measures mismatch rate before enforcing
    When Ilya queries shadow-mode mismatch logs over a week
    Then he can grep [mcp-authz] deny lines from stdout logs, but no aggregation API exists to produce a go/no-go rate
```
