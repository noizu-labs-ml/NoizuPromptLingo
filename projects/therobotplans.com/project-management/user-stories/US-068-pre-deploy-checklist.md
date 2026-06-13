---
id: US-068
title: "Automated pre-deploy checklist with verification gates"
personas: [maya-chen]
domain: checklists
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want an automated pre-deploy checklist that verifies tests pass, docs are updated, and approvals are obtained so that I can deploy with confidence even without a team to catch mistakes.

## Acceptance Criteria

- [ ] Pre-deploy checklist auto-populates with items based on what changed (code, config, infra, docs)
- [ ] Automated verification items (tests pass, lint clean, no secret leaks) check themselves via CI integration
- [ ] Manual verification items (docs reviewed, stakeholder approved) require explicit human check-off
- [ ] Deploy action is gated: cannot proceed until all required items are green or explicitly overridden
- [ ] Checklist persists as a deploy record, queryable for post-incident review ("what was checked before deploy X?")

## Notes

Solo devs like Maya need this the most: no team means no safety net. The monitor agent should be aware of deploy checklists and flag if a deploy is attempted without one. Integration with git hooks or CI webhooks for the automated items. The checklist should feel lightweight (not enterprise ceremony) for a single-person workflow.
