# Demo Preview

| Field | Value |
|-------|-------|
| **ID** | `demo-preview` |
| **Type** | Primary |
| **Category** | Ink Phase |
| **User Stories** | INK-057, INK-058, INK-059, INK-060 |

## Description

Live preview of the running application in an embedded iframe. Supports responsive device switching, stakeholder sharing via time-limited links, and screenshot snapshots for comparison.

## Key Components

- **Preview Iframe** — Embedded running application in isolated container (INK-057)
- **Device Switcher Toolbar** — Desktop/Tablet/Mobile presets + custom dimensions with device frame overlay (INK-058)
- **Share Preview Modal** — Time-limited URL with expiration config and revoke action (INK-059)
- **Snapshot Gallery** — Full-page screenshots per viewport with story ID + timestamp labels (INK-060)
- **Before/After Slider** — Comparison slider between two snapshots (INK-060)

## Interactions

- Iframe auto-refreshes on story approval
- Device switcher changes viewport; side-by-side mode for two viewports
- "Share" generates time-limited link with viewer comment widget
- "Snapshot" captures current state; auto-snapshot toggle available
- Snapshot gallery shows chronological history with download/share

## Navigation

- Accessible from: Agent Development toolbar, Agent Dashboard
- Links to: Share link (external), Snapshot Gallery, Publish phase
