# Review: Visualize Multi-Agent Decision Trees

- **Story**: `project-management/user-stories/US-062-visualize-multi-agent-decision-trees.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No decision-tree or graph visualization exists in the Python MCP server. Greps for `mermaid`, `graphviz`, and `decision tree` across `src/npl_mcp/` return no hits. The orchestration engine tracks only linear stage state as Python objects (`src/npl_mcp/orchestration/pipeline.py:88+` returns a status dict; no rendering, no node metadata with agent/timestamp/rationale, no edge labels, no filtering, no export). No worklog/tree event store exists to visualize in the first place. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Decision tree rendered as interactive mermaid/graphviz diagram | Not Met | no evidence found in `src/npl_mcp/` |
| Each node shows agent, timestamp, decision, rationale | Not Met | no evidence found |
| Edges labeled with dependencies or blocking conditions | Not Met | no evidence found |
| Clickable nodes link to detailed artifacts or session logs | Not Met | no evidence found |
| Export to markdown, SVG, or interactive HTML | Not Met | no evidence found |
| Filter by persona, time range, or decision outcome | Not Met | no evidence found |

## Gaps / Risks

- Fully unimplemented and doubly blocked: both the visualization layer and the underlying tree-structured decision/worklog data (vs. linear pipeline state) are absent.

## BDD Scenario

```gherkin
Feature: Visualize how a multi-agent decision was reached

  Scenario: PM opens a decision tree for an architecture decision
    Given a completed multi-agent workflow
    When the PM opens the decision visualization
    Then no such view exists in the product today
```
