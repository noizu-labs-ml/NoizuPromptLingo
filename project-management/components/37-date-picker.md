# Date Picker

| Field | Value |
|-------|-------|
| **ID** | `date-picker` |
| **Category** | Input & Forms |
| **Used In** | 03-Time Blocking, 08-Personal Lists, 14-Sprint Planning, 16-Gantt View |

## Description

Inline date/time selector with relative options (tomorrow, next week) and recurrence configuration

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Text-based date with click-to-edit |
| **Compact** | Icon + date text with dropdown calendar |
| **Expanded** | Calendar grid with time and recurrence options |

## Props / Configuration

- `value` — date
- `onChange` — callback
- `showTime` — boolean
- `relativeOptions` — array
- `recurrence` — boolean
- `minDate` — optional
- `maxDate` — optional

## Interactions

- click to open calendar
- type date text directly
- select relative options
- configure recurrence
