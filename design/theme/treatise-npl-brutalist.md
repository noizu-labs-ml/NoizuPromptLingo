---
slug: npl-brutalist
base_theme: theme-style-guide
status: sketch
revision: 1
---

# Theme Treatise — NPL Brutalist

Theme: `theme-npl-brutalist/` · Base: `theme-style-guide` · Status: sketch

> Reverse-engineered from the shipped `theme-npl-brutalist/` YAML. Where a value
> looks arbitrary rather than intentional, this treatise says so instead of
> inventing a rationale.

## 1. Identity

- **Intent:** A prompt-definition language shown as raw machinery — visible
  structure, no ornament, full voltage. The UI is the schematic, not a skin over
  it: borders are load-bearing, color is signal, nothing is softened to be
  polite.
- **Perception:** Confident, disruptive, unmistakable within the first second.
  "This tool does not apologize for taking up space." Loud, not chaotic — the
  loudness is disciplined by a hard grid.
- **Audience:** Builders who want the seams shown and the rules broken on
  purpose — power users who read the brutalist idiom as honesty, not hostility.
- **Tone:** Blunt, loud, declarative. ALL CAPS is idiomatic for headings and
  labels, not an accident.
- **Keywords:** raw, loud, structural, hard-edge, electric
- **Variant note:** Inherits `theme-style-guide` structure (shells, layouts,
  section set, 8px spacing scale, 12-col grid) unchanged. The delta is entirely
  chromatic (pure-primary seeds replace the base's neon-on-void), shape (radius
  driven to `0`), and border weight (hard solid rules replace the base's tonal
  separation). One sentence: **the base's cyberpunk glow is stripped to flat,
  high-voltage structure.**

## 2. References & Anchors

- **Anchor — neo-brutalist web (Gumroad-2021, Figma community brutalist kits):**
  borrow the flat fills, hard 1–2px black borders, oversized type, and the
  hard-offset (0-blur) block shadow as the *only* depth cue.
- **Anchor — International hazard signage / safety color:** borrow the discipline
  of a tiny fixed palette used at full saturation for meaning (stop = vermilion,
  caution = hazard yellow, go = green), never for decoration.
- **Anchor — exposed-structure brutalist architecture (béton brut):** borrow the
  thesis that the structural members *are* the finish — dividers, grids, and
  borders are shown, never concealed behind padding.
- **Anti-reference — the base `noizu.ink` cyberpunk skin:** reject the neon glow,
  the void gradients, the "slightly dangerous haze." Brutalist warmth is *flat
  voltage*, not phosphor bloom — no `box-shadow` glow, no gradient anywhere.
- **Anti-reference — friendly rounded SaaS (Stripe-lite, soft cards):** reject
  soft radii, drop-shadow elevation, and pastel reassurance. Rounded corners
  here are a thesis failure, not a taste difference.
- **Anti-reference — skeuomorphic depth:** reject blurred shadows and beveled
  surfaces; the only sanctioned depth is a solid offset block with zero blur.

## 3. Color Story

- **Temperature & register:** Neutral canvas (pure `#ffffff` / `#000000`) carrying
  electric primaries at maximum chroma. There is no muting anywhere — saturation
  is the point.
- **Hue relationships:** A hard RYB-primary triad — vermilion `#ff2d00`
  (~10°), ultramarine `#1500ff` (~250°), hazard yellow `#ffe600` (~54°). No
  analogous blends, no tints between them; each is used flat and whole.
- **Neutral strategy:** Pure, untinted gray. Light-mode grays `#f2f2f2 / #1a1a1a
  / #4d4d4d`; dark-mode `#0d0d0d / #e6e6e6 / #b3b3b3`. Zero hue in the neutrals —
  any warmth would read as a bug against the electric accents.
