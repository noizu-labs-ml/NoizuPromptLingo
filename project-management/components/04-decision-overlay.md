# Decision Overlay

| Field | Value |
|-------|-------|
| **ID** | `decision-overlay` |
| **Category** | AI-Specific |
| **Used In** | 02-Battle Replay Viewer, 27-Web Replay Viewer, 03-Post-Battle Screen |

## Description

Toggleable overlay showing per-node confidence scores during battle replay. Three states: hidden, full, filtered. Supports category filtering (Perception/Decision/Action) and screenshot export.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Confidence badge rendered directly on a single node |
| **Expanded** | Full overlay applied across all nodes in the replay canvas |

## Props / Configuration

- `state` — Overlay visibility mode: `hidden`, `full`, or `filtered`
- `categoryFilter` — Node categories to include when state is `filtered`
- `nodes` — Node activation data with per-node confidence scores
- `watermarkFree` — Removes watermark from screenshot exports for linked accounts

## Interactions

- Toggle between hidden, full, and filtered states via control button
- Filter visible nodes by category (Perception/Decision/Action)
- Take screenshot of current overlay state
- Export screenshot with or without watermark depending on account link status
