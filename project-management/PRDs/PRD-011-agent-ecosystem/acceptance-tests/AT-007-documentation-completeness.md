# AT-007: Agent Documentation Completeness

**Category**: Integration
**Related FR**: FR-010
**Status**: Not Started

## Description

Validates that all 45 agents have complete documentation including capabilities, examples, and usage patterns.

## Test Implementation

```python
def test_all_agents_documented():
    """Test all agents have complete documentation."""
    # Setup: Load all agents
    loader = AgentLoader()
    agents = loader.discover(resolve_agent_paths())

    # Check documentation for each agent
    incomplete = []
    for agent_meta in agents:
        definition = loader.load(agent_meta.id)
        report = validate_documentation(definition)

        if not report.is_complete:
            incomplete.append((agent_meta.id, report.missing_elements))

    # Assert: All agents fully documented
    assert len(incomplete) == 0, f"Incomplete docs: {incomplete}"

def test_capability_documentation():
    """Test all capabilities have inputs/outputs documented."""
    loader = AgentLoader()
    definition = loader.load("gopher-scout")

    for capability in definition.capabilities:
        assert capability.description, f"Missing description: {capability.id}"
        assert capability.inputs, f"Missing inputs: {capability.id}"
        assert capability.outputs, f"Missing outputs: {capability.id}"
```

## Acceptance Criteria

- [ ] All 45 agents have system prompts
- [ ] All capabilities have descriptions
- [ ] All capabilities document inputs/outputs
- [ ] At least one usage example per agent
- [ ] Dependencies documented

## Coverage

Covers:
- Documentation completeness
- Required elements validation
- Capability documentation
- Usage examples presence
