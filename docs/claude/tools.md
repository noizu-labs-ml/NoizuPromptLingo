# Claude Code Tools Reference

Comprehensive guide to using Claude Code's built-in tools for AI assistants and agents working in this environment.

---

## Quick Start (5-Minute Overview)

**The 5 essential tools you'll use most:**

| Tool | Purpose | When to use |
|------|---------|-------------|
| **Read** | View file contents | Before editing, checking code, reviewing docs |
| **Edit** | Make exact text changes | Modifying existing code/config |
| **Glob** | Find files by pattern | Locating test files, finding all `.py` files |
| **Grep** | Search file contents | Finding function definitions, locating where code is used |
| **Bash** | Run shell commands | Git ops, running tests, installing deps |

**Key principles to remember:**
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

## Table of Contents

*Note: Section headers below are organizational. Clicking links may not function depending on your markdown renderer.*

1. [Quick Start](#quick-start-5-minute-overview)
2. [File Operations](#file-operations)
3. [Search & Discovery](#search--discovery)
4. [Command Execution](#command-execution)
5. [Agent Management](#agent-management)
6. [Planning & Workflow](#planning--workflow)
7. [Task Tracking](#task-tracking)
8. [User Interaction](#user-interaction)
9. [Web Operations](#web-operations)
10. [Best Practices](#best-practices)
11. [Common Patterns](#common-patterns)
12. [Error Recovery](#error-recovery)
13. [Performance Tips](#performance-tips)
14. [Quick Reference](#quick-reference)
15. [Maintenance](#maintenance)

---

## File Operations

### Read

**Purpose**: Read file contents from the filesystem.

**When to use**:
- Need to examine existing code — e.g., before refactoring or adding functionality
- Review configuration files — e.g., checking YAML, JSON, or TOML settings
- Check documentation — e.g., reading internal README files, reviewing project docs
- Inspect test files before modifying — e.g., understanding test coverage before changing code
- Research external documentation — e.g., reading library API docs online

**Parameters**:
- `file_path` (required): Absolute path to file
- `offset` (optional): Line number to start reading from
- `limit` (optional): Number of lines to read

**Getting absolute paths**:

If you only have a relative path like `src/main.py`, use the working directory to construct the absolute path:
- Current directory is available via `Bash("pwd")`
- Combine with relative path: `/home/user/project/src/main.py`
- Or use `$PWD` in Bash to reference current directory

Recommended: always verify the path exists first using Glob or Bash `ls`.

**Usage**:
```json
{
  "file_path": "/absolute/path/to/file.py"
}
```

**With pagination** (for large files):
```json
{
  "file_path": "/absolute/path/to/large_file.py",
  "offset": 100,
  "limit": 50
}
```

**Pagination guidance**:
- Use 100-200 lines per chunk for good balance between context and speed
- Smaller chunks (50-100) are faster but reduce surrounding context
- Larger chunks (200-500) give more context but may hit output limits

**Key points**:
- Always use absolute paths (tool will error on relative paths)
- Files are returned with line numbers (cat -n format)
- Can read images, PDFs, Jupyter notebooks
- Lines longer than 2000 chars are truncated
- **MUST read a file before editing it**

**Media type capabilities & limitations**:

| Format | Notes | Limitations |
|--------|-------|-------------|
| **Images** | PNG, JPG, GIF, etc. can be read and visually analyzed | Cannot extract embedded text (OCR not supported). Large images may be truncated. |
| **PDFs** | Text is extracted page by page | Scanned/image-based PDFs return minimal content. Page count limits may apply to very long documents. |
| **Jupyter notebooks** | All cells (code + outputs) are displayed | Metadata and cell states beyond visible output are not preserved. |

---

### Write

**Purpose**: Create a new file or completely overwrite an existing file.

**When to use**:
- Creating new files
- Replacing entire file contents — **⚠️ This is destructive! Write completely replaces existing content with no undo.**
- **NOT for editing existing files** (use Edit instead)

**Parameters**:
- `file_path` (required): Absolute path
- `content` (required): Complete file contents

**Usage**:
```json
{
  "file_path": "/absolute/path/to/new_file.py",
  "content": "#!/usr/bin/env python3\n\ndef main():\n    print('Hello')\n"
}
```

**Critical rules**:
- MUST use Read first if file already exists — This confirms the file exists and establishes a baseline. Reading first prevents accidental overwriting of unknown contents and provides context for potential rollback if something goes wrong.
- Prefer Edit over Write for existing files
- Never create documentation files proactively — Only add new documentation files with explicit user request or TDD workflow requirement.
- Use absolute paths only

---

### Edit

**Purpose**: Make exact string replacements in existing files.

**When to use**:
- Modifying existing code
- Updating configuration
- Fixing bugs
- Adding features to existing files

**Parameters**:
- `file_path` (required): Absolute path
- `old_string` (required): Exact text to replace — Must match character-for-character, including case, whitespace (spaces vs tabs), and trailing newlines.
- `new_string` (required): Replacement text
- `replace_all` (optional): Replace all occurrences (default: false)

**What "exact match" means**:

The match is sensitive to:
- **Case**: `def hello(` ≠ `def Hello(`
- **Whitespace**: `return 'Hi'` (4 spaces) ≠ `return 'Hi'` (2 spaces)
- **Character type**: Regular space (` `) ≠ non-breaking space (`\u00A0`)
- **Tabs vs spaces**: Consistent indentation matters
- **Trailing newlines**: Whether the string ends with `\n` or not

Example where match fails:
```
File contains:  "def hello():\n    return 'Hi'\n"  (LF line endings)
old_string:    "def hello():\r\n    return 'Hi'\r\n"  (CRLF line endings)
Result:        Match fails due to line ending difference
```

**Usage**:
```json
{
  "file_path": "/path/to/file.py",
  "old_string": "def hello():\n    return 'Hi'",
  "new_string": "def hello(name: str):\n    return f'Hi {name}'"
}
```

**Replace all occurrences**:
```json
{
  "file_path": "/path/to/file.py",
  "old_string": "old_var_name",
  "new_string": "new_var_name",
  "replace_all": true
}
```

**Critical rules**:
- MUST use Read first to see exact formatting
- Preserve exact indentation (spaces/tabs) from Read output — **Important**: When copying from Read output, you're copying the *actual* whitespace characters, not escape sequences. Some environments display `\t` and `\n` literally, but these must be literal tab and newline characters in the Edit payload—not the backslash-t representation.
- Ignore line number prefixes when copying text
- `old_string` must be unique or use `replace_all`
- Edit will FAIL if old_string appears multiple times and replace_all=false

**Troubleshooting: Why Edit fails even after Read**

| Symptom | Cause | Solution |
|---------|-------|----------|
| "old_string not found" | Copied from different file with similar content | Re-Read the exact file you're editing |
| "old_string not found" | Line endings changed (CRLF vs LF) | Check Read output for `^M` (CR) characters; include `\r\n` in your old_string if visible |
| "old_string not found" | File modified by another editor after Read | Re-Read to get current state |
| "old_string not found" | Unicode normalization differences | Ensure you're copying exact characters from Read output |

---

## Search & Discovery

### Glob

**Purpose**: Fast file pattern matching using glob patterns.

**When to use**:
- Finding files by name or extension
- Locating configuration files
- Discovering test files
- Building file lists

**Parameters**:
- `pattern` (required): Glob pattern
- `path` (optional): Directory to search (defaults to current working directory)

**Usage**:

Find all Python files:
```json
{
  "pattern": "**/*.py"
}
```

Find test files:
```json
{
  "pattern": "**/test_*.py"
}
```

Find in specific directory:
```json
{
  "pattern": "*.ts",
  "path": "/path/to/src"
}
```

**Common patterns**:
- `**/*.py` - All Python files recursively
- `src/**/*.ts` - TypeScript files under src/
- `**/test_*.py` - All test files
- `*.{js,ts}` - JS or TS files in current dir
- `**/README.md` - All README files

**Key points**:
- Results sorted by modification time — Note: Sort order is not configurable; results are always returned by most recently modified. For alphabetically sorted results, post-process the output or use alternative approaches.
- Very fast, works on any codebase size
- Use for known file patterns
- For content search, use Grep instead

**Brace expansion note**:
The glob engine may not support standard brace expansion like `*.{js,ts,jsx}` across all environments. If this pattern fails, specify each extension separately or use multiple Glob patterns via parallel execution.

---

### Grep

**Purpose**: Search file contents using regex patterns (powered by ripgrep).

**When to use**:
- Finding where code is used
- Searching for function definitions
- Locating configuration values
- Finding TODO comments

**Parameters**:
- `pattern` (required): Regex pattern
- `path` (optional): File/directory to search
- `glob` (optional): Filter files (e.g., "*.py")
- `type` (optional): File type (js, py, rust, etc.)
- `output_mode` (optional): "content", "files_with_matches", "count"
- `-i` (optional): Case insensitive
- `-n` (optional): Show line numbers (default: true)
- `-A`, `-B`, `-C` (optional): Context lines after/before/both
- `multiline` (optional): Enable multiline matching
- `head_limit` (optional): Limit output lines — Applies after offset. Example: 100 matches found with `offset=50, head_limit=20` returns matches 50-69 (skips first 50, returns next 20).
- `offset` (optional): Skip first N results — Skips the specified number of matches before returning results.

**Usage**:

Find function definitions:
```json
{
  "pattern": "def hello",
  "output_mode": "files_with_matches"
}
```

Search with context:
```json
{
  "pattern": "import FastMCP",
  "output_mode": "content",
  "-C": 3
}
```

Search specific file types:
```json
{
  "pattern": "TODO",
  "type": "py",
  "output_mode": "content"
}
```

Case insensitive:
```json
{
  "pattern": "error",
  "-i": true,
  "output_mode": "content"
}
```

**Output modes**:
- `files_with_matches` - Just file paths (default, fastest)
- `content` - Matching lines with context
- `count` - Match counts per file

**Count mode example**:
```json
{
  "pattern": "TODO",
  "output_mode": "count"
}
```
Returns results like:
```
src/auth.py: 3
src/main.py: 1
tests/test_auth.py: 5
```

**Key points**:
- Uses ripgrep syntax (not grep)
- Literal braces need escaping: see below
- Default is single-line matching
- Use `multiline: true` for cross-line patterns
- Much faster than bash grep

**Escape sequences**:

To match literal special characters in regex patterns, you need to understand the double-escape behavior:

| What you want to match | What regex receives | What you type in JSON |
|------------------------|----------------------|----------------------|
| `interface{}` literal | `interface\{\}` | `"pattern": "interface\\{\\}"` |
| `file.ext` (literal dot) | `file\.ext` | `"pattern": "file\\.ext"` |
| `[test]` (literal brackets) | `\[test\]` | `"pattern": "\\[test\\]"` |

The JSON parser removes one level of escaping, so you double-escape to preserve the backslash for the regex engine.

**Common regex patterns**:

| Pattern | Purpose | Example |
|---------|---------|---------|
| `\bword\b` | Match whole word only | `pattern: "\bTODO\b"` matches "TODO" but not "TODOITEM" |
| `def\s+\w+\(` | Match function definition | `pattern: "def\s+\w+\("` matches "def my_func(" |
| `^import|^from` | Match at start of line | `pattern: "^import|^from"` matches import statements |
| `(TODO|FIXME|HACK)` | Match any alternative | `pattern: "(TODO|FIXME|HACK)"` matches any of these |

---

## Command Execution

### Bash

**Purpose**: Execute shell commands in a persistent working directory.

**When to use**:
- Git operations
- Running tests
- Installing dependencies
- Process management
- Any terminal operation

**Parameters**:
- `command` (required): Shell command to execute
- `description` (optional but recommended): Clear description
- `timeout` (optional): Milliseconds (default: 120000, max: 600000)
- `run_in_background` (optional): Run async

**Usage**:

Simple command:
```json
{
  "command": "git status",
  "description": "Check git working tree status"
}
```

With timeout:
```json
{
  "command": "npm test",
  "description": "Run test suite",
  "timeout": 300000
}
```

Background process:
```json
{
  "command": "npm run dev",
  "description": "Start development server",
  "run_in_background": true
}
```

**Critical rules**:
- **ALWAYS quote paths with spaces**: `cd "path with spaces/file.txt"`
- Use `&&` to chain dependent commands: `git add . && git commit`
- Use `;` for independent commands (runs even if prior fails)
- Working directory persists, shell state does NOT
- Avoid `cd`, use absolute paths instead
- NEVER use for file operations (use Read/Write/Edit/Glob/Grep)

**Git-specific considerations**:

| Issue | Why it happens | Solution |
|-------|----------------|----------|
| Command hangs | Interactive prompts (`git rebase -i`, `git commit` without `-m`) | Always use non-interactive flags: `-m` for commit messages, avoid `rebase -i` |
| Credential prompts | Git asking for login info | Ensure credentials are stored (`git config --global credential.helper`) or use token-based auth |
| Submodule fails | Permission issues with recursively nested repos | Use `--recurse-submodules` flag with appropriate permissions |
| Hook failures | Pre-commit hooks missing or failing | May need to skip with `--no-verify` or fix hook issues |

**Test output handling**:

When tests produce massive output:
- Output is truncated at ~30,000 characters
- Partial output is returned up to the limit
- For verbose test suites, redirect output to a file: `npm test > test-output.txt`
- Then read the file with Read tool for analysis

**Background process management**:

| Question | Answer |
|----------|--------|
| How to stop a background task? | Use `TaskStop` tool with the task ID |
| How to check if it's still running? | Use `TaskOutput` to check status |
| What happens when conversation ends? | Background processes terminate when the session ends |
| Can I run multiple background tasks? | Yes, each gets a unique task ID |

**Timeout recommendations by operation type**:

| Operation | Timeout range | Notes |
|-----------|---------------|-------|
| Quick commands (<1s) | Use default (120s) | Safe default, no need to specify |
| Test suites | 180,000-300,000ms (3-5 min) | Depends on suite size and hardware |
| Installations | 300,000-600,000ms (5-10 min) | For large packages may need background execution |
| Docker builds | 600,000ms max → use background | Exceeds max timeout, always run in background |

**What NOT to use Bash for**:
- ❌ `cat file.txt` → Use Read tool
- ❌ `grep "pattern" file` → Use Grep tool
- ❌ `find . -name "*.py"` → Use Glob tool
- ❌ `echo "text" > file` → Use Write tool
- ❌ `sed 's/old/new/' file` → Use Edit tool

**Parallel execution**:
```json
[
  {"command": "git status", "description": "Check status"},
  {"command": "git diff", "description": "Check changes"}
]
```

---

## Agent Management

### Task

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
- `description` (required): Short 3-5 word summary — This brevity constraint is for display/logging purposes. Longer descriptions are accepted but may be truncated in UI contexts.
- `model` (optional): "sonnet", "opus", "haiku"
- `resume` (optional): Agent ID to resume — The retained context includes all conversation history from the previous session. You can resume an agent multiple times. Resuming an already-completed agent will allow you to ask follow-up questions based on its results.
- `run_in_background` (optional): Run async

**Available agents**:

| Agent Type | Purpose | Tools Available |
|------------|---------|-----------------|
| `general-purpose` | Complex research, multi-step tasks | All tools |
| `Explore` | Fast codebase exploration | All except Task, Edit, Write |
| `Plan` | Design implementation plans | All except Task, Edit, Write |
| `Bash` | Command execution specialist | Bash only |
| `idea-to-spec` | Transform ideas to personas/user stories | All tools |
| `prd-editor` | Create PRD documents | All tools |
| `tdd-tester` | Generate test suites from PRDs | All tools |
| `tdd-coder` | Autonomous implementation | All tools |
| `tdd-debugger` | Test execution and debugging | All tools |

**Agent selection quick reference**:

| Your goal | Use agent |
|-----------|-----------|
| "I need to find X in the codebase" | `Explore` |
| "I need to understand how this system works" | `Explore` |
| "I need to design how to implement X" | `Plan` |
| "I need to transform an idea into user stories" | `idea-to-spec` |
| "I need to write a PRD from user stories" | `prd-editor` |
| "I need to create tests from a PRD" | `tdd-tester` |
| "I need to implement a feature from a PRD" | `tdd-coder` |
| "My tests are failing, I need to debug" | `tdd-debugger` |
| "I have a complex, multi-step task that doesn't fit other categories" | `general-purpose` |

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
  "subagent_type": "tdd-coder",
  "description": "Implement feature autonomously",
  "prompt": "Implement the feature described in .prd/auth.md",
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

**Key points**:
- Agents have full conversation context before tool call
- Can reference earlier discussion: "investigate the error discussed above"
- Agents return single message when done
- Use `model: "haiku"` for quick/cheap tasks
- Check for existing agents before spawning new ones

---

## Planning & Workflow

### EnterPlanMode

**Purpose**: Transition into planning mode for implementation tasks.

**When to use**:
- Non-trivial feature implementation — Defined as any task that:
  - Modifies more than 3 files, OR
  - Requires architectural decisions (even minor), OR
  - Affects multiple modules or systems, OR
  - User might reasonably have questions about the approach
- Multiple valid approaches exist
- Architectural decisions needed
- Multi-file changes expected
- Requirements are unclear
- User preferences matter

**When NOT to use**:
- Simple one-line fixes
- Pure research tasks
- Very specific detailed instructions
- User already provided full plan

**Usage**:
```json
{}
```

**What happens**:
1. User must approve entering plan mode
2. You explore codebase thoroughly
3. Design implementation approach
4. Present plan for approval
5. Use AskUserQuestion for clarifications
6. Exit with ExitPlanMode when ready

**Example flow**:
```
User: "Add user authentication"
→ EnterPlanMode (requires architectural decisions)
→ Explore codebase
→ Design approach (JWT vs session, middleware, etc.)
→ Present plan
→ ExitPlanMode
→ Implement
```

---

### ExitPlanMode

**Purpose**: Signal plan completion and request user approval.

**When to use**:
- After writing plan to plan file — The plan is written to a file in the working directory (typically named similar to `.claude/plan.md` or as determined during the planning session)
- Plan is complete and unambiguous
- Ready for user review
- **ONLY for code implementation tasks**

**When NOT to use**:
- Research tasks
- Gathering information
- Understanding codebase
- Don't ask "Is this plan okay?" - that's what this tool does

**Parameters**:
- `allowedPrompts` (optional): Semantic permissions needed

**Usage**:
```json
{
  "allowedPrompts": [
    {"tool": "Bash", "prompt": "run tests"},
    {"tool": "Bash", "prompt": "install dependencies"}
  ]
}
```

**Critical rules**:
- Plan must already be written to plan file
- Tool reads plan from file (doesn't take content as parameter)
- Use AskUserQuestion BEFORE this for clarifications
- Never ask "Should I proceed?" - this tool does that

---

## Task Tracking

### TaskCreate

**Purpose**: Create structured task lists for complex work.

**When to use**:
- Complex multi-step tasks (3+ steps) — The 3+ step threshold is a heuristic for when tracking provides value. Example: "Add validation, update tests, update docs" (3 steps, worth tracking). Example not worth tracking: "Open file X, change variable Y" (2 steps, inline instead).
- User provides multiple tasks
- After receiving new instructions
- In plan mode
- Tracking implementation progress

**When NOT to use**:
- Single straightforward task
- Trivial tasks
- Purely conversational requests

**Parameters**:
- `subject` (required): Brief imperative title
- `description` (required): Detailed requirements — A good description should include:
  - What change is being made (the "what")
  - Why it's being made (the "why", if not obvious)
  - Any constraints or edge cases to consider
  - How to verify completion (acceptance criteria)
- `activeForm` (recommended): Present continuous form
- `metadata` (optional): Arbitrary key-value data

**Usage**:
```json
{
  "subject": "Implement user authentication",
  "description": "Add JWT-based authentication with login/logout endpoints, middleware for protected routes, and token refresh logic",
  "activeForm": "Implementing user authentication"
}
```

Multiple tasks:
```json
[
  {
    "subject": "Create database schema",
    "description": "Design and implement user table with password hashing",
    "activeForm": "Creating database schema"
  },
  {
    "subject": "Implement auth endpoints",
    "description": "Add /login, /logout, /refresh routes",
    "activeForm": "Implementing auth endpoints"
  }
]
```

**Key points**:
- All tasks created with status `pending`
- Subject should be imperative: "Run tests"
- activeForm should be continuous: "Running tests"
- Check TaskList first to avoid duplicates

---

### TaskUpdate

**Purpose**: Update task status, details, or dependencies.

**When to use**:
- Mark task as in_progress when starting
- Mark task as completed when finished
- Update task details
- Set up dependencies
- Delete obsolete tasks

**Parameters**:
- `taskId` (required): Task ID to update
- `status` (optional): "pending", "in_progress", "completed", "deleted"
- `subject` (optional): New title
- `description` (optional): New description
- `activeForm` (optional): New active form
- `owner` (optional): Assign to agent — This is metadata for tracking/human review purposes. It does not route tasks to specific agents.
- `addBlocks` (optional): Tasks this blocks — Other task IDs that cannot start until this one completes
- `addBlockedBy` (optional): Tasks blocking this — Task IDs that must complete before this can start
- `metadata` (optional): Metadata updates

**Dependency examples**:
```
Task 1: Design schema (ID: "1")
Task 2: Create tables (ID: "2", blockedBy: ["1"]) — waits for schema design
Task 3: Add API endpoints (ID: "3", blockedBy: ["2"]) — waits for tables
Task 4: Update docs (ID: "4", blockedBy: ["1", "3"]) — waits for both schema and endpoints
```

**Usage**:

Start work:
```json
{
  "taskId": "1",
  "status": "in_progress"
}
```

Complete task:
```json
{
  "taskId": "1",
  "status": "completed"
}
```

Delete task:
```json
{
  "taskId": "1",
  "status": "deleted"
}
```

Set dependencies:
```json
{
  "taskId": "2",
  "addBlockedBy": ["1"]
}
```

**Critical rules**:
- ONLY mark completed when FULLY done
- Keep in_progress if tests fail or blocked
- Use TaskGet first for latest state
- Status flow: pending → in_progress → completed

**When is a task truly complete?**

| Task type | Completion criteria |
|-----------|--------------------|
| Implementation | Code written AND all tests passing |
| Documentation | Written AND reviewed AND formatting validated |
| Bug fix | Fixed AND edge cases tested AND root cause documented |
| Refactoring | Old code removed/new code written AND tests passing AND performance verified |

**Keep `in_progress` status when**:

| Situation | Action |
|-----------|--------|
| Tests failing | Keep in_progress, don't mark completed |
| Blocked by dependency | Keep in_progress, set `addBlockedBy` |
| Need user clarification | Keep in_progress, add note in description about what's needed |
| Partial implementation | Keep in_progress, mark completed only when all parts are done |

---

### TaskList

**Purpose**: View all tasks and their status.

**When to use**:
- Check available tasks
- See overall progress
- Find blocked tasks
- After completing a task
- Before creating new tasks

**Usage**:
```json
{}
```

**Returns**:
- Task ID
- Subject
- Status (pending, in_progress, completed)
- Owner
- blockedBy list

**Best practice**:
- Work on tasks in ID order (lowest first)
- Check after each completion for newly unblocked work

---

### TaskGet

**Purpose**: Retrieve full details for a specific task.

**When to use**:
- Before starting work on a task
- Need complete requirements
- Check dependencies
- After being assigned a task

**Parameters**:
- `taskId` (required): Task ID

**Usage**:
```json
{
  "taskId": "1"
}
```

**Returns**:
- Full description
- Status
- Dependencies (blocks, blockedBy)
- Metadata

---

## User Interaction

### AskUserQuestion

**Purpose**: Ask the user questions to clarify requirements or gather preferences.

**When to use**:
- Ambiguous requirements
- Multiple valid approaches
- Need user preference
- Making implementation choices
- **In plan mode to clarify BEFORE finalizing plan**

**When NOT to use**:
- Asking "Is my plan ready?" (use ExitPlanMode)
- Asking "Should I proceed?" (use ExitPlanMode)

**Parameters**:
- `questions` (required): Array of 1-4 questions
  - `question` (required): The question text
  - `header` (required): Short label (max 12 chars)
  - `options` (required): 2-4 choice objects
    - `label` (required): Display text (1-5 words)
    - `description` (required): Explanation
  - `multiSelect` (optional): Allow multiple selections

**Usage**:

Single choice:
```json
{
  "questions": [
    {
      "question": "Which authentication method should we use?",
      "header": "Auth Method",
      "multiSelect": false,
      "options": [
        {
          "label": "JWT (Recommended)",
          "description": "Stateless, scalable, good for microservices"
        },
        {
          "label": "Session Cookies",
          "description": "Server-side state, simpler but less scalable"
        },
        {
          "label": "OAuth2",
          "description": "Third-party auth (Google, GitHub, etc.)"
        }
      ]
    }
  ]
}
```

Multiple questions:
```json
{
  "questions": [
    {
      "question": "Which database should we use?",
      "header": "Database",
      "multiSelect": false,
      "options": [
        {"label": "PostgreSQL", "description": "Full ACID compliance, robust"},
        {"label": "SQLite", "description": "Lightweight, file-based"},
        {"label": "MongoDB", "description": "NoSQL, flexible schema"}
      ]
    },
    {
      "question": "Which features do you want to enable?",
      "header": "Features",
      "multiSelect": true,
      "options": [
        {"label": "Rate limiting", "description": "Prevent abuse"},
        {"label": "Caching", "description": "Improve performance"},
        {"label": "Monitoring", "description": "Track usage"}
      ]
    }
  ]
}
```

**Key points**:
- Users can always select "Other" for custom input — When selected, the user can provide free-form input which you'll see in the next message. You can then ask follow-up clarification questions this option is always available.
- Put recommended option first with "(Recommended)"
- Use multiSelect for non-exclusive choices
- Max 12 characters for header — This 1-5 word label limit is a UX recommendation for display purposes; longer labels will display but may be truncated in some UI contexts.

---

### Skill

**Purpose**: Invoke user-defined custom skills/commands.

**When to use**:
- User references a slash command (e.g., "/commit")
- Task matches an available skill
- User explicitly requests a skill

**When NOT to use**:
- Built-in CLI commands (/help, /clear)
- Skill is already running

**Parameters**:
- `skill` (required): Skill name
- `args` (optional): Arguments for the skill

**Usage**:

Basic:
```json
{
  "skill": "commit"
}
```

With arguments:
```json
{
  "skill": "commit",
  "args": "-m 'Fix bug in auth'"
}
```

Fully qualified:
```json
{
  "skill": "ms-office-suite:pdf"
}
```

**Available user-invocable commands** (in this project):
- `track-assumptions` - Structured response format with assumptions table and response plan
- `update-arch-doc` - PROJ-ARCH.md maintenance guide
- `update-layout-doc` - PROJ-LAYOUT.md maintenance guide
- `guest` - Welcome guide for new Claude Code users
- `annotate` - Adds footnote annotations to files without modifying originals

**Critical rule**:
- MUST invoke skill BEFORE responding about the task
- NEVER mention a skill without calling it
- Check if skill is already running first

---

## Web Operations

### WebFetch

**Purpose**: Fetch and analyze web content.

**When to use**:
- Fetch documentation
- Read blog posts
- Analyze web pages
- **NOT for authenticated services**

**When NOT to use**:
- Authenticated URLs (Google Docs, Confluence, Jira, private GitHub)
- Use specialized tools for those instead

**Authenticated URL alternatives**:

| Platform | Alternative approach |
|----------|---------------------|
| Private GitHub repos | Use `Bash("gh repo view")` or `Bash("gh api <endpoint>")` with auth |
| Google Docs | Not directly supported — may need alternative access methods |
| Confluence | Not directly supported — check for API access via CLI tools |
| Jira | Not directly supported — use `jira` CLI or API via Bash |
| Any authenticated service | Use Bash with appropriate CLI tools that handle auth (curl with headers, aws-cli, etc.) |

**Parameters**:
- `url` (required): Fully-formed URL
- `prompt` (required): What to extract/analyze

**Usage**:
```json
{
  "url": "https://docs.python.org/3/library/asyncio.html",
  "prompt": "Summarize the key concepts of asyncio and provide code examples"
}
```

**Key points**:
- HTTP upgraded to HTTPS automatically
- Handles redirects (will inform you)
- 15-minute cache for repeated access
- Read-only, doesn't modify content
- For GitHub, prefer `gh` CLI via Bash

---

### WebSearch

**Purpose**: Search the web for current information.

**When to use**:
- Need up-to-date information
- Research current events
- Find recent documentation
- Beyond knowledge cutoff

**Parameters**:
- `query` (required): Search query
- `allowed_domains` (optional): Only these domains
- `blocked_domains` (optional): Exclude these domains

**Usage**:

Basic search:
```json
{
  "query": "FastMCP documentation 2026"
}
```

Domain filtering:
```json
{
  "query": "Python asyncio tutorial",
  "allowed_domains": ["python.org", "realpython.com"]
}
```

Block domains:
```json
{
  "query": "JavaScript frameworks",
  "blocked_domains": ["w3schools.com"]
}
```

**Critical rule**:
- MUST include "Sources:" section in response
- List all URLs as markdown links
- Use current year (2026) in queries for recent info

---

## Best Practices

### General Principles

1. **Read before editing**: Always use Read before Edit or Write
2. **Prefer specialized tools**: Use Read/Write/Edit/Glob/Grep instead of Bash
3. **Absolute paths**: Always use absolute paths, never relative
4. **Parallel execution**: Make independent tool calls in single message
5. **Sequential execution**: Chain dependent Bash commands with `&&`

### File Operations

```javascript
// ✅ GOOD
Read("/path/to/file.py")
Edit("/path/to/file.py", old, new)

// ❌ BAD
Bash("cat /path/to/file.py")
Bash("sed 's/old/new/' /path/to/file.py")
```

### Search Operations

```javascript
// ✅ GOOD - Use Glob for file patterns
Glob(pattern="**/*.py")

// ✅ GOOD - Use Grep for content search
Grep(pattern="def hello", output_mode="files_with_matches")

// ❌ BAD - Don't use Bash
Bash("find . -name '*.py'")
Bash("grep 'def hello' *.py")
```

### Command Execution

```javascript
// ✅ GOOD - Sequential dependencies
Bash("git add . && git commit -m 'message' && git push")

// ✅ GOOD - Parallel independent commands
[
  Bash("git status"),
  Bash("git diff")
]

// ✅ GOOD - Quote paths with spaces
Bash("cd \"path with spaces/file.txt\"")

// ❌ BAD - Unquoted paths with spaces
Bash("cd path with spaces/file.txt")
```

### Task Management

```javascript
// ✅ GOOD - Create task when starting
TaskCreate({subject: "Run tests", activeForm: "Running tests"})
TaskUpdate({taskId: "1", status: "in_progress"})
// ... do work ...
TaskUpdate({taskId: "1", status: "completed"})

// ❌ BAD - Mark completed prematurely
TaskUpdate({taskId: "1", status: "completed"})
// ... but tests are still failing!
```

### Agent Usage

```javascript
// ✅ GOOD - Use Explore for open-ended searches
Task({
  subagent_type: "Explore",
  description: "Find error handling",
  prompt: "Find and explain error handling patterns"
})

// ✅ GOOD - Use haiku for quick tasks
Task({
  subagent_type: "Explore",
  description: "Quick file search",
  prompt: "Find all config files",
  model: "haiku"
})

// ❌ BAD - Using Grep directly for complex exploration
Grep(pattern="error")
Grep(pattern="exception")
Grep(pattern="try")
// ... many more attempts
```

### Planning Workflow

```javascript
// ✅ GOOD - Plan complex features
EnterPlanMode()
// ... explore codebase ...
// ... design approach ...
AskUserQuestion({...}) // clarify approach
// ... finalize plan ...
ExitPlanMode()

// ❌ BAD - Skip planning for complex features
// Immediately start editing files for multi-step feature
```

---

## Common Patterns

### Pattern: Read, Edit, Test

```javascript
// 1. Read the file
Read("/path/to/file.py")

// 2. Make changes
Edit("/path/to/file.py", old_code, new_code)

// 3. Run tests
Bash("mise run test")
```

### Pattern: Search, Read, Modify

```javascript
// 1. Find relevant files
Glob(pattern="**/auth*.py")

// 2. Search for specific code
Grep(pattern="def authenticate", output_mode="files_with_matches")

// 3. Read the file
Read("/path/to/auth.py")

// 4. Make changes
Edit("/path/to/auth.py", old, new)
```

### Pattern: Parallel Research

```javascript
// Execute multiple searches in parallel
[
  Grep(pattern="class User", output_mode="files_with_matches"),
  Grep(pattern="def login", output_mode="files_with_matches"),
  Grep(pattern="import jwt", output_mode="files_with_matches")
]
```

### Pattern: Task-Driven Implementation

```javascript
// 1. Create tasks
TaskCreate({subject: "Design schema", ...})
TaskCreate({subject: "Implement endpoints", ...})
TaskCreate({subject: "Write tests", ...})

// 2. Work through tasks
TaskUpdate({taskId: "1", status: "in_progress"})
// ... implement ...
TaskUpdate({taskId: "1", status: "completed"})

// 3. Continue
TaskList() // Find next task
```

### Pattern: Agent-Driven Exploration

```javascript
// Let agent handle complex exploration
Task({
  subagent_type: "Explore",
  description: "Understand authentication",
  prompt: "Explore the codebase and explain how authentication works, including all related files and the flow"
})
```

---

## Error Recovery

### Common Errors and Solutions

**"File not found"**:
- Ensure using absolute paths
- Use Glob to find correct path
- Check working directory with Bash("pwd")

**"old_string not found" (Edit)**:
- Use Read to see exact formatting
- Check indentation matches exactly
- Verify line endings and whitespace

**Line ending troubleshooting**:
CRLF (Windows `\\r\\n`) vs LF (Unix `\\n`) line endings are a common cause of Edit failures. When viewing Read output:
- Lines ending with `^M$` or `$^M$` indicate CRLF (includes carriage return)
- Lines ending with just `$` indicate LF only
- Your `old_string` must include the exact line endings present in the file

**"old_string appears multiple times"**:
- Provide more context in old_string
- Or use `replace_all: true`

**"Permission denied" (Bash)**:
- Check file permissions
- May need to quote paths
- Ensure command is correct

**Agent not finding results**:
- Try different search terms
- Use Explore agent for thorough search
- Check if files exist with Glob

---

## Performance Tips

1. **Use parallel calls**: Independent operations in single message
2. **Use haiku model**: For quick/simple agent tasks
3. **Limit Grep output**: Use `head_limit` for large results
4. **Cache-friendly WebFetch**: Same URL within 15min uses cache
5. **Prefer Glob over Grep**: For file name searches

---

## Quick Reference

| Task | Tool | Example |
|------|------|---------|
| Read file | Read | `Read("/path/file.py")` |
| Create file | Write | `Write("/path/file.py", content)` |
| Edit file | Edit | `Edit("/path/file.py", old, new)` |
| Find files | Glob | `Glob(pattern="**/*.py")` |
| Search content | Grep | `Grep(pattern="def hello")` |
| Run command | Bash | `Bash("git status")` |
| Explore codebase | Task | `Task(subagent_type="Explore", ...)` |
| Plan feature | EnterPlanMode | `EnterPlanMode()` |
| Track tasks | TaskCreate | `TaskCreate(subject="...", ...)` |
| Ask user | AskUserQuestion | `AskUserQuestion(questions=[...])` |
| Run skill | Skill | `Skill(skill="commit")` |
| Fetch web | WebFetch | `WebFetch(url, prompt)` |
| Search web | WebSearch | `WebSearch(query)` |

---

## Maintenance

This document should be updated when:

| Trigger | Action |
|---------|--------|
| New tools added/removed | Update relevant sections, remove deprecated content |
| Tool parameters change behavior or signature | Update parameter descriptions and examples |
| New patterns emerge from best practices | Add to "Best Practices" or "Common Patterns" sections |
| New agents added to the system | Update "Available agents" table and selection guide |
| Tool contract boundaries clarified | Update "Critical rules" sections |

**Version history**:
- 2026-02-02: Initial revision
- 2026-02-02: Phase 1 critical revisions applied — Quick Start added, clarifications for exact matching, line endings, agent selection, time-outs, and task completion criteria added.

---

*This documentation is intended for AI assistants and agents working in the Claude Code environment. Last updated: 2026-02-02*
