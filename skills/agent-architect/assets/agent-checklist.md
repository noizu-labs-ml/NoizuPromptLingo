# Agent Pre-Ship Checklist

Validate before deploying or publishing an agent. All critical items must pass.

---

## Structure

- [ ] **Agent identity defined** — name, role, lifecycle, autonomy level
- [ ] **Trigger language clear** — description matches intended invocation scenarios
- [ ] **Response format specified** — structured output schema defined
- [ ] **Guardrails section present** — explicit "never do" and "always do" lists

## Tools

- [ ] **All tools documented** — description includes examples and error guidance
- [ ] **Structured output** — tools return JSON/structured data, not human-formatted text
- [ ] **Error recovery** — tool errors suggest corrective actions
- [ ] **Pagination** — data-returning tools have limit/offset parameters
- [ ] **No unbounded returns** — no tool can dump unlimited data into context

## Guardrails

- [ ] **Pre-input** — input validation and sanitization
- [ ] **Post-retrieval** — retrieved content scanned for injection (if applicable)
- [ ] **Pre-tool-call** — tool name and parameter validation
- [ ] **Post-output** — content policy and format validation
- [ ] **Cost controls** — maximum tool calls, session budget, or iteration limits
- [ ] **Loop detection** — mechanism to detect infinite loops or circular handoffs

## Context

- [ ] **Critical info at top/bottom** — not buried in middle of context
- [ ] **No context bloat** — tools lazy-loaded or catalog is small (<15)
- [ ] **History management** — summarization or eviction strategy for long conversations
- [ ] **Scratchpad** — working state managed and compacted (if applicable)

## Safety

- [ ] **Least privilege** — agent only has access to tools it needs
- [ ] **No destructive defaults** — destructive operations require confirmation
- [ ] **Injection resistance** — tested against indirect injection through tool results
- [ ] **Goal persistence** — original objective doesn't drift over long conversations
- [ ] **Audit trail** — decisions and tool calls are logged/traceable

## Testing

- [ ] **Happy path tested** — primary task completes correctly
- [ ] **Edge cases tested** — unusual inputs handled gracefully
- [ ] **Error cases tested** — tool failures, bad data handled
- [ ] **Guardrail cases tested** — boundary conditions enforced
- [ ] **Adversarial cases tested** — injection attempts, scope violations resisted

## NPL (If Applicable)

- [ ] **Correct pump selection** — pumps chosen for genuine value, not decoration
- [ ] **Emission ordering** — follows the recommended pump sequence
- [ ] **Runtime flags** — production-appropriate verbosity settings
- [ ] **Secure blocks** — critical guardrails in `⌜🔒 ... ⌟` blocks

## Documentation

- [ ] **Purpose clear** — someone unfamiliar can understand what the agent does
- [ ] **Workflow documented** — step-by-step process visible
- [ ] **Failure modes listed** — known failure scenarios with mitigations
- [ ] **Test scenarios documented** — reproducible validation suite

---

## Sign-Off

| Check | Status | Notes |
|-------|--------|-------|
| Structure | Pass / Fail | |
| Tools | Pass / Fail | |
| Guardrails | Pass / Fail | |
| Context | Pass / Fail | |
| Safety | Pass / Fail | |
| Testing | Pass / Fail | |
| NPL | Pass / Fail / N/A | |
| Documentation | Pass / Fail | |

**Overall:** Ready to ship / Needs work

**Reviewer:** ___
**Date:** ___
