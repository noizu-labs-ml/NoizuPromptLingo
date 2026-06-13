# FR-006: Agent Dependency Resolution

**Status**: Draft

## Description

The system must resolve agent dependencies to construct dependency graphs for multi-agent orchestration patterns.

## Interface

```python
class DependencyGraph:
    """Represents agent dependency relationships."""

    def add_dependency(self, agent_id: str, depends_on: str) -> None:
        """Add a dependency edge."""

    def topological_sort(self) -> list[str]:
        """Return agents in dependency order (leaves first).

        Returns:
            List of agent IDs in topological order

        Raises:
            CyclicDependencyError: If circular dependencies detected
        """

    def get_required_agents(self, agent_id: str) -> set[str]:
        """Get all agents required (direct and transitive).

        Args:
            agent_id: Root agent ID

        Returns:
            Set of all required agent IDs
        """
```

## Behavior

- **Given** an agent with dependencies
- **When** dependencies are resolved
- **Then** a complete dependency graph is constructed including transitive dependencies

- **Given** a dependency graph
- **When** topologically sorted
- **Then** agents are ordered so dependencies come before dependents

## Edge Cases

- **Circular dependencies**: Detect and raise `CyclicDependencyError`
- **Missing dependency**: Raise `MissingAgentError` with agent ID
- **Self-dependency**: Validation error
- **Deep transitive chains**: Handle efficiently (no O(n²) behavior)

## Related User Stories

- US-003: Runtime Agent Registry

## Test Coverage

Expected test count: 10 tests
Target coverage: 100% for this FR
