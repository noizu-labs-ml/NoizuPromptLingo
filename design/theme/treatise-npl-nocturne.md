---
slug: npl-nocturne
base_theme: theme-style-guide
status: sketch
revision: 1
---

# Theme Treatise — NPL Nocturne

Theme: `theme-npl-nocturne/` · Base: `theme-style-guide` · Status: sketch

> Reverse-engineered from the shipped `theme-npl-nocturne/` YAML. One honest
> flag up front: this theme has **no true light mode** — both color-modes are
> dark (see §3).

## 1. Identity

- **Intent:** A prompt-definition language and MCP toolchain authored on a dark
  canvas where the signal lives — a near-black instrument with a single phosphor-
  green accent for "live" signal. Mono-first: the monospace face is a co-equal
  voice, not a code-only exception.
- **Perception:** Focused, immersive, expert within a second — "the lights are off
  and the work is on." The terminal you live in, made into a product.
- **Audience:** Agent engineers running long sessions in terminals and IDEs, often
  in low ambient light, watching streams of tool calls and logs.
- **Tone:** Low-noise, high-signal. Speaks in mono.
- **Keywords:** dark, terminal, signal, focus, mono
- **Variant note:** Inherits `theme-style-guide` structure unchanged. The delta is
  a **dark-native palette** (never a true white surface), a **phosphor-green
  signal accent**, **mono-forward** type usage, and **4px radius**. One sentence:
  **the base's neon-on-void is refined into a calm, GitHub-dark-class instrument
  where green means live.**

## 2. References & Anchors

- **Anchor — GitHub Dark / Primer:** the palette is squarely in this family
  (`#010409` canvas, `#58a6ff` links, `#3fb950` green, `#f85149` red). Borrow the
  proven dark-surface elevation ladder and the desaturated text hierarchy.
- **Anchor — a good terminal + editor (iTerm/Zed dark, tmux):** borrow the
  mono-first information density and the idea that green is a *status* color
  (running/ok), not decoration.
- **Anchor — instrument panels / oscilloscopes:** borrow the single-glow-source
  discipline — phosphor green is the one lit element against dark; everything else
  is quiet.
- **Anti-reference — the Minimal sibling:** reject light-nativeness and the sky
  accent. Nocturne is **dark-native**; if a screen reads as "clean white console,"
  it has drifted into Minimal. The shared Inter/JetBrains Mono type stack is the
  *only* thing these two share — palette, canvas, and mood are opposite.
- **Anti-reference — cyberpunk neon glow (the `noizu.ink` base):** reject the
  bloom, the void gradients, the "slightly dangerous" haze. Nocturne's green is a
  crisp signal, not a glowing sci-fi accent — no `box-shadow` glow.
- **Anti-reference — pitch-black OLED `#000` themes:** reject pure black canvas;
  Nocturne's darkest surface is `#010409` (a near-black with a trace of cool),
  and text is a soft `#e6edf3`, never pure `#fff` — both chosen for long-session
  eye comfort.

## 3. Color Story

- **Temperature & register:** Cool and dark, muted except for the one signal.
  Every surface is a near-black or dark slate; saturation is spent almost
  entirely on the green accent.
- **Hue relationships:** Dark monochrome + phosphor-green signal `#3fb950`
  (~135°), with cyan `#58a6ff` (~215°) as the link/secondary hue and amber
  `#d29922` (~40°) as the warm warning glow. Green dominates as "live"; cyan is
  navigational; amber is rare.
- **Neutral strategy:** Cool-tinted darks (the GitHub-dark slate ladder), not
  pure gray-black. The seed "white" is a **soft `#e6edf3`** — never pure `#fff`,
  because full-white text vibrates on a near-black canvas over long sessions. The
  canvas is `#010409`.
