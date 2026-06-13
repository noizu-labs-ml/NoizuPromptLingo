# US-075: Private Messaging and Mail System

**Persona:** Carol — Parent of Blind Daughter and Sighted Son
**Priority:** P1
**Epic:** Chat and Messaging

## Story
As Carol, I want a safe private messaging and in-game mail system with parental controls so that my daughter (blind, 14) and son (sighted, 12) can communicate with friends without being exposed to unsolicited contact from strangers.

## Acceptance Criteria
- [ ] `WHISPER [player] [message]` sends an instant private message delivered via Channel push
- [ ] `MAIL SEND [player]` opens a mail composition flow for longer messages with subject + body
- [ ] Incoming whispers and mail are announced with sender name; players can block unsolicited contact via `BLOCK [player]`
- [ ] Parent/guardian account controls include: friends-only messaging mode, contact whitelist, and message log accessible to linked parent account
- [ ] Blocked players cannot whisper, mail, or trade request the blocking player
- [ ] Reporting a player for harassment from a message: `REPORT [player] HARASSMENT` with the message pre-populated as evidence
- [ ] Young player mode (under-16 flag on account) defaults to friends-only messaging with opt-in for broader contact requiring guardian approval

## Notes
Carol manages two accounts with different needs. The parental control layer must be non-punitive and not obvious to other players (the blocked/restricted state should appear as "unavailable" not "blocked"). Young player mode protections should apply by default on account creation for minors. GDPR and COPPA compliance implications for message logging.
