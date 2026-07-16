---
slug: npl-minimal
base_theme: theme-style-guide
status: sketch
revision: 1
---

# Theme Treatise — NPL Minimal

Theme: `theme-npl-minimal/` · Base: `theme-style-guide` · Status: sketch

> Reverse-engineered from the shipped `theme-npl-minimal/` YAML.

## 1. Identity

- **Intent:** A structured prompt-definition language and MCP toolchain for
  building reliable AI agents, rendered as a barely-there console UI — monochrome
  canvas, one cool accent, precise tokens. The competent default that recedes so
  the work is foreground.
- **Perception:** Precise, calm, quietly authoritative — "a tool that gets out of
  your way." No color drama, no personality flourish demanding attention.
- **Audience:** Prompt engineers and agent builders who value rigor over flash —
  people who will run this for hours and resent anything that distracts.
- **Tone:** Direct, technical, unhurried. No marketing noise.
- **Keywords:** structured, precise, composable, reliable, minimal
- **Variant note:** Inherits `theme-style-guide` structure unchanged. The delta is
  a **cool monochrome-plus-one-accent palette**, **pure-gray neutrals**, standard
  **Inter/JetBrains Mono** type, and a softer **6px radius**. One sentence: **the
  base's cyberpunk voltage is dialed all the way down to a neutral, cool, default
  console.**

## 2. References & Anchors

- **Anchor — Vercel/Linear-class product UI:** borrow the restraint — near-
  monochrome surfaces, a single accent, hairline gray borders, type doing the
  hierarchy. This is the register Minimal sits in.
- **Anchor — the `references/styles/*` "minimal-tech" spec:** borrow its
  neutral-gray ramp and one-cool-accent discipline; Minimal is essentially that
  spec applied to NPL with sky `#0284c7` as the accent.
- **Anchor — Tailwind's default neutral + sky/indigo ramps:** borrow the
  well-behaved, predictable semantic scale (a green success, amber warning, red
  error) so nothing needs to be re-learned.
- **Anti-reference — the Nocturne sibling:** reject dark-nativeness. Minimal is a
  **light-primary** theme; its dark mode is a faithful translation, not the home
  it lives in. If it starts to feel like "the terminal you live in," it has
  drifted into Nocturne's lane.
- **Anti-reference — the Brutalist sibling:** reject hard black borders, `0`
  radius, and saturated primaries. Minimal's structure is a **gray hairline**,
  never a full-strength rule.
- **Anti-reference — multi-accent dashboards:** reject the second and third brand
  hue. Exactly one accent (sky blue) carries interactivity; more colors than that
  is a different theme.

## 3. Color Story

- **Temperature & register:** Cool and highly muted. A monochrome gray field
  with a single cool accent; saturation appears only in the accent and in
  semantics.
- **Hue relationships:** Monochrome + one accent. The accent is calm sky blue
  `#0284c7` (~200°). The seed slots also carry indigo `#4f46e5` and teal
  `#0d9488`, but these are held in reserve (data-viz / secondary emphasis), not
  spent on chrome — the working UI reads as gray + sky.
- **Neutral strategy:** **Pure gray**, no tint — the light mode is built on the
  engine's neutral `--gray-*` ramp (`gray-50` surface-alt, `gray-200/300`
  borders, `gray-500/700` text). Canvas is pure `#ffffff`; ink is `#0a0a0b` (a
  near-black with only a whisper of cool). This purity is the point; any warmth
  would push it toward Editorial.
- **Semantic mapping:** Standard and unambiguous — `success` green `#16a34a`,
  `warning` amber `#d97706`, `error` red `#dc2626`, `info` sky `#0284c7`. Unlike
  the Brutalist/Editorial siblings, **there is no error↔brand collision here**:
  the accent is sky blue and error is red, cleanly distinct at a glance. Keep it
  that way.
- **Contrast stance:** Crisp for text, deliberately soft for structure. Ink on
  white ≈ 20:1; borders are quiet gray hairlines (~1.4:1) because separation is
  meant to be felt, not seen. Minimal is allowed to be subtle everywhere except
  body text and focus.
- **Mode strategy:** Light is primary and the design target. Dark mode is a
  faithful translation into cool slate — surface `#0f1115`, alt `#171a21`, text
  `#e8eaed`, borders `#262a33` — recognizably the same theme at night, not a
  redesign. No high-contrast mode in v1; light clears AA comfortably and
  `forced-colors` falls back to system.

## 4. Typographic Voice

- **Families:** Inter for all UI and body text (neutral, high x-height,
  disappears into the work — exactly the "gets out of your way" intent);
  JetBrains Mono for code, NPL tokens, values, and IDs. **No serif.** Fallbacks:
  `-apple-system, BlinkMacSystemFont, sans-serif` and `'Menlo', monospace`.
- **Scale character:** Tight, functional scale ~1.2 — headings separate by weight
  and spacing more than size; the largest working-screen heading is ~2× body.
- **Weight usage:** 400 body, 500 emphasized labels/active items, 600 headings,
  700 reserved for the wordmark and rare hero headings. No bold paragraphs.
- **Rhythm:** Body line-height ~1.55; mono ~1.5; measure ~72ch in prose panes.
  Mono is strictly for literal/technical content — never headings or nav.

## 5. Space & Density

