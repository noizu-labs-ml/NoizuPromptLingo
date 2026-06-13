# US-090: Disconnect and Reconnect State Handling

**Persona:** Tyler — Sighted MMO refugee, burned out on visual MMOs
**Priority:** P0
**Epic:** Connection State

## Story
As Tyler, I want the game to gracefully handle network interruptions and reconnect me to my session seamlessly so that a dropped connection doesn't mean lost progress, dead characters, or ejection from active groups.

## Acceptance Criteria
- [ ] Connection loss is detected within 5 seconds and announced via an ARIA live region ("Connection lost. Attempting to reconnect...")
- [ ] Automatic reconnection is attempted up to 5 times with exponential backoff before prompting the user
- [ ] On successful reconnect, the game state (location, inventory, active combat) is restored from server-authoritative state
- [ ] A "Reconnecting..." status indicator is visible and screen-reader-announced during reconnection attempts
- [ ] If in a party, party members receive a notification that the player is reconnecting (not that they left)
- [ ] If in combat at disconnect, the character enters a protected "reconnecting" state for up to 60 seconds (server configurable)
- [ ] Session token is valid for at least 24 hours to support mobile users who switch between WiFi and cellular

## Notes
Phoenix LiveView WebSocket reconnection logic can handle this natively — leverage the built-in reconnection with a custom presence state. The 60-second combat protection window should be a configurable server parameter. Reconnect state must be tested on flaky mobile networks.
