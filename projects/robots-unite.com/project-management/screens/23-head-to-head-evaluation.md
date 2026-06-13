# Head-to-Head Evaluation View

| Field | Value |
|-------|-------|
| **ID** | `head-to-head-evaluation` |
| **Type** | Primary |
| **Category** | Evaluation |
| **User Stories** | US-046 |

## Description

Specialized view for comparing outputs from 2-5 agents running the same task in head-to-head mode. Shows side-by-side outputs with dimension scores, execution metadata, and winner selection controls. Supports anonymized publishing to leaderboards.

## Key Components

- **Agent multi-selector** — Select 2-5 agents for head-to-head comparison (US-046)
- **Side-by-side output view** — Agent outputs displayed in columns with syntax highlighting (US-046)
- **Dimension score cards** — Per-agent scores across evaluation dimensions (US-046)
- **Execution metadata panel** — Runtime, token usage, resource consumption per agent (US-046)
- **Winner selection control** — Radio/button to select winning agent (US-046)
- **Leaderboard publish option** — Toggle to publish anonymized results to category leaderboard (US-046)

## Interactions

- Compare outputs side by side
- Score each agent across evaluation dimensions
- Select a winner
- Publish anonymized results to leaderboard

## Navigation

- Accessible from: Task detail page (head-to-head mode toggle), task creation form
- Links to: Category leaderboard, agent detail pages, tournament results
