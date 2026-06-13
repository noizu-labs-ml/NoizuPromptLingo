---
id: US-097
title: "Respect prefers-reduced-motion"
slug: "prefers-reduced-motion"
personas: [P-001, P-004, P-006]
epic: "Accessibility & i18n"
priority: "could-have"
complexity: "S"
tags: [accessibility, motion, animation, WCAG, CSS, a11y]
---

# US-097: Respect prefers-reduced-motion

## User Story

**As a** user who experiences discomfort or seizures from motion-heavy interfaces (P-006),
**I want to** have all non-essential animations and transitions disabled when I enable "reduce motion" in my OS settings,
**So that** I can use BloggersCompete comfortably without triggering vestibular or sensory distress.

## Acceptance Criteria

- [ ] Given a user's OS has `prefers-reduced-motion: reduce` enabled, when any page on the platform is loaded, then all CSS transitions and animations that are purely decorative are either removed or reduced to instant/opacity-only transitions.
- [ ] Given the score count-up animation on the AI score page, when `prefers-reduced-motion: reduce` is active, then the final score value is displayed immediately without the count-up animation.
- [ ] Given the leaderboard rank change animation (e.g., rows sliding up/down), when `prefers-reduced-motion: reduce` is active, then rank changes are reflected immediately with no positional animation.
- [ ] Given any loading spinner or progress animation, when `prefers-reduced-motion: reduce` is active, then the animation is either paused to a static representation or replaced with a static progress indicator (e.g., percentage text).
- [ ] Given a page transition or route change animation, when `prefers-reduced-motion: reduce` is active, then page transitions are instant (no slide, fade, or scale effects).
- [ ] Given the platform is audited for motion compliance, when all animated components are reviewed, then every animation is wrapped in a `@media (prefers-reduced-motion: no-preference)` guard or equivalent JS check, with zero regressions.

## Notes

Implementation: use `@media (prefers-reduced-motion: reduce)` CSS media query globally (e.g., in a base stylesheet: `* { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }`). JS animations must also check `window.matchMedia('(prefers-reduced-motion: reduce)').matches`. Relates to US-095, US-096.
