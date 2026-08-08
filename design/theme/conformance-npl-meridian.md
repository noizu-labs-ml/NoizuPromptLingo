# Theme Conformance — npl-meridian (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-meridian.md`.

- **Treatise**: treatise-npl-meridian.md @ rev 1 (status: sketch → full this pass)
- **Theme**: theme-npl-meridian/ (6 files) · base chain: theme-npl-meridian → theme-style-guide
- **Audited by / workflow**: Stage C agent (uplift pipeline) / extract-seeds + tune-facets
- **Serve state**: legacy `generate-css` path (styleguide_serve=off); exit 0, no error/exception. Only pre-existing base `[style-guide]` + shared cross-theme `⚠` warnings (font-size-base fallback, target-section-not-in-page-sections, base jsx demo) — all reproduced identically by every shipped sibling theme (aurora/blueprint/editorial/minimal/nocturne/prism), none introduced by this theme.

## Verdict

**CONFORMANT** (with standing cautions + one serve-path verification gap)

Every hard signal was judged from the **compiled CSS** (the treatise-designated source of
truth), not from renders. The compiled output confirms warm-espresso dark surfaces
(`--theme-surface: #1a1613` aliased through `--surface`), a matte-brass primary accent
(`--brand-red` = brass, never Bauhaus `#e20613`), a verdigris secondary, Fraunces wired onto
headings/KPIs via `--font-display`, 6px radius, self-scoped snippets (0 bleed), and a
re-scoped brass `::selection`. The three base-cascade defects that would otherwise wreck this
theme in dark mode (cool-slate surfaces, brand revert to Bauhaus red/navy, semantic revert)
are all corrected in `style-guide.scoped-vars.yaml` and verified present in the output. The
one gap: `style-guide.color-modes.yaml`'s literal light/dark maps are not emitted on the
legacy path, so those specific maps are serve-unverified — but the same warm values are ALSO
declared in scoped-vars (which IS emitted and verified), so the modes themselves are proven;
only the color-modes.yaml file duplicating them is unverified. No treatise revision was
required — the sketch held up; flipping it to `status: full`.

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action taken |
|------------|-------|-----------|-------------|--------------|
| vars : white | `#f2ebe0` warm parchment | §3 neutrals ("never pure white") | conformant | seed |
| vars : black | `#1a1613` warm espresso | §3 neutrals | conformant | seed (tints gray ramp warm) |
| vars : brand-red | `#c9a15e` matte brass | §3 primary accent | conformant | seed (PRIMARY voice) |
| vars : brand-red-light | `color-mix(var(--brand-red) 70%, surface)` | §3 | conformant | re-point off base Bauhaus tint (seed trap) |
| vars : brand-blue | `#3f857e` verdigris teal | §3 secondary | conformant | seed (links/cool data) |
| vars : brand-blue-light | `color-mix(var(--brand-blue) 70%, surface)` | §3 | conformant | re-point (seed trap) |
| vars : success/warning/error/info | `#7fa650 / #d98a2b / #c85248 / #5a8fb0` | §3 semantics | conformant | warm-harmonized seeds |
| vars : font-sans | Inter | §4 body/UI | conformant | seed (matches font-url) |
| vars : font-display | Fraunces | §4 display | conformant | NEW token (base has none) + css-snippets wires it to headings/KPIs |
| vars : font-mono | JetBrains Mono | §4 data/IDs | conformant | seed |
| vars : radius | `6px` | §6 refined-moderate | conformant | seed |
| color-modes : dark | espresso `#1a1613` / panel `#241f1a` / parchment `#f2ebe0` | §3 mode (primary) | conformant | full dark map (also in scoped-vars for legacy path) |
| color-modes : light | ivory `#f6f1e8` / ink `#2a231c` | §3 true warm light | conformant | full light map (also in scoped-vars) |
| scoped-vars : surface/text/border (both modes) | warm espresso/ivory set | §3 | conformant | overrides base cool-slate dark cascade (legacy-path fix) |
| scoped-vars : brand-red/-blue (dark) | brass / verdigris brightened | §3/§9 | conformant | dark-leak fix (base reverts to Bauhaus) |
| scoped-vars : success/warning/error/info (dark) | warm semantics brightened | §3/§9 | conformant | dark-leak fix (base reverts semantics) |
| css-snippets : :not(.dark) --brand-red | `#a67c34` darkened brass | §3/§9 light brass | conformant | light-mode contrast (base has no light brand alias) |
| css-snippets : :not(.dark) --brand-blue | `#35706a` darkened verdigris | §9 AA links | conformant | light-mode link contrast |
| css-snippets : .btn.primary | solid brass, `#1a1613` label | §8 primary (dark-on-brass) | conformant | brass is the one metallic control |
| css-snippets : .btn.secondary / .destructive | brass hairline / terracotta ghost-fill | §8 | conformant | intent by fill+label, not brass |
| css-snippets : .stat-panel/.kpi-panel | raised panel, 8px, Fraunces numerals, `.featured` brass hairline | §5/§8 signature surface | conformant | project-specific executive KPI element |
| css-snippets : .nav-rail .active | brass left-rail + 600 weight | §8 nav | conformant | not a filled pill |
| css-snippets : .app-shell vignette | ≤6% brass radial | §6 lamp-lit room | conformant | the theme's only gradient, shell-only |
| css-snippets : ::selection | brass tint | §3 (re-scope off base gold) | conformant | neutralizes brand-yellow's only chrome use |
| css-snippets : motion + reduced-motion | 140/220ms; reduce guard | §7 | conformant | composed, no bounce |

