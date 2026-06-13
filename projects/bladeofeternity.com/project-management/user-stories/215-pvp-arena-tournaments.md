# US-215: PvP Arena Tournaments

**Persona:** Marcus — Blind power gamer, NVDA+Firefox, PvP focused
**Priority:** P2
**Epic:** Advanced Combat & Tactics

## Story
As Marcus, I want to compete in structured PvP tournaments with brackets, rankings, and prizes so that my combat mastery has a competitive outlet with stakes, recognition, and a community of rivals.

## Acceptance Criteria
- [ ] Tournament brackets displayed as an accessible tree structure: each match listed as "Match 3: Marcus vs. SilverBlade — Scheduled 14:00 server time" navigable with standard ARIA tree patterns
- [ ] Tournament registration open via keyboard-accessible sign-up flow with class/level bracket filtering
- [ ] Spectator mode available: spectators receive match narration via a dedicated ARIA live region channel distinct from their own status; joinable mid-match
- [ ] Match narration for spectators uses third-person perspective and includes more contextual framing than participant narration
- [ ] Rankings board accessible as a sortable table: rank, player name, wins, losses, rating — screen reader navigable with column headers
- [ ] Prize announcement at match end is a dedicated assertive live region: "Victory — you advance to the semi-finals. Prize: 500 gold, Gladiator's Pauldrons (Epic)"
- [ ] Tournament schedule available as a list with server time and participant count; subscription available for calendar-style reminders via in-game notification channel
- [ ] Historical match replays stored as turn-by-turn text logs; browsable and searchable by participant, date, or tournament name

## Notes
Marcus's PvP orientation means tournaments are the highest-prestige content for him. The P2 priority reflects that it requires all foundational combat systems to be solid first. The bracket display is a UX challenge: a tournament bracket is inherently visual (a tree of boxes). The ARIA tree structure (role="tree", role="treeitem") is the correct semantic approach — it conveys hierarchy and allows navigation by keyboard. Spectator mode is an important social feature: Marcus wants witnesses to his victories, and Elena or others may want to watch without participating. Third-person spectator narration needs to be calibrated to be engaging for observers who aren't making decisions. Rankings as a sortable table follow accessible table patterns that NVDA handles well with proper headers. The text replay archive is an important longevity feature — Marcus will analyze matches retrospectively and use them for clan training. Server time synchronization matters for the tournament schedule: the game must surface the correct local time equivalent or clearly mark all times as server time.
