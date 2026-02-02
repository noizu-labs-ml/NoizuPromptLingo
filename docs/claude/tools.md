# Claude Code Tools Reference

Extended details for Claude Code's built-in tools.

**Start with:** [tools.summary.md](tools.summary.md) for quick reference and navigation to category summaries.

---

## Category Index

| Category | Tools | Quick Reference | Full Documentation |
|----------|-------|-----------------|-------------------|
| **File Operations** | Read, Write, Edit, NotebookEdit | [file-ops.summary.md](tools/file-ops.summary.md) | [file-ops.md](tools/file-ops.md) |
| **Search & Discovery** | Glob, Grep | [search.summary.md](tools/search.summary.md) | [search.md](tools/search.md) |
| **Command Execution** | Bash | [command-exec.summary.md](tools/command-exec.summary.md) | [command-exec.md](tools/command-exec.md) |
| **Agent Management** | Task, TaskOutput, TaskStop | [agents.summary.md](tools/agents.summary.md) | [agents.md](tools/agents.md) |
| **Planning & Workflow** | EnterPlanMode, ExitPlanMode | [planning.summary.md](tools/planning.summary.md) | [planning.md](tools/planning.md) |
| **Task Tracking** | TaskCreate, TaskUpdate, TaskList, TaskGet | [task-tracking.summary.md](tools/task-tracking.summary.md) | [task-tracking.md](tools/task-tracking.md) |
| **User Interaction** | AskUserQuestion, Skill | [user-interaction.summary.md](tools/user-interaction.summary.md) | [user-interaction.md](tools/user-interaction.md) |
| **Web Operations** | WebFetch, WebSearch | [web-ops.summary.md](tools/web-ops.summary.md) | [web-ops.md](tools/web-ops.md) |

---

## Quick Start

**The 5 essential tools you'll use most:**

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

**Example workflow: Fix a bug**
```javascript
// 1. Find the file
Glob(pattern="**/auth.py")

// 2. Read it
Read("/path/to/auth.py")

// 3. Edit it
Edit("/path/to/auth.py", old_code, new_code)

// 4. Test it
Bash("mise run test")
```

---

## Before You Start Using Tools

**For file operations:** Read [file-ops.summary.md](tools/file-ops.summary.md) for critical rules:
- **MUST read before editing** (Read first, then Edit/Write)
- Write is destructive (overwrites entire file with no undo)
- Edit requires exact character-for-character matching (case, whitespace, line endings)

**For search:** Read [search.summary.md](tools/search.summary.md) for:
- Glob patterns (e.g., `**/*.py`, `src/**/*.ts`)
- Grep regex syntax and escape sequences
- Output modes: "files_with_matches", "content", "count"

**For agents:** Read [agents.summary.md](tools/agents.summary.md) for:
- Agent selection guide (Explore, Plan, tdd-coder, tasker-*, etc.)
- Required parameters: `subagent_type`, `prompt`, `description`
- Context reduction patterns using scratchpad files

**For complex tasks:**
1. Read the relevant category summary first (e.g., `file-ops.summary.md`, `agents.summary.md`)
2. Review context management patterns (use scratchpad files for shared setup)
3. Load detailed docs (e.g., `file-ops.md`, `agents.md`) only for unfamiliar tools or edge cases

---

## Tool Overviews

### File Operations

**Tools:** Read, Write, Edit, NotebookEdit

Core tools for modifying code, changing configurations, and reviewing project content. Read supports images, PDFs, and Jupyter notebooks. NotebookEdit provides specialized editing for .ipynb files with cell-level operations.

**Critical Requirements:**
- Read before editing (mandatory for Edit, required for Write if file exists)
- Use absolute paths only
- Edit requires exact string matching (preserving whitespace, line endings)

**Quick reference:** [tools/file-ops.summary.md](tools/file-ops.summary.md) | **Details:** [tools/file-ops.md](tools/file-ops.md)

---

### Search & Discovery

**Tools:** Glob, Grep

Find files by pattern and search content using fast ripgrep-powered regex matching.

**Key Features:**
- Glob: File name patterns sorted by modification time
- Grep: Content search with single-line or multiline modes
- Output modes: file paths, matching lines, or counts

