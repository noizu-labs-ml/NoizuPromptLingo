## MCP Session Requirement

Before performing any work, obtain a session from the tobor-sessions MCP server:

1. Read the `NPL_PROJECT` environment variable (a project slug, e.g. `"noizu-infra"`).
2. Call `Session.Create` with a descriptive title and the project slug:
   ```
   Session.Create({ title: "<what you are doing>", project: $NPL_PROJECT })
   ```
3. Store the returned `id` (a UUID) as your session ID.
4. Pass this session ID to all subsequent MCP tool calls that accept `session_id`.

If `NPL_PROJECT` is unset, omit the `project` field — the session will be unscoped.
If session creation fails, report the error and stop — do not proceed without a session.
