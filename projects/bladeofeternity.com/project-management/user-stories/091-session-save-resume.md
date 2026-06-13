# US-091: Session Save and Resume

**Persona:** Lena — Sighted tabletop RPG player, English teacher, short sessions
**Priority:** P1
**Epic:** Session Management

## Story
As Lena, I want to safely close the game mid-session and return to the same context later so that I can play in short bursts without losing narrative progress or being forced to re-navigate to where I was.

## Acceptance Criteria
- [ ] Closing the browser tab or navigating away triggers a graceful logout that saves session context server-side
- [ ] On next login, a "Resume where you left off" prompt displays the last location, active quest, and timestamp
- [ ] Command history (last 50 commands) is restored on session resume
- [ ] The game output scroll buffer for the last session is available via a `/history` command on resume
- [ ] Active quest objectives, journal entries, and inventory are server-persisted in real time (no manual save needed)
- [ ] Multiple sessions per account are not permitted simultaneously — a second login shows "Another session is active" with an option to terminate the old session
- [ ] Session context is also restored when switching between desktop and mobile on the same account

## Notes
Lena may close her laptop mid-dungeon when the bell rings. The server should record her last known room so she doesn't return to the starting zone. `/history` command output should respect current text rendering settings (font size, contrast).
