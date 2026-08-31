---
id: US-098
title: "Low idle resource usage for watcher"
slug: low-idle-resource-usage-watcher
personas: [P-001, P-008]
epic: "Performance & Scale"
priority: should-have
complexity: medium
tags: [performance, watcher]
---

# US-098: Low Idle Resource Usage For Watcher

## User Story

**As a** solo power-user developer
**I want to** the background file watcher to use minimal CPU/memory while idle
**So that** it can run continuously in the background all day without competing with my actual dev work

## Acceptance Criteria

- **Given** the background file watcher is running with no new JSONL activity
  **When** CPU usage is measured over a sustained idle period
  **Then** it stays near-zero (e.g. under 1-2% average)

- **Given** a new JSONL write occurs
  **When** the watcher detects it
  **Then** CPU/memory briefly spikes to process the change and returns to idle baseline within a few seconds

- **Given** Marcus leaves the watcher running continuously across a full workday
  **When** he checks Activity Monitor/`top`
  **Then** memory usage remains stable with no unbounded growth or leak

## Notes
Marcus and Yusuf both run the watcher continuously in the background while doing unrelated work — a resource-hungry watcher directly conflicts with the "just works in the background" expectation both personas rely on.
