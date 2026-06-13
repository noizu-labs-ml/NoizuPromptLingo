# Linked Items Section

| Field | Value |
|-------|-------|
| **ID** | `linked-items-section` |
| **Category** | Tables & Lists |
| **Used In** | 23-Bug Detail, 25-Root Cause Dashboard, 33-Incident Detail, 38-Post-Incident Review, 40-ADR Index, 41-Runbook Manager |

## Description

Section showing related/linked entities (bugs, incidents, PRs, deploys) with type badges and navigate actions

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact chip list of linked items |
| **Compact** | List with type badge and title |
| **Expanded** | Full section with metadata per link |

## Props / Configuration

- `items` — array of {type, title, id, status}
- `onNavigate` — callback
- `addEnabled` — boolean
- `linkTypes` — allowed types

## Interactions

- click to navigate to linked item
- add new links
- remove links
- filter by link type
