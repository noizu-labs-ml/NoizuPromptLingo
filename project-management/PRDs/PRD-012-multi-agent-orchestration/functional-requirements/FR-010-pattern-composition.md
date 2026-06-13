# FR-010: Pattern Composition

**Status**: Draft

## Description

Enables composition of orchestration patterns into complex multi-stage workflows with dependencies and data flows.

## Interface

```python
class CompositePattern(OrchestrationPattern):
    """Composite orchestration pattern."""

    def validate_config(self, config: dict) -> ValidationResult:
        """Validate composite pattern configuration.

        Required fields:
        - stages: list of pattern configs
        - dependencies: DAG of stage dependencies
        - data_flow: input/output mappings between stages
        """

    def execute(self, context: ExecutionContext) -> OrchestrationResult:
        """Execute composite pattern.

        Steps:
        1. Validate dependency graph is acyclic
        2. Topologically sort stages
        3. Execute stages respecting dependencies
        4. Pass data between stages via mappings
        5. Return aggregated results
        """

    def get_agent_assignments(self) -> list[AgentAssignment]:
        """Return union of agents from all composed patterns."""
```

## Behavior

- **Given** composite pattern with 3 sub-patterns
- **When** execute() is called
- **Then** sub-patterns execute in dependency order with data flow

- **Given** stage B depends on stage A
- **When** stage A completes
- **Then** outputs mapped to stage B inputs automatically

- **Given** circular dependency detected
- **When** validate_config() is called
- **Then** ValidationError raised

## Edge Cases

- **Missing data mapping**: Use pattern defaults or fail early
- **Type mismatch in data flow**: Attempt conversion or error
- **Sub-pattern failure**: Propagate failure to composite or retry
- **Deep nesting**: Limit composition depth to 3 levels

## Related User Stories

- US-065: Composable Orchestration Patterns

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
