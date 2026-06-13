# AT-002: Complete Schema Validation

**Category**: Unit
**Related FR**: FR-003, FR-004
**Status**: Not Started

## Description

Validates that all 45 agent definitions pass schema validation with 100% compliance.

## Test Implementation

```python
def test_all_agents_pass_validation():
    """Test all 45 agents have valid definitions."""
    # Setup: Load all agent definitions
    loader = AgentLoader()
    agents = loader.discover(resolve_agent_paths())

    # Action: Validate each agent
    results = []
    for agent_meta in agents:
        definition = loader.load(agent_meta.id)
        result = loader.validate(definition)
        results.append((agent_meta.id, result))

    # Assert: All pass validation
    failed = [(id, r) for id, r in results if not r.is_valid]
    assert len(failed) == 0, f"Failed validation: {failed}"
    assert len(results) == 45, "Should validate all 45 agents"
```

## Acceptance Criteria

- [ ] All 45 agents have required fields
- [ ] All agent IDs follow format (lowercase-with-hyphens)
- [ ] All versions use semantic versioning
- [ ] All categories are valid
- [ ] 100% validation pass rate

## Coverage

Covers:
- Required field validation
- Format constraint checking
- Semantic validation
- Complete agent coverage
