# Review: Respect prefers-reduced-motion in Chat and Board Animations

- **Story**: `project-management/user-stories/US-095-respect-reduced-motion-chat-board.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The frontend (Next.js app in the NoizuPromptLingo monorepo `frontend/`) has broad `prefers-reduced-motion: reduce` CSS handling in `frontend/src/app/globals.css` (blocks at lines 982, 1926, 1974, 2030, 2149) covering the hero mascot, console row-menu, reaction picker (fade-only under reduce), and a global shell transition-duration zeroing that is contract-tested (`frontend/src/components/app-shell.contract.test.ts:113`). However, the story's two named surfaces are not covered: the chat room page (`frontend/src/app/app/[orgId]/chat/[roomId]/page.tsx`) has no message-entrance motion handling (no reduce-aware cross-fade is defined), and the ticket board (`frontend/packages/npl-queue-board/src/npl-queue-board.ts`) contains CSS transitions/animations with no `prefers-reduced-motion` handling at all. The story's requested shared motion-preference utility does not exist (no `useReducedMotion` hook; the only JS-side `matchMedia` check is at mount in `frontend/src/components/landing/hero-mascot.tsx:18`). Confidence: medium-high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| New chat messages appear without slide/bounce under `prefers-reduced-motion: reduce` (minimal cross-fade max) | Partially Met | No entrance animation found on chat messages at all (`page.tsx` has no animation classes), but no reduce-aware cross-fade or explicit handling either; adjacent chat motion (reaction picker) IS handled — `frontend/src/app/globals.css:1926-1930` |
| Ticket card drag/keyboard-move uses instant state change under reduce | Not Met | `frontend/packages/npl-queue-board/src/npl-queue-board.ts` has transitions (`:128` border-color/background 120ms, `:248` spinner animation) and zero `prefers-reduced-motion` references |
| No regression for users who want motion | Met | Existing animated transitions are untouched; reduce blocks are additive `@media` overrides (e.g. `frontend/src/app/globals.css:982-987, 1926-1930`) |
| OS preference change mid-session adapts without reload | Partially Met | Pure-CSS blocks adapt live automatically (media queries re-evaluate without JS); but the JS-side check (`hero-mascot.tsx:18`) samples `matchMedia` once at mount with no change listener |

## Gaps / Risks

- No shared motion-preference utility as the story's Notes require — handling is scattered per-component CSS, and `npl-queue-board` (a separate web-component package) was never covered.
- Board component has no reduced-motion support; if US-091 keyboard board nav lands with tweened moves, reduce users get full tweens.
- Only coverage guard is the app-shell contract test; no test asserts chat or board surfaces respect the setting.
- No `matchMedia('(prefers-reduced-motion: reduce)').addEventListener('change')` for JS-driven motion.

## BDD Scenario

```gherkin
Feature: Reduced-motion accessibility in chat and board

  Scenario: Reduce user receives a chat message
    Given the browser reports prefers-reduced-motion: reduce
    When a new chat message appears in the room view
    Then it renders with at most a fade (no slide/bounce)
    # Today: messages have no entrance animation, but no explicit reduce-aware
    # cross-fade exists; the reaction picker menu does fade-only (globals.css:1926).

  Scenario: Reduce user moves a ticket between columns
    Given the browser reports prefers-reduced-motion: reduce
    When a ticket card is moved between board columns
    Then the state change is instant
    # Today: npl-queue-board.ts has no prefers-reduced-motion handling — FAILS.

  Scenario: Motion user is unaffected
    Given prefers-reduced-motion is not set
    When the same chat and board interactions occur
    Then the designed transitions play as before

  Scenario: Preference flips mid-session
    Given the app is open and the OS toggles prefers-reduced-motion
    When the media query value changes
    Then CSS-driven animations adapt without a page reload
    # Pure-CSS blocks satisfy this; any future JS-driven motion needs a change listener.
```
