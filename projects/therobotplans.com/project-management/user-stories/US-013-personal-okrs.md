---
id: US-013
title: "Personal OKRs with private visibility"
personas: [alex-russo]
domain: personal
priority: medium
mvp_phase: "v0.3"
---

## User Story

As an **Alex Russo (Productivity Enthusiast)**, I want to set personal OKRs separate from team goals with private visibility so that I can track long-term personal growth objectives using the same framework I use for work.

## Acceptance Criteria

- [ ] Users can create Objectives with 1-5 measurable Key Results, each with a target value and current value
- [ ] Personal OKRs are private by default and invisible to team views unless explicitly shared
- [ ] Key Results support numeric (0-100%), binary (done/not done), and milestone-based progress tracking
- [ ] OKRs can link to child items (todos, habits, projects) that contribute to their progress
- [ ] A quarterly review view shows OKR progress with red/yellow/green scoring against targets

## Notes

This leverages the scale-free model: an OKR Objective is just an item at a higher zoom level, with Key Results as child items that have progress metadata. The same item hierarchy that makes an "epic > story > task" tree also makes an "objective > key result > contributing task" tree. Personal OKRs might include things like "Read 24 books this year" or "Ship side project MVP by Q3."
