# AT-004: Agent Dependency Resolution

**Category**: Integration
**Related FR**: FR-006
**Status**: Not Started

## Description

Validates that agent dependencies are resolved correctly including transitive dependencies and cycle detection.

## Test Implementation

```python
def test_dependency_resolution():
    """Test multi-agent dependency resolution."""
    # Setup: Create dependency graph
    # nimps -> npl-prd-manager -> npl-templater
    registry = AgentRegistry()
    loader = AgentLoader()

    # Load agents with dependencies
    nimps = loader.load("nimps")
    prd_manager = loader.load("npl-prd-manager")
    templater = loader.load("npl-templater")

    registry.register(nimps)
    registry.register(prd_manager)
    registry.register(templater)

    # Action: Resolve dependencies
    graph = registry.get_dependencies("nimps")
    required = graph.get_required_agents("nimps")
    sorted_agents = graph.topological_sort()

    # Assert: Dependencies resolved correctly
    assert "npl-prd-manager" in required
    assert "npl-templater" in required  # Transitive dependency
    assert sorted_agents.index("npl-templater") < sorted_agents.index("npl-prd-manager")
    assert sorted_agents.index("npl-prd-manager") < sorted_agents.index("nimps")

def test_circular_dependency_detection():
    """Test circular dependency detection."""
    graph = DependencyGraph()
    graph.add_dependency("A", "B")
    graph.add_dependency("B", "C")
    graph.add_dependency("C", "A")  # Circular

    with pytest.raises(CyclicDependencyError):
        graph.topological_sort()
```

## Acceptance Criteria

- [ ] Direct dependencies resolved
- [ ] Transitive dependencies resolved
- [ ] Topological sort returns valid order
- [ ] Circular dependencies detected and rejected

## Coverage

Covers:
- Dependency graph construction
- Topological ordering
- Cycle detection
- Transitive dependency resolution
