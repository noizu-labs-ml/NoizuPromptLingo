---
slug: npl-blueprint
base_theme: theme-style-guide
status: sketch
revision: 1
---

# Theme Treatise — NPL Blueprint

Theme: `theme-npl-blueprint/` · Base: `theme-style-guide` · Status: sketch

> New direction (authored forward). Blueprint is the *schematic* theme — a
> technical-drafting surface with a faint grid, thin cyan/blue rules, and
> monospace measurements. The only NPL theme that treats a grid as texture.

## 1. Identity

- **Intent:** Render NPL's most *structural* surfaces — authorization policies,
  schemas, custom ticket types, MCP scope trees, project topology — as if drawn on
  an engineer's drafting table. Structure is the aesthetic: grid, rule, dimension,
  annotation.
- **Perception:** Precise, technical, trustworthy within five seconds — "this was
  drawn by someone who measures twice." Cool, exacting, calm.
- **Audience:** The Platform Administrator and the Delivery Lead when they're
  *configuring* the system — reading policy documents, mapping scopes, wiring
  schemas — where correctness and legibility of structure matter more than warmth.
- **Tone:** Exact, annotated, declarative. Labels read like callouts on a drawing.
- **Keywords:** schematic, precise, drafting, technical, structural
- **Variant note:** Inherits `theme-style-guide` structure and spacing scale.
  Deltas: a **cool drafting palette** (paper + blueprint-blue + a redline accent),
  **IBM Plex Sans/Mono** engineered type, **near-square 2px radius**, and — uniquely
  — a **faint grid texture** and **thin cyan rules** as the structural language.
  One sentence: **the base re-skinned as a drafting sheet where the grid is
  visible and the annotations are monospace.**

## 2. References & Anchors

- **Anchor — architectural/engineering blueprints & CAD:** borrow the literal
  vocabulary — a faint background grid, thin structural rules, dimension lines,
  and monospace callout labels. This is the theme's core reference.
- **Anchor — the IBM Plex type family + Carbon-adjacent technical UI:** borrow the
  engineered, slightly mechanical letterforms and the "documentation of a system"
  register; Plex Sans + Plex Mono *are* the voice.
- **Anchor — graph-paper / dot-grid notebooks (Dividat, technical journals):**
  borrow the light dot/line grid as a working surface that invites precise
  placement without shouting.
- **Anti-reference — the Editorial sibling:** reject warm paper, serifs, and prose
  rhythm. Blueprint is *cool* and *drawn*, not *warm* and *typeset* — its "paper"
  is a cool drafting sheet with a grid, not a book page.
- **Anti-reference — the Nocturne terminal:** reject dark-native green-signal
  density. Blueprint's default is a **light drafting sheet**; even its dark mode is
  a **cyanotype navy with cyan lines**, not a black terminal with a green cursor.
- **Anti-reference — decorative "tech" grids with glow/parallax:** reject animated
  grids, neon gridlines, and 3D wireframe kitsch; Blueprint's grid is a flat,
  static, low-contrast working surface.

## 3. Color Story

- **Temperature & register:** Cool and precise, low-to-mid saturation. A pale
  cool sheet carrying blueprint-blue structure and a single warm redline for
  markup — the "red pencil" on a blue drawing.
- **Hue relationships:** Blue-dominant with a warm annotation counterpoint.
  Primary blueprint blue `#245ea8` (~213°), secondary drafting cyan `#0e9bd6`
  (~196°) for rules/highlights, and a red-oxide **redline** `#c05a3e` (~14°)
  reserved for markup, deletions, and "attention" callouts (the drafting redline).
- **Neutral strategy:** **Cool-tinted** toward blueprint blue (~4%), not pure
  gray. Canvas is a pale cool sheet `#f5f8fc`; ink is a dark navy `#14263f`
  (reads as drafting ink, not black). The grid lines are the cyan at very low
  alpha. This cool tint is what separates Blueprint from Minimal's pure gray.
