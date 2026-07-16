---
slug: npl-editorial
base_theme: theme-style-guide
status: full
revision: 2
---

# Theme Treatise — NPL Editorial

Theme: `theme-npl-editorial/` · Base: `theme-style-guide` · Status: full

> Reverse-engineered from the shipped `theme-npl-editorial/` YAML — intent read
> back out of the implemented values.

> **Render-fidelity note (rev 2, Stage C pilot 2026-07-17).** Six image renders
> across five screens (wiki-browser ×2, instructions, artifact-detail,
> artifacts-list, ticket-detail) confirm the treatise is internally coherent but
> expose a hard limit of the current image model. It reliably honors the
> **warm-paper neutrals** (all six renders read warm; visible paper grain on
> artifact-detail, airy hairline-ruled tables on artifacts-list) yet does **not**
> honor the theme's three defining hard signals no matter how forcefully prompted:
> (1) the **serif body/UI** rendered as sans-serif in every frame — including a
> re-render whose prompt front-loaded "serif book face, no sans anywhere"; (2) the
> **muted-claret accent** was swapped for a familiar SaaS hue (violet on
> wiki-browser, cobalt on instructions, green-ghost on artifacts-list, orange-coral
> on ticket-detail; only artifact-detail stayed neutral-warm); (3) the **2px
> cut-paper radius** rendered as friendly 6–12px rounding throughout. These are
> render-model limitations, not treatise defects — the **engine YAML is the
> enforcing source of truth** for serif, claret, and 2px, and downstream reviewers
> should judge those three from the compiled theme, not the mockups. No treatise
> value changed; this note only records the gap.

## 1. Identity

- **Intent:** A prompt-definition language presented as a craft document — a spec
  you read, annotate, and cite. The interface behaves like a well-set printed
  standard: warm stock, serif body, careful margins, footnotes welcome.
- **Perception:** Considered, premium, durable within five seconds — "the
  authority of a printed standard." Nothing feels disposable or auto-generated.
- **Audience:** Architects and authors who treat prompts as specifications, not
  throwaway text — people who will read a long convention page top to bottom and
  quote it later.
- **Tone:** Literate, measured, exact. Footnotes and citations are idiomatic, not
  clutter.
- **Keywords:** spec, literate, craft, durable, considered
- **Variant note:** Inherits `theme-style-guide` structure (shells, layouts,
  section set, spacing scale, grid) unchanged. The delta is a **serif-primary
  type system**, a **warm-paper palette**, and **near-square 2px radius** — one
  sentence: **the base's console skin is reset into a warm, printed-spec register
  where the body face is a serif.**

## 2. References & Anchors

- **Anchor — printed technical standards (ISO/RFC typesetting, O'Reilly spec
  pages):** borrow the reading rhythm — serif body, generous measure and margins,
  a mono face reserved for literal tokens, numbered/footnoted structure.
- **Anchor — long-form editorial reading (Instapaper/Readability, a well-set
  book):** borrow the warm off-white stock and high-but-soft ink contrast that
  survives a two-hour read without glare.
- **Anchor — the `references/styles/*` "editorial/print" register:** borrow the
  claret-and-ink accent discipline — one authoritative accent, used like a
  section rule or a drop-cap, not a button-candy color.
- **Anti-reference — pure-white `#ffffff` SaaS dashboards:** reject the clinical
  cold white; Editorial's stock is warm `#fbf8f1`, and a cold white would read as
  a different (Minimal) theme.
- **Anti-reference — the Brutalist sibling:** reject hard black borders, zero
  radius, and shouting caps. Editorial's structure comes from **type hierarchy
  and warm hairline rules**, not from full-strength borders.
- **Anti-reference — saturated "primary blue" link color:** reject the generic
  web-blue; links and info take the deep petrol `#1d4e5f`, so the page reads as
  ink-on-paper, never as a form.

## 3. Color Story

- **Temperature & register:** Warm and muted. Every neutral is tinted toward
  paper/ink; every accent is desaturated toward a printed-pigment feel — claret,
  petrol, ochre, moss. Nothing is at full chroma.
- **Hue relationships:** A muted triad — claret `#9a2c3f` (~350°), deep petrol
  `#1d4e5f` (~195°), burnt ochre `#b45309` (~28°) — plus an olive success. Claret
  dominates as the "ink accent"; petrol is the cool counterweight for links/info;
  ochre is a warm highlight used sparingly.
