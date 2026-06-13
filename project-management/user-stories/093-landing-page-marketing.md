# US-093: Accessible Marketing Landing Page

**Persona:** Raj — Sighted accessible gaming content creator, YouTube/Twitch
**Priority:** P1
**Epic:** Landing Page / Marketing

## Story
As Raj, I want the marketing landing page to be fully accessible and clearly communicate the game's accessibility-first mission so that I can confidently recommend it to my audience and link it in my content without caveats.

## Acceptance Criteria
- [ ] Landing page passes WCAG 2.1 AA automated scan (axe-core zero violations)
- [ ] All images have meaningful alt text; decorative images have `alt=""`
- [ ] Video content (trailers, gameplay demos) includes captions and audio descriptions
- [ ] Page heading hierarchy is logical (single H1, descriptive H2/H3 sections)
- [ ] Accessibility statement is linked prominently from the landing page footer
- [ ] "Play now" and "Create account" CTAs have sufficient color contrast and are not color-only differentiated
- [ ] Page loads in under 2 seconds on a 4G connection
- [ ] Social share metadata (og:title, og:description) accurately describes the accessibility-first positioning

## Notes
Raj's audience includes both blind gamers and accessibility advocates — the landing page is a direct reflection of the game's credibility. The accessibility statement should list tested AT combinations (NVDA+Firefox, VoiceOver+Safari, TalkBack+Chrome). Consider a dedicated "For Blind Gamers" section.