- **Semantic mapping:** Technical and distinct — `success` teal-green `#2e8b6f`,
  `warning` ochre-amber `#c98a2b`, `error` drafting red `#bd3b34`, `info`
  blueprint blue `#245ea8` (≡ primary — "info" and "structure" share the blue,
  which is correct here). `error` red is cleanly distinct from the blue primary;
  the redline accent `#c05a3e` is a *markup* color, kept visually distinct from
  `error` by being more orange/earthy.
- **Contrast stance:** Crisp for ink and structure, deliberately faint for the
  grid. Ink on sheet ≈ 13:1; structural rules are thin but legible (~3:1); the
  background grid is intentionally near-invisible (~1.1:1) — present when you look,
  gone when you read. Blueprint is subtle *only* in its grid.
- **Mode strategy:** Light (drafting sheet) is primary. Dark mode is a genuine,
  designed **cyanotype** — deep navy canvas `#0a1a2f`, white/cyan lines, brass-free
  — the classic blueprint negative, not a dimmed light mode. Both modes are
  first-class and equally "on-brand." No separate high-contrast mode; both clear
  AA and `forced-colors` falls back to system.

## 4. Typographic Voice

- **Families:** **IBM Plex Sans** for UI and body (engineered, technical, calm);
  **IBM Plex Mono** as a co-lead for all *measurements, coordinates, keys, policy
  identifiers, and callout labels* — Blueprint is mono-forward wherever a value is
  precise. No serif. Fallbacks: `-apple-system, sans-serif` and `'Menlo',
  monospace`.
- **Scale character:** Tight, drawing-like scale ~1.2 — hierarchy by weight and by
  sans-vs-mono contrast; callouts are small mono, titles are Plex Sans medium.
- **Weight usage:** 400 body, 500 labels/callouts, 600 titles; 700 rare (sheet
  title block). Mono labels often 500 to hold on the grid.
- **Rhythm:** Body line-height 1.5; mono 1.5; measure ~74ch. Mono appears
  prominently — coordinates (pixel-anchored review x/y/w/h), policy IDs, scope
  paths, schema field names — anywhere precision reads better fixed-width.

## 5. Space & Density

- **Spacing philosophy:** 8px base unit, aligned to an **8px grid that is faintly
  visible** — spacing is not just consistent, it's *shown*. Mid density: precise,
  not cramped.
- **Density target:** Reference screen is Admin: Authz (PBAC policy + scope tree)
  or Ticket Field/Type Admin — a structured tree/table plus a detail panel, with
  dimension-line separators, comfortably on a 1440×900 viewport.
- **Responsive stance:** The grid and structural rules are protected — they define
  the layout — while annotation columns collapse first. Mono coordinate readouts
  never wrap; they truncate with a tooltip.

## 6. Shape & Surface

- **Radius language:** Near-square — **2px base**, 0–2px on rules/cells, 4px
  maximum on floating panels. Precision reads as sharp, not soft (but not
  Brutalist-hard `0` — a 2px easing keeps it "drawn," not "stamped").
- **Borders:** The structural language — **thin 1px cyan/blue rules** everywhere:
  cell dividers, panel edges, dimension lines. Borders are the drawing; surfaces
  are the paper between them.
- **Elevation:** Nearly flat — the sheet is a plane. Floating panels (inspectors,
  menus) get a minimal cool shadow; resting cards use a rule + faint tone step,
  never a shadow. Depth is drawn (a heavier rule), not lit.
- **Texture & gradient policy:** The **one theme that embraces texture** — a faint
  blueprint grid (8px minor / 40px major, cyan at ≤6% alpha on light, ≤10% on the
  cyanotype dark) is a first-class part of the canvas. No gradients, no glow.
  Grid is static.

## 7. Motion & Feedback

- **Animation character:** Instrumental and constructive — where motion appears it
  behaves like a line being drawn (a rule extending, a panel unrolling), reinforcing
  the drafting metaphor. Sparse.
- **Duration & easing:** Micro-feedback 80–120ms ease-out; panel transitions
  160–200ms ease-in-out; an optional "draw-in" of a rule (≤200ms) on first render
  of a diagram. Nothing exceeds 220ms. No spring.