- **Neutral strategy:** Warm-tinted, not gray. Paper `#fbf8f1` (a warm off-white,
  ~40° at very low saturation), warm ink `#1c1917`, and secondary/muted text
  `#5c534a / #8a7f72` that stay in the warm-gray family. Borders are **warm beige
  hairlines** `#e3d9c6 / #cdc0a8`, not neutral gray — this is the theme's quiet
  signature.
- **Semantic mapping:** Harmonize with the print pigments. `success` = moss/olive
  `#3f6212`; `warning` = ochre `#b45309` (≡ the yellow seed); `error` = claret
  `#9a2c3f` (≡ the red seed); `info` = petrol `#1d4e5f` (≡ the blue seed).
  **Collision flag (honest signal):** as in Brutalist, `error` and the brand
  claret are the *same hex* — destructive and primary share a hue. Muted so the
  clash is gentle, but the fine-tuner must still separate destructive intent by
  label/icon, not hue.
- **Contrast stance:** Crisp for body, soft for structure. Warm ink on paper
  clears ~13:1 (a deliberately easy read); borders sit low (~1.3:1 beige
  hairlines) because separation comes from type and margin, not lines. The theme
  is allowed to be subtle in its rules and never subtle in its body text.
- **Mode strategy:** Light is primary and is the design target (warm paper). A
  dark mode exists as a faithful **warm** translation — surface `#1c1917`, warm
  paper text `#f0e9dd`, warm borders `#352f2b / #4a423c` — the "leather-bound"
  night edition, not a cold inversion. No high-contrast mode in v1; the light
  palette clears AA with margin.

## 4. Typographic Voice

- **Families:** **Source Serif 4** carries body *and* UI text — the theme's whole
  personality is "the body face is a serif," signalling authored, durable prose.
  IBM Plex Mono is reserved for literal tokens: code, NPL glyphs, values, IDs.
  **No geometric sans anywhere** — a sans body would collapse the thesis.
  Fallbacks: `'Iowan Old Style', Georgia, serif` and `'Menlo', monospace`.
- **Scale character:** Tight editorial scale, ~1.2 ratio — a printed-page
  hierarchy that distinguishes by weight, optical size, and leading more than by
  dramatic size jumps.
- **Weight usage:** 400 body, 600 headings/emphasis, 700 for the top heading and
  the wordmark. Source Serif 4's optical-size axis (`opsz`) is used: larger sizes
  take the display optical size. Never bold a whole paragraph.
- **Rhythm:** Body line-height ~1.65 (generous, book-like); measure capped ~68ch
  for reading panes. Mono blocks 1.5. Mono appears only for literal content —
  never for headings, nav, or prose emphasis.

## 5. Space & Density

- **Spacing philosophy:** 8px base unit inherited; generosity scaled up — this is
  the airiest NPL theme after nothing. Margins and inter-paragraph space are
  protected like a printed page's gutters.
- **Density target:** Reference screen is the Wiki Browser or a Convention page —
  a single-column reading measure with wide margins, holding one comfortably-read
  article per viewport, not a dense grid. Lists breathe (row height ~48–56px).
- **Responsive stance:** The reading measure is protected above all — under width
  pressure, side rails and secondary columns drop before the body measure
  narrows; body font-size never shrinks below the comfortable reading size.

## 6. Shape & Surface

- **Radius language:** Near-square — 2px base, 2px on cards/inputs, ~4px maximum.
  The slight softening reads as "cut paper edge," not "rounded UI." No pills.
