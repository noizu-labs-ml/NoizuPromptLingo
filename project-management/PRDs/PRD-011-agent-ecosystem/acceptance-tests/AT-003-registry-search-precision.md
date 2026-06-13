# AT-003: Registry Search Precision

**Category**: Integration
**Related FR**: FR-005
**Status**: Not Started

## Description

Validates that registry search returns relevant agents with >90% precision.

## Test Implementation

```python
def test_registry_search_precision():
    """Test search returns relevant results with >90% precision."""
    # Setup: Register all agents
    registry = AgentRegistry()
    loader = AgentLoader()
    for agent in loader.discover(resolve_agent_paths()):
        registry.register(loader.load(agent.id))

    # Test cases with expected results
    test_cases = [
        ("test", ["npl-tester", "npl-qa-tester", "npl-grader"]),
        ("documentation", ["npl-technical-writer", "npl-system-analyzer"]),
        ("security", ["npl-threat-modeler", "npl-code-reviewer"]),
        ("build", ["npl-build-manager", "npl-integrator"]),
    ]

    precision_scores = []
    for query, expected in test_cases:
        results = registry.search(query)
        result_ids = [r.id for r in results[:5]]  # Top 5 results
        relevant = sum(1 for id in result_ids if id in expected)
        precision = relevant / len(result_ids) if result_ids else 0
        precision_scores.append(precision)

    # Assert: Average precision >90%
    avg_precision = sum(precision_scores) / len(precision_scores)
    assert avg_precision >= 0.90, f"Precision: {avg_precision:.2%} (target: >=90%)"
```

## Acceptance Criteria

- [ ] Search by capability returns relevant agents
- [ ] Search by category filters correctly
- [ ] Average precision across test cases >= 90%
- [ ] Results ranked by relevance

## Coverage

Covers:
- Search relevance
- Precision metric validation
- Multiple search scenarios
