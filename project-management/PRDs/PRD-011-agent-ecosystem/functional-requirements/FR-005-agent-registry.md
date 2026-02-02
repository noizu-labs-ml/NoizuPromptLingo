# FR-005: Agent Registry Implementation

**Status**: Draft

## Description

The system must provide a runtime registry that stores, retrieves, and searches loaded agent definitions.

## Interface

```python
class AgentRegistry:
    """Runtime registry for available agents."""

    def register(self, agent: AgentDefinition) -> None:
        """Register an agent definition.

        Args:
            agent: Agent definition to register
        """

    def get(self, agent_id: str) -> AgentDefinition | None:
        """Retrieve agent by ID.

        Args:
            agent_id: Unique agent identifier

        Returns:
            Agent definition or None if not found
        """

    def list(self, category: str | None = None) -> list[AgentMetadata]:
        """List available agents, optionally filtered by category.

        Args:
            category: Optional category filter

        Returns:
            List of agent metadata objects
        """

    def search(self, query: str, capabilities: list[str] = None) -> list[AgentMetadata]:
        """Search agents by name, description, or capabilities.

        Args:
            query: Search query string
            capabilities: Optional capability filter

        Returns:
            List of matching agent metadata, ranked by relevance
        """

    def get_dependencies(self, agent_id: str) -> DependencyGraph:
        """Resolve agent dependencies for orchestration.

        Args:
            agent_id: Agent ID to resolve dependencies for

        Returns:
            Dependency graph with all required agents
        """
```

## Behavior

- **Given** an agent is registered
- **When** `get()` is called with the agent ID
- **Then** the agent definition is returned

- **Given** a search query
- **When** `search()` is called
- **Then** agents matching the query are returned ranked by relevance with >90% precision

## Edge Cases

- **Duplicate registration**: Overwrite existing, log warning
- **Unregistered agent ID**: Return None
- **Empty search query**: Return all agents
- **Circular dependencies**: Detect and prevent infinite loops

## Related User Stories

- US-003: Runtime Agent Registry

## Test Coverage

Expected test count: 14 tests
Target coverage: 100% for this FR
