# Review: Create a Pull Request from Within the Platform

- **Story**: `project-management/user-stories/US-101-create-pull-request-from-platform.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

PR creation is implemented on the Elixir backend as the `Github.PullCreate` MCP tool (`backend/lib/noizu_prompt_lingua/domains/github/tools/pull_create.ex:1`), backed by `NoizuPromptLingua.Github.Client` which resolves repo access/tokens and returns specific error tuples (`{:error, :forbidden}`, `{:error, {:github, status, body}}`, `{:error, :repo_not_found}` — `backend/lib/noizu_prompt_lingua/github/client.ex:13-15`). Title, body, head, and base are all caller-supplied parameters. However, this is an MCP tool surface only: there is no platform UI form, no pre-fill of the description from a linked ticket, no linkage of the resulting PR number/URL back to a ticket, and no GitHub-webhook-driven PR status sync into tickets. The US-104 webhook infrastructure exists (`backend/lib/noizu_prompt_lingua/events/webhook_handler.ex`) but nothing consumes GitHub PR events to update tickets.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create PR action with title, description pre-filled from linked ticket, base and target branch | Partially Met | `pull_create.ex:11-19` — title/body/head/base params exist; no ticket pre-fill, no UI form |
| On success, platform shows PR number/URL and links it back to originating ticket | Partially Met | `client.ex:55` `normalize_github_result/1` returns the GitHub result (includes URL), but no evidence of ticket linking anywhere in `domains/tickets/` or `domains/github/` |
| On GitHub API failure, specific actionable error, no partial/duplicate PR | Met | `client.ex:76-77` returns `{:error, {:github, status, body}}`; ACL denial returns `{:error, :forbidden}` (`client.ex:13`); single API call, no partial state |
| Later PR status changes on GitHub sync back to the linked ticket via webhook | Not Met | No GitHub webhook receiver updating tickets found; `mcp/vfs/github.ex:53` explicitly notes "no webhook→publish bridge" |

## Gaps / Risks

- No ticket↔PR link model or UI; the "without switching tools and losing context" goal is only partially served (an agent can call the tool, a human cannot drive a form).
- Description pre-fill from ticket is absent — the tool requires an explicit `body`.
- PR status → ticket sync (US-104 dependency) is entirely missing.
- Repo connection prerequisite (US-100): token resolution exists (`client.ex:26-40`), which suggests the US-100 substrate is present.

## BDD Scenario

```gherkin
Feature: Create a pull request from within the platform

  Scenario: Create a PR via the GitHub MCP tool
    Given a repo is connected with a mapped token for the caller
    When the agent calls Github.PullCreate with organization, repo, title, body, head, and base
    Then the platform resolves the caller's UUID and organization
    And creates the pull request through the GitHub API
    And returns the created PR data including its URL

  Scenario: GitHub API rejects the PR creation
    Given the head branch has no diff or the caller lacks write access
    When the agent calls Github.PullCreate
    Then the platform returns a specific error such as {:error, {:github, 422, body}} or {:error, :forbidden}
    And no partial or duplicate PR is created

  Scenario: PR status sync back to ticket (NOT yet possible)
    Given a PR created from the platform is later merged or closed on GitHub
    When the corresponding webhook event arrives
    Then no ticket update occurs because no GitHub-webhook-to-ticket bridge exists
```
