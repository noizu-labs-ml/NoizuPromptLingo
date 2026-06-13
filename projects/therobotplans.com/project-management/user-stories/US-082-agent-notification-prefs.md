---
id: US-082
title: "Configure per-agent notification preferences"
personas: [sarah-kim]
domain: agents
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to configure per-agent notification preferences — specifying when agents should alert humans and what they should handle silently — so that my team isn't buried in noise but never misses critical escalations.

## Acceptance Criteria

- [ ] Each agent has a notification settings panel with categories: errors, completions, escalations, status updates, and custom events
- [ ] Per-category options include: silent (log only), in-app notification, push notification, and escalate-to-human
- [ ] Threshold-based rules are supported (e.g., "notify only if confidence is below 80%" or "alert if task takes longer than 2x estimate")
- [ ] Notification preferences can be set at the agent level and overridden at the team level by an admin
- [ ] Changes to notification preferences take effect immediately without requiring agent restart

## Notes

The default notification posture should be conservative for new agents — lean toward notifying humans until trust is established. As agents prove reliable via eval scores, the platform could suggest relaxing notification thresholds. This ties into the agent-eval domain: high-performing agents earn more autonomy. Consider a "digest mode" that batches non-urgent notifications into periodic summaries.
