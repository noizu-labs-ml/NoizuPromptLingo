# Review: Grant GitHub Token/Repo Access at the Org Level

- **Story**: `project-management/user-stories/US-060-grant-org-level-github-access.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Elixir backend implements org-scoped GitHub token and repo grant administration: token CRUD (`backend/lib/noizu_prompt_lingua_web/controllers/admin_controller.ex:172-210`), repo CRUD bound to a token (:212-260), group-level repo grants with read/write levels (:262-311), all over local DB tables via `NoizuPromptLingua.Github`. Token values are masked on every read (`token_json/1` returns `token_preview`; explicit comment at :168-170 "Token values are NEVER returned"; the GitHub client masks again, `backend/lib/noizu_prompt_lingua/github/client.ex:130-141`). Revocation deletes the local grant/token rows. The decisive gap is stated in the code itself: "No GitHub API work yet — these are raw text values" (`admin_controller.ex:169`) — `github/client.ex` reads the local DB, not GitHub, so grants are never live-verified and revocation is not exercised against real GitHub auth. Frontend: `frontend/src/app/app/admin/github/page.tsx`.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Scoped token grant to a repo appears in org's GitHub access list and org projects can reference it | Met | `create_github_token` (:180-197) + `create_github_repo` with `token_id` binding (:220-240); `list_github_tokens`/`list_github_repos` (:172-218); group grants via `grant_repo_access` (:267-290) |
| Org owner sees authorized repos without plaintext token | Met | `token_json/1` returns only `token_preview` (masked); `github/client.ex:130-141` masks token in caller-facing repo payloads too |
| Revoking a grant makes subsequent coding-agent auth against GitHub fail | Partially Met | `revoke_github_repo_access`/`delete_github_token` remove local rows (:199-210, :292-307), so local access checks (`Github.can_access?/3`, `github/client.ex:110-113`) stop passing — but no GitHub API is contacted at all, so "fails authentication against GitHub" is untested/meaningless today |
| Granting a repo the token cannot reach reports the permission failure on test | Not Met | no verification call exists; creation saves whatever token text is supplied (`admin_controller.ex:180-196`) — the "live-verification pattern from US-057" named in the story is not implemented |

## Gaps / Risks

- The whole integration is DB-local simulation: tokens are never validated against GitHub, so any garbage token saves successfully and only surfaces as broken agent access later.
- No audit trail on grant/revoke (actor + timestamp of the grant decision is not recorded beyond row timestamps).

## BDD Scenario

```gherkin
Feature: Org-level GitHub token and repo grants

  Scenario: Admin grants repo access with a scoped token
    Given Ilya is on the org's GitHub admin page
    When he registers a PAT and maps a repo to it with a group grant of "write"
    Then the repo and grant appear in the org's GitHub access list (token masked)

  Scenario: Revoked grant blocks access
    When Ilya revokes the repo grant
    Then local access checks deny subsequent agent access to that repo
    (no real GitHub authentication is exercised — gap)

  Scenario: Unreachable repo grant
    When Ilya grants a repo the token cannot reach
    Then the grant is saved silently — no reachability test runs (gap)
```
