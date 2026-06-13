---
id: US-042
title: "Auto-transition items on deploy success or failure"
personas: [sarah-kim]
domain: cicd
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want items to automatically transition status when linked deployments succeed or fail so that my team's board reflects reality without manual status shuffling.

## Acceptance Criteria

- [ ] Items linked to a deploy (via commit SHA, branch, or PR reference) auto-transition to "Deployed" on successful deploy to the configured target environment
- [ ] Items auto-transition to "Deploy Failed" with a failure reason annotation when a linked deploy fails
- [ ] Transition rules are configurable per project (e.g., deploy to staging moves to "In QA", deploy to prod moves to "Done")
- [ ] An activity log entry records each auto-transition with the triggering deploy event, timestamp, and environment
- [ ] Manual override is always available — auto-transitions can be reverted and the automation can be paused per-item or per-project

## Notes

This leverages the scale-free item model: the deploy event itself is an item linked to the work items it carries. Transition rules should be defined at the project methodology level so different projects (Kanban vs. Scrum) can have different deploy-aware workflows. The PM agent should be able to suggest transition rules based on observed team patterns.
