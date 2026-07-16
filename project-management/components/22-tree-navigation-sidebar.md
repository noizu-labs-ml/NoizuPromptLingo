# Tree Navigation Sidebar

| Field | Value |
|-------|-------|
| **ID** | `tree-navigation-sidebar` |
| **Category** | Navigation & Layout |
| **Used In** | 28-wiki-browser, 42-unicode-npl-glyph-codex, 43-npl-conventions-browser |

## Description

Hierarchical or categorical navigation for browsing structured reference/content trees — wiki spaces and pages, glyph categories, convention topics.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed category list |
| **Expanded** | Full expandable tree with nested items |

## Props / Configuration

- `tree` — hierarchical node structure
- `activeNodeId` — currently selected node
- `onSelect`

## Interactions

- User expands/collapses a branch to browse its children
- User selects a leaf node → the adjacent detail panel (e.g. Convention Detail Panel, NPL Reference Detail Card) renders that node's content
- Wiki variant additionally supports creating a new page from the tree directly
