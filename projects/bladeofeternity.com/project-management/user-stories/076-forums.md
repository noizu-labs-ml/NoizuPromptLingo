# US-076: In-Game Forums with Accessibility-First Threading

**Persona:** Jamie — Sighted IF Enthusiast, Literature Grad Student
**Priority:** P2
**Epic:** Forums

## Story
As Jamie, I want in-game forums with proper threading and rich narrative posts so that the community can build lore, debate game events, and organize around content in a space that rewards thoughtful writing.

## Acceptance Criteria
- [ ] Forums are organized by board: Lore & Roleplay, Trade & Economy, Clan Recruitment, Game Discussion, Help & Questions
- [ ] Threads are navigable as a list: title, author, reply count, last post time — each as a focusable row
- [ ] Thread view renders as a sequence of `<article>` elements with clear heading hierarchy (thread title h1, each post h2 with author + timestamp)
- [ ] Screen reader can navigate post-by-post using heading navigation (H key in most screen readers)
- [ ] Rich text posts support basic markdown (bold, italic, blockquote, code) rendered as semantic HTML
- [ ] `FORUM POST [board] [title]` opens a text editor for new posts; `FORUM REPLY [thread-id]` opens reply editor
- [ ] Lore posts can be tagged as canonical (moderator-verified) vs player-speculation, with the distinction announced

## Notes
Jamie wants forums to be a place for literary quality. The semantic HTML structure is critical for screen reader navigation — `<article>`, `<header>`, `<time datetime="...">` elements on every post. Consider a "post of the week" community spotlight that surfaces excellent writing. Forum posts should persist and be searchable as part of the game's historical record.
