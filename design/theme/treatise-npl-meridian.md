---
slug: npl-meridian
base_theme: theme-style-guide
status: sketch
revision: 1
---

# Theme Treatise — NPL Meridian

Theme: `theme-npl-meridian/` · Base: `theme-style-guide` · Status: sketch

> New direction (authored forward). Meridian is the *warm-dark, refined* theme —
> a luxe executive register. It shares "dark" with Nocturne and "warm+serif" with
> Editorial but is neither: warm dark, brass-accented, and display-serif-led.

## 1. Identity

- **Intent:** Give NPL a dark surface with *authority and warmth* rather than
  terminal utility — the register a Delivery Lead or Org Owner wants when reviewing
  the whole portfolio: a dashboard that feels considered and premium, like a
  well-lit study at night, not a build monitor.
- **Perception:** Refined, premium, calm-with-gravitas within five seconds — "this
  is where decisions get made." Warm low light, brass detailing, quiet confidence.
- **Audience:** The Delivery Lead and Org Owner in oversight mode — org dashboards,
  project rollups, board overviews, admin home — where the job is *reading the
  state of things*, at a glance, with a sense of stewardship.
- **Tone:** Composed, editorial, understated-premium. Speaks briefly and well.
- **Keywords:** warm-dark, refined, brass, luxe, considered
- **Variant note:** Inherits `theme-style-guide` structure and spacing scale.
  Deltas: a **warm espresso-dark palette** with a **brass/champagne accent**, a
  **display serif (Fraunces) over Inter body**, and a **6px refined radius**. One
  sentence: **the base re-skinned as a warm, low-lit, brass-detailed executive
  surface.** Unlike Nocturne, it ships a **true warm light mode** as well.

## 2. References & Anchors

- **Anchor — premium dark dashboards & fintech "night" modes (Arc, Superhuman
  dark, high-end analytics):** borrow the warm-charcoal surfaces, restrained
  metallic accent, and the sense that dark here is *chosen luxury*, not default
  utility.
- **Anchor — editorial display typography (Fraunces / high-contrast serifs):**
  borrow the warm, slightly characterful display serif for headings and numbers —
  the "printed annual report" gravitas, on a dark ground.
- **Anchor — brass/patina material pairings (dark wood + aged brass + verdigris):**
  borrow the palette logic — a warm metal accent (brass) with a cool patina
  counterpoint (verdigris teal), against warm dark.
- **Anti-reference — the Nocturne sibling:** reject the *cool* terminal darkness
  and phosphor-green signal. Meridian's dark is **warm** (espresso, not slate) and
  its accent is **brass**, not green; it is a study, not a terminal. (This is the
  most important separation — both are dark; temperature and accent must not blur.)
- **Anti-reference — the Editorial sibling:** reject the *light warm paper* and the
  text-serif body. Meridian is dark-native and uses the serif for *display*, with
  a neutral sans (Inter) for body — the serif is jewelry, not the whole outfit.
- **Anti-reference — "gamer RGB" or gold-gradient bling:** reject saturated gold
  gradients and glow; Meridian's brass is a **matte, desaturated metal**, used as
  a thin line or a small fill, never a shiny gradient.

## 3. Color Story

- **Temperature & register:** Warm and dark, muted, with one metallic accent. Every
  neutral is a warm charcoal; saturation is spent sparingly on brass and a quiet
  verdigris.
- **Hue relationships:** Warm-dark monochrome + brass, with a cool patina
  counterpoint. Brass/champagne `#c9a15e` (~40°, desaturated) is the accent;
  verdigris teal `#3f857e` (~175°) is the secondary (links, cool data). No third
  brand hue.
- **Neutral strategy:** **Warm-tinted charcoals**, not cool slate. Canvas espresso
  `#1a1613` (~30° at low saturation), panel `#241f1a`, text a warm parchment
  `#f2ebe0` (never pure white). The warmth is the whole separation from Nocturne —
  do not let the charcoals go cool.