- **Interaction states:** Hover thickens/brightens the relevant rule and tints the
  cell faintly; active deepens the blue; focus is a 2px blueprint-blue `#245ea8`
  outline, 2px offset (cyan `#4fc3e8` on the cyanotype dark for contrast); disabled
  drops to ~45% and lightens rules. State pairs a rule change with the outline —
  never hue alone.

## 8. Component Inflections

- **Buttons:** Rectangular with 2px radius and a 1px blueprint-blue rule. Primary
  is a solid blueprint-blue `#245ea8` fill, white text; secondary is a cyan-rule
  ghost on the sheet; destructive uses `error` red rule→fill on hover. Labels are
  Plex Sans medium, sentence case (callout, not shout).
- **Inputs:** Sit on the grid — 2px radius, 1px cyan rule, mono value text for
  precise fields; focus swaps to the blueprint-blue outline. Labels are small mono
  callouts above, like dimension annotations.
- **Cards / panels:** "Drawing regions" — a bordered rectangle on the sheet with a
  title-block header (a labeled top strip, like a drawing's title block), 2px
  radius, rule separators inside. No resting shadow.
- **Navigation:** A left rail that reads like a sheet index; active item marked by
  a 2px cyan left-rule + medium weight. Breadcrumbs render as a mono path
  (`org / project / scope`).
- **At base defaults (deliberately):** toasts and modal *mechanics* inherit
  `theme-style-guide`; only palette (cool), radius (2px), border (cyan rule), and
  the grid canvas change their look.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum across both (light sheet + cyanotype) modes.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. Ink `#14263f` on sheet
  `#f5f8fc` ≈ 13:1 (safe); blueprint-blue `#245ea8` on sheet ≈ 5.6:1 (safe as
  text). **Near-the-line pairs to verify:** cyan `#0e9bd6` on sheet ≈ **3.0:1 →
  rules/large-UI only, never body text**; redline `#c05a3e` on sheet ≈ **4.6:1** —
  just clears body, so don't lighten it. On the cyanotype dark, text `#dbe7f5` on
  navy `#0a1a2f` ≈ 13:1; grid lines must stay ≤10% alpha so they never fight text.
- **Focus visibility:** 2px solid outline — blueprint-blue on light, cyan on the
  cyanotype dark — 2px offset; both clear 3:1 against their canvas. Never removed.
  The faint grid must never be mistaken for a focus indicator.
- **Reduced motion:** `prefers-reduced-motion` disables the rule "draw-in" and
  panel unroll (they snap in); hover rule-thickening survives as an instant swap.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Blueprint"; intent/perception/audience/tone verbatim; keywords: schematic, precise, drafting, technical, structural; font-url: IBM Plex Sans + IBM Plex Mono |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#f5f8fc` (cool sheet), black `#14263f` (navy ink); neutrals tinted ~4% toward blue |
| §3 accents | `style-guide.vars.yaml` Seed Colors | primary `#245ea8`, cyan `#0e9bd6`, redline `#c05a3e` (markup only) |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#2e8b6f`, warning `#c98a2b`, error `#bd3b34`, info `#245ea8` (≡primary) — keep redline visually distinct from error |
| §3 modes | `style-guide.color-modes.yaml` | light: sheet `#f5f8fc`, cyan grid; dark(cyanotype): canvas `#0a1a2f`, cyan/white lines, focus cyan `#4fc3e8` |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-sans `'IBM Plex Sans', -apple-system, sans-serif`; font-mono `'IBM Plex Mono', 'Menlo', monospace`; mono-forward callouts |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px, aligned to a visible 8px grid; mid density |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `2px`; thin cyan rule borders; grid-canvas snippet (8px/40px, ≤6% alpha); title-block card header |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 100ms`; optional rule draw-in ≤200ms; reduced-motion guard |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | blueprint-blue primary, cyan-rule ghost, title-block cards, mono breadcrumbs |
| §9 a11y | verification across facets | recheck cyan-as-text (fail → rules only), redline (≈4.6:1), grid alpha vs text after any change |
