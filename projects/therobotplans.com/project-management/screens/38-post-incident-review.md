# Post-Incident Review

| Field | Value |
|-------|-------|
| **ID** | `post-incident-review` |
| **Type** | Storyboard |
| **Category** | Monitoring & Incidents |
| **User Stories** | US-055 |

## Description

Pre-filled post-incident review (PIR) template with reconstructed timeline, AI-drafted 5-whys analysis, editable sections for contributing factors, and action item creation. Saves to wiki.

## Flow Steps

1. **Review timeline** — AI-reconstructed timeline from incident events
2. **5-Whys analysis** — AI draft of root cause chain (editable)
3. **Contributing factors** — Add environmental/process factors
4. **Action items** — Create follow-up tasks from findings
5. **Publish** — Save to wiki and notify team

## Key Components

- **Pre-filled timeline** — Auto-generated from incident data
- **Five-whys draft** — AI-suggested root cause chain
- **Root cause section** — Final determination (editable)
- **Action items editor** — Create tracked follow-up tasks
- **Contributing factors** — Process/environmental notes
- **Save to wiki action** — Publish PIR to documentation

## Navigation

- Triggered from: Incident Detail (after resolution), scheduled reminder
- Outputs to: Wiki (published PIR), Action items in project backlog
