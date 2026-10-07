# Review: Comment on a GitHub Pull Request

- **Story**: `project-management/user-stories/US-080-comment-on-a-github-pull-request.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend (`/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend`). The `Github.PullComment` MCP tool (`backend/lib/noizu_prompt_lingua/domains/github/tools/pull_comment.ex`) posts via `Github.Client.comment_pull/5` (`backend/lib/noizu_prompt_lingua/github/client.ex:249-257`), which resolves the repo with a **write** ACL check (`resolve_repo/4` → `Github.can_access?(user, repo, :write)`) before calling the Issues comments API (a PR is also an issue). Permission failures surface as distinct errors: `:forbidden` on missing write ACL, `:token_not_mapped` when the repo has no token — not silent no-ops. Round-trip reading is provided by `list_pull_comments` (`client.ex:234-241`), which deliberately uses the same Issues comments API so posted and listed comments match (documented at `client.ex:229-233`). Attribution is the integration's repo-mapped token identity, matching the story's "integration's configured identity" alternative. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Submitted comment appears on the real GitHub PR thread, attributed to integration or linked user identity | Met | `backend/lib/noizu_prompt_lingua/github/client.ex:243-257` (`comment_pull` → `Issues.create_comment` with repo token built by `build_opts/1`); attribution = mapped token identity |
| Missing write permission → clear permission error, not silent no-op | Met | `resolve_repo/4` ACL write check returns `{:error, :forbidden}`; `{:error, :token_not_mapped}` for unmapped tokens; tool surfaces `{:error, reason}` (`pull_comment.ex` call branch) |
| Posted comment appears in platform's PR comment list (round-trip sync) | Met | `list_pull_comments` (`client.ex:234-241`) uses the same Issues comments API, with doc comment noting the deliberate symmetry (`client.ex:229-233`) |

## Gaps / Risks

- Comments are general PR-conversation comments only; inline/diff-positioned review comments are explicitly out of scope per the client docstring (`client.ex:244-246`) — fine for this story but limits review workflows that annotate specific lines.
- No dedicated test file found for `pull_comment.ex` / `comment_pull` error-path behavior (forbidden, token_not_mapped).
- Comment body is posted as-is; if the platform ever embeds secret material in bodies there is no redaction layer on this write path.

## BDD Scenario

```gherkin
Feature: Comment on a GitHub pull request from the platform
  Scenario: Reviewer posts feedback to a PR
    Given a repo is linked with a token that has write access and the caller passes the write ACL
    When the reviewer calls Github.PullComment with organization, repo, pull_number, and body
    Then the comment is created on the real github.com PR thread via the Issues comments API
    And it is attributed to the repo's configured integration identity
  Scenario: Round-trip verification
    When the platform lists the PR's comments via Github.PullCommentList
    Then the newly posted comment appears in the returned list
  Scenario: Token lacks write permission
    Given the caller fails the write ACL check (or the repo token is read-only/unmapped)
    When a comment submission is attempted
    Then a forbidden / token_not_mapped error is returned — no silent no-op
```
