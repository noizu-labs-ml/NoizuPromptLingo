# Claude Code Tools Summary

Quick reference guide to Claude Code's built-in tools.

---

## Quick Reference

| Task | Tool | Call Example |
|------|------|--------------|
| Read file | Read | `Read(file_path="/path/file.py")` |
| Create file | Write | `Write(file_path="/path/file.py", content="...")` |
| Edit file | Edit | `Edit(file_path="/path/file.py", old_string="old", new_string="new")` |
| Find files | Glob | `Glob(pattern="**/*.py")` |
| Search content | Grep | `Grep(pattern="def hello", output_mode="files_with_matches")` |
| Run command | Bash | `Bash(command="git status", description="Show working tree status")` |
| Explore codebase | Task | `Task(subagent_type="Explore", prompt="Find and explain authentication patterns", description="Find auth code")` |
| Plan feature | EnterPlanMode | `EnterPlanMode()` |
| Track tasks | TaskCreate | `TaskCreate(subject="...", description="...", activeForm="...")` |
| Ask user | AskUserQuestion | `AskUserQuestion(questions=[...])` |
| Run skill | Skill | `Skill(skill="commit")` |
| Fetch web | WebFetch | `WebFetch(url="https://...", prompt="...")` |
| Search web | WebSearch | `WebSearch(query="term 2026")` |

---

## Essential Tools (Top 5)

| Tool | Purpose | When to use |
|------|---------|-------------|
| **Read** | View file contents | Before editing, checking code, reviewing docs |
| **Edit** | Make exact text changes | Modifying existing code/config |
| **Glob** | Find files by pattern | Locating test files, finding all `.py` files |
| **Grep** | Search file contents | Finding function definitions, locating where code is used |
| **Bash** | Run shell commands | Git ops, running tests, installing deps |

**Key principles:**
1. Always use **absolute paths** (e.g., `/home/user/project/file.py`)
2. **Read before editing** → Use Read tool, then Edit tool
3. **Prefer specialized tools** over Bash (Read instead of `cat`, Glob instead of `find`)
4. Run independent operations in **parallel** (send multiple tool calls in one message)

---

## File Operations

**Tools:** Read, Write, Edit

Core tools for modifying code, changing configurations, and reviewing project content. Supports images, PDFs, and Jupyter notebooks.

**Critical Requirements:**
- Read before editing (mandatory for Edit, required for Write if file exists)
- Use absolute paths only
- Edit requires exact string matching (preserving whitespace, line endings)

See [tools/file-ops.summary.md](tools/file-ops.summary.md) for details.

---

## Search & Discovery

**Tools:** Glob, Grep

Find files by pattern and search content using fast ripgrep-powered regex matching.

**Key Features:**
- Glob: File name patterns sorted by modification time
- Grep: Content search with single-line or multiline modes
- Output modes: file paths, matching lines, or counts

See [tools/search.summary.md](tools/search.summary.md) for details.

---

## Command Execution

**Tools:** Bash

Execute shell commands with persistent working directory. Use for git operations, tests, dependencies, and terminal operations.

**Critical Rules:**
- ALWAYS quote paths with spaces
- Use `&&` for dependent commands, `;` for independent
- Avoid `cd` — use absolute paths instead
- NEVER use for file operations (use Read/Write/Edit/Glob/Grep)

See [tools/command-exec.summary.md](tools/command-exec.summary.md) for details.

---

## Agent Management

**Tools:** Task, TaskOutput, TaskStop

Launch specialized sub-agents for complex multi-step tasks. Agents explore codebases, design implementation plans, run TDD workflows, create PRDs, and handle autonomous implementation.

**Required Parameters:**
- `subagent_type` — Agent selection
- `prompt` — Task description
- `description` — Short 3-5 word summary (max 200 chars)

**Context Reduction Pattern:**
Store shared setup in temp files (e.g., `/tmp/claude-XXX/scratchpad/task.md`) when launching multiple similar agents.

See [tools/agents.summary.md](tools/agents.summary.md) for details.

---

## Planning & Workflow

**Tools:** EnterPlanMode, ExitPlanMode

Transition into planning mode for non-trivial features requiring architectural decisions. Get user approval before writing code.

**When to use EnterPlanMode:**
- Modifies more than 3 files
- Requires architectural decisions
- Multiple valid approaches exist
- User preferences matter

