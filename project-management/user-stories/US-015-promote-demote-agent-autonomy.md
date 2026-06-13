---
id: US-015
title: "Promote or Demote Agent Autonomy Level"
slug: "promote-demote-agent-autonomy"
personas: [P-001, P-002]
epic: "Agent Management"
priority: "must-have"
complexity: "M"
tags: [agents, autonomy, promotion, demotion, safety, workflow]
---

# US-015: Promote or Demote Agent Autonomy Level

## User Story

**As an** Industrial Operations Manager (P-002),
**I want to** approve or reject proposed autonomy level increases for agents,
**So that** operational changes to autonomous behavior require business sign-off and are not made unilaterally by engineers.

## Acceptance Criteria

- [ ] Given an Operator submits a request to promote an agent from Level 2 to Level 3, when the request is saved, then an approval notification is sent to all Admins and the agent status shows "Promotion Pending."
- [ ] Given I am an Admin, when I view the pending promotion request, then I see the requesting user, the target level, the agent's recent action history, and a summary of what the new level will permit the agent to do.
- [ ] Given I approve a promotion, when the approval is saved, then the agent's autonomy level changes immediately and both the requester and all Admins receive a confirmation notification.
- [ ] Given I reject a promotion, when I submit a rejection with an optional reason, then the agent remains at its current level and the requester is notified with the reason.
- [ ] Given any Admin manually changes an agent's autonomy level directly (bypassing the approval workflow), when the change is saved, then the direct change is flagged in the audit log as "Direct Override" to distinguish it from approved promotions.

## Notes

Emergency demotion (reducing autonomy level) does not require approval and should be executable with a single click from the agent card for speed. Related to US-013 for level definitions.
