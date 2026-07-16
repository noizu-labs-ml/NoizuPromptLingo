---
slug: npl-aurora
base_theme: theme-style-guide
status: sketch
revision: 1
---

# Theme Treatise — NPL Aurora

Theme: `theme-npl-aurora/` · Base: `theme-style-guide` · Status: sketch

> New direction (authored forward: intent first, values follow). Aurora is the
> *soft-elevation* theme — the only one in the NPL set that uses rounded shapes,
> resting drop-shadows, and warm approachability as its whole thesis.

## 1. Identity

- **Intent:** Make NPL feel *welcoming* — a warm, soft, rounded surface for the
  humans who supervise agents rather than live in a terminal. Where the shipped
  themes optimize for expert density, Aurora optimizes for arrival: onboarding,
  invitations, first-run, and the marketing funnel.
- **Perception:** Friendly, calm, unintimidating within five seconds — "this is
  going to be okay." Soft light, gentle depth, nothing sharp.
- **Audience:** The Evaluating Newcomer and the human supervisor (Delivery Lead
  in her "invite the team / set things up" moments) — people who have *not* used
  NPL before and must not feel they've walked into a hacker tool.
- **Tone:** Warm, plain-spoken, encouraging. Explains before it demands.
- **Keywords:** warm, soft, welcoming, rounded, humane
- **Variant note:** Inherits `theme-style-guide` structure and 8px spacing scale.
  Deltas: a **warm cream palette**, **humanist rounded type (Nunito)**, the set's
  **highest radius (14px + pills)**, and — uniquely — **resting soft shadows** as
  the elevation model. One sentence: **the base's structure re-skinned as a warm,
  rounded, softly-lit welcome mat.**

## 2. References & Anchors

- **Anchor — friendly onboarding products (Duolingo, Notion's lighter surfaces,
  Headspace):** borrow the rounded cards, soft shadows, generous whitespace, and
  warm illustration-friendly neutrals that read as "approachable," not "childish."
- **Anchor — warm humanist type systems:** borrow Nunito's rounded terminals and
  high x-height — letterforms that feel spoken, not engineered.
- **Anchor — a warm sunrise/aurora gradient sensibility (restrained):** borrow the
  *palette temperature* — corals, warm golds, soft violets — without literal
  gradients on chrome (see §6).
- **Anti-reference — the Brutalist sibling:** reject every hard edge — no `0`
  radius, no full-strength borders, no shouting caps. Aurora's structure is soft
  shadow and tone, never a hard rule.
- **Anti-reference — the Nocturne/terminal register:** reject dark-nativeness and
  mono-first density; Aurora is light, airy, and sans-led. Mono appears only where
  a literal token truly must (API keys, glyphs).
- **Anti-reference — saccharine "cute" UI (heavy mascots, bubblegum saturation):**
  reject candy over-saturation and infantilizing roundness; Aurora is warm and
  *adult* — muted-warm, not neon-pastel.

## 3. Color Story

- **Temperature & register:** Warm and gently saturated. A cream canvas with
  coral/gold warmth and a soft violet counterpoint; everything is a step softer
  than a "web default."
- **Hue relationships:** Warm-led with a cool anchor. Interactive primary is a
  soft grape violet `#6b4de6` (~255°); the *warmth* comes from decorative accents
  — coral `#f4776b` (~7°) and warm gold `#f2b054` (~38°) — used as soft fills and
  illustration, not as status.
- **Neutral strategy:** Warm-tinted, low. Canvas cream `#fff9f4` (~30° at very low
  saturation), warm charcoal ink `#37303a` (a plum-tinged near-black, never pure
  `#000`), warm-gray secondary text. The tint is what separates Aurora from
  Minimal's pure gray — do not neutralize it.
- **Semantic mapping:** Soft but unambiguous — `success` mint-green `#2fa980`,
  `warning` amber `#e8952f`, `error` rose-crimson `#e23d51`, `info` periwinkle
  `#5b8def`. **Watch-pair (designed, flagged):** `error` `#e23d51` sits hue-near
  the decorative coral `#f4776b`. Mitigation is deliberate: error is **deeper and
  more saturated**, is **always paired with an icon**, and coral is **never used
  for status** — coral is decoration only. Fine-tuner: keep that separation.
