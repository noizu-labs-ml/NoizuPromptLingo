---
slug: npl-prism
base_theme: theme-style-guide
status: full
revision: 2
---

# Theme Treatise — NPL Prism

Theme: `theme-npl-prism/` · Base: `theme-style-guide` · Status: full (rev 2, render-validated)

> New direction (authored forward). Prism is the *expressive* theme — the only
> NPL theme that embraces gradients and translucent glass. It exists for the
> marketing/creative surfaces where "this is a modern AI product" must be felt.

## 1. Identity

- **Intent:** Give NPL a vivid, contemporary face for its outward and creative
  moments — the landing page, the creative/marketing suite (campaigns, ad copy,
  landing-page generation, competitor research), and reviews. Where the expert
  themes recede, Prism *presents*: spectrum color, frosted glass, soft light.
- **Perception:** Premium, energetic, current within a second — "these people
  ship modern software." Vibrant but composed, not a rave.
- **Audience:** The Growth Operator working the creative suite, prospects hitting
  the landing page, and anyone reviewing generated creative — audiences who
  respond to polish and color, not density.
- **Tone:** Confident, contemporary, a little bold. Marketing-literate.
- **Keywords:** vibrant, luminous, spectrum, premium, glass
- **Variant note:** Inherits `theme-style-guide` structure and spacing scale.
  Deltas: a **cool-spectrum gradient palette**, **translucent frosted-glass
  surfaces**, **Sora** geometric type, and a **generous 16px radius**. One
  sentence: **the base's void-neon is refined into luminous glass over a soft
  spectrum gradient.** It is the *only* theme permitted gradients and blur.

## 2. References & Anchors

- **Anchor — modern AI/SaaS marketing (Linear's gradient hero era, Vercel ship
  pages, Framer templates):** borrow the spectrum gradient accents, glassy cards,
  and generous radius that read as "2020s premium software."
- **Anchor — Apple "frosted glass" (Big Sur / visionOS materials):** borrow the
  translucent, backdrop-blurred surface material and its rules for legibility over
  busy backdrops.
- **Anchor — a literal prism/spectrum:** borrow the *palette logic* — a controlled
  violet→cyan→fuchsia spectrum where the gradient direction and stops are
  consistent and meaningful, not random.
- **Anti-reference — the `noizu.ink` cyberpunk base:** reject neon-on-void,
  scanlines, and "dangerous" grit. Prism's light is *soft and luminous*, not
  hard neon; its default is bright glass, not a dark void.
- **Anti-reference — the Minimal/expert themes:** reject flat monochrome
  restraint; Prism is *supposed* to use color and depth. If a Prism screen reads
  as "clean gray console," it has failed its brief.
- **Anti-reference — gradient-soup (uncontrolled rainbow gradients, gradient body
  text, tie-dye buttons):** reject spectrum used without discipline; gradients run
  one consistent axis, appear on hero/CTA/glass-edge only, and never behind body
  text.

## 3. Color Story

- **Temperature & register:** Cool-spectrum and saturated-but-luminous. Color is
  the point, but it lives in gradients and glass tints, not flat fills — light
  passing through a prism, not paint.
- **Hue relationships:** A controlled spectrum — violet `#7c3aed` (~270°, primary)
  → cyan `#06b6d4` (~190°) → fuchsia `#d946ef` (~292°). The signature gradient runs
  violet→cyan (primary) or violet→fuchsia (creative/energetic). Violet dominates
  as the anchor; cyan and fuchsia are the spectrum ends.
- **Neutral strategy:** Cool near-white with a faint violet tint. Canvas `#f7f8ff`
  carrying a soft, low-alpha gradient *mesh* (violet/cyan/rose blobs, blurred);
  ink `#1a1730` (a deep indigo-charcoal). Neutrals lean cool so the spectrum reads
  as belonging.
- **Semantic mapping:** Bright but standard so status stays legible against the
  color — `success` emerald `#10b981`, `warning` amber `#f59e0b`, `error` rose
  `#f43f5e`, `info` blue `#3b82f6`. `error` rose (~350°) is distinct from the
  violet primary (~270°); `warning` amber is the one warm break, deliberately
  kept for contrast against the cool field. Semantics are **flat, opaque** chips —
  never gradient — so meaning never depends on a gradient stop. **(rev 2,
  render-validated):** the Stage-C renders confirmed the violet primary tends to
  swallow accents toward monochrome, so the engine must **pin
  `success`/`warning`/`error`/`info` explicitly** (not trust the base cascade), or
  status collapses into all-violet.
