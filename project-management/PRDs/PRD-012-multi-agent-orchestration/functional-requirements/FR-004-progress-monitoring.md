# FR-004: Progress Monitoring

**Status**: Draft

## Description

Tracks orchestration progress and provides visibility into current stage, metrics, and estimated completion.

## Interface

```python
class ProgressMonitor:
    """Tracks orchestration progress and provides visibility."""

    def get_progress(self, execution_id: str) -> ProgressReport:
        """Get current progress across all stages/agents.

        Args:
            execution_id: Unique execution identifier

        Returns:
            ProgressReport with stage statuses and overall progress
        """

    def get_timeline(self, execution_id: str) -> list[TimelineEvent]:
        """Get chronological event timeline.

        Args:
            execution_id: Unique execution identifier

        Returns:
            List of TimelineEvent objects in chronological order
        """

    def get_metrics(self, execution_id: str) -> Metrics:
        """Get execution metrics (duration, tokens, errors).

        Args:
            execution_id: Unique execution identifier

        Returns:
            Metrics object with aggregated statistics
        """
```

## Behavior

- **Given** orchestration in progress
- **When** get_progress() is called
- **Then** current stage, agent activity, and progress percentage returned

- **Given** orchestration completed
- **When** get_timeline() is called
- **Then** chronological list of all events returned

- **Given** orchestration has consumed resources
- **When** get_metrics() is called
- **Then** token count, duration, and error count returned

## Edge Cases

- **Execution not found**: Raise ExecutionNotFoundError
- **Progress calculation overflow**: Cap at 100%
- **Negative duration**: Handle clock skew gracefully
- **Missing metrics data**: Return partial metrics with nulls

## Related User Stories

- US-059: Pipeline Execution with Quality Gates
- US-061: Iterative Refinement with Quality Scoring
- US-063: Progress Visibility for Orchestrations

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
