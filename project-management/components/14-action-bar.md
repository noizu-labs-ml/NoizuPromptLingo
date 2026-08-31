# 14: Action Bar

| Field | Value |
|-------|-------|
| ID | CMP-14 |
| Category | Navigation & Layout |
| Surfaces | web, cli-ink |
| Used In | SCR-04, SCR-19 |

## Description
The action hub for a thread: Edit, Convert, Continue, Merge, Tag, Archive, Rehome, Delete. On web these are buttons; on cli-ink they're single-key bindings (`e`, `c`, `u`, `t`/`T`, `a`, `r`, plus `C` clone) surfaced via the StatusLine (CMP-39) key legend rather than visible buttons.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Full (web) | Button row under/beside ThreadHeader |
| Key-bound (cli-ink) | No persistent visual row — actions live in the key legend |

## Props / Configuration
- `availableActions` — action set can vary (e.g. Archive hidden for already-archived threads, Restore shown instead)

## Interactions
- Each action either navigates to a dedicated screen (Edit → SCR-05/21, Convert → SCR-06/22, Continue → SCR-07/20) or opens a modal/confirmation (Archive, Rehome, Delete, Tag, Clone)
