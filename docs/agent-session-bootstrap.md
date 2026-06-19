# Agent Session Bootstrap

## Required: Obtain a Session Before Working

Every agent that connects to the NoizuPromptLingo MCP server **must** obtain a session UUID before performing any other work. The session ties all artifacts, tickets, chat messages, and activity to a trackable context.

### Bootstrap Procedure

1. **Read the `NPL_PROJECT` environment variable.** This contains the project slug that scopes your work.

2. **Create a session** via the `Session.Create` MCP tool on the `tobor-sessions` server:
   ```
   Session.Create({
     title: "<descriptive session title>",
     project: "<value of NPL_PROJECT>"
   })
   ```
   The `project` field accepts a project slug (e.g. `"noizu-infra"`, `"codefresh"`) and the server resolves it to the correct project internally.

3. **Store the returned session UUID.** Use it as the `session_id` parameter on all subsequent MCP tool calls that accept one (tickets, artifacts, chat rooms, etc.).

### Rules

- **Do not skip this step.** If you cannot create a session (server unreachable, project slug invalid), report the failure and stop — do not proceed without a session.
- **One session per agent invocation.** Do not create multiple sessions for a single task.
- **Use a descriptive title.** The title should reflect what the agent is doing (e.g. `"Code review: PR #42"`, `"Deploy validation: staging"`, `"Bug investigation: auth timeout"`).
- **If `NPL_PROJECT` is unset or empty**, create the session without a project association — pass no `project` field. The session will be unscoped.

### Example

```
# Step 1: Read environment
NPL_PROJECT = "noizu-infra"

# Step 2: Create session
result = Session.Create({
  title: "Infrastructure audit: Helm chart versions",
  project: "noizu-infra"
})
# => { id: "a1b2c3d4-...", title: "...", status: "active", project_id: "..." }

# Step 3: Use session UUID in subsequent calls
session_id = result.id
```

### For System Prompt / CLAUDE.md Integration

Add this to your agent's system prompt or CLAUDE.md:

```
## MCP Session Requirement

Before performing any work, you must obtain a session from the NoizuPromptLingo MCP server:

1. Read the NPL_PROJECT environment variable (project slug).
2. Call Session.Create with a descriptive title and the project slug.
3. Use the returned session UUID for all subsequent MCP interactions.

If session creation fails, report the error and stop.
```
