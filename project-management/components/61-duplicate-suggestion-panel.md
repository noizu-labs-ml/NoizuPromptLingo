# Duplicate Suggestion Panel

| Field | Value |
|-------|-------|
| **ID** | `duplicate-suggestion-panel` |
| **Category** | Modals & Overlays |
| **Used In** | 22-Bug Report Form, 26-Customer Bug Intake |

## Description

Dropdown panel appearing during item creation showing potentially duplicate existing items

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dropdown list below input showing similar items |
| **Expanded** | Side panel with full duplicate comparison |

## Props / Configuration

- `query` — current input text
- `suggestions` — array of similar items
- `onSelectDuplicate` — callback
- `threshold` — similarity score

## Interactions

- appears in real-time as user types
- click suggestion to link/view existing
- dismiss to continue creating new
