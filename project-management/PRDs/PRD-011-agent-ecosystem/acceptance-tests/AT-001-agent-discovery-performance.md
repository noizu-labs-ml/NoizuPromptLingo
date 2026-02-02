# AT-001: Agent Discovery Performance

**Category**: Integration
**Related FR**: FR-001, FR-002
**Status**: Not Started

## Description

Validates that agent discovery completes within performance requirements (<100ms for typical projects).

## Test Implementation

```python
def test_agent_discovery_performance():
    """Test agent discovery completes under 100ms."""
    # Setup: Create typical project structure with 45 agents
    loader = AgentLoader()
    paths = resolve_agent_paths()

    # Action: Time discovery operation
    start_time = time.perf_counter()
    agents = loader.discover(paths)
    elapsed_ms = (time.perf_counter() - start_time) * 1000

    # Assert: Discovery completes within limit
    assert elapsed_ms < 100, f"Discovery took {elapsed_ms}ms (limit: 100ms)"
    assert len(agents) == 45, "Should discover all 45 agents"
```

## Acceptance Criteria

- [ ] Discovery scans all 4 path locations
- [ ] Discovery completes in <100ms
- [ ] All 45 agents discovered
- [ ] No duplicate agent IDs returned

## Coverage

Covers:
- Normal path: Typical project setup
- Performance constraint validation
- Complete agent set discovery
