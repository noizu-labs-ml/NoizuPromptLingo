# Review: Implement Persona Permission Scopes

- **Story**: `project-management/user-stories/US-072-implement-persona-permission-scopes.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-06-09

## Implementation Assessment

The story's exact model (persona-level `read-only|contributor|admin|system` scopes) does not exist. The Elixir backend instead ships a mature **user/org-role RBAC**: `MCP.ToolGuard` (`backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex`) intercepts every MCP tool dispatch, resolves identity server-side from `ctx.assigns.auth_claims["sub"]`, resolves the caller's role (ladder `owner>admin>lead>member>viewer` via `Authz.authorize/4`) against the resource org/project, and is deny-closed (unknown role ⇒ most-restrictive). A general ACL engine (groups, rules, deny-wins resolver) also exists (`backend/lib/noizu_prompt_lingua/acl.ex`, Liquibase 081). However: (1) rollout is **shadow mode by default** (`:mcp_authz_mode, default :shadow` — decisions logged, never blocked); (2) tools carry no `authz:` metadata in `domains/wiki/`, `domains/review/`, or other domains (grep confirms zero `authz:` attributes), and tools without the blob are "unguarded passthrough"; (3) there is no `read-only/contributor/admin/system` persona scope field — personas (`domains/personas/`) carry no scope. The Python MCP server (`src/npl_mcp/`) has no authorization checks at all (no `forbidden`/`403` hits). Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Personas have assigned scope: read-only / contributor / admin / system | Not Met | no `scope` field on personas (`backend/lib/noizu_prompt_lingua/domains/personas/`); the implemented ladder is user/org roles (`tool_guard.ex` moduledoc), a different model |
| `read-only` personas can only read artifacts and chat | Partially Met | a `viewer` role exists on the ladder and `KeyToolsets` can hard-disable tools per API key (`tool_guard.ex` `key_toolset_check`), but nothing maps a persona to viewer-only |
| `contributor` personas can create but not delete | Not Met | no per-operation create-vs-delete distinction is enforced for any persona identity |
| `admin` personas can perform all operations | Partially Met | org `admin`/`owner` roles authorize via `Authz.authorize/4` — but only in `:enforce` mode and only for tools carrying `authz:` metadata (currently none) |
| `system` personas have unrestricted access | Partially Met | a SYSTEM principal exemption exists (`ctx.assigns[:system_principal] == true`, `tool_guard.ex` moduledoc) but it is session-flag-based, not a persona scope |
| MCP server checks persona scope before executing privileged operations | Partially Met | `ToolGuard.before_call/3` runs before dispatch (`tool_guard.ex:57-71`), but defaults to shadow (never denies) and no domain tools declare `authz:` blobs, so effectively nothing is gated |
| Scope violations return `403 Forbidden` with clear error message | Partially Met | `before_call/3` returns `{:error, map}` denials in enforce mode (deny-closed), but the Python server returns no 403s and shadow mode denies nothing today |

## Gaps / Risks

- Enforcement gap is the headline risk: the RBAC machinery exists but the default `:shadow` mode plus zero `authz:` metadata means **no tool is actually blocked** in the shipped configuration.
- The Python `src/npl_mcp/` server (artifacts, reviews, chat) has no authorization layer whatsoever — any caller can read/write anything.
- Story-vs-implementation model mismatch should be reconciled: either the story is rewritten to the user/org-role model or a persona-scope mapping layer is added.

## BDD Scenario

```gherkin
Feature: Persona permission scopes
  Intended behavior, partially backed by ToolGuard (shadow mode).

  Scenario: Read-only persona attempts deletion (today)
    Given the MCP authz mode is :shadow (default)
    When an unauthenticated caller invokes Wiki.PageDelete
    Then the delete executes (no authz metadata on the tool; shadow mode logs only)

  Scenario: Same call after rollout (:enforce + authz metadata — not yet wired)
    When a caller lacking the required role invokes a tool declaring authz: [required_role: :member]
    Then ToolGuard resolves the role server-side and returns a denial error map before dispatch
```
