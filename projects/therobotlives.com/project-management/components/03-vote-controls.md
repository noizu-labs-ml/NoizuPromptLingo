# Vote Controls

| Field | Value |
|-------|-------|
| **ID** | `vote-controls` |
| **Category** | Data Display |
| **Used In** | 17-Thread View, 36-User Profile |

## Description

Upvote/downvote buttons with net score display. Supports toggle behavior (click again to remove) and vote switching. Prevents self-voting and gates downvotes behind karma threshold.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Vertical up/down arrows + score, compact layout |
| **Expanded** | Score with visible upvote/downvote counters |

## Props / Configuration

- `score` — Net vote count
- `userVote` — Current user's vote state (up/down/none)
- `canDownvote` — Requires 5+ karma
- `isOwnPost` — Hides controls when true

## Interactions

- Click upvote → record vote; click again → remove vote
- Click downvote → record vote (if karma >= 5); click again → remove
- Click opposite → switch vote
- Unauthenticated → login prompt
