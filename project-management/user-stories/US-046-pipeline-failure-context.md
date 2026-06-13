---
id: US-046
title: "Pipeline failure notifications with full context"
personas: [maya-chen]
domain: cicd
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to receive pipeline failure notifications with full contextual info — logs, affected items, and related changes — so that I can diagnose and fix failures without hunting through multiple tools.

## Acceptance Criteria

- [ ] Pipeline failure generates a notification containing: failure stage, relevant log excerpt (last 50 lines or first error block), and the triggering commit/PR
- [ ] Notification links to all items associated with the failing deploy, showing which work is blocked
- [ ] The monitor agent can pre-analyze the failure log and suggest likely causes (e.g., "test X failed — last passing run was commit Y, diff shows changes to module Z")
- [ ] Notification delivery respects user preferences: in-app, email digest, or push notification (mobile capture)
- [ ] Failed pipeline items appear in the "Today" view with priority boost so they're not buried under other work

## Notes

This is where the AI-native philosophy shines — the monitor agent doesn't just forward an alert, it enriches it with context a human would otherwise spend 10 minutes assembling. Log excerpts should be syntax-highlighted and truncated intelligently (not mid-stack-trace). For solo devs, the agent should auto-link the failure to recent commits since the last green build.