- **Semantic mapping:** Harmonize warm. `success` olive `#7fa650`, `warning` amber
  `#d98a2b`, `error` terracotta-red `#c85248`, `info` muted slate-blue `#5a8fb0`.
  **Watch-pair (designed, flagged):** brass accent (~40°) sits hue-near `warning`
  amber (~35°). Mitigation: brass is **lower-saturation and lighter (metallic)**,
  warning amber is **more saturated**; warning is **always icon-paired**, and brass
  is reserved for accent/structure, never for status. Keep that split.
- **Contrast stance:** Warm-soft for chrome, crisp for content. Parchment on
  espresso ≈ 14:1; brass on espresso ≈ 7:1 (legible accent); borders are low warm
  charcoals — separation comes from surface steps and the occasional brass
  hairline, not heavy rules.
- **Mode strategy:** Dark is primary and the design home. **Meridian ships a true
  warm light mode** (unlike Nocturne) — an "study by day": ivory `#f6f1e8` canvas,
  espresso ink `#2a231c`, brass darkened to `#a67c34` for contrast — a faithful
  warm translation, not a cold flip. No separate high-contrast mode in v1; both
  modes clear AA and `forced-colors` falls back to system.

## 4. Typographic Voice

- **Families:** **Fraunces** (warm high-contrast display serif) for headings,
  large numerals, and stat displays — the identity face, "annual-report" gravitas;
  **Inter** for body and UI (neutral workhorse so the serif stays special);
  JetBrains Mono for IDs, values, and data cells. Fallbacks: `Georgia, serif`,
  `-apple-system, sans-serif`, `'Menlo', monospace`.
- **Scale character:** Elegant scale ~1.25–1.333, with **display serif carrying
  the drama** — big Fraunces numerals for dashboard KPIs; body stays calm Inter.
- **Weight usage:** Inter 400 body, 500 labels, 600 UI headings; Fraunces 500–600
  for display, using its `opsz`/`SOFT` axes at large sizes. Brass is never
  expressed as a font weight — only as color/rule.
- **Rhythm:** Body line-height 1.6; display serif tighter (1.1–1.2); measure ~70ch.
  Mono for data cells and IDs; Fraunces never for body or UI labels (display only).

## 5. Space & Density

- **Spacing philosophy:** 8px base unit; comfortable-refined — more generous than
  Nocturne's terminal density, so each stat and panel has presence. Padding inside
  panels is generous (16–24px); gutters are calm.
- **Density target:** Reference screen is the Org Dashboard or a Board Overview —
  6–10 KPI/stat panels and a couple of summary tables readable at a glance on a
  1440×900 viewport, each with room to feel considered. A reading-the-state
  density, not an operating-the-machine density.
- **Responsive stance:** KPI display numerals and their labels are protected;
  secondary tables collapse to summaries first. Body/stat legibility never trades
  down to fit more panels.

## 6. Shape & Surface

- **Radius language:** Refined-moderate — **6px base** on cards/inputs, 4px on
  chips, 8px maximum on feature panels. Not soft (Aurora), not sharp (Blueprint) —
  a tailored, even radius.
- **Borders:** Low warm-charcoal borders for structure; a **thin brass hairline
  (1px, low alpha)** marks featured/premium panels and the active nav — brass as
  *detailing*, used like a pinstripe, never a heavy frame.
- **Elevation:** Warm tonal layering (espresso → panel → raised, each a warmer/
  lighter charcoal) plus a **subtle warm shadow** under raised panels and overlays
  (`rgba(15,10,6,0.5)`, soft, no glow). Three elevation steps.
- **Texture & gradient policy:** No gradients on chrome or text. One sanctioned,
  barely-visible touch: a warm radial vignette (≤6% alpha) on the app shell — the
  "lamp-lit room." No noise, no metallic gradient on the brass.

## 7. Motion & Feedback

- **Animation character:** Composed and unhurried — motion has a settled,
  expensive quality (a smooth ease, never a snap), signalling care. Restrained;
  the theme never fidgets.
- **Duration & easing:** Micro-feedback 120–160ms ease-out; panel/overlay
  transitions 200–260ms ease-in-out; nothing exceeds 300ms. No spring/bounce — a
  bounce would read as cheap here.