- **Spacing philosophy:** 8px base unit inherited; comfortable-but-efficient — the
  middle of the density field. Neither marketing-airy nor terminal-cramped.
- **Density target:** Reference screen is an admin table (Users, Organizations) or
  an Org Settings form — ~15–20 rows or a two-column form comfortably on a
  1440×900 viewport, with quiet gutters. The workhorse density for the app's
  routine screens.
- **Responsive stance:** Under width pressure, secondary columns and side panels
  collapse first; table row height and body font-size are protected. Nothing is
  ever crushed to fit — Minimal would rather scroll than crowd.

## 6. Shape & Surface

- **Radius language:** Soft-default — 6px base on cards/inputs/buttons, ~4px on
  small chips, 8px maximum. This is the roundest of the four shipped themes; the
  softness is intentional calm, not indecision. No pills except avatars.
- **Borders:** Gray hairlines (`gray-200`, `gray-300` for stronger separation) —
  visible but quiet. Surfaces prefer a hairline over a shadow; borderless tonal
  separation (white → `gray-50`) is used inside cards.
- **Elevation:** Mostly flat/tonal. One soft, low shadow is permitted on true
  overlays (dropdowns, dialogs, popovers) — small blur, low alpha, neutral. No
  resting-card drop shadows; cards rest on hairline + tone.
- **Texture & gradient policy:** None. No gradients, no texture, no glow — flat
  neutral fills only. (Restraint is the brand.)

## 7. Motion & Feedback

- **Animation character:** Instrumental and quiet — motion confirms causality and
  nothing more. The theme never performs.
- **Duration & easing:** Micro-feedback 100–140ms ease-out; overlay/panel
  transitions 160–200ms ease-in-out; nothing exceeds 220ms. No spring, no
  scroll-linked motion.
- **Interaction states:** Hover lifts a surface one tonal step (white → `gray-50`)
  or tints a control with sky at low alpha; active deepens slightly; focus is a
  2px sky `#0284c7` ring, 2px offset; disabled drops to ~45% and removes hover
  affordance. State pairs tone/ring — never the sky hue alone.

## 8. Component Inflections

- **Buttons:** Primary is a solid sky `#0284c7` fill with white text, 6px radius —
  the only saturated fill on a routine screen. Secondary is a `gray-300`
  hairline ghost; tertiary is text-only in sky. Destructive uses the red error
  token as a ghost that fills on hover.
- **Inputs:** White field, gray hairline, 6px radius; focus swaps to the sky ring.
  Labels are 500-weight gray above the field; placeholder holds the 4.5:1 floor.
- **Cards:** The workhorse — white on a `gray-200` hairline, 6px radius, 16–20px
  padding, no shadow at rest. Selected/active state adds a 1px sky border, not a
  fill.
- **Navigation:** Sidebar on `gray-50`, content on white. Active item: 500 weight
  + a subtle sky-tinted background pill (low alpha) or a 2px sky left-rail — one
  or the other, not both.
- **At base defaults (deliberately):** tables, toasts, breadcrumbs, and modal
  mechanics inherit `theme-style-guide` almost verbatim; only palette (neutral),
  radius (6px), and accent (sky) shift. Minimal is defined as much by what it
  leaves alone as by what it changes.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum across both modes.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. Ink `#0a0a0b` on white ≈ 20:1.
  **Near-the-line pairs to verify:** sky accent `#0284c7` on white ≈ **4.6:1** —
  only just clears body; do not lighten the accent or the canvas without
  rechecking, and prefer sky for large text / UI. `success #16a34a` (≈3.5:1) and
  `warning #d97706` (≈3.6:1) on white are **large-text / icon only, not body** —
  pair them with a glyph, never color-only status. `error #dc2626` on white ≈
  4.8:1 (safe for text).
- **Focus visibility:** 2px solid sky ring, 2px offset, on every focusable
  element; clears 3:1 on white and on `gray-50`. Never removed.
- **Reduced motion:** `prefers-reduced-motion` turns transitions into instant
  state swaps; hover tone changes survive as immediate swaps. Nothing essential
  depends on motion.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Minimal"; intent/perception/audience/tone verbatim; keywords: structured, precise, composable, reliable, minimal; font-url: Inter + JetBrains Mono |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#ffffff`, black `#0a0a0b`; light mode built on engine `--gray-*` ramp (pure gray, no tint) |
| §3 accent | `style-guide.vars.yaml` Seed Colors | accent sky `#0284c7`; indigo `#4f46e5` + teal `#0d9488` held in reserve, not on chrome |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#16a34a`, warning `#d97706`, error `#dc2626`, info `#0284c7` — keep error(red) distinct from accent(sky) |
| §3 modes | `style-guide.color-modes.yaml` | light: surface `#fff`, alt `gray-50`, border `gray-200`; dark: surface `#0f1115`, alt `#171a21`, text `#e8eaed`, border `#262a33` |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-sans `'Inter', -apple-system, sans-serif`; font-mono `'JetBrains Mono', 'Menlo', monospace`; ~1.2 scale |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px; comfortable-efficient density, protect row height/body size |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `6px`; gray hairline borders; single soft overlay shadow snippet |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 120ms`, `--motion-panel: 180ms`; sky focus ring |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | sky primary button, gray ghost secondary, hairline cards; leave listed components at base |
| §9 a11y | verification across facets | recheck sky-on-white (≈4.6:1), success/warning as large-only, after any seed change |
