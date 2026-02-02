# Command Execution Summary

| Tool | Purpose | Required Params |
|------|---------|-----------------|
| **Bash** | Execute shell commands | `command` |

**Key rules:**
- **Quote paths with spaces**: `"path with spaces/file.txt"`
- **Use absolute paths**, avoid `cd`
- **Chain commands**: `&&` for dependent, `;` for independent
- **Avoid interactive prompts**: Always use `-m` for commits, never `rebase -i`
- **NEVER use for file ops**: Use Read/Write/Edit/Glob/Grep instead

**Timeouts**: Default 120s, max 600s. Use `run_in_background` for longer operations (Docker builds, large installs).

**Background tasks**: Use `TaskOutput` (check status) and `TaskStop` (terminate). See [agents.md](agents.md).

**Git safety**: NEVER use interactive flags (`-i`, `--amend` unless requested). Always use `-m` for commits. Avoid destructive commands unless explicitly requested.

---

**Parallel execution**: Call Bash multiple times in one response for independent commands.

---

**For expanded view:** [command-exec.md](command-exec.md) — Full documentation with usage examples, timeout recommendations, Git safety protocols, and background task management. Load for unfamiliar tools or edge cases.