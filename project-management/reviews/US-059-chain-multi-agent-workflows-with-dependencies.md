# Review: Chain Multi-Agent Workflows with Dependencies

- **Story**: `project-management/user-stories/US-059-chain-multi-agent-workflows-with-dependencies.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python MCP server has a minimal orchestration engine: `OrchestrationPattern` base + registry (`src/npl_mcp/orchestration/patterns.py:17-69`), a strictly linear `PipelinePattern` that runs stages sequentially with quality gates and retry (`src/npl_mcp/orchestration/pipeline.py:31-84`), `PipelineStage`/`QualityGate` primitives (`src/npl_mcp/orchestration/stages.py`), and a TDD workflow constructor (`src/npl_mcp/orchestration/tdd_pipeline.py:47+`). This covers sequential chaining with failure-blocking, but there is no DAG: no branching, no agent assignment per node, no declared prerequisites/outputs, no worklog persistence (results live in an in-memory dict), and no visualization. The package docstring scopes it explicitly: sequential pipeline only, other patterns "planned for future releases" (`src/npl_mcp/orchestration/__init__.py:3-5`). The task store (`src/npl_mcp/tasks/tasks.py`) has priority fields but no dependency edges.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Define workflow as DAG with agent assignments per node | Not Met | only linear `PipelinePattern` exists; `orchestration/__init__.py:3-5`; no graph structure in `stages.py` |
| Agents declare prerequisites and outputs | Partially Met | `PipelineStage` accepts a quality-gate predicate and stages pass results through a shared context dict (`pipeline.py:31-49`, `stages.py`), an implicit output contract — but there is no explicit agent assignment or prerequisite declaration |
| Workflow engine tracks completion state and triggers next agent | Partially Met | `pipeline.py:39-84` tracks `RunStatus`/per-stage `StageStatus` and advances sequentially with gate checks; no cross-agent triggering, purely in-process |
| Failed agent tasks block downstream dependencies | Met | `pipeline.py:47-70` — exhausted gate retries set `RunStatus.FAILED` and return before later stages run |
| Workflow state persists to session worklog | Not Met | results kept in `self.results` in memory only; no persistence call anywhere in `pipeline.py` |
| Visualization of workflow progress (graph or timeline) | Not Met | no evidence found; `status()` returns a dict only (`pipeline.py:88+`) |

## Gaps / Risks

- Failure semantics verified by code read: blocking works, but the retry loop reuses the same stage object's `retries` counter, so a `PipelineStage` instance cannot be reused across runs without reset.
- No persistence means a crashed run loses all state — a prerequisite for any real multi-agent dependency engine.

## BDD Scenario

```gherkin
Feature: Chain agents in a dependency-ordered workflow

  Scenario: Sequential pipeline with quality gate
    Given a TDD pipeline (idea-to-spec → PRD → tests → code)
    When a stage's quality gate fails after max retries
    Then the pipeline reports status "failed" and downstream stages never execute

  Scenario: Branching DAG workflow
    Given a workflow where two agents run in parallel then merge
    When the workflow is defined
    Then no DAG definition surface exists in the product today
```
