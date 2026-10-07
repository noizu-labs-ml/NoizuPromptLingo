# Review: Detect and Prevent Secret Leakage in Artifacts

- **Story**: `project-management/user-stories/US-071-detect-and-prevent-secret-leakage-in-artifacts.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No secret-detection machinery exists in either codebase. The Python artifact write path (`src/npl_mcp/artifacts/artifacts.py:82-235`, `artifact_create`/`artifact_add_revision`) persists content directly to `npl_artifact_revisions` with zero content scanning — no pre-save hook, no pattern matching, no warnings. Grep for secret formats (`sk-`, `AKIA`, `ghp_`, `Bearer`) finds only incidental strings in unrelated modules; there is no detector module, no custom-pattern configuration, and no audit-log integration (`grep -ri "audit" src/npl_mcp/` returns nothing). The Elixir backend likewise has no secret-scanning code (no `encrypt`/pattern-scan hits in `backend/lib/noizu_prompt_lingua/`). The only adjacent feature is `src/npl_mcp/browser/secrets.py`, which is a named-credential store (plaintext in `npl_secrets`, per its own docstring) — unrelated to leak detection. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Pre-save hooks scan artifact content for API keys, AWS keys, tokens, passwords | Not Met | `src/npl_mcp/artifacts/artifacts.py:82-153` — `artifact_create` validates title/kind/size only, then inserts; no scan step |
| Detects `sk-...`, `AKIA...`, `ghp_...`, `Bearer ...` formats | Not Met | no evidence found (no pattern list anywhere in `src/` or `backend/lib/`) |
| Warns persona before finalizing artifact revision | Not Met | `artifact_add_revision` (`artifacts.py:156-235`) has no warning/confirmation path or return shape for warnings |
| Option to encrypt detected secrets or reject submission | Not Met | no evidence found |
| Logs secret detection events to audit trail | Not Met | no audit-log infrastructure exists in `src/npl_mcp/` (grep "audit": no hits) |
| Supports custom regex patterns for organization-specific secrets | Not Met | no evidence found |

## Gaps / Risks

- Artifacts, chat messages, and revisions accept arbitrary content with credentials persisted verbatim — the exact critical risk the story names.
- `src/npl_mcp/browser/secrets.py` stores secret *values* as plaintext in Postgres (its own module docstring, line 3), compounding the exposure.
- Story id collides with `US-071-search-the-wiki-by-keyword.md`.

## BDD Scenario

```gherkin
Feature: Secret leakage prevention in artifacts
  Story is NOT implemented — scenario describes the intended behavior, currently unsupported.

  Scenario: Revision containing an API key
    Given an existing artifact "Integration Notes"
    When a caller invokes ArtifactAddRevision with content embedding "AKIAIOSFODNN7EXAMPLE"
    Then the revision is saved silently with no warning (current behavior)
    And no detection event is logged anywhere
    And the secret is retrievable in plaintext via ArtifactGet
```
