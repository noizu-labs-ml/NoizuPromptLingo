# Severity Badge

| Field | Value |
|-------|-------|
| **ID** | `severity-badge` |
| **Category** | Feedback / Status |
| **Used In** | S18 Consistency Dashboard, S19 Issue Cards, S25 Admin Alerts |

## Description

Color-coded badge conveying the severity of an issue, alert, or policy violation. Pairs a semantic icon with a short label. Three levels: Error (red, X-circle icon), Warning (amber, triangle-alert icon), Suggestion (blue, info icon). Used in consistency check results, moderation issue cards, and admin system alerts.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon + label in a tight pill; used inside table cells and list rows |
| **Compact** | Icon only with tooltip; used in dense dashboards where space is limited |
| **Expanded** | Icon + label + short description text; used in issue detail cards |

## Props / Configuration

- `level` — `error | warning | suggestion`; drives color and icon
- `label` — Display text; defaults to the level name capitalized
- `description` — Optional secondary text shown in expanded variant
- `size` — `inline | compact | expanded`
- `icon` — Optional icon override; defaults to level-mapped glyph

## Interactions

- Compact (icon-only) variant shows tooltip with level name and description on hover
- Badge is non-interactive by default; parent component handles click/navigation
- When used in admin alert banners, badge is part of a dismissible container
- Color values meet WCAG AA contrast requirements against both light and dark panel backgrounds
