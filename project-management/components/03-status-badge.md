# Status Badge

| Field | Value |
|-------|-------|
| **ID** | status-badge |
| **Type** | Simple |
| **Category** | Lists |
| **Screen Usage** | Canon Editor List, Canon Entry Detail, Generation Queue |

## Description

Colored badge displaying entity status (Canon/Draft/Generated, etc.).

## Size Variants

- XSmall — Inline badges
- Small — Default list items
- Medium — Detail headers

## Props

- `status` — Status value (canon, draft, generated, pending, completed, failed, etc.)
- `label` — Custom label override
- `size` — Badge size variant
- `icon` — Optional icon prefix

## Interactions

- None (display only component)
- Hover shows tooltip with full status name

## Accessibility

- `role="status"` ARIA role
- `aria-label` for screen readers
- Color coded with sufficient contrast (3:1)