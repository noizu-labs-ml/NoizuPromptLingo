# Review: Validate Database Integrity

- **Story**: `project-management/user-stories/US-044-validate-database-integrity.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No integrity-validation tooling exists. The story's premise (`PRAGMA integrity_check` + `foreign_key_check` across three SQLite databases) is stale: storage is PostgreSQL (`src/npl_mcp/storage/pool.py:1-30`), Ecto/Postgres on the backend. Searches found no integrity-check functions, no orphan-row detection queries, no FK validation sweeps, and no structured integrity report in `src/` or `backend/lib`. This is the last of the six coordination-cluster stories (US-039/040/041/042/043/044), and none of that cluster is implemented. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Run integrity check on each database | Not Met | no evidence found |
| Detect orphaned rows / FK violations | Not Met | no evidence found |
| Verify index consistency | Not Met | no evidence found |
| Emit structured integrity report with severity | Not Met | no evidence found |

## Gaps / Risks

- Premise is stale (SQLite → Postgres); a re-scope would use Postgres constraints (enforced by the engine), orphan-detection queries, and `amcheck` for index validation.
- Data corruption/violations today surface only as runtime errors.

## BDD Scenario

```gherkin
Feature: Database integrity validation
  Scenario: Operator validates integrity after an incident
    Given the platform's PostgreSQL databases
    When the operator requests an integrity validation
    Then no such tool exists and validation must be done by hand
```
