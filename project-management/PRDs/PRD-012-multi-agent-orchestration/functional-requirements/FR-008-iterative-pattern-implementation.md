# FR-008: Iterative Pattern Implementation

**Status**: Draft

## Description

Implements the iterative refinement spiral with analyzer, enhancer, evaluator, and quality-based termination.

## Interface

```python
class IterativePattern(OrchestrationPattern):
    """Iterative refinement spiral pattern."""

    def validate_config(self, config: dict) -> ValidationResult:
        """Validate iterative pattern configuration.

        Required fields:
        - initial: agent config for initial draft
        - iterations: max count, min improvement, stages
        - termination: condition and threshold
        """

    def execute(self, context: ExecutionContext) -> OrchestrationResult:
        """Execute iterative pattern.

        Steps:
        1. Produce initial draft
        2. Loop:
           a. Analyze gaps
           b. Enhance content
           c. Evaluate quality
           d. Check termination condition
        3. Return final artifact
        """

    def get_agent_assignments(self) -> list[AgentAssignment]:
        """Return list of agents needed (initial + iteration stages)."""
```

## Behavior

- **Given** iterative pattern with threshold 0.85
- **When** execute() is called
- **Then** loop continues until quality >= 0.85 or max iterations

- **Given** quality improvement < min_improvement
- **When** iteration completes
- **Then** termination triggered with "diminishing returns" status

- **Given** max iterations reached
- **When** quality < threshold
- **Then** execution completes with "incomplete" status

## Edge Cases

- **Quality decreases**: Revert to previous version and retry
- **Analyzer/enhancer loop**: Break after 2 failed improvements
- **Initial draft fails**: Retry with modified prompt
- **Evaluator always returns 0**: Fallback to iteration count

## Related User Stories

- US-061: Iterative Refinement with Quality Scoring

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