- **Contrast stance:** High-but-luminous. Ink on light glass clears ~14:1; but the
  defining rule is **glass legibility** — text over a frosted surface requires the
  surface to be opaque *enough* (≥70% fill behind text) that body always clears
  4.5:1 regardless of the gradient mesh behind it. Prism may be subtle in its
  backdrops, never in its text.
- **Mode strategy:** Light is primary (frosted glass over a pale spectrum mesh).
  Dark mode is a genuine, designed translation — glass over a deep violet-navy
  gradient `#12102a`, where the frosted material and spectrum glow read even
  better; it is not an afterthought. No separate high-contrast mode in v1; a
  reduced-transparency fallback (see §9) covers the accessibility need.

## 4. Typographic Voice

- **Families:** **Sora** (modern geometric sans with a premium, slightly
  distinctive cut) for display and UI — it carries the "current software" tone;
  JetBrains Mono for code, generated-prompt bodies, and IDs. No serif. Fallbacks:
  `-apple-system, sans-serif` and `'Menlo', monospace`.
- **Scale character:** Expressive scale ~1.333 — bigger jumps than the expert
  themes; hero and section headings are large and confident (up to ~3× body on
  marketing screens).
- **Weight usage:** 400 body, 600 headings/emphasis, 700–800 for hero display.
  Gradient *text* is permitted **only** on large display headings (≥28px), never
  on body, labels, or UI text.
- **Rhythm:** Body line-height ~1.6; measure ~68ch on content, wider on marketing
  hero blocks. Mono for generated content blocks and code; not for UI chrome.

## 5. Space & Density

- **Spacing philosophy:** 8px base unit, spent generously — marketing-airy on
  outward screens, comfortable on creative-suite tools. Glass cards want room to
  float; crowding kills the material.
- **Density target:** Reference screen is the Landing hero or the Creative Assets
  Pipeline — a few large glass cards, a prominent gradient CTA, generous
  whitespace; ~3–6 primary cards per viewport, not a dense grid.
- **Responsive stance:** Hero gradients and primary CTA are protected; secondary
  glass panels stack and the gradient mesh simplifies (fewer blobs) before body
  spacing compresses. Blur radius reduces on low-power/mobile for performance.

## 6. Shape & Surface

- **Radius language:** Generous — **16px base** on cards/inputs, 12px on small
  controls, pills on chips/tags, 24px maximum on hero glass. Soft, modern, but a
  touch sharper than Aurora's 14+pill-everything (Prism is premium, not cozy).
- **Borders:** Mostly a **1px translucent light border with a subtle gradient
  sheen** (the "glass edge"), not a solid rule. Opaque hairlines appear only where
  legibility demands (form field rest state).
- **Elevation:** Frosted glass + soft colored shadow. Surfaces are **translucent**
  (backdrop-blur ~16–24px) with a violet-tinted soft shadow
  (`rgba(90,60,200,0.18)`); two glass elevation steps (panel, raised). The gradient
  mesh shows *through* surfaces — that translucency is the identity.
- **Texture & gradient policy:** The **one theme built on gradients** — a soft
  spectrum mesh on the canvas, gradient CTAs, gradient glass edges, and gradient
  large-display text. Discipline: one consistent axis, spectrum stops only, never
  behind body text, semantics stay flat. No noise, no scanlines.

## 7. Motion & Feedback

- **Animation character:** Smooth and luminous — motion is expressive here (unlike
  the instrumental expert themes): gentle gradient drift on hero backdrops, glass
  that lifts and refracts on hover. Motion sells "alive and premium."
- **Duration & easing:** Micro-feedback 120–160ms ease-out; card/panel transitions
  200–280ms ease-in-out; the hero gradient mesh may drift slowly (~12–20s loop, very
  low amplitude). Nothing interactive exceeds 320ms; no bounce.
- **Interaction states:** Hover lifts the glass (shadow grows, edge-sheen
  brightens) and may shift the gradient a few degrees; active presses back; focus
  is a 2px violet `#7c3aed` ring, 2px offset, with a solid (non-glass) backdrop
  guaranteed under it; disabled drops to ~50% and removes translucency (flattens
  to a solid muted fill). State pairs elevation/sheen + ring — never hue alone.

## 8. Component Inflections

- **Buttons:** Primary is a **violet→cyan gradient fill** with white text and a
  soft glow shadow — the signature control; the gradient runs the canonical axis.
  Secondary is a glass button (translucent, gradient-sheen border, ink text);
  destructive is a flat rose fill (semantics never gradient). Chips are pills.
