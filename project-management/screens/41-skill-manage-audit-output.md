# 41: skill-manage Audit (command output)

| Field | Value |
|-------|-------|
| ID | SCR-41 |
| Surface | cli-command |
| Type | primary |
| Category | skill-manage (audit) |
| Route / Entry | `skill-manage audit --strict` |
| Primary Personas | P-004, P-008 |
| User Stories | US-094 |

## Description
One-shot, non-interactive audit command (separate from `skill-manage tui`) that walks every provider's install root and reports symlink drift against the shared source root: broken/unresolved symlinks, items missing for a provider, and duplicated/inconsistent installs pointing at different source versions.

## Entry Points
- `skill-manage audit --strict` from any shell — typically run right after `skill-manage enable`/`skill-manage tui` bulk changes to verify rollout

## Key Components
- Drift report — one line per finding: exact path + drift type (`unresolved symlink`, `missing for provider: {name}`, `duplicated/inconsistent`)
- Clean-run summary — "no drift detected" message with exit code 0 when nothing is found

## States
- **Clean:** no drift → summary message, exit 0
- **Drift found:** one or more findings printed, non-zero exit code so it composes in CI/scripts
- **Findings detail:** each finding includes both/all relevant paths when items are duplicated across providers, not just the first one found

## Interactions
- `--strict` is the documented invocation; no interactive input — designed for scripting and pre/post-rollout verification

## Navigation
- **From:** shell invocation (often chained after `skill-manage tui` or `skill-manage enable`)
- **To:** n/a (prints and exits); findings typically send the user back into SCR-36 TUI Catalog Browser or SCR-39 Confirm Replace to fix drift
