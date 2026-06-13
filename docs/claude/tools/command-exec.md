# Command Execution

## Bash

**Purpose**: Execute shell commands in a persistent working directory.

**When to use**:
- Git operations
- Running tests
- Installing dependencies
- Process management
- Any terminal operation

**Parameters**:
- `command` (required): Shell command to execute
- `description` (optional but recommended): Clear description of what command does
- `timeout` (optional): Milliseconds (default: 120000, max: 600000)
- `run_in_background` (optional): Run async (returns task ID)
- `dangerouslyDisableSandbox` (optional): Override sandbox mode (use with caution)

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

**Safety guidelines**:
- **Destructive operations**: Commands like `rm -rf`, `git reset --hard`, `git push --force` should only be used when explicitly requested
- **Git commits**: Only create commits when the user explicitly asks. Never use `--amend` after hook failures (creates NEW commit instead)
- **Secrets**: Never commit files that may contain secrets (.env, credentials.json, etc.)
- **Force operations**: Never force push to main/master branches without explicit user approval
- **Hooks**: Don't skip hooks with `--no-verify` unless explicitly requested

**Git-specific considerations**:

| Issue | Why it happens | Solution |
|-------|----------------|----------|
| Command hangs | Interactive prompts (`git rebase -i`, `git commit` without `-m`) | Always use non-interactive flags: `-m` for commit messages. NEVER use `rebase -i` or `--no-edit` with rebase |
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

When you run a command with `run_in_background: true`, you receive a task ID.

| Question | Answer |
|----------|--------|
| How to check output/status? | Use `TaskOutput` tool with the task ID (see [agents.md](agents.md)) |
| How to stop a background task? | Use `TaskStop` tool with the task ID (see [agents.md](agents.md)) |
| What happens when conversation ends? | Background processes terminate when the session ends |
| Can I run multiple background tasks? | Yes, each gets a unique task ID |

**Note**: TaskOutput and TaskStop also work with background Task agents (sub-agents), not just Bash commands.

**Timeout recommendations by operation type**:

| Operation | Timeout range | Notes |
|-----------|---------------|-------|
| Quick commands (<1s) | Use default (120000ms = 2 min) | Safe default, no need to specify |
| Test suites | 180000-300000ms (3-5 min) | Depends on suite size and hardware |
| Installations | 300000-600000ms (5-10 min) | For large packages may need background execution |
| Docker builds | 600000ms max → use background | Exceeds max timeout, always run in background |

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

**Managing background tasks**:

Background tasks (both Bash commands and Task agents) return a task ID. Use these tools to manage them:
- **TaskOutput** - Retrieve output from running or completed background tasks
- **TaskStop** - Stop a running background task

For complete documentation, see [agents.md](agents.md#taskoutput) and [agents.md](agents.md#taskstop).