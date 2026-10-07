# Review: Facilitate Multi-Persona Consensus

- **Story**: `project-management/user-stories/US-058-facilitate-multi-persona-consensus.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No consensus mechanism exists in the Python MCP server. The orchestration engine's own module docstring states the boundary: `src/npl_mcp/orchestration/__init__.py:3-5` — "This package provides the pipeline orchestration pattern … Additional patterns (consensus, hierarchical, iterative, synthesis) are planned for future releases." Only `PipelinePattern` (linear, sequential) is registered (`src/npl_mcp/orchestration/patterns.py`, `pipeline.py`). Debate mode is an agent-prompt-layer capability (per the story's own technical notes about `npl-persona --debate`), not a system feature: there is no agreement-level signaling, no synthesis of common ground/disagreement, no voting or weighted scoring, no worklog logging of a consensus process, and no decision-artifact attribution structure in `src/npl_mcp/`. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Multiple personas invoked in "debate" or "consensus" mode | Partially Met | debate mode exists only at the persona-prompt layer (story technical notes); no consensus mode — `src/npl_mcp/orchestration/__init__.py:4-5` lists consensus as planned/future |
| Persona responses indicate agreement level or objections | Not Met | no evidence found |
| System synthesizes common ground and disagreement points | Not Met | no evidence found |
| Voting or weighted scoring for final decisions | Not Met | no evidence found |
| Consensus process logged to session worklog | Not Met | no evidence found; no worklog instrumentation exists |
| Final decision artifacts include attribution and dissenting views | Not Met | no evidence found |

## Gaps / Risks

- Entire synthesis/voting layer unimplemented; the only groundwork is the (extensible) `OrchestrationPattern` registry in `src/npl_mcp/orchestration/patterns.py:26-69`, which is the natural insertion point for a future consensus pattern.

## BDD Scenario

```gherkin
Feature: Multi-persona consensus on an architecture decision

  Scenario: Personas debate and converge
    Given three personas with conflicting positions on a decision
    When the project manager requests a consensus decision
    Then no consensus mode exists in the product today — only prompt-level debate
```
