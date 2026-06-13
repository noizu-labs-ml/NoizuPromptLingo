---
id: US-007
title: "Mobile capture for on-the-go ideas"
personas: [raj-patel, alex-russo]
domain: inbox
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Raj Patel (Side-Project Builder)**, I want to capture items via mobile (PWA or native) for on-the-go ideas and tasks so that I never lose a thought just because I am away from my desk.

## Acceptance Criteria

- [ ] A mobile-optimized capture screen is accessible via PWA with home-screen installability
- [ ] The capture form supports text input, optional photo attachment, and inline tag syntax
- [ ] Captured items sync to the inbox within 5 seconds on a standard mobile connection
- [ ] Offline capture queues items locally and syncs when connectivity is restored
- [ ] Share-sheet integration (iOS/Android) allows sending text or URLs from other apps directly into the inbox

## Notes

The mobile experience is capture-first, not a full mobile app. Resist the urge to build a complete mobile client at this phase. The PWA approach keeps the scope manageable for v0.3 while still being installable on home screens. Offline support is critical for subway commuters and spotty connectivity scenarios.
