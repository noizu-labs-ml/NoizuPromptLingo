# Semantic Memory Search Bar

| Field | Value |
|-------|-------|
| **ID** | `semantic-memory-search-bar` |
| **Category** | AI-Specific |
| **Used In** | 36-agent-memory-browser |

## Description

Similarity search over a persona's memory store, paired with a filter over emotional valence/signature to narrow or reorder results. Kept distinct from the generic Search & Filter Bar because it searches by embedding similarity rather than keyword match, and its filter dimension (emotional valence) is an AI-native concept, not a generic facet.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Search input plus valence filter, wired to a ranked results list |

## Props / Configuration

- `query` — natural-language search text
- `valenceFilter` — narrows/reorders by emotional valence or signature
- `results` — ranked matches with similarity scores

## Interactions

- User searches → ranked results render with similarity scores
- User applies the valence filter → results narrow/reorder by valence or signature