- **Semantic mapping:** GitHub-dark conventions — `success` = green `#3fb950` (≡
  the signal accent), `warning` = amber `#d29922`, `error` = red `#f85149`, `info`
  = cyan `#58a6ff`. **success and the brand signal are the same green** — here
  that is *correct*, not a collision: "brand signal" and "success/live" mean the
  same thing in this theme. `error` red is cleanly distinct from the green signal.
- **Contrast stance:** Soft-dark for chrome, crisp for content. Soft-white text on
  canvas clears ~16:1; secondary text (`#909dab`) stays ≥ 4.5:1; borders sit low
  (`#161b22`, near the surface) because elevation comes from surface steps, not
  lines. Never let the green drop to a decorative low-contrast state — when it is
  "live," it must be legibly lit.
- **Mode strategy — HONEST FLAG:** Nocturne is **dark-native and ships no true
  light mode.** Its `light` color-mode is a *dimmed slate* (surface `#0d1117`),
  not a paper white — deliberately, per the theme's own comment ("meant to be
  lived in at night"). Consequence for the fine-tuner: a user who forces "light"
  still gets a dark UI; there is no paper escape hatch. If a genuinely bright
  environment must be served, that is **Minimal's or another theme's job**, not a
  new Nocturne mode. `forced-colors`/high-contrast falls back to system colors —
  the only true light path.

## 4. Typographic Voice

- **Families:** Inter for UI text; JetBrains Mono (fallback Fira Code) as a
  **co-equal, mono-first** voice — code, tool-call streams, IDs, timestamps,
  values, *and* many labels and section eyebrows render mono, per the "speaks in
  mono" intent. No serif. Fallbacks: `-apple-system, sans-serif` and `'Menlo',
  monospace`.
- **Scale character:** Tight terminal scale ~1.2; headings distinguish by weight
  and mono-vs-sans contrast more than by size. Largest working heading ~2× body.
- **Weight usage:** 400 body, 500 emphasized UI and active nav, 600 headings; 700
  exists (the mono has a 700) for the wordmark and hard emphasis. Mono is often
  set at 500 for labels to hold up on dark.
- **Rhythm:** Body line-height 1.55; mono blocks 1.5 (log readability). Measure
  ~80ch in log/stream panes (wider than the other themes — terminal habit). Mono
  is prominent, not reserved.

## 5. Space & Density

- **Spacing philosophy:** 8px base unit inherited; tuned dense — this is a tool
  for watching a lot of signal at once. Padding is spent inside panels, gutters
  between panels stay tight (8–12px).
- **Density target:** Reference screen is the Agent Memory Browser or a Mock MCP
  LLM Pool monitor — multiple live panels (a stream, a detail, a status rail)
  visible together on a 1440×900 viewport without scrolling the shell. Denser than
  Minimal, looser than Brutalist.
- **Responsive stance:** Under width pressure, the sidebar collapses to icons
  first, then secondary panels stack; the primary stream/log pane and its mono
  legibility are protected — never shrink the log to fit chrome.

## 6. Shape & Surface

- **Radius language:** Soft-technical — 4px base on cards/inputs, 2px on small
  chips/badges, 6px maximum. No pills. Slightly sharper than Minimal (4 vs 6) to
  read as "instrument," not "app."
- **Borders:** Low-contrast dark borders (`#161b22` / `#21262d`) mark interactive
  or panel edges; most separation comes from the surface-step ladder
  (`#010409` → `#0d1117` → `#161b22`). A green edge appears only on the *live*
  element.
- **Elevation:** Expressed by lightness of surface, not shadow — three steps
  (canvas / panel / raised). Shadows exist only under true overlays (menus,
  dialogs): large-radius, near-black, no glow.
- **Texture & gradient policy:** No gradients, no glow, no scanlines (explicitly
  not a retro-CRT theme). Flat dark fills only; the only "light" is the green
  signal itself.

## 7. Motion & Feedback

- **Animation character:** Instrumental, with one sanctioned expressive beat — a
  slow green "live" pulse (opacity 0.7→1.0, ~1.6s loop) permitted **only** on
  active/running status indicators (the coal breathing). Everything else confirms
  causality and stops.
