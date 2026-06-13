# Expectation List

| Field | Value |
|-------|-------|
| **ID** | `expectation-list` |
| **Category** | Domain-Specific |
| **Used In** | 02-Graph Editor, 09-Run Detail, 12-Rubric Detail, 14-Persona Detail, 17-Review Detail |

## Description

Ordered list of expectations attached to a node or persona. Each expectation has label, weight, direction (higher_is_better/lower_is_better), scoring_method, and optional rubric reference. Used in editing (add/edit/remove) and display (show scores) contexts.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Read-only display of expectations with scores (Run Detail) |
| **Expanded** | Editable list with inline forms for label, weight, direction, method (Graph Editor) |

## Props / Configuration

- `expectations` — Array of { label, weight, direction, scoringMethod, rubricRef }
- `editable` — Whether items can be added/edited/removed
- `scores` — Optional scores to display alongside each expectation (read mode)
- `onUpdate` — Callback when expectations are modified
- `personaScoped` — Whether these are persona-specific expectations

## Interactions

- Add new expectation with inline form
- Edit existing expectation fields
- Reorder by drag
- Remove expectations
- In display mode: show score/verdict per expectation
