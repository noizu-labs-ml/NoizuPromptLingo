# Review: Cross-Validate Agent Outputs

- **Story**: `project-management/user-stories/US-060-cross-validate-agent-outputs.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No agent-to-agent validation protocol exists in the Python MCP server. Greps for `cross-validat`, `validator`, and validation-chain concepts across `src/npl_mcp/` return no implementation hits. The orchestration package offers only a linear pipeline pattern (`src/npl_mcp/orchestration/__init__.py:3-5` — consensus/hierarchical/synthesis explicitly "planned for future releases"), and the artifact review system (`src/npl_mcp/artifacts/reviews.py`) supports single persona-authored reviews with no validator-role semantics, no read-only access scoping, no pass/fail verdict structure, and no chain-depth control. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Specify "validator" agent for a given task output | Not Met | no evidence found in `src/npl_mcp/` |
| Validator has read-only access to original agent's output | Not Met | no evidence found |
| Validation results include pass/fail and detailed critique | Not Met | no evidence found |
| Original agent can optionally revise based on validation feedback | Not Met | no evidence found |
| Validation chain depth is configurable (prevent infinite loops) | Not Met | no evidence found |
| Validation reports are versioned alongside artifacts | Not Met | no evidence found |

## Gaps / Risks

- Fully unimplemented; would require both a validation-workflow pattern in `src/npl_mcp/orchestration/` and artifact-versioned report storage, neither of which has groundwork.

## BDD Scenario

```gherkin
Feature: Cross-validate an agent's output with a validator agent

  Scenario: Developer requests validation of a code output
    Given an artifact produced by agent A
    When the developer designates agent B as validator
    Then no validator designation mechanism exists in the product today
```