See [tools/planning.summary.md](tools/planning.summary.md) for details.

---

## Task Tracking

**Tools:** TaskCreate, TaskUpdate, TaskList, TaskGet

Create and manage structured task lists for complex work. Track progress, set up dependencies, and organize implementation steps.

**Status Flow:** pending → in_progress → completed

**Key Rule:** Only mark completed when FULLY done (tests passing, all parts implemented)

See [tools/task-tracking.summary.md](tools/task-tracking.summary.md) for details.

---

## User Interaction

**Tools:** AskUserQuestion, Skill

Gather user preferences via structured questions and invoke custom skills/slash commands.

**AskUserQuestion Constraints:**
- Max 4 questions per call
- 2-4 options per question
- Max 12 character headers
- Users can always select "Other" for custom input

**Skill Requirements:**
- MUST invoke BEFORE responding about the task
- Check if skill is already running first

See [tools/user-interaction.summary.md](tools/user-interaction.summary.md) for details.

---

## Web Operations

**Tools:** WebFetch, WebSearch

Fetch web content and search for current information beyond knowledge cutoff.

**Limitations:**
- No authenticated URL support (Google Docs, Confluence, Jira, private GitHub)
- Use CLI tools via Bash for authenticated services (gh api, aws-cli, etc.)

**Critical Rule:** WebSearch responses MUST include "Sources:" section with markdown links.

See [tools/web-ops.summary.md](tools/web-ops.summary.md) for details.

---

## Agent Invocation Examples

```javascript
// Explore codebase
Task(subagent_type="Explore", prompt="Find and explain authentication patterns", description="Find auth code")

// Quick lookup with haiku model
Task(subagent_type="Explore", model="haiku", prompt="List all test files", description="List test files")

// TDD implementation
Task(subagent_type="tdd-coder", prompt="Implement feature from docs/PRDs/auth.md", description="Implement auth feature")

// Resume previous agent
Task(subagent_type="Explore", resume="agent-id-here", prompt="Now look at migrations", description="Continue exploration")

// Context reduction: read temp prompt file for setup
Task(subagent_type="general-purpose", prompt="Read /tmp/claude-1000/.../scratchpad/setup-task.md then process Folder B", description="Process setup+B")
```

**Note**: When launching many similar agents, use temporary prompt files (e.g., `/tmp/claude-XXX/scratchpad/task.md`) to store shared setup context. Have each agent read the file for instructions instead of duplicating the same prompt across calls. This reduces token usage by avoiding repeated context transmission.

---

## Available Agents (via Task tool)

| Agent Type | Purpose | Use when... |
|------------|---------|-------------|
| `Explore` | Fast codebase exploration | "Find X in the codebase", "Understand how this works" |
| `Plan` | Design implementation plans | "Need to design how to implement X" |
| `Bash` | Command execution specialist | Terminal-only tasks |
| `idea-to-spec` | Ideas → personas/stories | Transform feature ideas to structured output |
| `prd-editor` | Create PRDs | Write PRD from user stories |
| `tdd-tester` | Generate test suites | Create tests from PRD |
| `tdd-coder` | Autonomous implementation | Implement feature from PRD + tests |
| `tdd-debugger` | Test debugging | Diagnose test failures |
| `tasker-*` (haiku/fast/sonnet/ultra/opus) | Context-efficient task execution | Simple lookups, file operations, context reduction |
| `claude-code-guide` | Claude Code/SDK/API help | Questions about Claude Code itself |
| `general-purpose` | Complex research | Multi-step tasks not fitting other categories |

---

## Important Agent Usage Guidelines

**Before using specialized agents or complex tools:**
1. **Read the relevant category summary first** — Each category (`tools/*.summary.md`) contains critical rules, required parameters, and usage patterns.
2. **Review agent-specific guidance** — Agent patterns and workflows in `tools/agents.summary.md`.
3. **Load detailed docs only when needed** — For unfamiliar tools or edge cases, consult `tools/*.md` files.

**Context Management Pattern:**
When launching multiple similar agents, store shared setup in a scratchpad file (`/tmp/claude-XXX/.../scratchpad/`). Each agent reads this file instead of receiving duplicate setup prompts.

---

→ *For extended details, see [tools.md](tools.md)*