# PRD-019: Tobor Locker UX Overhaul

**Version:** 1.0
**Status:** Approved for implementation
**Owner:** UX / frontend
**Created:** 2026-08-26

## Outcome

Make Tobor Locker feel like a focused professional instrument for human-agent
work. The overhaul must improve orientation, scanning, and keyboard/mobile use
without changing application capabilities, routes, API contracts, or auth.

## Experience direction

- Use **Nocturne (80%) + Minimal Tech (20%)**: a dark, low-glare workspace with
  restrained cyan/teal signal color, neutral surfaces, crisp typography, and
  sparse elevation. Light mode remains fully supported.
- Keep the Tobor Locker identity and SVG mark. Avoid decorative gradients,
  glass effects, novelty navigation, and dense color coding.
- Motion communicates state only, lasts 150–220 ms, and is removed when
  `prefers-reduced-motion: reduce` is active.
- Information hierarchy is grayscale-first: page purpose and primary action
  remain understandable without accent color.

## Information architecture and shell

The authenticated workspace keeps one persistent global header and task-oriented
navigation. Existing destinations and route hrefs are preserved.

| Group | Destinations |
|---|---|
| Workspace | Organizations, Members, Projects, Sessions |
| Delivery | Tickets, Boards, Reviews, Chatrooms |
| Knowledge | Personas, Memory, Instructions, Wiki, Artifacts, Assets, NPL Conventions, Unicode Codex |
| Integrations | Browser, GitHub, Mock MCP, MCP clients |
| Configuration | Ticket Types, Ticket Fields, Org settings |
| Admin | Existing role-gated admin destinations |

- Desktop uses a collapsible labeled sidebar. The active destination exposes
  both a visible state and `aria-current="page"`.
- At 820 px and below, the sidebar is replaced by a labeled mobile menu; no
  destination is removed or renamed.
- The header keeps organization/project context, profile access, and a visible
  appearance control for light/dark mode. The selection persists in the existing
  `color-mode` local-storage key.
- A keyboard-visible “Skip to content” link targets a semantic `<main>` landmark.

## Accessibility and responsive acceptance criteria

1. Meet WCAG 2.2 AA: 4.5:1 body-text contrast, 3:1 UI/focus contrast, semantic
   landmarks, logical headings, visible focus, and no color-only status.
2. Every mobile navigation control has a minimum 44×44 px hit area. Compact
   desktop visuals may remain smaller only when the interactive hit area remains
   at least 44 px on coarse pointers.
3. Sidebar sections expose state with `aria-expanded`; active links use
   `aria-current="page"`; icon-only collapsed items retain accessible names.
4. The appearance control is keyboard-operable, names the resulting mode, and
   exposes its state through `aria-pressed` or an equivalent native control.
5. At 320, 375, 768, 1280, and 1920 px there is no page-level horizontal scroll;
   navigation, dialogs, tables, and primary actions remain reachable.
6. At 200% zoom the shell remains operable without content overlap. Reduced
   motion removes sidebar/menu movement and nonessential animation.

## Compatibility constraints

- Preserve every existing Next.js route, organization-slug resolution rule,
  REST/mock API facade, OIDC cookie/local-storage behavior, and authorization gate.
- Preserve confirmed chat selectors and security behavior covered by Playwright.
- Keep Next `output: "standalone"`, `next.config.ts`, Tailwind 4, and the
  `@noizu/styleguide` YAML-to-generated-CSS build pipeline.
- Durable theme changes belong in YAML seed/config files or intentional app CSS;
  do not hand-edit ignored generated CSS as the source of truth.
- No backend, database, MCP tool, or deployment change is part of this work.

## Verification

- Deterministic source contracts cover shell landmarks, task-oriented groups,
  preserved hrefs, active state semantics, appearance control, mobile switching,
  touch targets, and reduced motion.
- Existing TypeScript checks and the 14 chat Playwright scenarios remain valid.
- Implementation completion requires a production Next build plus Playwright
  smoke screenshots at 375, 768, 1280, and 1920 px and axe scans of representative
  public, workspace, and admin routes with zero critical/serious violations.
