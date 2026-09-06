# Review: Connect a GitHub Repository and Set Its Default ACL

- **Story**: `project-management/user-stories/US-100-connect-github-repo-default-acl.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The core ACL model is fully implemented in the Elixir backend: repos carry a validated `default_acl` field (`private|org_read|org_write`, `backend/lib/noizu_prompt_lingua/schema/github/repo.ex:9,21-23`), access resolves server-side via `can_access?/3` (`backend/lib/noizu_prompt_lingua/entities/github.ex:190-196` — org membership + default_acl baseline, plus group grants via scoped_memberships per the model documented in `domains/github/tools/overview.ex:13-19`), and every GitHub MCP tool verifies access through these checks (`domains/github/mcp.ex:5,12-13`). Admin surfaces register repos and set/change `default_acl` (`backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:225,243`), and tests cover the ACL logic (`backend/test/noizu_prompt_lingua/entities/github_test.exs`, `domains/github/tools_residual_test.exs`, `mcp/vfs/github_test.exs`). Two criteria fall short: the connection flow is admin-driven registration with a stored token (`token_id`), not the OAuth App/GitHub App install the story specifies, and there is no revocation-sync path — nothing detects an uninstalled/revoked connection or flips the repo to a disconnected state. Confidence: medium-high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Repo connection via OAuth or App install; repo listed as linked to the project | Partially Met | Connection exists but as admin registration (`admin_controller.ex:225` creates repo with `default_acl` + `token_id`), not OAuth/GitHub-App install; no evidence of an install-flow or project-linking confirmation step |
| Default ACL (role → read/write) stored and auto-applied to new members without per-user grants | Met | `default_acl` persisted and validated (`schema/github/repo.ex:9,21-23`); `can_access?` applies it to any org member automatically (`entities/github.ex:195-196`); group grants via scoped_memberships complement it (`overview.ex:15-19`) |
| Revoked connection / uninstalled app reflected as disconnected on next sync | Not Met | No revocation/disconnect/sync handling found in `entities/github.ex` or `github/client.ex` (grep for revoked/disconnect/stale/sync → nothing); a stale token would surface as failed calls, not a disconnected state |
| Agent denied when its role isn't covered by the default ACL | Met | Server-side `can_access?/3` enforcement on all repo tools (`entities/github.ex:190-196`; `domains/github/mcp.ex:5,12-13`); tested in `backend/test/noizu_prompt_lingua/entities/github_test.exs` |

## Gaps / Risks

- The OAuth/App-install criterion is architecturally unmet: `token_id` references a stored token, and nothing links repos to the OAuth identity of the connecting user — the story's entry-point UX doesn't exist as described.
- No connection-health sync: a revoked token or uninstalled app leaves the repo "connected" in the UI/admin views until a tool call fails at runtime — the stale-state failure mode AC3 targets.
- `can_access?/3` enforces read/write but the story's Notes expect enforcement "routed through the same server-side identity resolution that tool_guard (US-086) uses" — the GitHub MCP checks are domain-local; confirm the identity-resolution path is shared before treating this as fully aligned.
- Denial UX: no explicit "denied because ACL" signal was found for agent-facing callers (beyond the check failing).

## BDD Scenario

```gherkin
Feature: Connect a GitHub repository and set its default ACL

  Scenario: Org owner connects a repo
    Given Marcus has GitHub org admin rights
    When he initiates the repo connection via OAuth or App install
    Then the platform confirms the connection
    And the repo is listed as linked to the chosen project
    # Today: PARTIAL — repos are admin-registered with a stored token
    # (admin_controller.ex:225), no OAuth/App-install flow.

  Scenario: Default ACL applies to a new member
    Given a repo's default_acl is org_read
    When a new member joins the project
    Then they automatically get read (not write) access
    Without any per-user manual grant
    # Today: MET — can_access?/3 applies default_acl to any org member
    # (entities/github.ex:195-196).

  Scenario: Connection is revoked on GitHub's side
    Given the GitHub App is uninstalled or the token revoked
    When the platform next syncs
    Then the repo is shown as disconnected to Marcus
    Rather than a stale "connected" state
    # Today: NOT MET — no revocation/sync handling exists.

  Scenario: Agent exceeds its ACL coverage
    Given the Autonomous Coding Agent's resolved role is not covered by the default ACL
    When it attempts a repo-scoped write action
    Then the action is denied consistently with the configured ACL
    # Today: MET — server-side can_access? enforcement on all GitHub tools.
```
