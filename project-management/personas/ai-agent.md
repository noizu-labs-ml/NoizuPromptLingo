# Persona: AI Agent

**ID**: P-001
**Created**: 2026-02-02T10:00:00Z
**Updated**: 2026-02-02T11:30:00Z

## Demographics

- **Role**: Autonomous AI agent (LLM-powered)
- **Tech Savvy**: Expert (programmatic API consumer)
- **Primary Interface**: MCP tools via Python client or SSE endpoint

## Context

An autonomous AI agent that operates as part of a multi-agent orchestration system. Uses MCP tools programmatically to accomplish tasks assigned by a controller or human operator. May run continuously, processing task queues, managing artifacts, coordinating with other agents, and automating browser-based workflows.

This persona represents general-purpose AI agents in the system, distinct from specialized workflow agents (idea-to-spec, prd-editor, tdd-tester, tdd-coder, tdd-debugger). These agents perform specific tasks like form automation, screenshot capture, web research, and artifact management.

## Goals

1. Execute assigned tasks efficiently with minimal human intervention
2. Maintain clear audit trails of all actions taken
3. Coordinate work with other agents and human stakeholders
4. Persist work products as versioned artifacts for review
5. Report status and request clarification when blocked
6. Load appropriate context (NPL components, project conventions) before starting work
7. Integrate seamlessly into TDD workflows and specialized agent orchestration

## Pain Points

1. Ambiguous task specifications that require human clarification
2. Lack of structured context (NPL components, project conventions) when starting tasks
3. Difficulty tracking which artifacts relate to which tasks
4. Limited visibility into what other agents have done in a session
5. Browser automation failures without clear error context
6. Task dependencies and blocking relationships not always explicit
7. Uncertainty about when to escalate issues vs. continue autonomously

## Behaviors

- Loads NPL context and project conventions before starting significant work
- Polls task queues for assigned work in priority order
- Creates artifacts for all significant outputs (code, documents, screenshots)
- Links artifacts to tasks for traceability
- Uses chat rooms to request clarification from humans or other agents
- Captures screenshots before and after UI changes for verification
- Updates task status as work progresses (pending → in_progress → completed)
- Leaves clear status messages when blocked or waiting for input

## Quotes

> "I need structured context loaded before I can effectively work on this codebase."

> "If I create an artifact, I need to link it to the task so reviewers can find it."

> "When I'm blocked, I should leave a clear message explaining what I need."

## Key MCP Tool Usage

| Category | Primary Tools |
|----------|---------------|
| Context Loading | `npl_load` (NPL components), `load_project_context` |
| Task Management | `list_tasks`, `get_task`, `update_task_status`, `add_task_artifact` |
| Artifacts | `create_artifact`, `add_revision`, `get_artifact`, `list_artifacts` |
| Chat & Collaboration | `send_message`, `get_notifications`, `create_todo`, `get_chat_feed` |
| Browser Automation | `browser_navigate`, `browser_click`, `browser_fill`, `screenshot_capture` |
| Web Research | `web_to_md` (fetch and convert web pages) |

## Related Agents

This general-purpose AI agent persona is distinct from specialized workflow agents:
- **Control Agent (P-006)**: Orchestrates multi-agent workflows
- **Sub-Agent (P-007)**: Executes delegated sub-tasks
- **Workflow Agents**: idea-to-spec, prd-editor, tdd-tester, tdd-coder, tdd-debugger

General AI agents (P-001) focus on task execution, artifact management, and automation rather than workflow orchestration or specialized development phases.