- **Duration & easing:** Micro-feedback 80–120ms ease-out; panel transitions
  160–200ms ease-in-out; nothing exceeds 220ms except the status pulse. No
  spring/bounce.
- **Interaction states:** Hover lifts a surface one step (no hue shift); active
  compresses 1px (translate); focus is a 2px green `#3fb950` outline, 2px offset;
  disabled drops to ~45% and removes the interactive border. State never rides on
  green alone — pair with surface lift or outline.

## 8. Component Inflections

- **Buttons:** Primary is a green `#3fb950` fill with near-black text `#010409`,
  4px radius — the one lit control. Secondary is a dark-border ghost on the panel
  tone; destructive uses the red error hue as a ghost that fills on hover. Green
  is reserved for *go/primary/live* — never a decorative fill.
- **Inputs:** Recessed one surface step *below* their panel (darker, "cut in"),
  dark border, 4px radius; focus swaps to the green outline. Mono is the default
  face for value/token inputs.
- **Cards / panels:** The workhorse — one surface step up from canvas, 4px radius,
  low dark border, 12–16px padding; a running panel carries a 2–3px green
  left-edge, not a tinted fill.
- **Navigation:** Sidebar on canvas (`#010409`), content on panel (`#0d1117`) —
  nav is "the rack," content is "the instrument." Active item: 500 weight + 2px
  green left-rail; no filled active background.
- **At base defaults (deliberately):** tables, toasts, breadcrumbs, and modal
  mechanics inherit `theme-style-guide` with the dark tokens applied; only
  palette, radius (4px), and the green-signal rule change their look.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum; body text targets AAA (7:1+) on the dark
  canvas, since long-session legibility is the promise.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. Soft-white `#e6edf3` on canvas
  `#010409` ≈ 16:1 (pass with margin). Green `#3fb950` on canvas ≈ 8:1 (safe as
  text). **Near-the-line pairs to verify:** in the *dimmed-slate* ("light") mode,
  muted text `#768390` on `#0d1117` ≈ **4.5:1 — exactly on the body floor**;
  don't darken that text or lighten that surface. Secondary text `#909dab` on
  canvas ≈ 6:1 (safe). Amber `#d29922` on canvas ≈ 7:1 (safe).
- **Focus visibility:** 2px solid green outline, 2px offset, on every focusable
  element; clears 3:1 against all three surface steps. Never removed.
- **Reduced motion:** `prefers-reduced-motion` disables the green status pulse
  (replaced by a static lit-green dot + label) and all transitions over 100ms;
  hover surface lifts survive as instant swaps.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Nocturne"; intent/perception/audience/tone verbatim; keywords: dark, terminal, signal, focus, mono; font-url: Inter + JetBrains Mono (Fira Code fallback) |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#e6edf3` (soft, never pure), black `#010409` (near-black canvas) |
| §3 accents | `style-guide.vars.yaml` Seed Colors | signal green `#3fb950`; cyan `#58a6ff`; amber `#d29922` |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#3fb950` (≡ signal — intentional), warning `#d29922`, error `#f85149`, info `#58a6ff` |
| §3 modes | `style-guide.color-modes.yaml` | BOTH dark: `light` = dimmed slate `#0d1117`; `dark` = `#010409`. No true paper mode — see §3 flag |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-sans `'Inter', -apple-system, sans-serif`; font-mono `'JetBrains Mono', 'Fira Code', 'Menlo', monospace`; mono-forward usage |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px; dense multi-panel; protect log/stream legibility |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `4px`; surface-step elevation ladder; overlay-only shadows, no glow |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 100ms`; green status-pulse keyframes + reduced-motion guard |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | green primary button, recessed inputs, green live-edge panels; leave listed components at base |
| §9 a11y | verification across facets | recheck dimmed-slate muted text (≈4.5:1 floor) and green-on-canvas after any seed change |