- **Interaction states:** Hover lifts a panel one warm step and may reveal a brass
  hairline; active settles it back; focus is a 2px brass `#c9a15e` outline, 2px
  offset (darkened brass `#a67c34` in light mode for contrast); disabled drops to
  ~45% and removes the brass detail. State pairs elevation/hairline + outline —
  never hue alone.

## 8. Component Inflections

- **Buttons:** Primary is a solid brass `#c9a15e` fill with espresso text `#1a1613`
  (dark-on-brass — brass is too light for white text), 6px radius — the one
  metallic control. Secondary is a warm-charcoal panel with a 1px brass hairline
  and parchment text; destructive uses the terracotta error hue as a ghost that
  fills on hover. Labels are Inter, title case.
- **Inputs:** Recessed one warm step below the panel, low warm border, 6px radius;
  focus swaps to the brass outline. Labels are Inter 500 above; values in mono.
- **Cards / stat panels:** The signature surface — a raised warm panel, 6px
  radius, optional brass hairline for "featured," generous padding; KPI numerals
  set in large Fraunces with a mono/Inter label beneath. No cool slate anywhere.
- **Navigation:** A warm sidebar on canvas; active item marked by a brass left-rail
  + 600 Inter weight, not a filled pill. Section headers may be small Fraunces.
- **At base defaults (deliberately):** toasts, breadcrumbs, and modal mechanics
  inherit `theme-style-guide` with warm-dark tokens; only palette (warm),
  accent (brass), and type (Fraunces display) change their character.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum across both modes; dashboard body/stat text
  targets AAA (7:1) on the dark canvas since at-a-glance reading is the promise.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. Parchment `#f2ebe0` on espresso
  `#1a1613` ≈ 14:1 (safe); brass `#c9a15e` on espresso ≈ 7:1 (safe as text);
  espresso text on a brass button ≈ 7:1 (safe). **Near-the-line pairs to verify:**
  in **light mode**, darkened brass `#a67c34` on ivory `#f6f1e8` ≈ **4.6:1** —
  just clears body, so don't lighten it; `info` slate-blue `#5a8fb0` on espresso ≈
  4.6:1 (verify after any seed change). `warning` amber and brass must stay
  distinguishable (see §3) — verify side by side.
- **Focus visibility:** 2px solid brass outline (darkened brass in light mode), 2px
  offset; clears 3:1 against espresso, panel, and ivory. Never removed.
- **Reduced motion:** `prefers-reduced-motion` turns the composed transitions into
  instant swaps and disables the vignette if ever animated; hover elevation
  survives as an immediate step change.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Meridian"; intent/perception/audience/tone verbatim; keywords: warm-dark, refined, brass, luxe, considered; font-url: Fraunces + Inter + JetBrains Mono |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#f2ebe0` (warm parchment, never pure), black `#1a1613` (warm espresso) — warm seeds |
| §3 accents | `style-guide.vars.yaml` Seed Colors | brass `#c9a15e`; verdigris teal `#3f857e`; no third brand hue |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#7fa650`, warning `#d98a2b`, error `#c85248`, info `#5a8fb0` — keep warning distinct from brass |
| §3 modes | `style-guide.color-modes.yaml` | dark(primary): canvas `#1a1613`, panel `#241f1a`; light: ivory `#f6f1e8`, ink `#2a231c`, brass `#a67c34` |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-display `'Fraunces', Georgia, serif` (headings/KPIs); font-sans `'Inter', -apple-system, sans-serif` (body); font-mono `'JetBrains Mono', 'Menlo', monospace` |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px; comfortable-refined; protect KPI numerals |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `6px`; warm tonal elevation + brass hairline snippet; warm vignette ≤6% |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 140ms`, `--motion-panel: 220ms` ease; no bounce; reduced-motion guard |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | brass primary (dark text), hairline secondary, Fraunces KPI panels; leave listed components at base |
| §9 a11y | verification across facets | recheck light-mode brass `#a67c34` (≈4.6:1), info slate-blue, brass-vs-warning distinction |
