# Consistency Issue Detail

| Field | Value |
|-------|-------|
| **ID** | consistency-issue-detail |
| **Type** | Modal |
| **Category** | Consistency |
| **User Stories** | US-056, US-051, US-052, US-053, US-054 |

## Description

Detailed view of a consistency issue with resolution actions.

## Key Components

- **Issue Header** — Type (timeline/geographic/duplicate/orphan), severity badge, detected timestamp (US-056)
- **Issue Description** — Plain-language explanation of the conflict (US-051)
- **Affected Entries** — Side-by-side view of conflicting entries (US-053)
- **Conflicting Fields** — Highlighted conflicting values (US-056)
- **Geographic Details** — Locations, character, time gap, min travel time (US-052)
- **Timeline Details** — Events, participants, contradictions (US-051)
- **Broken References** — Source entry, broken text, last known target (US-054)
- **Resolution Actions** — Pick Side, Merge, Mark Intentional buttons (US-056)
- **Merge Wizard** — Field-by-field conflict resolution (US-056)
- **Mark Intentional Form** — Rationale input (US-056)
- **Audit Log Reference** — Link to audit log for issue (US-059)

## Interactions

- Pick Side marks losing entry field as strikethrough
- Merge combines fields with conflict resolution per field
- Mark Intentional suppresses issue with rationale
- All resolutions create audit log entry
- Merge redirects references to surviving entry
- Absorbed entry archived, not deleted

## Navigation

- Accessible from: Consistency Dashboard (issue click), Real-time check callout
- Links to: Canon Entry Detail (affected entries), Audit Log