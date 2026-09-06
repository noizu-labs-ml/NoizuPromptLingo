# Review: Manage API Key Vault for Personas

- **Story**: `project-management/user-stories/US-077-manage-api-key-vault-for-personas.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

A minimal secrets module exists in the Python repo: `src/npl_mcp/browser/secrets.py` implements `secret_set`/`secret_get`/`get_secrets_batch` over a PostgreSQL `npl_secrets` table with name validation (`^[a-zA-Z_][a-zA-Z0-9_]*$`, max 128 chars). Only `secret_set` is registered as an MCP tool (`src/npl_mcp/meta_tools/discoverable_tools.py:48-55`, tool name `Secret`); `secret_get` is not exposed as an MCP tool, so the story's `get_secret(name)` tool does not exist. The module docstring states secrets are "stored as plaintext" (`secrets.py:1-5`) — no encryption at rest, no versioning/rotation (UPSERT overwrites in place, `secrets.py:57-67`), no audit logging of access, no redaction mechanism, and no admin interface. Confidence is high that most criteria are unmet; the tests (`tests/test_secrets.py`) cover only name validation.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Key vault stores secrets encrypted at rest | Not Met | `src/npl_mcp/browser/secrets.py:1-5` — "Secrets are stored as plaintext in the npl_secrets table"; no crypto anywhere in the module |
| Secrets referenced by name (e.g. `openai_key`) | Met | `src/npl_mcp/browser/secrets.py:13` name regex; `secret_set/secret_get` key everything by name |
| Personas request secrets via MCP tool `get_secret(name)` | Partially Met | `secret_get` exists (`secrets.py:72-92`) but only `secret_set` is registered (`src/npl_mcp/meta_tools/discoverable_tools.py:48-55`); no `get_secret` MCP tool |
| Secret access logged to audit trail | Not Met | no logging in `secret_get`/`get_secrets_batch`; no audit table touched |
| Secrets never appear in artifact content or chat logs | Not Met | no redaction/filtering mechanism found in `src/` |
| Supports rotation with version history | Not Met | `secrets.py:57-67` UPSERT overwrites `value`; single row per name, no version history |
| Admin interface for adding/updating/revoking secrets | Not Met | only `Secret.Set` tool; no admin surface, no revoke/delete function |

## Gaps / Risks

- Plaintext secrets in Postgres is a security gap versus the story's AES-256-GCM requirement (see `docs/secret-management.md` for the infra-level Infisical pattern this story mirrors).
- Once `get_secret` is exposed, returning the raw value to any caller with no authz/audit makes exfiltration trivial — the story's audit and redaction criteria are prerequisites for exposing it.
- No deletion/revocation path exists at all.

## BDD Scenario

```gherkin
Feature: Persona API key vault
  Scenario: Agent fetches a named credential
    Given a secret named "openai_key" has been stored via Secret.Set
    When the persona calls get_secret("openai_key")
    Then the decrypted value is returned to the persona
    And the access event is appended to the audit trail with persona ID and timestamp (not implemented today)
  Scenario: Rotation
    When an admin rotates "openai_key" to a new value
    Then the new version is stored and prior versions remain retrievable in version history (not implemented today — UPSERT overwrites)
  Scenario: Redaction
    When the secret value would flow into an artifact or chat message
    Then it is redacted before persistence (not implemented today)
```
