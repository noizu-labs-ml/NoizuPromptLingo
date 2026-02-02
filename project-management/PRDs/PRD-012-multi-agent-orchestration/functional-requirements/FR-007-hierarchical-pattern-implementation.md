# FR-007: Hierarchical Pattern Implementation

**Status**: Draft

## Description

Implements the hierarchical decomposition pattern with coordinator, teams, and structured aggregation.

## Interface

```python
class HierarchicalPattern(OrchestrationPattern):
    """Hierarchical task decomposition pattern."""

    def validate_config(self, config: dict) -> ValidationResult:
        """Validate hierarchical pattern configuration.

        Required fields:
        - coordinator: agent responsible for decomposition/aggregation
        - teams: list of team configs with agents and focus areas
        - decomposition: strategy and depth config
        - aggregation: merge strategy and conflict resolution
        """

    def execute(self, context: ExecutionContext) -> OrchestrationResult:
        """Execute hierarchical pattern.

        Steps:
        1. Coordinator decomposes problem into subtasks
        2. Assign subtasks to teams
        3. Teams work in parallel
        4. Coordinator aggregates results
        5. Resolve conflicts
        """

    def get_agent_assignments(self) -> list[AgentAssignment]:
        """Return list of agents needed (coordinator + all team agents)."""
```

## Behavior

- **Given** complex problem
- **When** execute() is called
- **Then** coordinator decomposes, teams execute, results aggregated

- **Given** conflicting team outputs
- **When** aggregation occurs
- **Then** conflicts resolved using configured strategy

- **Given** team dependencies exist
- **When** subtasks assigned
- **Then** execution order respects dependencies

## Edge Cases

- **Coordinator decomposition fails**: Abort with error
- **Team output incompatible**: Attempt conversion or escalate
- **Deadlock in dependencies**: Detected and broken
- **Team size exceeds limit**: Split into sub-teams

## Related User Stories

- US-060: Hierarchical Task Decomposition

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
