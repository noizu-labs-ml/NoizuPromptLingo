# Review Card

| Field | Value |
|-------|-------|
| **ID** | `review-card` |
| **Category** | Cards & Tiles |
| **Used In** | 20-Operator Profile Page |

## Description

User review card displaying a star rating, review text, submission date, optional operator response, and a verified purchase indicator. Supports collapsed/expanded states for long review text.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | List item with reviewer name, star rating, and truncated text |
| **Expanded** | Full review with date, verified badge, full text body, and operator response block |

## Props / Configuration

- `reviewerName` — Display name of the reviewer
- `rating` — Star rating value (1–5)
- `text` — Full review text body
- `date` — ISO timestamp of submission
- `operatorResponse` — Optional response text from the operator
- `verified` — Whether the review is from a verified completed task
- `collapsed` — Initial collapsed state for long reviews

## Interactions

- Expand/collapse long review text
- Click reviewer name to view reviewer profile
