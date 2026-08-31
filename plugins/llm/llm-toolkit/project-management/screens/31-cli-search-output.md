# 31: CLI Search (command output)

| Field | Value |
|-------|-------|
| ID | SCR-31 |
| Surface | cli-command |
| Type | primary |
| Category | Core |
| Route / Entry | `llm-toolkit search <query> [--semantic] [--project <path>]` |
| Primary Personas | P-001, P-008 |
| User Stories | US-060, US-021, US-022 |

## Description
One-shot Ink command that hits the running API's `/api/search` endpoint and renders results to stdout as a simple, scriptable list — the non-interactive counterpart to CLI Explore's search mode (SCR-16), for use in shell pipelines or quick lookups without entering the full-screen TUI.

## Entry Points
- `llm-toolkit search "<query>"` from any shell (auto-starts the API server via `ensureApi()` if not already running)

## Key Components
- Result list renderer — conversation title, project path, updated date, matched snippet, relevance score

## States
- **Loading:** brief inline "searching…" while the fetch resolves
- **Empty:** "No results" message
- **Error:** API error surfaces the HTTP status inline (`API error: {status}`)

## Interactions
- `--semantic` switches ranking mode from full-text to semantic
- `--project` scopes results to one project path
- JSON output for scripting (US-060) mirrors the `recent` command's `--json` convention

## Navigation
- **From:** shell invocation
- **To:** n/a (prints and exits); result id feeds `llm-toolkit show <id>` (SCR-33)
