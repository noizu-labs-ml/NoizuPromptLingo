# Review: Parallel Agent Synthesis

- **Story**: `project-management/user-stories/US-065-parallel-agent-synthesis.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No mechanism exists to run multiple agents in parallel on the same task and synthesize/compare their outputs. The word "parallel" appears in `src/` only for concurrent image description fetches (`src/npl_mcp/markdown/image_descriptions.py:84,118`). `npl-persona team synthesize` (`src/npl_persona/teams.py:254`, `src/npl_persona/cli.py:417-418`) synthesizes *team member knowledge domains* into a document — it does not run agents in parallel, compare outputs, or pick a winner. No comparison matrix, merge/select-winner option, or per-run quality/time metrics exist. Confidence: high (keyword sweep across both repos found no candidate).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Specify multiple agents for same task with parallel execution | Not Met | no evidence found (`grep -rn parallel src/` hits only image_descriptions) |
| Each agent works independently without cross-contamination | Not Met | no evidence found |
| Synthesis agent compares outputs and identifies best practices | Not Met | `src/npl_persona/teams.py:254` `synthesize_knowledge` merges team expertise, not agent run outputs |
| Synthesis report includes comparison matrix and recommendation | Not Met | no evidence found (`show_matrix` at `teams.py:419` is an expertise matrix of team members, unrelated) |
| Option to merge outputs or select single winner | Not Met | no evidence found |
| Performance metrics tracked (time, quality scores) | Not Met | no evidence found |

## Gaps / Risks

- Story's own technical note remains accurate: npl-persona `--parallel` capability referenced in the story is not present in `src/npl_persona/cli.py` either — even the prerequisite parallel execution is absent.
- Adjacent-but-different functionality (`team synthesize`, `team matrix`) risks being mistaken for this story during status rollups.

## BDD Scenario

```gherkin
Feature: Parallel agent synthesis

  Scenario: PM compares three agent approaches (NOT YET POSSIBLE)
    Given a project manager with three candidate agent configurations
    When they request the same task be run by all three agents in parallel
    Then no CLI, MCP tool, or workflow exists today to launch the parallel runs
    And no synthesis report, comparison matrix, or winner-selection option is produced
```
