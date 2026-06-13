# Post-Battle Screen

| Field | Value |
|-------|-------|
| **ID** | `post-battle-screen` |
| **Type** | Primary |
| **Category** | Core Gameplay |
| **User Stories** | US-004, US-010, US-012, US-047, US-063, US-067, US-076 |

## Description

Post-match results showing outcome, analytics, improvement suggestions, and sharing options. Scales from a glanceable summary to detailed per-match stats.

## Key Components

- **Battle Outcome Card** — Win/Loss/Draw above the fold with damage delta and highlight stat (US-067)
- **Node Activation Heatmap** — Heatmap overlay on fighter graph with phase filtering (US-004)
- **Improvement Suggestion Cards** — 2-3 ranked tips in plain language with one-tap Fighter Studio links (US-012, US-063)
- **Quick-Tweak Card** — Top single suggestion card with dismiss/review-later actions (US-063)
- **Detailed Stats Panel** — Actions/sec, confidence histogram, top node activations, exploitation score (US-047)
- **Highlight Clip Preview** — Auto-selected clip with trim UI and one-tap share (US-010)
- **Accessible Insight Report** — VoiceOver-navigable list with text equivalents for charts (US-076)
- **CSV Download Button** — Export detailed match stats (US-047)

## Interactions

- View summary or drill into detailed stats
- Share highlight clip to social media
- Accept suggestion to jump to Fighter Studio with pre-highlighted node
- Download stats as CSV
- Navigate to full replay

## Navigation

- Accessible from: Notifications (battle resolved), Ranked Arena
- Links to: Battle Replay Viewer, Fighter Studio, Share Sheet, Match History
