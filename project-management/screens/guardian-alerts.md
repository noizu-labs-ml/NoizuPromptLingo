---
id: screen-guardian-alerts
title: "Guardian Alerts"
route: /guardian/alerts
personas: [persona-the-guardian]
priority: must-have
---

# Guardian Alerts

## Purpose
Security and integrity alert feed from the Guardian agent. Shows blocked memories, detected contradictions, quarantined entries awaiting review, and injection pattern detections. Operators use this screen to review and resolve Guardian decisions — approving legitimate memories that were quarantined, confirming rejections, and monitoring for adversarial patterns.

## Layout

```
+------------------------------------------------------------------+
|  Alert Summary Bar                                                 |
|  Quarantined: 3 | Contradictions: 7 | Blocked: 12 | Injections: 0|
|  [Filter: All ▼] [Severity: All ▼] [Time: 24hr ▼] [Status: Open ▼]|
+------------------------------------------------------------------+
|                                                                    |
|  Alert Feed (vertical, scrollable)                                 |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  | [!] QUARANTINED — High severity              2 min ago        | |
|  |                                                                | |
|  | Memory: "Service X now uses OAuth2 for authentication"        | |
|  | [EmotionBadge: neutral]                                       | |
|  |                                                                | |
|  | Reason: Contradicts existing memory m-def456:                 | |
|  |   "Service X uses JWT authentication (confirmed 3 weeks ago)" | |
|  | Similarity: 0.89 | Contradiction confidence: 0.82             | |
|  |                                                                | |
|  | [✓ Approve] [✗ Reject] [⊞ Merge] [→ Escalate] [Details ▼]   | |
|  +--------------------------------------------------------------+ |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  | [△] CONTRADICTION DETECTED — Medium severity   14 min ago     | |
|  |                                                                | |
|  | Memory A: "Deploy succeeded on first try" (m-abc123)          | |
|  | Memory B: "Deploy required 3 rollbacks" (m-ghi789)            | |
|  | Same session, same timestamp range, incompatible claims.       | |
|  |                                                                | |
|  | [Keep A] [Keep B] [Keep Both + Link] [Merge] [Details ▼]     | |
|  +--------------------------------------------------------------+ |
|                                                                    |
|  +--------------------------------------------------------------+ |
|  | [○] BLOCKED — Low severity                    1 hour ago      | |
|  |                                                                | |
|  | Memory: "[redacted content pattern]"                          | |
|  | Reason: Matches injection blocklist pattern #7                 | |
|  | Pattern: "ignore previous instructions..."                    | |
|  |                                                                | |
|  | [Override + Store] [Confirm Block] [Details ▼]                | |
|  +--------------------------------------------------------------+ |
|                                                                    |
+------------------------------------------------------------------+
```

## Key Components
- **Alert Summary Bar**: Counts by category (quarantined, contradictions, blocked, injections). Filter dropdowns for category, severity (high/medium/low), time range, and resolution status (open/resolved/escalated).
- **Alert Cards**: Each alert is a card showing:
  - Severity icon and color (red=high, amber=medium, grey=low)
  - Category label (quarantined, contradiction, blocked, injection)
  - Timestamp (relative, hover for absolute)
  - Affected memory content preview with emotion badge
  - Reason for the alert (why the Guardian flagged this)
  - For contradictions: both memories side by side with similarity score
  - Action buttons appropriate to the alert type
- **Action Buttons**: Context-sensitive per alert type:
  - Quarantined: Approve (store the memory), Reject (delete), Merge (combine with existing), Escalate (flag for senior review)
  - Contradiction: Keep A, Keep B, Keep Both + Link (acknowledge both are valid), Merge
  - Blocked: Override + Store (admin bypass), Confirm Block
  - All types: Details toggle for full metadata view

## Interactions
- **Approve quarantined memory** → Memory moves from quarantine to the standard storage pipeline. Weaver creates associations. Toast confirmation.
- **Reject quarantined memory** → Memory is permanently deleted. Logged in audit trail.
- **Merge** → Opens merge modal showing both memories side by side with a proposed merged version. Editable before confirming.
- **Escalate** → Sends notification to configured escalation channel. Alert card shows "Escalated" badge.
- **Keep Both + Link** → Both memories are kept. A `contradiction` association edge is created between them with a note.
- **Override + Store (blocked)** → Admin-only. Stores the blocked memory, adds the override to audit log, and updates Guardian patterns.
- **Filter change** → Immediate re-filter of the alert feed.
- **Click memory ID** → Navigate to `/memories/:id` (if stored) or show quarantine detail modal.
- **Details toggle** → Expand alert card to show full memory metadata, Guardian's analysis, related memories, and timeline of the detection.

## Data Requirements
- `GET /api/v1/admin/quarantine` — Quarantined memories with Guardian analysis
- `GET /api/v1/guardian/alerts?category=...&severity=...&status=...&range=...` — Filtered alert feed
- `POST /api/v1/admin/quarantine/:id/approve` — Approve quarantined memory
- `POST /api/v1/admin/quarantine/:id/reject` — Reject quarantined memory
- `POST /api/v1/memories/:id/merge` — Merge two memories
- `GET /api/v1/guardian/patterns` — Injection blocklist patterns (for details view)
- WebSocket: `integrity.alert`, `integrity.contradiction` for real-time feed updates

## States
- **Empty state**: "No alerts. The Guardian reports all clear." with a green checkmark illustration.
- **Loading state**: Skeleton alert cards. Summary bar shows loading shimmer.
- **High-severity flood**: If > 10 high-severity alerts in the last hour, show a warning banner: "Unusual alert volume detected. Possible coordinated injection attempt." with a link to escalation procedures.
- **Error state**: Error banner at top. Alert feed shows last-cached data with "Data may be stale" warning.
