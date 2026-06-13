---
id: US-095
title: "Compliance-grade audit trail for prompt changes"
personas: [lin-zhao]
domain: prompt-archival
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want a compliance-grade audit trail of all prompt changes with who/when/why metadata so that my organization can demonstrate governance over AI agent behavior for internal reviews and external audits.

## Acceptance Criteria

- [ ] Every prompt modification is recorded in an append-only audit log that cannot be edited or deleted by any user, including admins
- [ ] Each audit entry includes: actor identity (user or system), timestamp (UTC, millisecond precision), change type (create, edit, restore, delete), before/after state, and a mandatory change rationale field
- [ ] The audit trail is queryable by actor, date range, agent, change type, and keyword search across rationale text
- [ ] Audit logs can be exported in compliance-friendly formats (CSV, JSON Lines) with cryptographic integrity verification (hash chain or similar)
- [ ] Retention policies are configurable but default to indefinite retention, with deletion requiring admin + secondary approval

## Notes

This is the governance story that makes tobornalp viable for regulated industries and security-conscious organizations. The append-only constraint is non-negotiable — if audit entries can be modified, the entire trust model collapses. The mandatory change rationale field forces intentionality: no more "oops I tweaked the prompt and forgot why." The hash chain for export integrity lets external auditors verify that the exported log matches the actual history. Consider SIEM integration for organizations that feed audit logs into centralized security monitoring. This story has a direct dependency on US-086 (prompt versioning) — the audit trail wraps around the versioning system.
