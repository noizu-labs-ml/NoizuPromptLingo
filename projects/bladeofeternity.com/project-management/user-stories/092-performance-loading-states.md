# US-092: Performance and Loading State Communication

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P1
**Epic:** Performance

## Story
As Elena, I want loading states and performance delays to be communicated clearly via screen reader so that I always know whether the game is processing my input or if something has gone wrong.

## Acceptance Criteria
- [ ] All asynchronous operations (command submission, zone loading, world-state fetch) show a loading indicator with `role="status"` and `aria-live="polite"`
- [ ] Loading messages are descriptive: "Loading the Thornwood Forest..." not "Loading..."
- [ ] Operations exceeding 3 seconds display a more detailed status update
- [ ] Operations exceeding 10 seconds offer a cancel option
- [ ] Initial page load time is under 3 seconds on a 4G mobile connection (Lighthouse target: Performance score ≥ 85)
- [ ] Critical game text (room description, command output) is server-rendered for fast first meaningful paint
- [ ] A progress indicator for zone transitions is announced at start and completion by ARIA live region

## Notes
Elena on an iPhone on a school WiFi network is the worst-case performance scenario to target. Next.js server-side rendering of the initial game state is essential. WebSocket messages should be batched to avoid overwhelming the screen reader with rapid-fire announcements during zone loads.
