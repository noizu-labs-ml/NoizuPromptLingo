# US-243: Mentorship Program

**Persona:** Carol — Parent of a blind child concerned with safety, guidance, and positive community
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Carol, I want an official mentorship program that pairs experienced players with newcomers so that my child has a trusted, vetted guide who can help them learn the game without relying on strangers with unknown intentions.

## Acceptance Criteria
- [ ] Mentorship enrollment is opt-in for both mentors and mentees; mentors must meet eligibility criteria (minimum account age, minimum level, no active conduct violations in past 90 days)
- [ ] Matching algorithm considers: playstyle tags (PvP, exploration, crafting, roleplay), session time overlap (timezone-aware), accessibility needs (blind/low-vision players matched with mentors who have completed accessibility training module)
- [ ] Mentor dashboard presents active mentees with progress: quests completed, skills learned, hours played, milestones reached; all data navigable via screen reader as structured list
- [ ] Mentee receives dedicated `/mentor help` command that opens a private channel with their assigned mentor; first message auto-narrates mentor's name, experience summary, and specialties
- [ ] Milestone-based reward system: mentors earn in-game currency and cosmetic rewards when mentees reach defined milestones (first dungeon, first crafted item, first 30 days active, level thresholds)
- [ ] Both parties can end the relationship at any time via `/mentor end` with optional feedback; system ensures graceful handoff with no gap in support availability
- [ ] Parent/guardian accounts (linked via US-209 or equivalent family settings) receive weekly digest notifications of mentee activity and mentor interaction summaries
- [ ] Mentors can flag concerns (inappropriate content seen, mentee distress) to moderation team via in-panel report; flagging does not notify mentee

## Notes
Carol's concern is fundamentally about trust and visibility. The mentorship program must feel like a structured institution, not a random pairing. Mentor eligibility criteria need to be clearly communicated during enrollment — Carol should be able to read exactly what standards a mentor had to meet.

The accessibility training module for mentors is non-negotiable for the blind/low-vision matching path. This doesn't need to be a lengthy course — a 10-minute guided walkthrough of how screen readers interact with the game, common questions blind players ask, and how to give directions without assuming spatial/visual context. Mentors who complete this module get a "Accessibility-Aware Mentor" badge visible on their profile.

Privacy is a tension: parents want oversight, but teenage players (like Elena) also need to feel the relationship is theirs. The weekly digest should be high-level (time played, milestones hit, mentor interaction occurred) rather than transcript-level surveillance. Full transcripts should only be available to moderation on request, not to parents by default.

Mentor workload cap: no mentor should have more than 3 active mentees at once. Quality degrades with volume, and burned-out mentors become absent mentors. The matching system should respect this cap and show waitlist status honestly: "You are #4 in queue for a mentor matching your profile. Estimated wait: 3 days."

Consider a "mentorship hall" room in each city where mentors and mentees can meet in a safe, moderated public space — making the relationship visible and socially recognized rather than purely private.
