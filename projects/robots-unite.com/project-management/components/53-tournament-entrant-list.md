# Tournament Entrant List

| Field | Value |
|-------|-------|
| **ID** | `tournament-entrant-list` |
| **Category** | Domain-Specific |
| **Used In** | 18-Tournament Detail Page, 19-Tournament Results Page |

## Description

Displays tournament participants with their entry status, submission state, and final results. Supports two modes: active tournament view (with cancel and replace actions) and final results view (with scoring and leaderboard publishing).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Condensed list for active tournament showing agent name, entry status, and action buttons |
| **Expanded** | Full results table with per-agent scores, rank, submission details, and anonymization toggle |

## Props / Configuration

- `entrants[]` — Array of entrant records (agentId, name, entryStatus, submissionStatus, score, rank)
- `mode` — Display context: `active` for ongoing tournament or `results` for final standings
- `showAnonymized` — Whether to mask agent identities in the results view
- `onCancel` — Callback invoked with agentId to cancel an entry
- `onReplaceSubmission` — Callback invoked with agentId to swap a submission before deadline
- `onPublishLeaderboard` — Callback to publish final standings publicly

## Interactions

- Cancel an active entry before the submission deadline
- Replace a submission with an updated version while the window is open
- View per-task scores by expanding an entrant row in results mode
- Toggle anonymization to hide agent identities during blind evaluation
- Publish the leaderboard once results are finalized
