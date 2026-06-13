---
id: US-039
title: "Bug-to-deploy lifecycle tracking"
personas: [maya-chen]
domain: bugs
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev)**, I want to track a bug from initial report through fix, code review, merge, deploy, and verification so that I have full lifecycle visibility without manually updating status at each stage.

## Acceptance Criteria

- [ ] Bug items support a lifecycle pipeline view showing stages: Reported -> Triaged -> In Progress -> Fix Ready -> In Review -> Merged -> Deployed -> Verified, with the current stage highlighted
- [ ] Stage transitions are auto-detected via integrations: linking a branch/PR moves to "In Progress," PR approval moves to "In Review," merge moves to "Merged," deploy detection moves to "Deployed"
- [ ] The "Deployed" stage is detected by matching the bug's linked PR/commit to a deployment event (via webhook from CI/CD or MCP integration with GitHub Actions, ArgoCD, etc.)
- [ ] "Verified" requires explicit human or agent confirmation that the fix works in production, preventing premature closure
- [ ] The bug's timeline view shows all lifecycle events with timestamps, enabling cycle time analysis from report to verified-fix

## Notes

Maya works alone, so manual status updates are pure friction. The pipeline should update itself as she works through her normal git/deploy workflow. This is a key differentiator over traditional bug trackers that require manual status changes. The integration layer (MCP connections to GitHub, CI/CD, deployment tools) is the heavy lift here. Consider a "stale stage" alert if a bug sits in one stage too long without progression.
