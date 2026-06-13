---
id: US-081
title: "Pause and resume agents without losing context"
personas: [maya-chen]
domain: agents
priority: medium
mvp_phase: "v0.2"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to pause and resume individual agents without losing their queue or context so that I can temporarily free up compute or focus without destroying in-progress work.

## Acceptance Criteria

- [ ] A pause action is available on each running agent via the agent panel and keyboard shortcut
- [ ] Pausing an agent freezes its task queue in place — no queued or in-progress items are dropped
- [ ] Agent context (conversation history, working memory, tool state) is serialized and persisted on pause
- [ ] Resuming an agent restores it to the exact pre-pause state within 3 seconds and continues processing its queue
- [ ] Paused agents display a distinct visual indicator and their queue remains inspectable while paused

## Notes

This is critical for solo devs who share a single machine's compute budget across coding, building, and agent work. The pause mechanism must be lightweight — it should not require a full agent restart cycle. Consider edge cases where an agent is mid-API-call when paused: the platform should complete the current atomic operation, then pause before the next queue item. Paused agents should not consume API credits or compute cycles.
