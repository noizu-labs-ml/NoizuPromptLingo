# User Story: Add Executor System Test Suite (? → 80%)

**ID**: US-0100
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: Medium
**Status**: Draft
**PRD Group**: test_coverage
**Created**: 2026-02-02

## As a...
DevOps engineer improving test coverage for external executor system

## I want to...
Create comprehensive tests for executor lifecycle and Fabric pattern integration

## So that...
External agent execution is reliable for distributed work orchestration

## Acceptance Criteria
- [ ] Executor spawn and lifecycle management tested with 80%+ coverage
- [ ] Executor spawn tested (factory pattern, configuration)
- [ ] Lifecycle management tested (auto-spawn, idle timeout, cleanup)
- [ ] Fabric pattern integration tested (pattern application, context preservation)
- [ ] Context buffering tested (context injection, memory management)
- [ ] Background monitoring tested (health checks, timeout detection)
- [ ] Test suite passes in CI/CD with coverage report validation

## Implementation Notes

**Reference**: `.tmp/mcp-server/categories/10-external-executors.md`

**Modules to Test**:
- `src/npl_mcp/executor/manager.py` - Executor lifecycle management
- `src/npl_mcp/executor/fabric.py` - Fabric pattern integration

**Core Components**:

**Executor Manager**:
- Spawn executor with lifecycle parameters
- Track active executors by ID
- Monitor health (heartbeat, timeout)
- Auto-cleanup on idle or timeout
- Graceful termination with context cleanup

**Fabric Pattern System**:
- Apply Fabric patterns (atomic workflow units)
- Pattern discovery and enumeration
- Context preservation across pattern execution
- Pattern output capture and validation

**Database Table**: taskers (id, type, owner, context, status, created_at, expires_at, last_heartbeat)

**Test Categories**:
- Unit: Manager API, context formatting, pattern matching
- Integration: Database operations, process spawning, IPC
- Lifecycle: Auto-spawn conditions, idle detection, timeout handling
- Fabric: Pattern application, context injection, output capture
- Concurrency: Multiple executors, context isolation, race conditions
- Resource: Memory usage, process cleanup, fd leaks
- Performance: Spawn time, context buffer size, monitoring overhead

**Executor Lifecycle States**:
- SPAWNED: Initial state after process creation
- RUNNING: Executor responding to heartbeat
- IDLE: No activity for timeout_threshold
- TERMINATED: Clean shutdown (dismiss or timeout)
- FAILED: Process exited unexpectedly

**Test Framework**: pytest

**Target Coverage**: 80%+

**Current Coverage**: Unknown - needs documentation

**Dependencies**:
- Process spawning (subprocess or similar)
- Inter-process communication mechanism
- Fabric pattern library
- Database schema for taskers table

**Critical Test Scenarios**:
- Auto-spawn: Trigger conditions, spawn timing, configuration passing
- Idle timeout: Detect inactivity, graceful termination, cleanup
- Heartbeat: Health check frequency, timeout detection, restart
- Context buffering: Size limits, serialization/deserialization, memory cleanup
- Fabric patterns: Pattern discovery, parameter binding, error handling
- Concurrent executors: Isolation, resource sharing (if applicable)
- Graceful shutdown: Complete context cleanup, no orphaned processes
- Error recovery: Process crash, stale state cleanup, restart logic

**Related Knowledge**:
- Multi-agent orchestration patterns from `docs/arch/agent-orchestration.md`
- Task dependency chains (US-059)
- Agent handoff protocol (US-064, US-090)

## Related Stories
- US-101 (Expose Executor Spawn Tool)
- US-102 (Expose Executor Lifecycle Tools)
- US-103 (Expose Fabric Pattern Tools)
- US-059 (Chain Multi-Agent Workflows with Dependencies)
- US-064 (Agent Handoff Protocol)
- US-090 (Create Agent Handoff Protocol)

## Notes
Executor system enables distributed task execution via ephemeral agents. Currently not exposed as MCP tools - implementation exists in manager.py and fabric.py. Test coverage unknown. Implementation prerequisite for US-101, US-102, US-103 (executor tool exposure). Lifecycle management with auto-spawn and idle timeout is sophisticated feature requiring careful testing. Context buffering critical for performance and memory management. Fabric pattern integration enables reusable workflow automation.
