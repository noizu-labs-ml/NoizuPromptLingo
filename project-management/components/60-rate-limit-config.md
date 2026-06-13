# Rate Limit Config

| Field | Value |
|-------|-------|
| **ID** | `rate-limit-config` |
| **Category** | Admin |
| **Used In** | S-25 Admin Dashboard (Rate Limits Section) |

## Description

Configuration form for API rate limit rules organized by subscription tier. Allows admins to set request-per-minute limits, burst allowances, and cooldown periods per tier. Changes take effect immediately upon save with no service restart required.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-tier edit form — used when an admin drills into one tier from a summary list |
| **Expanded** | Full multi-tier table with one row per subscription tier and inline editable fields |

## Props / Configuration

- `tiers` — Array of tier config objects: `{ tierId, tierName, requestsPerMinute, burstAllowance, cooldownSeconds }`
- `isLoading` — Boolean; renders skeleton rows while config is fetching
- `isSaving` — Boolean; disables all inputs and shows spinner on save button during save operation
- `onSave` — Callback receiving updated tiers array on form submission
- `onReset` — Callback to reset all fields to last-saved values

## Interactions

- Each tier is displayed as a table row with inline number inputs for `requestsPerMinute`, `burstAllowance`, and `cooldownSeconds`
- Input fields enforce numeric-only entry with min/max constraints: RPM 1–10,000, burst 0–500, cooldown 0–3,600
- Changing any field marks that row with a "Modified" indicator (amber dot) without immediately saving
- Save button is enabled only when at least one field has been changed; disabled and shows "No changes" otherwise
- Save action applies all modified tiers in a single API call; partial failures display per-tier error badges
- Reset discards all unsaved changes and reverts inputs to the last-saved values with a confirmation prompt
- A "Default" badge marks any tier whose values match the system defaults; clicking "Restore Default" per row resets that tier
- Hover tooltip on each column header explains the field's effect (e.g., "Burst Allowance: extra requests allowed in a short spike before throttling begins")
