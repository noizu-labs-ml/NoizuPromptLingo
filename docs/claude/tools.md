# Claude Code Tools Reference

Comprehensive guide to using Claude Code's built-in tools for AI assistants and agents working in this environment.

---

## Table of Contents

1. [File Operations](#file-operations)
2. [Search & Discovery](#search--discovery)
3. [Command Execution](#command-execution)
4. [Agent Management](#agent-management)
5. [Planning & Workflow](#planning--workflow)
6. [Task Tracking](#task-tracking)
7. [User Interaction](#user-interaction)
8. [Web Operations](#web-operations)
9. [Best Practices](#best-practices)

---

## File Operations

### Read

**Purpose**: Read file contents from the filesystem.

**When to use**:
- Need to examine existing code
- Review configuration files
- Check documentation
- Inspect test files before modifying

**Parameters**:
- `file_path` (required): Absolute path to file
- `offset` (optional): Line number to start reading from
- `limit` (optional): Number of lines to read

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

**Key points**:
- Always use absolute paths (tool will error on relative paths)
- Files are returned with line numbers (cat -n format)
- Can read images, PDFs, Jupyter notebooks
- Lines longer than 2000 chars are truncated
- **MUST read a file before editing it**

---

### Write

**Purpose**: Create a new file or completely overwrite an existing file.

**When to use**:
- Creating new files
- Replacing entire file contents
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
- MUST use Read first if file already exists
- Prefer Edit over Write for existing files
- Never create documentation files proactively
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
- `old_string` (required): Exact text to replace
- `new_string` (required): Replacement text
- `replace_all` (optional): Replace all occurrences (default: false)

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
- Preserve exact indentation (spaces/tabs) from Read output
- Ignore line number prefixes when copying text
- `old_string` must be unique or use `replace_all`
- Edit will FAIL if old_string appears multiple times and replace_all=false

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
- Results sorted by modification time
- Very fast, works on any codebase size
- Use for known file patterns
- For content search, use Grep instead

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
- `head_limit` (optional): Limit output lines
- `offset` (optional): Skip first N results

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

**Key points**:
- Uses ripgrep syntax (not grep)
- Literal braces need escaping: `interface\\{\\}`
- Default is single-line matching
- Use `multiline: true` for cross-line patterns
- Much faster than bash grep

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
- `description` (required): Short 3-5 word summary
- `model` (optional): "sonnet", "opus", "haiku"
- `resume` (optional): Agent ID to resume
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
- Non-trivial feature implementation
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
- After writing plan to plan file
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
- Complex multi-step tasks (3+ steps)
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
- `description` (required): Detailed requirements
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
- `owner` (optional): Assign to agent
- `addBlocks` (optional): Tasks this blocks
- `addBlockedBy` (optional): Tasks blocking this
- `metadata` (optional): Metadata updates

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
- Users can always select "Other" for custom input
- Put recommended option first with "(Recommended)"
- Use multiSelect for non-exclusive choices
- Max 12 characters for header

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

**Available skills** (in this project):
- `track-assumptions` - Structured response format
- `update-arch-doc` - PROJ-ARCH.md maintenance
- `update-layout-doc` - PROJ-LAYOUT.md maintenance

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

*This documentation is intended for AI assistants and agents working in the Claude Code environment. Last updated: 2026-02-02*
