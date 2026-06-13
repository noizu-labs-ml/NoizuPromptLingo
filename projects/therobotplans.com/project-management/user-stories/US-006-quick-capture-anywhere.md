---
id: US-006
title: "Quick-capture from any screen via keyboard shortcut"
personas: [raj-patel]
domain: inbox
priority: high
mvp_phase: "v0.1"
---

## User Story

As a **Raj Patel (Side-Project Builder)**, I want to quick-capture items from any screen via a keyboard shortcut so that I can dump ideas and tasks without losing flow in whatever I am currently doing.

## Acceptance Criteria

- [ ] A global keyboard shortcut (Cmd+K or configurable) opens a capture modal overlay from any screen in the app
- [ ] The capture modal supports a single text field with optional inline metadata (tags via `#`, project via `@`, due date via `/date`)
- [ ] Submitting the capture modal creates an inbox item and returns focus to the previous screen in under 300ms
- [ ] Captured items appear in the inbox for later triage; they are not auto-assigned to any project
- [ ] The capture modal supports multi-line input for longer notes with Shift+Enter

## Notes

Speed is paramount. This should feel like Spotlight or Alfred — appear instantly, accept input, disappear. The inline metadata syntax avoids the need for dropdown menus or multi-step forms. Consider supporting a "capture and assign" variant (Cmd+Shift+K) that allows immediate project assignment for power users.