- **Inputs:** Glass field (translucent) with an opaque inner backdrop behind the
  text for legibility, 16px radius, gradient-sheen border; focus swaps to the
  violet ring. Labels are Sora 600 above.
- **Cards:** The signature surface — frosted glass, 16px radius, gradient-sheen
  edge, violet-tinted soft shadow; the canvas mesh glows through. Featured cards
  get a stronger gradient edge, not a solid accent bar. **(rev 2, render-validated):**
  on pure *marketing* surfaces (the landing feature grid) fuller spectrum-gradient
  card *fills* read well and are permitted; *in-app* cards keep the glass +
  gradient-edge discipline (never a flat gradient fill) so data stays legible.
- **Navigation:** A glass top bar floating over the mesh; active item is a
  gradient-underline or a gradient-text label (large enough to pass contrast). No
  solid pill.
- **At base defaults (deliberately):** dense tables and admin forms inherit
  `theme-style-guide` on a solid (non-glass) surface — glass is for presentation
  surfaces, and data grids opt out of translucency for legibility.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum across both modes.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. Ink `#1a1730` on light glass
  (opaque backing) ≈ 14:1; white on the violet→cyan gradient button — verified at
  the **lightest** gradient stop (cyan `#06b6d4`, white ≈ **2.4:1**) — so the CTA
  gradient must be **darkened / violet-weighted** enough that white text clears
  4.5:1 across the whole sweep, or the button uses ink text at the cyan end. This
  is the theme's single most important check. **Glass rule:** any text over a
  frosted surface requires ≥70% surface opacity behind it so body always clears
  4.5:1 over the busiest mesh. Gradient text is display-size (≥28px, ~3:1) only.
  `error` rose `#f43f5e` and `info` blue `#3b82f6` on light ≈ 3.5–4:1 → large/UI,
  pair with icons. **(rev 2, render+contrast-validated):** semantic **chips carry
  ink `#1a1730` text on the flat fill** (measured AA: ink-on-fill 4.7–8.1:1; white
  text *fails* on these bright fills at 2.2–3.7:1), and status never signals by
  color alone — an icon + label always accompanies, so the sub-3:1 fill-vs-canvas
  edge of the brightest fills (`success` 2.4:1, `warning` 2.0:1) is never the sole
  indicator. **Borders** are decorative glass-edges (§6), not meaningful boundaries;
  a compliant ≥3:1 hairline (~`#8f8caf` on light) is reserved for a form-field
  rest-state token only — general separation is carried by surface-fill + the
  violet-tinted shadow + the focus ring.
- **Focus visibility:** 2px solid violet ring, 2px offset, always on a guaranteed
  solid (non-translucent) backing so it clears 3:1 regardless of the mesh. Never
  removed.
- **Reduced transparency / motion:** `prefers-reduced-transparency` (and a manual
  toggle) replaces frosted glass with solid tinted surfaces; `prefers-reduced-
  motion` stops the gradient drift and hover refraction (instant state swaps).
  Neither degrades meaning — semantics were never carried by glass or gradient.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Prism"; intent/perception/audience/tone verbatim; keywords: vibrant, luminous, spectrum, premium, glass; font-url: Sora + JetBrains Mono |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#f7f8ff` (cool, faint violet tint), black `#1a1730` (indigo-charcoal) |
| §3 accents | `style-guide.vars.yaml` Seed Colors | primary violet `#7c3aed`, cyan `#06b6d4`, fuchsia `#d946ef`; gradient axis violet→cyan |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#10b981`, warning `#f59e0b`, error `#f43f5e`, info `#3b82f6` — flat/opaque chips, never gradient |
| §3 modes | `style-guide.color-modes.yaml` | light: glass over pale mesh; dark: glass over deep violet-navy `#12102a` gradient |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-sans `'Sora', -apple-system, sans-serif`; font-mono `'JetBrains Mono', 'Menlo', monospace`; ~1.333 scale; gradient text ≥28px only |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px; marketing-airy; protect hero/CTA |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `16px`; glass material (backdrop-blur), gradient-sheen border, violet-tinted shadow, canvas mesh snippet |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 140ms`; hero gradient drift ~16s; reduced-motion + reduced-transparency guards |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | gradient primary button, glass secondary/cards; data grids opt out of glass |
| §9 a11y | verification across facets | recheck white-on-gradient at the cyan stop (worst case), glass ≥70% opacity behind text, gradient-text size floor |
