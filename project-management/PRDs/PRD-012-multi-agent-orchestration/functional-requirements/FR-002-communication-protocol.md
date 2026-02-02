# FR-002: Communication Protocol

**Status**: Draft

## Description

Structured inter-agent communication via worklog entries supporting handoff, request/response, broadcast, and status updates.

## Interface

```python
class WorklogEntry:
    """Structured worklog entry for agent communication."""

    id: str                    # Unique entry ID (UUID)
    timestamp: str             # ISO-8601 timestamp
    source_agent: str          # Sending agent ID
    target_agent: str          # Receiving agent ID or "*" for broadcast
    entry_type: EntryType      # handoff | request | response | status | error
    payload: dict              # Entry-specific data

class CommunicationProtocol:
    """Manages inter-agent communication patterns."""

    def handoff(self, from_agent: str, to_agent: str, outputs: list[Artifact], next_steps: list[str]) -> WorklogEntry:
        """Create handoff entry passing work to next agent."""

    def request(self, from_agent: str, to_agent: str, action: str, params: dict) -> WorklogEntry:
        """Create request entry asking agent for specific output."""

    def respond(self, request_id: str, from_agent: str, result: dict) -> WorklogEntry:
        """Create response entry replying to previous request."""

    def broadcast(self, from_agent: str, message: str, metadata: dict) -> WorklogEntry:
        """Create broadcast entry notifying all agents."""

    def status_update(self, from_agent: str, progress: float, status: str) -> WorklogEntry:
        """Create status entry reporting progress."""
```

## Behavior

- **Given** agent completes work
- **When** handoff() is called
- **Then** worklog entry created with outputs and next steps

- **Given** agent needs information from another agent
- **When** request() is called
- **Then** request entry written and response monitored

- **Given** broadcast message sent
- **When** broadcast() is called
- **Then** all agents in orchestration receive entry

## Edge Cases

- **Target agent offline**: Entry queued for later delivery
- **Malformed payload**: Entry rejected with validation error
- **Circular handoff**: Detected and blocked
- **Broadcast storm**: Rate limiting applied

## Related User Stories

- US-058: Consensus-Driven Feature Assessment
- US-060: Hierarchical Task Decomposition
- US-062: Parallel Analysis with Synthesis
- US-079: Worklog-Based Communication

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
