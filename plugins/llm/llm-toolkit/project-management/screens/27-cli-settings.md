# 27: CLI Settings

| Field | Value |
|-------|-------|
| ID | SCR-27 |
| Surface | cli-ink |
| Type | settings |
| Category | Onboarding / Core |
| Route / Entry | interactive router: `settings` |
| Primary Personas | P-008, P-001, P-005 |
| User Stories | US-016, US-017, US-018, US-019, US-020, US-012 |

## Description
Terminal counterpart to Web Settings (SCR-14): sectioned configuration (index paths, embedding provider, LLM provider, display) navigated with section focus + list cursor movement.

## Entry Points
- Router/sidebar navigation

## Key Components
- Sectioned SelectableList — one focusable section at a time (`index`, `embedding`, `llm`, `display`)
- PathList row navigation within the `index` section

## States
- **Loading:** Spinner while config resolves
- **Saving:** inline confirmation per field on save

## Interactions
Exact key binding (from `SettingsPage.tsx`, `index` section):
- `j` / `k` — move the watched-path cursor down/up within the index section
- (other sections follow the same `SelectableList` conventions as other pages)

## Navigation
- **From:** router / sidebar
- **To:** n/a (terminal settings page)
