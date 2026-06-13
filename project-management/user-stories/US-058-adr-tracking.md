---
id: US-058
title: "Create and track Architecture Decision Records"
personas: [lin-zhao]
domain: docs
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to create and track Architecture Decision Records with status and supersession so that architectural decisions are documented, discoverable, and traceable over time.

## Acceptance Criteria

- [ ] ADRs are created from a structured template with fields: title, status (proposed, accepted, deprecated, superseded), context, decision, consequences, and date
- [ ] ADRs support a supersession chain — when a new ADR supersedes an old one, both are cross-linked and the old ADR's status auto-updates to "superseded by ADR-XXX"
- [ ] ADRs are stored as wiki pages (US-056) with a dedicated ADR index view showing all ADRs filterable by status, date, and tag
- [ ] The agent can surface relevant ADRs during planning discussions — e.g., when creating an item about database changes, it references the ADR that chose PostgreSQL
- [ ] ADRs can be linked to items, deploys, and incidents to create a traceable decision-to-outcome chain

## Notes

ADRs are a well-established practice but most teams abandon them because they're stored in a random docs folder and forgotten. Making them first-class entities in the platform with agent-powered surfacing changes the dynamic. The agent should proactively suggest "this looks like an architectural decision — want to record an ADR?" when it detects significant technical discussions in item comments or planning sessions.
