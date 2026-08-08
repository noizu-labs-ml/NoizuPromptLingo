---
name: session-info
description: Outputs the current registered tobor work session — session GUID, project, organization, title, status — plus the resolved NPL org/project slugs.
---

# Session Info

Report the **registered work session** for this conversation — the session
created via `Session.Create` (tobor-sessions MCP) per CLAUDE.md's FIRST ACTION
step. This is NOT the Claude Code harness/runtime; it's the NPL work session
that artifacts, tickets, and chat rooms hang off of.

## 1. Resolve the environment slugs

```bash
echo $NPL_ORG        # organization slug (e.g. noizu-labs)
echo $NPL_PROJECT    # project slug (e.g. npl)
```

## 2. Identify the active session

- If a session was already registered earlier in this conversation, use that
  **session UUID** — do not create a new one.
- If no session UUID is known yet, say so plainly: report that no work session
  has been registered this conversation, and note that registering one is the
  CLAUDE.md FIRST ACTION step. Do **not** silently create one just to populate
  this report.

When a session UUID is known, fetch its current details:

```
ToolCall(tool: "Session.Get", arguments: { "session": "<session-uuid>" })
```

(If `Session.Get` isn't available, use the tobor-sessions discovery tools —
`ToolSearch` / `ToolDefinition` — to find the right read tool.)

## 3. Output

Report as a terse definition list:

- **Session GUID** — the UUID
- **Title** — short session title
- **Description** — longer detail, if set
- **Status** — active / etc.
- **Organization** — slug (and name/UUID if returned)
- **Project** — slug (and name/UUID if returned), or `none` if the session has
  no project association
- **Created / updated** — timestamps, if returned

Then a one-line reconciliation note: do the session's org/project match
`$NPL_ORG` / `$NPL_PROJECT`? Flag any mismatch (e.g. session has no project but
`$NPL_PROJECT` is set, or org slugs differ).

Do not invent values — report only what the tool returns and what the env
resolves to. If a field is absent, write `unknown` or `none`.