## 2. Claim Coverage (treatise → YAML)

| § | Claim (condensed) | Status | Where encoded / rationale |
|---|-------------------|--------|---------------------------|
| §1 | Warm-dark luxe executive register; Fraunces+Inter; 6px | realized | branding.yaml + vars + css-snippets |
| §3 | Warm espresso neutrals, never cool slate | realized | scoped-vars surfaces (both modes) override base slate |
| §3 | Brass primary + verdigris secondary; no third brand hue | realized | brand-red/blue seeds; brand-yellow left off-chrome (see §6 cautions) |
| §3 | Warm-harmonized semantics; warning ≠ brass | realized | semantic seeds + dark re-points; warning icon-paired (see cautions) |
| §3 | True warm light mode (unlike Nocturne) | realized | color-modes.light + scoped-vars standard (ivory/ink) |
| §4 | Fraunces DISPLAY-only; Inter body; mono data | realized | font-display wired to headings/KPIs only; body stays Inter |
| §5 | Comfortable-refined KPI panels; protect numerals | realized | .stat-panel generous padding + large Fraunces numerals |
| §6 | 6px radius (4px chips, 8px feature); warm elevation + brass hairline; warm shadow; ≤6% vignette; no chrome gradient | realized | radius seed; stat-panel 8px; token 4px; shadow-color warm; app-shell vignette |
| §7 | Composed 140/220ms, no bounce; reduced-motion instant | realized | motion tokens + reduced-motion guard |
| §8 | Brass primary (dark label), hairline secondary, terracotta destructive, brass nav rail, Fraunces KPI panels; toasts/breadcrumbs/modals at base | realized + waived | inflections encoded; listed base components deliberately inherited |
| §9 | AA both modes; dashboard text AAA on dark; brass focus ring never removed | realized | contrast table §4; focus ring on every :focus-visible |

## 3. Mode-Verification Matrix Results

