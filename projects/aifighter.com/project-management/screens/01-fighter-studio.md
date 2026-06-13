# Fighter Studio

| Field | Value |
|-------|-------|
| **ID** | `fighter-studio` |
| **Type** | Primary |
| **Category** | Core Gameplay |
| **User Stories** | US-001, US-006, US-015, US-017, US-019, US-053, US-058, US-062, US-070, US-071, US-075, US-087, US-088, US-089, US-093, US-097, US-100 |

## Description

The primary graph editor where players design their AI fighters by connecting nodes (Perception, Decision, Action, Utility). Supports visual canvas editing, list-based editing for accessibility, version control, import/export, and aesthetic customization.

## Key Components

- **Node Palette** — Searchable panel with 20+ node types organized by category tabs (US-001, US-015)
- **Graph Canvas** — Visual node editor with drag-to-position, snap-to-grid toggle, edge connections (US-001, US-087, US-093)
- **List Editor Mode** — Accessible alternative to visual canvas using sequential node/port pickers (US-070)
- **Version History Panel** — Snapshot list with timestamps, labels, restore, and visual diff overlay (US-006, US-058, US-097)
- **Graph Export Controls** — Export to .aifighter JSON (with full training history including topology, weights, hyperparams, seed, reward history), SVG, PNG with resolution options (US-017, US-053, US-088)
- **Graph Import Dialog** — Import with schema validation and conflict resolution (US-017)
- **Node State Indicators** — Non-color icons for active/error/inactive states (US-071)
- **Semantic Node Labels** — Screen reader labels with type, config summary, connections (US-075)
- **Graph Color Theme Picker** — 8+ visual themes for edges, nodes, backgrounds (US-089)
- **Alignment Toolbar** — Multi-select alignment and distribution tools (US-093)
- **Node Annotation Labels** — Freeform text labels on nodes/edges, 80 char max (US-100)
- **Patch Affected Banner** — Login banner showing nodes affected by recent patches (US-019)
- **Auto-Save Indicator** — "Saved"/"Saving" status in top bar (US-062)

## Interactions

- Drag nodes from palette onto canvas
- Connect node ports to create edges
- Search/filter nodes by name, category, or tags
- Save named version snapshots; restore or diff versions
- Switch between visual canvas and list editor mode
- Export graph as JSON, SVG, or PNG
- Apply color themes from cosmetic collection
- Multi-select nodes for alignment/distribution
- Add/edit annotation labels on nodes and edges

## Navigation

- Accessible from: Home, Template Gallery (fork), Post-Battle suggestions
- Links to: Training Gym, Ranked Arena, Version History, Graph Export, Template Gallery
