# Review: List GitHub Pull Requests for a Linked Repo

- **Story**: `project-management/user-stories/US-079-list-github-pull-requests-for-a-linked-repo.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend (`/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend`). The `Github.PullList` MCP tool (`backend/lib/noizu_prompt_lingua/domains/github/tools/pull_list.ex:1-56`) accepts caller_user_id, organization, repo (UUID or `owner/name`), and optional `state` (open|closed|all), page, per_page; it delegates to `Github.Client.list_pulls` (`backend/lib/noizu_prompt_lingua/github/client.ex:183-193`) which resolves the repo with an ACL read check and calls the GitHub PRs list API. The three failure/edge states the story requires are all handled distinctly: no repo linked → `{:error, :repo_not_found}` (`client.ex` `resolve_repo/4`), token not mapped → `{:error, :token_not_mapped}`, and no read access → `{:error, :forbidden}` — none of these are an indistinguishable empty list. Confidence: high on plumbing; the normalized PR payload fields (title/author/branch/status) come from the shared `Pulls.list` normalization and were not individually asserted in tests.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Open PRs returned with title, author, branch, and status given valid credentials | Met | `backend/lib/noizu_prompt_lingua/domains/github/tools/pull_list.ex:33-55` → `client.ex:183-193` (`Pulls.list` with repo-scoped opts); token from `GithubRepo` (`resolve_repo/4`) |
| Filter for closed/merged PRs included when requested | Met | `state` field open|closed|all (`pull_list.ex:14`) passed through `client.ex:186-188` (`Keyword.take` keeps `:state`) |
| No linked repo → clear "no repo linked" state, not empty list | Met | `resolve_repo/4` (`client.ex`) returns `{:error, :repo_not_found}` / `{:error, :token_not_mapped}`, surfaced as `{:error, reason}` by the tool (`pull_list.ex:47-50`) |

## Gaps / Risks

- "Merged" is not a distinct state filter — GitHub's API folds merged into `closed`; the PR payload must carry a `merged` flag for the platform to distinguish, which depends on the shared normalize step (not verified here).
- Checks-passing / draft sub-status (story's "e.g. draft, ready, checks-passing") would require additional API calls; only base state filtering is wired.
- No dedicated test file found for `pull_list.ex` tool behavior (state pass-through, error mapping).

## BDD Scenario

```gherkin
Feature: List GitHub pull requests for a linked repo
  Scenario: Reviewer lists open PRs
    Given a project repo is linked with a valid GitHub token and the caller has read access
    When the reviewer calls Github.PullList with organization, repo, and no state filter
    Then open pull requests are returned with title, author, head branch, and state
  Scenario: Filter closed PRs
    When the reviewer calls Github.PullList with state "closed"
    Then closed (including merged) PRs are returned instead of open ones
  Scenario: Repo not linked
    When the reviewer calls Github.PullList for a project with no linked GitHub repo
    Then an explicit repo_not_found (or token_not_mapped) error is returned, not an empty list
  Scenario: No read access
    Given the caller lacks read ACL on the repo
    When Github.PullList is called
    Then a forbidden error is returned
```
