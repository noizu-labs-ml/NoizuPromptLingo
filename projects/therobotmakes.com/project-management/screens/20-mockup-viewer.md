# Mockup Viewer

| Field | Value |
|-------|-------|
| **ID** | `mockup-viewer` |
| **Type** | Primary |
| **Category** | Draft Phase |
| **User Stories** | INK-034, INK-035, INK-036 |

## Description

High-fidelity mockup display with full style guide applied. Shows mockups alongside source wireframes for comparison. Supports revision workflow and approval gate.

## Key Components

- **Mockup Canvas** — Full-fidelity rendered screen with style guide tokens applied (INK-034)
- **Wireframe Comparison** — Side-by-side wireframe vs. mockup (INK-034)
- **Region Selector** — Click regions to target specific areas for revision (INK-035)
- **Revision Input** — Natural-language change description per region (INK-035)
- **Approval Controls** — Per-screen status (Pending/Approved/Needs Revision/Rejected) with rationale note (INK-036)

## Interactions

- Side-by-side comparison toggleable
- Click region → enter revision description → generates new version
- Before/after shows revision result
- Per-screen approval with required rationale on rejection
- Approval summary gating advance to next phase

## Navigation

- Accessible from: Wireframe Gallery completion, Dashboard "Continue" on Draft:Mockups
- Links to: Interactive Prototype, Export, Phase completion
