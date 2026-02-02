# Agent Management Summary

| Tool | Purpose | Required Params | Optional Params |
|------|---------|-----------------|-----------------|
| **Task** | Launch sub-agents | `subagent_type`, `prompt`, `description` | `model`, `resume`, `run_in_background` |
| **TaskOutput** | Get background task output | `task_id` | `block`, `timeout` |
| **TaskStop** | Stop background task | `task_id` | — |

**Key agents:**
- `general-purpose` - Complex research, multi-step tasks
- `Explore` - Fast codebase exploration
- `Plan` - Design implementation plans
- `Bash` - Command execution specialist
- `npl-idea-to-spec` - Transform ideas to personas/user stories
- `prd-editor` - Create PRD documents
- `tdd-tester` - Generate test suites from PRDs
- `tdd-coder` - Autonomous implementation (uses `mise run test-status`)
- `tdd-debugger` - Test execution and debugging (uses `mise run test-errors`)
- `tasker-*` - Context-efficient task execution (haiku/fast/sonnet/ultra/opus)
- `claude-code-guide` - Claude Code/Agent SDK/API questions

---

**Quick decision guide:**
- Need to find/understand code? → `Explore`
- Need implementation plan? → `Plan`
- Simple lookup task? → `tasker-haiku`
- Complex multi-step task? → `general-purpose`
- TDD workflow? → `npl-idea-to-spec` → `prd-editor` → `tdd-tester` → `tdd-coder` → `tdd-debugger`

**For expanded view:** [agents.md](agents.md) — Full documentation with usage examples, all agent types, tool restrictions, and parameter details. Load for unfamiliar agents or advanced use cases.