**Quick reference:** [tools/search.summary.md](tools/search.summary.md) | **Details:** [tools/search.md](tools/search.md)

---

### Command Execution

**Tools:** Bash

Execute shell commands with persistent working directory. Use for git operations, tests, dependencies, and terminal operations.

**Critical Rules:**
- ALWAYS quote paths with spaces
- Use `&&` for dependent commands, `;` for independent
- Avoid `cd` — use absolute paths instead
- NEVER use for file operations (use Read/Write/Edit/Glob/Grep)

**Quick reference:** [tools/command-exec.summary.md](tools/command-exec.summary.md) | **Details:** [tools/command-exec.md](tools/command-exec.md)

---

### Agent Management

**Tools:** Task, TaskOutput, TaskStop

Launch specialized sub-agents for complex multi-step tasks. Agents explore codebases, design implementation plans, run TDD workflows, create PRDs, and handle autonomous implementation.

**Required Parameters:**
- `subagent_type` — Agent selection
- `prompt` — Task description
- `description` — Short 3-5 word summary (max 200 chars)

**Context Reduction Pattern:**
When launching many similar agents, store shared setup in a temp file (e.g., `/tmp/claude-XXX/scratchpad/task.md`). Each agent reads this file instead of receiving duplicate setup prompts.

**Quick reference:** [tools/agents.summary.md](tools/agents.summary.md) | **Details:** [tools/agents.md](tools/agents.md)

---

### Planning & Workflow

**Tools:** EnterPlanMode, ExitPlanMode

Transition into planning mode for non-trivial features requiring architectural decisions. Get user approval before implementation. Integrates with TDD workflow for structured feature development.

**When to use EnterPlanMode:**
- Modifies 3+ files
- Requires architectural decisions
- Multiple valid approaches exist
- User preferences or design choices matter

**When to use ExitPlanMode:**
- After writing plan to plan file (`.claude/` or `.tmp/`)
- Plan is complete and unambiguous
- Ready for user review and approval
- Only for code implementation tasks

**Quick reference:** [tools/planning.summary.md](tools/planning.summary.md) | **Details:** [tools/planning.md](tools/planning.md)

---

### Task Tracking

**Tools:** TaskCreate, TaskUpdate, TaskList, TaskGet

Create and manage structured task lists for complex work. Track progress, set up dependencies, and organize implementation steps.

**Status Flow:** pending → in_progress → completed

**Key Rule:** Only mark completed when FULLY done (tests passing, all parts implemented)

**Quick reference:** [tools/task-tracking.summary.md](tools/task-tracking.summary.md) | **Details:** [tools/task-tracking.md](tools/task-tracking.md)

---

### User Interaction

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

**Quick reference:** [tools/user-interaction.summary.md](tools/user-interaction.summary.md) | **Details:** [tools/user-interaction.md](tools/user-interaction.md)

---

### Web Operations

**Tools:** WebFetch, WebSearch

Fetch web content and search for current information beyond knowledge cutoff.

**Limitations:**
- No authenticated URL support (Google Docs, Confluence, Jira, private GitHub)
- Use CLI tools via Bash for authenticated services (gh api, aws-cli, etc.)

**Critical Rule:** WebSearch responses MUST include "Sources:" section with markdown links.

**Quick reference:** [tools/web-ops.summary.md](tools/web-ops.summary.md) | **Details:** [tools/web-ops.md](tools/web-ops.md)

---

## Error Recovery

| Error | Cause | Solution |
|-------|-------|----------|
| "File not found" | Wrong path | Use absolute paths, verify with Glob |
| "old_string not found" | Indentation/line endings mismatch | Re-Read for exact formatting, check CRLF vs LF |
| "old_string multiple times" | Not unique | Add more context or use `replace_all: true` |
| "Permission denied" | File permissions/quoted paths | Check permissions, quote paths with spaces |
| Agent not finding results | Wrong search terms | Try different search terms, use Explore agent |
| Tool validation error | Missing required parameters | Check all required fields, verify JSON syntax |

---

→ *For comprehensive examples and detailed parameter documentation, see each category's summary and detail files.*