- **Borders:** Warm beige hairlines (`#e3d9c6`) for structure, used like printed
  rules — thin, quiet, warm. Many surfaces are borderless and separated by margin
  alone. A heavier `#cdc0a8` rule marks major section breaks (the "horizontal
  rule" of the printed page).
- **Elevation:** Predominantly flat/tonal — surfaces separate by the paper/alt
  tone step (`#fbf8f1` → `#f4efe4`). Shadows are minimal and warm-toned, reserved
  for genuine overlays (menus, dialogs); never a resting-card drop shadow.
- **Texture & gradient policy:** No gradients. One optional restrained texture: a
  barely-perceptible paper grain on the app canvas (≤3% opacity) is permitted as
  the "stock" cue; nowhere else, and never behind body text.

## 7. Motion & Feedback

- **Animation character:** Quiet and page-like — motion behaves like turning to a
  section, not like a UI performing. Nothing calls attention to itself.
- **Duration & easing:** 150–240ms `ease-in-out` for transitions; 100–140ms
  ease-out for micro-feedback; nothing exceeds 260ms. No spring/bounce.
- **Interaction states:** Hover warms the surface one alt step and underlines
  links (link underline is a permanent affordance, thickening on hover, per the
  print idiom); active deepens the ink; focus is a 2px petrol `#1d4e5f` outline,
  2px offset; disabled drops to ~45% and removes underline affordance. States
  pair a tonal shift with the underline/outline — never hue alone.

## 8. Component Inflections

- **Buttons:** Restrained. Primary is a claret `#9a2c3f` fill with warm-paper
  text and 2px radius — the *one* saturated element on a page. Secondary is a
  petrol or ink 1px-hairline ghost on paper. Buttons read as "typeset labels,"
  small-caps or title-case, never uppercase-shouting.
- **Inputs:** Warm-paper field on a beige hairline, 2px radius, generous interior
  padding; label is a serif small-caps above the field. Focus swaps to the petrol
  outline. Placeholder holds the 4.5:1 floor in warm gray.
- **Cards:** Reads as a clipping or a boxed sidebar — `surface-alt` fill, warm
  hairline, 2px radius, generous 20–24px padding; a claret top-rule marks a
  featured/pinned card instead of a tinted background.
- **Navigation:** A table-of-contents sensibility — active item marked by a claret
  left-rule + 600 weight, not a filled pill. Section eyebrows in mono small-caps.
- **At base defaults (deliberately):** tables, toasts, and modal mechanics inherit
  `theme-style-guide`; only their palette (warm), radius (2px), and border (beige
  hairline) shift.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum; body text targets AAA (7:1+) because long-form
  reading is the product promise here.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. Warm ink `#1c1917` on paper
  `#fbf8f1` ≈ 13:1 (pass with margin). **Near-the-line pairs to verify:** burnt
  ochre `#b45309` on paper ≈ **4.6:1** — just over the body floor, so any canvas
  lightening breaks it; treat ochre as large-text/UI by preference. Muted text
  `#8a7f72` on paper ≈ **3.4:1 — large text or non-essential meta only, never
  body.** Claret `#9a2c3f` on paper ≈ 8:1 and petrol `#1d4e5f` on paper ≈ 8.5:1
  (both safe).
- **Focus visibility:** 2px solid petrol outline, 2px offset, on every focusable
  element; clears 3:1 on paper and on `surface-alt`. Link underlines are never
  removed (they are an accessibility affordance, not decoration).
- **Reduced motion:** `prefers-reduced-motion` disables page-turn transitions and
  the paper-grain (if ever animated); hover underline/tone changes survive as
  instant swaps.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Editorial"; intent/perception/audience/tone verbatim; keywords: spec, literate, craft, durable, considered; font-url: Source Serif 4 + IBM Plex Mono |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#fbf8f1` (warm paper), black `#1c1917` (warm ink) — warm seeds carry the tint through the ramp |
| §3 accents | `style-guide.vars.yaml` Seed Colors | red `#9a2c3f` (claret), blue `#1d4e5f` (petrol), yellow `#b45309` (ochre) — muted |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#3f6212`, warning `#b45309`, error `#9a2c3f`, info `#1d4e5f` — keep error≡claret, add label separation |
| §3 modes | `style-guide.color-modes.yaml` | light: surface `#fbf8f1`, alt `#f4efe4`, border `#e3d9c6`; dark: surface `#1c1917`, alt `#262220`, text `#f0e9dd`, border `#352f2b` |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-sans `'Source Serif 4', 'Iowan Old Style', Georgia, serif` (serif in the sans slot — intentional); font-mono `'IBM Plex Mono', 'Menlo', monospace`; ~1.2 scale, opsz axis |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px; protect reading measure (~68ch), generous leading |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `2px`; beige hairline rules; optional ≤3% paper-grain canvas snippet |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 120ms`, `--motion-page: 200ms` ease-in-out; permanent link underline |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | claret primary button, hairline ghosts, claret top-rule featured card |
| §9 a11y | verification across facets | recheck ochre-on-paper (≈4.6:1) and muted-text after any seed lightening |
