# FR-001: Agent Loader System

**Status**: Draft

## Description

The system must provide an `AgentLoader` class that discovers and loads agent definitions from a hierarchical file system.

## Interface

```python
class AgentLoader:
    """Discovers and loads agent definitions from hierarchical paths."""

    def discover(self, paths: list[Path]) -> list[AgentMetadata]:
        """Scan paths for agent definition files.

        Args:
            paths: List of directories to scan for agent definitions

        Returns:
            List of agent metadata objects for discovered agents
        """

    def load(self, agent_id: str) -> AgentDefinition:
        """Load and validate a specific agent definition.

        Args:
            agent_id: Unique identifier for the agent

        Returns:
            Validated agent definition object
        """

    def validate(self, definition: AgentDefinition) -> ValidationResult:
        """Validate agent definition against schema.

        Args:
            definition: Agent definition to validate

        Returns:
            Validation result with errors/warnings
        """

    def instantiate(self, definition: AgentDefinition, config: dict) -> AgentInstance:
        """Create configured agent instance.

        Args:
            definition: Agent definition to instantiate
            config: Configuration overrides

        Returns:
            Configured agent instance ready for execution
        """
```

## Behavior

- **Given** a list of paths to scan
- **When** `discover()` is called
- **Then** all valid agent definition files are located and metadata extracted

- **Given** a valid agent ID
- **When** `load()` is called
- **Then** the agent definition is parsed, validated, and returned

## Edge Cases

- **Missing paths**: Return empty list, log warning
- **Invalid agent files**: Skip and log validation errors
- **Duplicate agent IDs**: Use first found, warn about duplicates
- **Permission errors**: Skip inaccessible paths, continue discovery

## Related User Stories

- US-001: Agent Discovery System
- US-002: Agent Schema Validation
- US-004: Agent Instantiation and Configuration

## Test Coverage

Expected test count: 12 tests
Target coverage: 100% for this FR
