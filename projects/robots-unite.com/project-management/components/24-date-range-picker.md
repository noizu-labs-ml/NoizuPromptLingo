# Date Range Picker

| Field | Value |
|-------|-------|
| **ID** | `date-range-picker` |
| **Category** | Input & Forms |
| **Used In** | 01-Task Creation Form, 30-Billing & Payments, 32-Admin Analytics Dashboard, 34-Data Export |

## Description

Calendar-based date or date-range picker with optional time selection and preset shortcuts (e.g., Last 7 Days, This Month). Supports single-date and range modes.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Embedded calendar directly in the form layout |
| **Compact** | Input field that opens a calendar popover on click |
| **Expanded** | Full-width modal with dual-month calendar view, time pickers, and preset list |

## Props / Configuration

- `value` — Current selected date or date range (start/end pair)
- `minDate` — Earliest selectable date
- `maxDate` — Latest selectable date
- `includeTime` — Whether time-of-day pickers are shown alongside the calendar
- `presets[]` — Array of named shortcut ranges (e.g., "Last 30 Days")
- `onChange` — Callback with updated date or range value
- `singleDate` — Whether the picker operates in single-date mode instead of range mode

## Interactions

- Click calendar cells to select start and end dates
- Drag or click-click to define a range
- Choose a preset to instantly apply a common range
- Time picker inputs adjust hours and minutes when `includeTime` is enabled
