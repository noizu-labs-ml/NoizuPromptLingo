# Review: Copy Claude `mcp add` Setup Command

- **Story**: `project-management/user-stories/US-042-copy-claude-mcp-add-setup-command.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented in the frontend setup panel. `frontend/src/components/mcp-setup-panel.tsx` offers a client selector (claude, desktop, codex, cursor, vscode, grok) and `getCommandLine` (`mcp-setup-panel.tsx:123-133`) emits the correct per-client syntax — codex: `codex mcp add NAME --url URL --bearer-token-env-var ENV`; claude/grok: `mcp add --transport http NAME URL --header "Authorization: Bearer $ENV"`. A copy button writes it via `navigator.clipboard.writeText` (`:176-185`), and the raw key is displayed once (`:439-446`). The env-var name is org-scoped via `mcpAuthEnvVar` (`frontend/src/lib/mcp-setup.ts`, e.g. `TOBOR_LOCKER_AUTH_TOKEN`) rather than the story's literal `$AUTH_TOKEN` — semantically equivalent and arguably better (multi-org safe). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Copyable `claude mcp add` command with HTTP transport + bearer env var | Met | `mcp-setup-panel.tsx:123-133` (`mcp add --transport http NAME URL --header "Authorization: Bearer $ENV"`) |
| Server URL + name correct per org | Met | name/URL rendered into the command; env var org-scoped via `mcpAuthEnvVar` (`frontend/src/lib/mcp-setup.ts`) |
| One-click copy to clipboard | Met | `mcp-setup-panel.tsx:176-185` (navigator.clipboard.writeText) |
| Key never embedded in the command (env var reference only) | Met | command references `$ENV`, never the raw key; raw key shown once separately (`:439-446`) |

## Gaps / Risks

- Minor divergence: env var is org-scoped (e.g. `TOBOR_LOCKER_AUTH_TOKEN`) instead of the literal `$AUTH_TOKEN` in the story — documentation should be updated to match, not the code.
- Windows/PowerShell shell-quoting differences are not addressed (commands are POSIX-style).

## BDD Scenario

```gherkin
Feature: Copy MCP setup command
  Scenario: User sets up Claude Code against the MCP server
    Given an authenticated user with a minted API key on the setup panel
    When they select the "claude" client and click copy
    Then a `claude mcp add --transport http <name> <url> --header "Authorization: Bearer $<ORG>_AUTH_TOKEN"` command is on the clipboard
    And the command contains no literal key material
    And after exporting the env var, `claude` connects successfully
```