- **Semantic mapping:** Deliberately *is* the primary palette — `error` = the red
  seed `#ff2d00`, `warning` = the yellow seed `#ffe600`, `info` = the blue seed
  `#1500ff`; only `success` `#00c853` (electric green) is added outside the triad.
  **Collision flag (honest signal):** `error` and the brand-primary red are the
  *same hex* — a destructive action and a primary accent are indistinguishable by
  hue. This is on-thesis (full voltage, no reserved "brand" tint) but means
  destructive intent must be carried by **label, position, and the hard border**,
  never color alone. Fine-tuner: do not "fix" this by desaturating error; do
  reinforce it with iconography/copy.
- **Contrast stance:** Maximal and non-negotiable. Body text is pure black on
  white (21:1) or white on black (21:1). Borders are full-strength (`#000` /
  `#fff`), never a faint hairline. The theme is *never* allowed to be subtle;
  subtlety is the failure mode.
- **Mode strategy:** Light **and** dark are both first-class and both hard —
  mirror images (white-canvas/black-ink ↔ black-canvas/white-ink), not a primary
  plus a dimmed afterthought. No separate high-contrast mode exists in v1 and
  none is needed: the theme already clears AAA on its core pairs. `forced-colors`
  users inherit system colors untouched.

## 4. Typographic Voice

- **Families:** Space Grotesk (geometric grotesk — mechanical, wide-aperture,
  slightly odd; the "machine" voice) for UI and headings; Space Mono for code,
  data, tags, IDs, and — per the theme's "mono everything" intent — for many
  labels too. **No serif, ever.** Fallbacks: `'Arial Narrow', sans-serif` and
  `'Courier New', monospace`.
- **Scale character:** Dramatic display jumps — ratio ~1.333–1.5. The largest
  heading on a working screen may reach 3–5× body size; brutalist type is meant
  to shout, and undersized headings read as timid.
- **Weight usage:** 400 body, 500 emphasized UI, 700 for all headings and hard
  emphasis. Headings are 700 + UPPERCASE, tracking tightened ~−1% at display
  sizes. Never set long paragraphs in 700 or in caps.
- **Rhythm:** Heading line-height 1.0–1.1 (tight, blocky); body 1.5. Measure is
  not precious — text may run to the hard border. Mono appears prominently: code,
  values, timestamps, tags, and section eyebrows.

## 5. Space & Density

- **Spacing philosophy:** 8px base unit inherited from the base theme, but spent
  starkly — content butts directly against hard borders with little "comfort"
  padding (8–12px inside dense cells). Whitespace is either large and deliberate
  or absent; there is no cozy middle.
- **Density target:** Reference screen is the NPL Glyph Codex or a Tickets List —
  a dense grid packed edge-to-edge, cells separated by 1px hard rules, ~24–40
  rows visible on a 1440×900 viewport. Denser than any other NPL theme.
- **Responsive stance:** Columns drop hard at breakpoints — no fluid reflow
  niceties, no shrinking gutters. Hard dividers and border weight are protected
  first (structure must stay legible); heading size is protected second; internal
  padding compresses first.

## 6. Shape & Surface

- **Radius language:** `0px` everywhere. Base 0, exceptions 0, maximum 0. A pill
  or rounded card is a thesis break.
- **Borders:** The primary structural language — 1–2px solid `#000` (light) /
  `#fff` (dark) on every card, input, button, and section edge. Borders are never
  a faint tonal hairline; if an edge exists, it is drawn at full strength.
- **Elevation:** Flat — **no blurred shadows.** The single sanctioned depth cue
  is a **hard-offset block shadow**: a solid color block (black, or an accent)
  offset 4–6px with `0` blur, on primary buttons and pulled-forward cards. That
  is the only "elevation" the theme owns.
- **Texture & gradient policy:** None. Flat fills only — no gradient, no noise, no
  glow. (This is the sharpest departure from the neon base.)

## 7. Motion & Feedback

- **Animation character:** Instrumental to the point of near-absence. Motion
  confirms an action happened; it is never expressive or eased-for-delight.
  Brutalism resists the smooth curve.
- **Duration & easing:** 0–100ms, `linear` or `steps()`. Nothing springs,
  bounces, or exceeds 150ms. No scroll-linked motion.
