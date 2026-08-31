# 20: CLI Continue Session

| Field | Value |
|-------|-------|
| ID | SCR-20 |
| Surface | cli-ink |
| Type | primary |
| Category | Core |
| Route / Entry | interactive router: `continue` (via `u` from CLI Thread) |
| Primary Personas | P-001, P-007, P-008 |
| User Stories | US-035, US-093 |

## Description
Terminal counterpart to Web Continue Session (SCR-07): generates a copy/paste-ready resume command or cross-harness transfer prompt for the current conversation, rendered directly in the terminal.

## Entry Points
- `u` from CLI Thread (SCR-19)

## Key Components
- ResumeCommandBlock / TransferPromptBlock — rendered text block, selectable for terminal copy
- HarnessSelector

## States
- **Loading:** Spinner while the universal conversation transform resolves
- **Error:** inline error text on transform failure

## Interactions
Exact key bindings (from `ContinueSessionPage.tsx`):
- `Esc` / `b` — back to Thread
- `t` — switch target harness
- `m` — switch view mode (continuation/universal/raw)
- `r` — regenerate / refresh output

## Navigation
- **From:** SCR-19 CLI Thread
- **To:** SCR-19 (back)
