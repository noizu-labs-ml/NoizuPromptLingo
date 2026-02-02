# Agent Management

## Task

**Purpose**: Launch specialized sub-agents for complex multi-step tasks.

**When to use**:
- Complex searches requiring multiple attempts
- Multi-step tasks needing autonomous work
- Planning implementation approaches
- Creating PRDs, specs, or documentation
- Running TDD workflows

**Parameters**:
- `subagent_type` (required): Agent type to launch
- `prompt` (required): Task description
- `description` (required): Short 3-5 word summary (max 200 chars)
- `model` (optional): "sonnet", "opus", "haiku"
- `resume` (optional): Agent ID to resume — Retains full conversation context
- `run_in_background` (optional): Run async

**Available agents**:

| Agent Type | Purpose | Tools Available |
|------------|---------|-----------------|
| `general-purpose` | Complex research, multi-step tasks | All tools |
| `Explore` | Fast codebase exploration | All except Task, Edit, Write |
| `Plan` | Design implementation plans | All except Task, Edit, Write |
| `Bash` | Command execution specialist | Bash only |
| `npl-idea-to-spec` | Transform ideas to personas/user stories | All tools |
| `npl-prd-editor` | Create PRD documents | All tools |
| `npl-tdd-tester` | Generate test suites from PRDs | All tools |
| `npl-tdd-coder` | Autonomous implementation (uses `mise run test-status`) | All tools |
| `npl-tdd-debugger` | Test execution and debugging (uses `mise run test-errors`) | All tools |
| `npl-tasker-haiku` / `npl-tasker-fast` / `npl-tasker-sonnet` / `npl-tasker-ultra` / `npl-tasker-opus` | Context-efficient task execution | All tools |
| `claude-code-guide` | Claude Code/Agent SDK/API questions | Glob, Grep, Read, WebFetch, WebSearch |

**Agent selection quick reference**:

| Your goal | Use agent |
|-----------|-----------|
| "I need to find X in the codebase" | `Explore` |
| "I need to understand how this system works" | `Explore` |
| "I need to design how to implement X" | `Plan` |
| "I need to transform an idea into user stories" | `npl-idea-to-spec` |
| "I need to write a PRD from user stories" | `npl-prd-editor` |
| "I need to create tests from a PRD" | `npl-tdd-tester` |
| "I need to implement a feature from a PRD" | `npl-tdd-coder` |
| "My tests are failing, I need to debug" | `npl-tdd-debugger` |
| "I have a simple lookup task (file exists? grep for X?)" | `npl-tasker-haiku` |
| "I have a complex multi-step task" | `general-purpose` |

**Usage**:

Explore codebase:
```json
{
  "subagent_type": "Explore",
  "description": "Find error handling",
  "prompt": "Find all error handling code and explain the patterns used",
  "model": "haiku"
}
```

Create implementation plan:
```json
{
  "subagent_type": "Plan",
  "description": "Plan authentication feature",
  "prompt": "Design an implementation plan for adding JWT authentication to the API"
}
```

Run in background:
```json
{
  "subagent_type": "npl-tdd-coder",
  "description": "Implement feature autonomously",
  "prompt": "Implement the feature described in docs/PRDs/auth.md",
  "run_in_background": true
}
```

Resume previous agent:
```json
{
  "subagent_type": "Explore",
  "description": "Continue exploration",
  "prompt": "Now look at the test files",
  "resume": "previous-agent-id"
}
```

**Context reduction pattern**:
When launching multiple similar agents, store shared setup in a temp file (e.g., `/tmp/claude-XXX/.../scratchpad/task.md`). Each agent reads this file instead of receiving duplicate setup prompts, reducing token usage.

**Key points**:
- Agents have full conversation context before tool call
- Can reference earlier discussion: "investigate the error discussed above"
- Agents return single message when done
- Use `model: "haiku"` for quick/cheap tasks
- Check for existing agents before spawning new ones

---

## TaskOutput

**Purpose**: Retrieve output from a running or completed background task.

**Parameters**:
- `task_id` (required): Background task ID
- `block` (optional): Wait for completion (default: true)
- `timeout` (optional): Max wait in ms (default: 30000, max: 600000)

---

## TaskStop

**Purpose**: Stop a running background task.

**Parameters**:
- `task_id` (required): Background task ID