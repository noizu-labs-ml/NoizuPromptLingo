# 22: CLI Convert

| Field | Value |
|-------|-------|
| ID | SCR-22 |
| Surface | cli-ink |
| Type | storyboard |
| Category | Core |
| Route / Entry | interactive router: `convert` (via `c` from CLI Thread) |
| Primary Personas | P-002, P-004 |
| User Stories | US-047, US-048, US-049, US-050, US-051, US-052 |

## Description
Terminal counterpart to Web Convert Wizard (SCR-06): the same 5-step artifact-extraction flow (type → messages → configure → preview → export), navigated with `StepIndicator` and list/form controls instead of mouse-driven steps.

## Entry Points
- `c` from CLI Thread (SCR-19)

## Key Components
- StepIndicator — current step of 5, keyboard-advanceable
- SelectableList — artifact type selection (Step 1), candidate selection
- Message range selector — reuses the multi-select pattern from CLI Edit (Step 2)
- Metadata form via sequential `TextInput` fields (Step 3)
- Rendered preview pane with syntax highlighting (Step 4)
- Export confirmation (Step 5)

## States
- **Loading:** Spinner while AI candidates resolve (Step 1/2 boundary)
- **Error:** export failure shown inline at Step 5, wizard state preserved for retry

## Interactions
- Tab/Enter advances steps; a dedicated back key returns to the prior step without losing entered data
- Selecting a suggested candidate pre-fills Step 2's range and jumps to Step 3

## Navigation
- **From:** SCR-19 CLI Thread
- **To:** SCR-19 (on complete/cancel), filesystem (export target)
