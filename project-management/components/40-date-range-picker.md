# Date Range Picker

| Field | Value |
|-------|-------|
| **ID** | `date-range-picker` |
| **Category** | Forms / Filtering |
| **Used In** | S24 Admin Analytics, S12 Generation History, S25 Audit Logs |

## Description

Calendar-based date range selector for filtering data by a start and end date. Renders as a trigger input showing the selected range, opening a popover with one or two calendar months. Supports preset ranges (Last 7 days, Last 30 days, This month, Last 3 months, Custom) for quick selection. Used in admin analytics to scope metric views, in generation history to filter by date, and in audit logs for time-bounded queries.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single trigger + single-month calendar popover; used in filter toolbars with limited width |
| **Expanded** | Dual trigger inputs + two-month side-by-side calendar; preset list on the left; used in full-width filter panels |

## Props / Configuration

- `startDate` — Date or null; controlled start of range
- `endDate` — Date or null; controlled end of range
- `onChange` — Callback `(start: Date | null, end: Date | null) => void`
- `presets` — Array of `{ label, start, end }`; shown as quick-select buttons; defaults to standard presets
- `minDate` — Date; earliest selectable date; defaults to account creation date
- `maxDate` — Date; latest selectable date; defaults to today
- `placeholder` — String shown in trigger when no range is selected; defaults to "Select date range"
- `size` — `compact | expanded`
- `clearable` — Boolean; when true shows a clear (×) button on the trigger to reset selection

## Interactions

- Click on trigger opens the calendar popover; Escape or outside-click closes it
- First click in calendar sets start date; second click sets end date; range is highlighted between them
- If user clicks a start date after the current end date, the range resets and user picks a new start
- Preset buttons immediately apply the range and close the popover
- Clear button resets both dates to null and calls `onChange(null, null)`
- Keyboard: arrow keys navigate calendar days, Enter selects, Tab moves between months