- **Interaction states:** Hover **inverts** (swap foreground/background: black-on-
  white ↔ white-on-black) or flips to an accent fill; active "presses" the
  element into its offset block-shadow (translate by the offset, shadow to 0);
  focus is a **3px solid ultramarine `#1500ff` outline, offset 2px** (high
  contrast on both modes); disabled drops to 40% opacity and loses its fill but
  **keeps its border**. State never rides on hue alone — inversion and border
  change always co-signal.

## 8. Component Inflections

- **Buttons:** Rectangular, `0` radius, 2px solid border, UPPERCASE mono label,
  hard-offset block shadow. Primary = vermilion `#ff2d00` fill with black border
  and near-black text; secondary = surface fill, black border; destructive reuses
  the error/red hue and *must* add an explicit label (see §3 collision flag).
- **Inputs:** `0` radius, 2px solid border, no inner shadow, no rounded focus
  ring — focus swaps the border to ultramarine and adds the 3px outline.
  Uppercase mono field labels sit above, not floating inside.
- **Cards:** Hard-bordered rectangles on `surface-alt` (`#f2f2f2` / `#0d0d0d`),
  optional hard-offset shadow when pulled forward; `0` radius; header separated
  by a full-weight rule, not padding.
- **Navigation:** Bordered blocks; the active item is a full **inverted fill** or
  carries a thick (3–4px) accent bar. No soft pill highlight.
- **At base defaults (deliberately):** tables inherit base structure but render
  with 1px hard black grid lines; toasts, breadcrumbs, and modal *mechanics*
  inherit `theme-style-guide` with the brutalist tokens applied — only their
  radius (→0) and border (→hard) change.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum; the black/white core clears AAA (21:1) with
  enormous margin.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. **Near-the-line / failing
  pairs the fine-tuner must respect:** hazard yellow `#ffe600` on white ≈ **1.1:1
  — never text on a light surface** (fill/highlight only; as text it requires the
  black canvas, where it clears ~17:1); vermilion `#ff2d00` on white ≈ **3.5:1**
  (large text and UI borders only, not body copy); ultramarine `#1500ff` on white
  ≈ 5.6:1 (safe for text). Success green `#00c853` on white ≈ 2.0:1 — icon/fill,
  not text on light.
- **Focus visibility:** 3px solid ultramarine outline, 2px offset, on every
  focusable element; exceeds 3:1 against both white and black canvases. Focus is
  never removed, only restyled.
- **Reduced motion:** `prefers-reduced-motion` makes the already-instant hover
  inversion a hard swap and disables the press-translate; nothing else animates,
  so nothing else needs disabling.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Brutalist"; intent/perception/audience/tone verbatim; keywords: raw, loud, structural, hard-edge, electric; font-url: Space Grotesk + Space Mono |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#ffffff`, black `#000000` — pure, no tint |
| §3 accents | `style-guide.vars.yaml` Seed Colors | red `#ff2d00`, blue `#1500ff`, yellow `#ffe600` at full chroma |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#00c853`, warning `#ffe600`, error `#ff2d00`, info `#1500ff` — keep error≡red seed (do not desaturate) |
| §3 modes | `style-guide.color-modes.yaml` | light: surface `#fff`, alt `#f2f2f2`, border `#000`; dark: surface `#000`, alt `#0d0d0d`, border `#fff` |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-sans `'Space Grotesk', 'Arial Narrow', sans-serif`; font-mono `'Space Mono', 'Courier New', monospace`; ~1.4 scale, uppercase headings |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px unit; tight interior padding, hard dividers |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `0px`; hard-offset block-shadow snippet (0 blur), full-weight border snippets |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 80ms linear`; hover-invert + press-translate; reduced-motion guard |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | button/input/card/nav per §8; tables get 1px hard grid |
| §9 a11y | verification across facets | recheck yellow-as-text (fail on light), vermilion-as-text, success-green after any seed change |
