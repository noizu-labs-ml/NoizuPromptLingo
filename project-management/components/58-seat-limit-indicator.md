# Seat Limit Indicator

| Field | Value |
|-------|-------|
| **ID** | `seat-limit-indicator` |
| **Category** | Domain-Specific |
| **Used In** | 25-Organization Settings |

## Description

Visual display of current seat usage against the plan limit. Renders a progress-style indicator and surfaces an upgrade prompt when usage approaches or reaches the cap.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Full usage bar with seat count label and upgrade link within the settings panel |
| **Compact** | Small badge for headers or navigation showing used/limit ratio with color state |

## Props / Configuration

- `used` — Number of seats currently occupied
- `limit` — Maximum seats allowed under the current plan
- `onUpgrade` — Callback triggered when the upgrade prompt is activated
- `warningThreshold` — Ratio (0–1) at which the warning state is applied (default 0.8)

## Interactions

- Click the upgrade prompt or CTA to invoke `onUpgrade` and navigate to billing
- Warning color state activates automatically when `used / limit` exceeds `warningThreshold`
