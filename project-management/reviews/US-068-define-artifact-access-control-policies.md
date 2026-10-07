# Review: Define Artifact Access Control Policies

- **Story**: `project-management/user-stories/US-068-define-artifact-access-control-policies.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A platform authorization foundation exists on the Elixir backend: a policy-decision layer (`backend/lib/noizu_prompt_lingua/authz/policy_evaluator.ex` — allow/deny statement matching, deny-wins, implicit deny), an ACL resolver (`backend/lib/noizu_prompt_lingua/acl/resolver.ex`), and a dispatch guard that resolves the caller's identity/role and denies unauthenticated or unauthorized calls before tool execution (`backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex`, wired via `mcp/dispatch.ex`, `mcp/acl_provider.ex`, `mcp/server.ex`). However, the artifact domain itself has no artifact-level ACL: the artifact schemas/tools (`domains/artifacts/tools/artifact_get.ex`, `artifact_add_revision.ex`, `artifact_list.ex`, etc.) carry no owner/readers/editors fields and no per-resource permission checks beyond the generic tool/key-level guard. The Python repo's artifacts module (`src/npl_mcp/artifacts/artifacts.py`) likewise has no permission model. So enforcement is "who may call this tool at all", not "who may view/edit/delete this artifact". Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| System supports artifact-level ACLs (owner, readers, editors) | Not Met | no owner/reader/editor fields on artifact schemas or tool inputs (`backend/lib/noizu_prompt_lingua/domains/artifacts/` — grep for acl/owner/reader/editor returns nothing); no evidence found in `src/npl_mcp/artifacts/artifacts.py` |
| Permissions propagate to all revisions of an artifact | Not Met | revisions inherit nothing because no artifact-level permissions exist; `artifact_add_revision.ex` has no ACL logic |
| MCP server enforces permission checks before get_artifact, add_revision, list_artifacts | Partially Met | generic per-tool/per-key authz enforced at dispatch (`backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex:19-37,137-160` — deny-closed, membership-scoped), but it is identity/tool-level, not per-artifact |
| Permission denied errors return clear authorization failure messages | Partially Met | guard returns structured deny reasons (`{:deny, :no_identity}` etc., `tool_guard.ex:141-160`); messages are reason atoms, not artifact-scoped "you lack edit rights on artifact X" |
| ACL changes are logged to audit trail | Not Met | no artifact ACL to change; no audit hook found (see US-070 review) |

## Gaps / Risks

- Risk of false confidence: the presence of `authz/` + `acl/` + `tool_guard.ex` makes the repo *look* like this story is done; the gap is specifically per-artifact granularity.
- `tool_guard.ex` notes a `:shadow` enforcement mode (log-only, line 25) — confirm production is flipped to `:enforce` before relying on any deny behavior.
- Python MCP artifacts path has no authz whatsoever.

## BDD Scenario

```gherkin
Feature: Artifact access control policies

  Scenario: Unauthenticated caller denied at dispatch (exists today)
    Given an MCP key with no identity or membership
    When it calls Artifact.Get
    Then ToolGuard denies the dispatch with a structured deny reason before the tool runs

  Scenario: Reader blocked from editing a specific artifact (NOT YET POSSIBLE)
    Given an artifact with an owner and a reader
    When the reader calls Artifact.AddRevision on that artifact
    Then no per-artifact check exists — the call succeeds if tool-level authz allows
    And no owner/readers/editors ACL can even be defined on the artifact
```
