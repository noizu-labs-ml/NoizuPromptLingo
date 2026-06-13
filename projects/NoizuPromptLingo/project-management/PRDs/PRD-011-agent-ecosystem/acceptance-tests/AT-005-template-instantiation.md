# AT-005: Agent Template Instantiation

**Category**: Integration
**Related FR**: FR-007, FR-008
**Status**: Not Started

## Description

Validates that agent templates can be instantiated with custom parameters and variable substitution works correctly.

## Test Implementation

```python
def test_template_instantiation():
    """Test template-based agent instantiation."""
    # Setup: Load TDD builder template
    loader = AgentLoader()
    tdd_template = loader.load("tdd-driven-builder")

    # Action: Instantiate with custom config
    config = {
        "coverage_threshold": 95,
        "test_framework": "pytest"
    }
    instance = loader.instantiate(tdd_template, config)

    # Assert: Configuration applied
    assert instance.config["coverage_threshold"] == 95
    assert "95%" in instance.prompt  # Variable substitution
    assert "pytest" in instance.prompt

def test_template_parameter_validation():
    """Test template parameter validation."""
    loader = AgentLoader()
    template = loader.load("tdd-driven-builder")

    # Invalid range
    with pytest.raises(ValidationError):
        loader.instantiate(template, {"coverage_threshold": 150})

    # Invalid enum option
    with pytest.raises(ValidationError):
        loader.instantiate(template, {"test_framework": "invalid"})
```

## Acceptance Criteria

- [ ] Template parameters override defaults
- [ ] Variable substitution in prompts works
- [ ] Parameter validation enforces constraints
- [ ] Invalid configurations rejected
- [ ] Custom variants load without errors

## Coverage

Covers:
- Template instantiation
- Configuration override
- Variable substitution
- Parameter validation
- Error conditions
