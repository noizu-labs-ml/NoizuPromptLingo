# 33: CLI Show (command output)

| Field | Value |
|-------|-------|
| ID | SCR-33 |
| Surface | cli-command |
| Type | primary |
| Category | Core |
| Route / Entry | `llm-toolkit show <conversation-id>` |
| Primary Personas | P-001 |
| User Stories | US-076 |

## Description
One-shot Ink command that prints a single conversation's metadata and full message sequence to stdout — a non-interactive counterpart to CLI Thread (SCR-19) / Web Thread Viewer (SCR-04) for quick inspection or piping into other tools.

## Entry Points
- `llm-toolkit show <id>` from any shell

## Key Components
- ConversationMeta header block (title, project path, message count, started/updated timestamps)
- Message renderer — role + content per message, printed sequentially

## States
- **Missing id:** usage error printed in red ("Usage: llm-toolkit show <conversation-id>") when no id argument is given
- **Loading:** brief inline loading indicator while the API resolves
- **Not found:** clear "conversation not found" message and non-zero exit
- **Error:** API error surfaced with status code

## Interactions
- None beyond the initial invocation — output is a static print, not interactive

## Navigation
- **From:** shell invocation, output of `recent`/`search`/`list`
- **To:** n/a (prints and exits)
