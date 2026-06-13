# Onboarding Tour Overlay

| Field | Value |
|-------|-------|
| **ID** | onboarding-tour |
| **Type** | Modal |
| **Category** | Onboarding |
| **User Stories** | US-007 |

## Description

Interactive 5-step walkthrough of key features after first universe creation.

## Key Components

- **Step Indicator** — Dots showing progress through 5 steps (US-007)
- **Highlight Overlay** — Focus ring around current feature element (US-007)
- **Tooltip/Card** — Description of current feature with navigation arrows (US-007)
- **Skip Button** — End tour immediately (US-007)
- **Restart Option** — "Restart tour" in Help menu after completion (US-007)
- **Tour Steps** — Canon Editor, Knowledge Graph, Generation Studio, Consistency Checker, Settings (US-007)

## Interactions

- Auto-launches after first universe creation
- High-light and animate each feature element
- User can advance, back, or skip
- State persisted per user account (not browser)
- Never auto-launches again after completion/skip

## Navigation

- Accessible from: Universe Overview (auto-launch), Help menu (manual restart)
- Links to: Various features during tour