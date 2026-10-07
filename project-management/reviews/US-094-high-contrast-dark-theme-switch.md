# Review: Switch to the High-Contrast Nocturne Theme

- **Story**: `project-management/user-stories/US-094-high-contrast-dark-theme-switch.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The `npl-nocturne` theme does not exist anywhere in the frontend — repo-wide grep for "nocturne" across tsx/ts/css returns nothing. The frontend has a single static theme: `frontend/src/app/layout.tsx:49` sets `data-design-theme={config.slug}` from one config directory (`frontend/src/config/theme-style-guide/`), and `frontend/src/app/globals.css` defines tokens for that style-guide theme plus a `.dark` variant (`globals.css:269`) — dark-mode scaffolding, not a selectable theme. There is no theme switcher UI, no per-user persistence (no theme-related localStorage usage found), and no `prefers-color-scheme` handling in `frontend/src`. The story's premise of four YAML-driven themes (`npl-nocturne`, `npl-brutalist`, `npl-editorial`, `npl-minimal`) is unimplemented. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Selecting `npl-nocturne` re-renders dashboard without reload | Not Met | no evidence found — "nocturne" absent from `frontend/src`; single hardcoded theme (`layout.tsx:49`) |
| All four shipped themes meet WCAG AA contrast | Not Met | no evidence found — only one theme exists (`config/theme-style-guide/`) |
| Theme choice persists per user across sessions | Not Met | no evidence found — no theme persistence or settings surface |
| OS dark-mode preference defaults to a dark-capable theme | Not Met | no evidence found — no `prefers-color-scheme` usage in `frontend/src`; `.dark` class exists (`globals.css:269`) but nothing applies it from OS preference |

## Gaps / Risks

- The `.dark` token block (`globals.css:269`) is a ready foundation; the gap is the switching mechanism (user setting → data attribute → persistence), not the palette work.
- The story says themes are "YAML-driven"; the existing `theme-style-guide` YAML config shows the intended pattern but only one theme directory exists.

## BDD Scenario

```gherkin
Feature: High-contrast nocturne theme

  Scenario: Jordan tries to switch themes (today)
    Given Jordan opens the app settings
    When he looks for a theme selector
    Then none exists — the app renders the single style-guide theme set at layout.tsx:49
    And "npl-nocturne" is not present in the stylesheet
    And his OS dark-mode preference is ignored (no prefers-color-scheme handling)
    And no theme choice can persist because none can be made
```
