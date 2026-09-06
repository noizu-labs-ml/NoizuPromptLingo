# Review: Tailor a session's tool descriptions to the target model/runner

- **Story**: `project-management/user-stories/US-005-tailor-session-tool-descriptions-to-model-runner.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No code implements runner/model-specific tool-description tailoring. A repo-wide search for "tailor" matches only an unrelated docstring in `src/npl_mcp/launcher.py:369` (ToolHelp guidance text). Tool registration is static: every tool is registered once via `mcp_discoverable` with a single fixed description (`src/npl_mcp/launcher.py` throughout, e.g. `Session.Update` at 1086-1104), with no per-session, per-model, or per-runner variation mechanism, no description-variant catalog, and no cache of tailored sets. The generic session model (`src/npl_mcp/sessions/sessions.py`) carries no model/runner identifier, and no resolution/fallback path exists. Non-breaking default behavior (AC 2) holds only trivially — because there is exactly one description set — not by design.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Requesting tailored descriptions for a declared model/runner yields runner-traceable variants | Not Met | no evidence found — no tailoring parameter on any tool-listing path; descriptions are fixed strings at registration |
| No tailoring requested → default untailored descriptions served (opt-in, non-breaking) | Not Met | trivially true but vacuous — there is no alternative set to opt into; no evidence found of the opt-in mechanism itself |
| Unrecognized model/runner falls back to defaults rather than failing | Not Met | no evidence found — no runner-identifier input exists to reject or fall back on |
| Cached tailored set served on repeat requests without recomputation | Not Met | no evidence found — no cache layer for tool descriptions |

## Gaps / Risks

- Whole feature absent: would require (a) a runner-identifier field on the session, (b) per-runner description variants, (c) a resolution/fallback order, and (d) a cache — none exist.
- Any future implementation must decide where variation lives: MCP tool descriptions are static at server startup in FastMCP, so per-session tailoring likely needs a meta-tool (e.g. `ToolSearch`-style filtered output) rather than mutating registrations — an architectural decision the story's notes don't address.
- Related but distinct: `ToolSummary`/`ToolSearch` meta-tools (`src/npl_mcp/meta_tools/`) provide discovery-level brevity today; that is the nearest existing capability and a possible substrate.

## BDD Scenario

```gherkin
Feature: Runner-tailored tool descriptions
  Scenario: Agent requests tailored tool surface
    Given an active session and runner "codex-cli"
    When the agent requests the session's tool descriptions tailored to that runner
    Then today no such request path exists — the agent receives the single static description set
  Scenario: Untailored default
    When tools are listed with no tailoring requested
    Then the static descriptions are returned (today by necessity, not by an opt-in design)
  Scenario: Unknown runner
    When an unrecognized runner identifier is supplied
    Then today the call cannot even express the identifier — no fallback path exists
  Scenario: Repeat request
    When the same runner requests tools twice
    Then today there is no tailored cache — the static set is served both times
```
