# Persona: Dave the Fellow Developer

**ID**: P-005
**Created**: 2026-02-02T10:15:00Z
**Updated**: 2026-02-02T10:15:00Z

## Demographics

- **Role**: Senior Developer / Tech Lead
- **Tech Savvy**: High
- **Primary Device**: Desktop with multi-monitor setup, terminal-first

## Context

Works alongside AI agents and vibe coders in a synergistic workflow. Reviews agent-generated code, pairs with vibe coders on architecture decisions, and bridges the gap between rapid prototyping and production-ready code. Often the "cleanup crew" who refactors agent output into maintainable patterns.

## Goals

1. Leverage agent output without sacrificing code quality
2. Collaborate asynchronously with vibe coders
3. Review and approve agent-generated PRs efficiently
4. Share context with agents so they produce better code
5. Maintain team velocity while onboarding AI collaborators

## Pain Points

1. Agent code lacks consistent style/patterns
2. Vibe coder prototypes need significant hardening
3. Context doesn't carry over between agent sessions
4. Hard to give feedback that agents actually learn from
5. PRs from agents lack meaningful commit messages

## Behaviors

- Reviews agent artifacts before they're marked complete
- Writes detailed inline comments for agent learning
- Creates "recipe" documents that guide agent behavior
- Pairs with vibe coders via shared chat rooms
- Uses browser automation to test agent-built features

## Quotes

> "The agent got 80% right, but that last 20% is where the bugs live."

> "I don't want to rewrite their code—I want to teach them to write it better."

## Key MCP Command Usage

| Category | Primary Commands |
|----------|------------------|
| Reviews | `get_artifact`, `add_artifact_comment`, `get_artifact_history` |
| Chat | `send_message`, `create_todo`, `share_artifact` |
| Tasks | `list_tasks`, `update_task_status`, `add_task_message` |
| Browser | `screenshot_capture`, `screenshot_diff`, `browser_navigate` |
| Script Tools | `npl_load` (for understanding context), `git_tree` |

## Collaboration Patterns

### With AI Agents (P-001)
- Reviews agent artifacts using `get_artifact` and `add_artifact_comment` for inline feedback
- Shares architectural patterns via `create_artifact` and `share_artifact` in agent chat rooms
- Monitors agent task queues with `list_tasks` and unblocks via `add_task_message`
- Tests agent-built features using browser automation tools

### With Vibe Coders (P-003)
- Pairs on architecture decisions via `send_message` in shared chat rooms
- Reviews prototypes using `get_artifact_history` to see evolution
- Refactors rapid iterations while preserving artifact lineage
- Uses `screenshot_diff` to verify visual changes

### With Project Manager (P-004)
- Reviews task complexity using `list_tasks` and provides estimates
- Reports blockers via `add_task_message` with technical context
- Advises on agent capability for new features based on past artifact quality
- Tracks code quality trends through artifact review patterns

