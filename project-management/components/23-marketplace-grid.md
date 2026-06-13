# Marketplace Grid

| Field | Value |
|-------|-------|
| **ID** | `marketplace-grid` |
| **Category** | Cards & Tiles |
| **Used In** | 34-Persona Marketplace, 35-Rubric Marketplace |

## Description

Card-based grid layout for browsing community-shared entities (personas, rubrics). Each card shows title, author, description preview, download count, rating, and an import action. Supports filtering by domain/category.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full-page grid with filter sidebar and detail panel on selection |

## Props / Configuration

- `items` — Array of marketplace items (title, author, description, downloads, rating, domain)
- `filters` — Available filter dimensions (domain, tone, category)
- `onImport` — Callback to deep-copy item into user's org
- `detailPanel` — Show full details on selection

## Interactions

- Browse cards in grid layout
- Filter by domain/category/tone
- Click card to open detail panel with full info and sample data
- Click "Import" to copy into organization
- View ratings and download counts for social proof