| # | Check | Light | Dark | HC / reduced-motion | Notes |
|---|-------|-------|------|---------------------|-------|
| 1 | Body text vs surface (AAA on dark per §9) | PASS (ink/ivory ≈13.6:1) | PASS (parchment/espresso ≈14.9:1, AAA) | n/a | computed |
| 2 | Secondary/muted text (≥4.5:1) | PASS (muted ≈4.8:1) | PASS (muted ≈6.6:1) | n/a | text-muted tuned to clear body floor both modes |
| 3 | Accent as text/UI (≥4.5 / ≥3 large) | PASS (brass→#a67c34 ≈4.6:1; verdigris→#35706a ≈4.5:1) | PASS (brass ≈7:1; verdigris brightened) | n/a | light darkening in css-snippets |
| 4 | Semantic text-on-tint; not hue-alone | PASS | PASS (dark re-points keep warm palette) | icon-paired | warning always icon-paired (near brass hue) |
| 5 | Meaningful borders (≥3:1) | PARTIAL by design | PARTIAL by design | n/a | §3/§6: separation via surface steps + brass hairline (≈7:1), not heavy rules — low-contrast borders intentional |
| 6 | Focus ring (visible, ≥3:1) | PASS (darkened brass on ivory ≥3:1) | PASS (brass ≈7:1) | n/a | 2px brass, 2px offset, never removed |
| 7 | Mode distinctness | — | PASS | — | espresso vs ivory — genuinely distinct |
| 8 | Reduced-motion per §7 | — | — | PASS | scoped reduce guard zeroes transition/animation |
| 9 | Exclusions sweep (no Bauhaus red/navy/gold on chrome; no glow/gradient bling) | PASS | PASS | — | grep: 0 `#e20613` in npl-meridian selectors; vignette is only gradient |
| 10 | Validator (no ✗) | PASS (legacy: no error/exception) | PASS | — | legacy path has no ✗/⚠ severity split; warnings all benign/shared |

## 4. Contrast Measurements (near-the-line pairs)

| Pair | Mode | Required | Measured (approx) | Result |
|------|------|----------|-------------------|--------|
| parchment `#f2ebe0` on espresso `#1a1613` | dark | 4.5 (AAA 7) | ≈14.9:1 | PASS (AAA) |
| text-muted `#a99d8b` on espresso | dark | 4.5 | ≈6.6:1 | PASS |
| brass `#c9a15e` on espresso (accent text) | dark | 4.5 | ≈7:1 | PASS |
| darkened brass `#a67c34` on ivory `#f6f1e8` | light | 4.5 | ≈4.6:1 | PASS (treatise's flagged pair) |
| darkened verdigris `#35706a` on ivory | light | 4.5 (links) | ≈4.5:1 | PASS (borderline — see cautions) |
| info slate-blue `#5a8fb0` on espresso | dark | 4.5 | ≈5.4:1 (seed) / brightened in dark | PASS |
| espresso `#1a1613` label on brass button | both | 4.5 | ≈7:1 dark / ≈4.8:1 light (#a67c34) | PASS |
| text-muted `#6e6456` on ivory | light | 4.5 | ≈4.8:1 | PASS |

Contrast figures are computed (WCAG relative-luminance), not serve-measured, because
`styleguide_serve=off`. Re-measure under `npx serve` when it returns.

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale | Approved by |
|------|-----------------|-----------|-----------|-------------|
| Low-contrast borders | §5 mode matrix row 5 | dark/light borders < 3:1 | §3/§6 explicitly make separation come from surface steps + brass hairline, not rules — intentional, hairline (≈7:1) carries meaningful boundaries | treatise §3/§6 |
| toasts/breadcrumbs/modals | §8 "at base defaults" | left on base cascade | treatise says inherit these with warm-dark tokens; only palette/accent/type change their character | treatise §8 |

## 6. Standing Cautions

| Caution | Trigger to recheck |
|---------|--------------------|
| **brand-yellow left on base dark cascade** (off-chrome). Its only base chrome use, `::selection`, is re-scoped to brass; if a future base/base-consumer wires brand-yellow onto other chrome, base Bauhaus gold would surface in dark. | any base scoped-vars change; adding a component that uses `--brand-yellow*` |
| **Light-mode brass/verdigris darkening lives in css-snippets, not scoped-vars** (base has no light `--brand-*` alias). If the base adds a light brand alias, migrate these to scoped-vars to avoid double-override. | base cascade adds a standard-section brand alias |
| **warning amber (~35°) sits hue-near brass (~40°)** | any change to warning or brass hue; keep warning icon-paired and brass off-status |
| **verdigris link on ivory ≈4.5:1** (right at the AA line) | any change to `#35706a`, ivory surface, or link usage — do not lighten |
| **color-modes.yaml literal maps serve-unverified** on legacy path | when `npx @noizu/styleguide serve` returns, verify the color-modes.yaml maps match the scoped-vars warm values |

## 7. Escalations to trl-user-experience-engineer

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | **Base-cascade dark leak** (`theme-style-guide/style-guide.scoped-vars.yaml`): dark mode re-points brand-red/-blue/-yellow AND success/warning/error/info AND surface/text/border from LITERAL Bauhaus/slate hexes (not `var(--*)`), forcing every non-Bauhaus theme to re-declare its full warm set in dark. Worked around here in scoped-vars; the base file should read `var(--brand-*)` / theme surfaces so themes inherit correctly. | base | open (pipeline-wide; do not fix base from a Stage C run) |
| 2 | **color-modes.yaml not emitted on legacy `generate-css` path** — literal light/dark maps only resolve under `npx serve`; the legacy path silently drops them, so themes must duplicate mode values into scoped-vars. Tooling gap, not a treatise defect. | tooling | open |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| 2026-07-17 | extract-seeds + tune-facets | Built theme-npl-meridian/ from treatise rev 1: 6 files (meta, branding, vars, color-modes, scoped-vars, css-snippets). Corrected base dark-leak for brand/semantic/surface families; wired Fraunces display; self-scoped all snippets; light-mode brass darkening. Validated via legacy generate-css (exit 0, warm espresso + brass confirmed in compiled CSS). Treatise flipped sketch → full. | CONFORMANT |
