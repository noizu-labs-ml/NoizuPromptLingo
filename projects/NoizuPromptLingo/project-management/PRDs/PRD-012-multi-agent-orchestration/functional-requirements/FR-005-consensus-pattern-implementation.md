# FR-005: Consensus Pattern Implementation

**Status**: Draft

## Description

Implements the consensus-driven analysis pattern with parallel analysts, weighted voting, and synthesis.

## Interface

```python
class ConsensusPattern(OrchestrationPattern):
    """Consensus-driven analysis pattern."""

    def validate_config(self, config: dict) -> ValidationResult:
        """Validate consensus pattern configuration.

        Required fields:
        - analysts: list of agent configs with perspective and weight
        - synthesizer: agent config for synthesis
        - decision: output format config
        """

    def execute(self, context: ExecutionContext) -> OrchestrationResult:
        """Execute consensus pattern.

        Steps:
        1. Spawn analyst agents in parallel
        2. Collect individual reports
        3. Apply weighted voting if configured
        4. Spawn synthesizer agent
        5. Produce final recommendation
        """

    def get_agent_assignments(self) -> list[AgentAssignment]:
        """Return list of agents needed for consensus."""
```

## Behavior

- **Given** consensus pattern configuration
- **When** execute() is called
- **Then** analysts run in parallel, synthesizer combines results

- **Given** weighted voting enabled
- **When** votes collected
- **Then** weights applied to analyst recommendations

- **Given** dissenting opinions exist
- **When** synthesis complete
- **Then** dissents included in final output

## Edge Cases

- **Analyst failure**: Proceed with remaining analysts if threshold met
- **Synthesizer failure**: Return raw reports without synthesis
- **Weight sum != 1.0**: Normalize weights automatically
- **Tie vote**: Escalate to human decision

## Related User Stories

- US-058: Consensus-Driven Feature Assessment

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
