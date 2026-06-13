# Rubric Marketplace

| Field | Value |
|-------|-------|
| **ID** | `rubric-marketplace` |
| **Type** | Primary |
| **Category** | Rubric & Scoring |
| **User Stories** | US-119 |

## Description

Community marketplace for browsing and importing shared rubrics (e.g., safety rubrics, RAG quality rubrics). Shows domain, provenance, criteria list, and sample scoring.

## Key Components

- **Marketplace grid** — Rubric cards with title, domain, author, criteria summary
- **Domain filter** — Safety, RAG, code-gen, etc.
- **Detail panel** — Full criteria list, judge model, sample scoring on canned example
- **Import action** — Deep-copies rubric into caller's org with provenance pointer

## Interactions

- Browse rubrics by domain and provenance
- Preview criteria and sample scoring
- Import into organization

## Navigation

- Accessible from: Rubric List (Import from Marketplace)
- Links to: Rubric Detail (after import)
