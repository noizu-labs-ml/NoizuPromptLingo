# US-059 - Chain Multi-Agent Workflows with Dependencies

**ID**: US-059
**Persona**: P-004 - Project Manager
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a project manager, I want to chain multiple specialized agents in sequential workflows with explicit dependencies so that complex tasks are decomposed and executed reliably.

## Acceptance Criteria

- [ ] Define workflow as DAG with agent assignments per node
- [ ] Agents declare prerequisites and outputs
- [ ] Workflow engine tracks completion state and triggers next agent
- [ ] Failed agent tasks block downstream dependencies
- [ ] Workflow state persists to session worklog
- [ ] Visualization of workflow progress (graph or timeline)

## Technical Notes

Current orchestration is manual (piped `@persona` invocations). No explicit workflow DAG or state tracking exists.

## Dependencies

- Related stories: US-032
- Related personas: P-004

## Background

Question: How do users orchestrate complex workflows that span multiple specialized agents sequentially?

This story extends beyond simple task assignment (US-032) to enable DAG-based workflow orchestration where agents execute in a specific order based on declared dependencies. The workflow engine should track state, handle failures, and provide visibility into execution progress.

## Key Gap

No workflow engine exists to model agent execution as directed acyclic graphs with dependency tracking and automatic triggering.
