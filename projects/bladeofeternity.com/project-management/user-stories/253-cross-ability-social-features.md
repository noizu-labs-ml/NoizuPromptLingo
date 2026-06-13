# US-253: Cross-Ability Social Features

**Persona:** Priya — Accessibility advocate who cross-tests with multiple screen readers and pushes for universal design
**Priority:** P0
**Epic:** Advanced Social & Governance

## Story
As Priya, I want all social features to be designed from the start so that blind and sighted players interact through the same interface without separate modes, special accommodations, or degraded experiences, so that accessibility is a design principle rather than an afterthought retrofit.

## Acceptance Criteria
- [ ] No social feature ships with a separate "accessibility mode" toggle — all players use the same commands, the same interface, the same narration; if a feature cannot be made universally accessible, it is redesigned or deferred
- [ ] All social interactions (emotes, mail, reviews, partnerships, elections, trials) pass full WCAG 2.1 AA compliance audit conducted with NVDA/Firefox, JAWS/Chrome, VoiceOver/iOS, and VoiceOver/macOS before each feature ships
- [ ] Screen reader testing is included in the definition of done for every social feature ticket — not a separate QA phase but a parallel development requirement; at least one blind tester (internal or community beta) must validate each feature
- [ ] Sighted players' convenience features (sorting, filtering, quick-navigation) are implemented as keyboard-accessible equivalents, never as mouse-only or touch-drag interactions; example: list sorting is via labeled buttons or a keyboard-invokable sort dialog, not column header clicks
- [ ] Color is never the sole differentiator of state — all status indicators (reputation badges, faction standing, online/offline) are conveyed by text label in addition to any color coding; example: "Distinguished (green)" not just a green indicator
- [ ] Social feature documentation (help text, tutorials) is written in plain language, avoids visual metaphors ("click the icon," "you'll see a panel"), and describes interactions in terms of commands and text output; tutorial text is testable by screen reader as delivered
- [ ] Community social spaces (bulletin boards, election results, trial transcripts) are archived in a plain-text accessible format retrievable via command; no social record exists only as a visual-only render
- [ ] Priya (or designated accessibility lead) holds veto power on any social feature design decision that would compromise cross-ability usability; this is a formal design authority, not an advisory role

## Notes
US-253 is a meta-story — it defines the standard that all social features must meet. Priya's role here is as a systems-level advocate, and the acceptance criteria reflect that: they are process and governance requirements as much as technical ones.

The "no separate accessibility mode" requirement is the most important and the most frequently violated in practice. Every time a team adds an "accessible version" of a feature, they are making a statement that the default experience is not for blind users. This is the failure mode Priya exists to prevent. The design pressure this creates is productive: if a feature can't be made universally accessible, the answer is not a separate mode but a better design.

The definition of done inclusion is a cultural requirement as much as a technical one. Many teams complete accessibility as a late-stage QA task, by which point the architecture is fixed and only cosmetic changes are feasible. Requiring a blind tester before a PR merges changes this. The project should maintain a panel of community beta testers (compensation: early access, in-game rewards) specifically for this purpose.

The veto authority for the accessibility lead is unusual but necessary. Without formal authority, accessibility feedback becomes optional. The veto should be scoped: it applies to social feature design decisions where the proposed design would create a different experience for blind vs. sighted users. It does not extend to game balance, lore, or economic decisions.

Priya's testing methodology: each social feature should be validated against a standard test script that covers: feature discovery (can you find it without knowing it exists?), feature use (can you complete the primary workflow?), error recovery (if you make a mistake, can you understand and correct it?), and social participation (can you participate equally with sighted users?). These four questions should be explicitly answered for each social feature in the feature's accessibility review documentation.

The plain-language documentation requirement prevents a common accessibility gap: technically accessible features described in visually-oriented language. "Click the star icon to rate" is useless to a blind user who navigates by commands. "Type `/review [player]` to begin a reputation review" is universal.
