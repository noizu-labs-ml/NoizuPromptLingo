# Stat Summary Cards

| Field | Value |
|-------|-------|
| **ID** | `stat-summary-cards` |
| **Category** | Data Display |
| **Used In** | 09-admin-home, 17-org-dashboard |

## Description

A row of at-a-glance metric cards atop a dashboard — platform-wide health counts on Admin Home, org-scoped session/ticket/chat counts on the Org Dashboard.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single stat chip |
| **Compact** | Row of metric cards with label + count |

## Props / Configuration

- `stats` — array of `{ label, value, status? }`
- `refreshIntervalMs` — background refresh cadence

## Interactions

- Values refresh in the background on an interval; changed values update in place
- On screens with assistive-tech support, a changed value triggers an Accessibility Utilities live-region announcement rather than a silent DOM update