- **Contrast stance:** Soft for chrome, firm for text. Ink on cream ≈ 11:1
  (comfortable, not harsh 21:1 black); borders barely exist (shadow does the
  separating). Aurora is allowed to be gentle everywhere except body text and
  focus, which stay firm.
- **Mode strategy:** Light is primary and the design home. Dark mode is a *cozy*
  translation — a warm plum-charcoal `#221d29` canvas (not a cold slate), same
  violet primary lightened to `#8f78f2` for contrast, shadows softened to warm
  glows. No high-contrast mode in v1; light clears AA and `forced-colors` falls
  back to system.

## 4. Typographic Voice

- **Families:** **Nunito** (rounded humanist sans) for all UI, body, and display —
  the rounded terminals *are* the friendliness. JetBrains Mono only for literal
  tokens (API keys, NPL glyphs, IDs). No serif. Fallbacks: `-apple-system,
  'Segoe UI', sans-serif` and `'Menlo', monospace`.
- **Scale character:** Gentle, generous scale ~1.25 — headings are clearly larger
  and friendly-round; the largest onboarding heading may reach ~2.5× body to feel
  welcoming.
- **Weight usage:** 400 body, 600 headings and emphasized labels, 700/800 for
  hero/welcome moments (Nunito's heavier weights read warm, not aggressive). Avoid
  thin weights — Aurora is soft, not delicate.
- **Rhythm:** Body line-height ~1.6 (roomy); measure ~64ch (short, reassuring
  lines); mono set at 1.5 and used sparingly. Never set mono for prose or nav.

## 5. Space & Density

- **Spacing philosophy:** 8px base, spent generously — Aurora is the airiest
  working theme. Cards float with 20–28px internal padding and 16–20px gaps;
  whitespace is a feature, not waste.
- **Density target:** Reference screen is Registration / Organization Picker — one
  focused task per viewport, a single centered card with room to breathe, ~1–3
  primary choices visible, never a dense grid.
- **Responsive stance:** On narrow widths Aurora stays single-column and generous;
  it compresses horizontal padding last and never trades away the rounded-card
  breathing room. It would rather stack than densify.

## 6. Shape & Surface

- **Radius language:** The softest in the set — **14px base** on cards/inputs,
  10px on small controls, **pills** on buttons/chips/badges/avatars, 20px maximum
  on hero cards. Aurora is the **only** NPL theme that uses pills as a norm.
- **Borders:** Mostly borderless. Separation is **soft shadow + warm tone step**
  (cream → `#fdf3ea`). A 1px warm hairline appears only on inputs at rest.
- **Elevation:** The signature — **resting soft drop-shadows.** Aurora is the only
  NPL theme with true elevation on non-overlay surfaces: three steps of soft,
  warm-tinted, low-alpha shadow (blur 8–24px, y-offset 2–8px, color
  `rgba(120,80,90,0.10)`), giving cards a gentle float. No hard-offset blocks.
- **Texture & gradient policy:** No gradients on chrome or text. One sanctioned
  decorative gradient: a soft aurora wash (coral→gold→violet, ≤12% alpha) allowed
  on empty states, the welcome hero, and illustration backdrops — never behind
  body text, never on a control.

## 7. Motion & Feedback

- **Animation character:** Gentle and reassuring — motion softens transitions and
  rewards actions (a subtle settle on card entrance), signalling "handled." Warmer
  and slightly slower than the expert themes.
- **Duration & easing:** Micro-feedback 120–160ms ease-out; card/panel transitions
  200–280ms with a soft ease (`cubic-bezier(.22,.61,.36,1)`); a gentle overshoot
  (≤4%) is permitted on primary confirmations only. Nothing exceeds 320ms.
- **Interaction states:** Hover lifts a card one shadow step and warms it slightly;
  active presses it back down (shadow shrinks); focus is a 2px violet `#6b4de6`
  ring at 3px offset (soft, rounded to match); disabled drops to ~50% and flattens
  the shadow. State pairs elevation + ring — never hue alone.

## 8. Component Inflections

- **Buttons:** Pill-shaped. Primary is a solid violet `#6b4de6` fill with white
  text and a soft shadow — the one saturated control. Secondary is a violet-tinted
  soft fill (low alpha) with violet text; coral appears only as a *decorative*
  accent button in marketing contexts, always with dark text. No hard edges.
- **Inputs:** 14px radius, warm hairline at rest, generous 12–16px padding; focus
  swaps to the violet ring and a faint violet-tinted fill. Labels are 600 Nunito
  above the field; helper text is warm and encouraging.
- **Cards:** The signature surface — 14px radius, no border, resting soft shadow,
  20–24px padding, cream-to-warm tonal fills. Featured cards get the aurora wash
  backdrop, not a hard accent bar.
- **Navigation:** Soft pill nav items; active item is a filled violet-tint pill
  with 600 weight. Top bar floats on a subtle shadow rather than a border.
- **At base defaults (deliberately):** tables and data-dense components inherit
  `theme-style-guide` — Aurora is *not* the theme for a 40-row grid, and doesn't
  pretend to be; those surfaces stay at base with only palette/radius softened.

## 9. Accessibility Commitments

- **WCAG target:** 2.2 AA minimum across both modes; onboarding copy targets AAA
  (7:1) because first-run comprehension is the whole point.
- **Contrast minimums:** 4.5:1 body / 3:1 large-UI. Ink `#37303a` on cream
  `#fff9f4` ≈ 11:1 (safe). White on violet primary `#6b4de6` ≈ 5.0:1 (safe for
  button labels). **Never-as-text-on-light (fill/large only):** coral `#f4776b`
  (≈2.6:1), gold `#f2b054` (≈1.9:1), and the aurora wash — decorative only; body
  and labels use ink. `info #5b8def` on cream ≈ 3.3:1 → large/UI only.
- **Focus visibility:** 2px solid violet ring, 3px offset, rounded to the control;
  clears 3:1 on cream and on the warm tone step. Never removed.
- **Reduced motion:** `prefers-reduced-motion` disables entrance settles and the
  confirmation overshoot; hover elevation becomes an instant shadow swap; the
  aurora wash never animates.

## 10. Facet Mapping Appendix

| Treatise section | Engine facet | Seed hints |
|---|---|---|
| §1 Identity | `branding.yaml` | name "NPL — Aurora"; intent/perception/audience/tone verbatim; keywords: warm, soft, welcoming, rounded, humane; font-url: Nunito + JetBrains Mono |
| §3 neutrals | `style-guide.vars.yaml` Seed Colors | white `#fff9f4` (warm cream), black `#37303a` (warm plum-charcoal) — warm seeds carry the tint |
| §3 accents | `style-guide.vars.yaml` Seed Colors | primary(interactive) violet `#6b4de6`; decorative coral `#f4776b`, gold `#f2b054` |
| §3 semantics | `style-guide.vars.yaml` Semantic | success `#2fa980`, warning `#e8952f`, error `#e23d51`, info `#5b8def` — keep error deeper/icon-paired vs decorative coral |
| §3 modes | `style-guide.color-modes.yaml` | light: surface `#fff9f4`, alt `#fdf3ea`; dark: surface `#221d29` (warm plum), primary `#8f78f2` |
| §4 type | `style-guide.vars.yaml` Typography + `style-guide.typography.yaml` | font-sans `'Nunito', -apple-system, sans-serif`; font-mono `'JetBrains Mono', 'Menlo', monospace`; ~1.25 scale |
| §5 space | `style-guide.vars.yaml` Layout + `style-guide.spacing.yaml` | inherit 8px; airy — 20–28px card padding, ~64ch measure |
| §6 shape | `style-guide.vars.yaml` radius + `style-guide.css-snippets.yaml` | radius `14px`, pills on buttons/chips; 3-step warm soft-shadow snippet; aurora-wash gradient snippet (empty states only) |
| §7 motion | `style-guide.css-snippets.yaml` / `style-guide.scoped-vars.yaml` | `--motion-micro: 140ms`, `--motion-card: 240ms` soft-ease; ≤4% overshoot on confirm; reduced-motion guard |
| §8 components | `style-guide.css-snippets.yaml` + `style-guide.semantic-classes.yaml` | pill violet primary, soft-fill secondary, shadow cards; leave data grids at base |
| §9 a11y | verification across facets | recheck white-on-violet (≈5:1); enforce coral/gold as fill-only; verify glass-free (no text on wash) |
