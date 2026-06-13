# Tab Bar

| Field | Value |
|-------|-------|
| **ID** | `tab-bar` |
| **Category** | Navigation & Layout |
| **Used In** | 21-Template Library, 44-Checklist Library, 64-Prompt Template Library, 73-User Settings, 74-Workspace Settings |

## Description

Horizontal tab switcher for content categories within a view

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Inline text tabs (underline style) |
| **Compact** | Pill-style tab buttons |
| **Expanded** | Tabs with icon + label + count badge |

## Props / Configuration

- `tabs` — array of {id, label, icon, count}
- `activeTab` — selected tab id
- `onChange` — callback

## Interactions

- click to switch tab
- keyboard left/right navigation
- badge counts update dynamically
