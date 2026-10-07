# Review: Provision least-privilege scoped DB credentials via Infisical for DB-access services

- **Story**: `project-management/user-stories/US-404-least-privilege-db-credentials-infisical.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No DB-access MCP service exists yet to provision, and the current credential posture is exactly the anti-pattern the story calls out: the entire Python legacy fleet shares one env-configured credential with permissive dev defaults (`src/npl_mcp/storage/pool.py:26-28`, `NPL_DB_USER`/`NPL_DB_PASSWORD` defaulting to `"npl"`/`"npl"`), used for every internal service (sessions, metrics, instructions, artifacts, executors, browser.secrets). No per-service Postgres roles exist in this codebase; there is no evidence of write-attempt-under-readonly-role testing. The Infisical → InfisicalSecret → k8s Secret flow is established platform infrastructure (monorepo `docs/secret-management.md`, `.infisical-secrets.yaml`), but nothing in this repo wires a DB-access service into it — there is nothing to wire yet. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Each DB-access service connects with a dedicated role covering exactly its operations | Not Met | no evidence found — single shared role; no DB-access services exist |
| Credentials from Infisical via InfisicalSecret → k8s Secret; none in env files/images/source | Not Met | `src/npl_mcp/storage/pool.py:24-28` reads raw env vars with hardcoded defaults; no Infisical integration in this repo's DB path |
| Rotation via Infisical without code/chart edits | Not Met | no evidence found |
| Write attempt under read-only role fails at Postgres layer | Not Met | no evidence found — no read-only role exists; untestable until US-401/402 ships |
| Shared/over-privileged legacy credentials identified for replacement | Not Met | the story itself documents the finding (`pool.py` single `NPL_DB_*` credential); no audit artifact or remediation exists in code |

## Gaps / Risks

- `pool.py:27-28` defaults (`npl`/`npl`) mean a misconfigured deployment silently connects with dev credentials — worth failing fast on missing real credentials when the service is deployed outside local dev.
- The Python fleet's *internal* services (not just future DB tools) share the single credential; the story's audit scope should cover them too, since any of them becoming a write tool inherits the over-privileged role.
- Credential rotation behavior on this repo's side is "restart the process" (pool created once at `pool.py:19-32`, cached in a module global); a rotation story must account for that — no hot-reload path exists.

## BDD Scenario

```gherkin
Feature: Least-privilege DB credentials via Infisical

  Scenario: Read tool uses a SELECT-only role
    Given the read-only query service is deployed via Helm
    When it boots
    Then its connection string resolves from a k8s Secret synced by an InfisicalSecret CRD
    And the Postgres role behind it holds only CONNECT and SELECT on the mandated schema

  Scenario: Write attempt fails at Postgres layer
    Given the read-only tool's dedicated role
    When a statement "UPDATE projects SET name = 'x'" is executed under that role
    Then Postgres rejects it with a permission-denied error
    And the tool surfaces the error even if a tool-level guard were bypassed

  Scenario: Rotation without code or chart edits
    Given the service is running with credentials from Infisical
    When the Postgres password for its role is rotated in Infisical
    Then the k8s Secret syncs and, per the documented restart/sync behavior, the service reconnects
    And no source code or Helm chart values were modified

  Scenario: Legacy shared credential is retired
    Given the audit of the legacy Python fleet's single NPL_DB_* credential
    When the audit completes
    Then each consuming service is mapped to a per-service role
    And the shared credential is flagged for replacement with a dated plan
```
