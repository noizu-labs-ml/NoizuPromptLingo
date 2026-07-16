# Theme Conformance — npl-nocturne (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-nocturne.md`.

- **Treatise**: treatise-npl-nocturne.md @ rev 1 (status → full this pass)
- **Theme**: theme-npl-nocturne/ (6 files) · base chain: theme-npl-nocturne → theme-style-guide
- **Audited by / workflow**: Loom (Stage C, uplift pipeline) / tune-facets
- **Serve state**: legacy `generate-css` path (npx serve unavailable — public npm 404s
  on `@noizu/styleguide`); compiled CSS exit 0, no error/exception. Only base-theme
  (`[style-guide]`) ⚠ warnings present; none from npl-nocturne.

## Verdict

**CONFORMANT (with documented waivers + cautions)**

This was a substantive TUNE, not a cosmetic pass: the shipped theme was carrying two
silent, identity-breaking defects. (1) `style-guide.vars.yaml` set the accents under
the bare `red`/`blue`/`yellow` keys, which the base does not wire as accent-driving
seeds — so the phosphor-green signal was a **silent no-op** and every accent fell back
to the base Bauhaus red. (2) Even after renaming to `brand-*`, the base's dark cascade
re-points the brand tints from **literal Bauhaus hexes**, so a dark-native theme
reverted to red/navy in its *primary* mode. Both are now fixed and **verified in the
compiled CSS**: nocturne resolves `--brand-red` → `#3fb950` in light *and* dark, with
zero `#e20613` in the nocturne scope. Remaining open items are treatise-sanctioned
waivers (no true light mode; deliberately low-contrast borders) and legacy-path
verification limits (color-modes literal maps), not drift.

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action taken |
|------------|-------|-----------|-------------|--------------|
| meta : name/slug/title/description | NPL — Nocturne / npl-nocturne / … | §1 | conformant | kept |
| branding : intent/perception/audience/tone/keywords | verbatim §1 | §1 | conformant | kept (has logo-text + font-url) |
| vars : white | `#e6edf3` | §3 (soft off-white, never #fff) | conformant | kept |
| vars : black | `#010409` | §3 (near-black, never #000) | conformant | kept |
| vars : brand-red | `#3fb950` | §3 primary (green signal) | conformant | **renamed from `red`** (seed-trap) |
| vars : brand-red-light | `color-mix(--brand-red 70% …)` | §3 | conformant | **added** (base pinned old hex) |
| vars : brand-blue | `#58a6ff` | §3 secondary (link cyan) | conformant | **renamed from `blue`** |
| vars : brand-blue-light | `color-mix(--brand-blue 70% …)` | §3 | conformant | **added** |
| vars : brand-yellow | `#d29922` | §3 tertiary (amber, rare) | conformant | **renamed from `yellow`** |
| vars : brand-yellow-light | `color-mix(--brand-yellow 70% …)` | §3 | conformant | **added** |
| vars : success | `#3fb950` | §3 (success ≡ signal) | conformant | kept |
| vars : warning/error/info | `#d29922` / `#f85149` / `#58a6ff` | §3 semantics | conformant | kept |
| vars : font-sans / font-mono | Inter / JetBrains Mono | §4 | conformant | kept (matches branding font-url) |
| vars : radius | `4px` | §6 | conformant | kept |
| color-modes : light | dimmed slate `#0d1117` | §3 (no true light) | conformant | kept |
| color-modes : dark | canvas `#010409` | §3 | conformant | kept |
| color-modes : shadow-color | `rgba(1,4,9,.5/.6)` | §6 (overlay-only shadow) | conformant | **added** both modes |
| scoped-vars : dark brand-red/-light/-mid | `#3fb950` family | §3 (dark-leak fix) | conformant | **added file** |
| scoped-vars : dark brand-blue/-light/-mid | `#58a6ff` family | §3 | conformant | **added** |
| scoped-vars : dark success/-tint, info/-tint | green / cyan | §3 (semantics ≡ brands) | conformant | **added** |
| css-snippets : focus-motion | 2px green focus, 100/180ms, RM guard | §7/§9 | conformant | **added**, self-scoped |
| css-snippets : btn-primary | green fill, near-black label | §8 | conformant | **added** |
| css-snippets : input | recessed, mono-default, green focus | §8 | conformant | **added** |
| css-snippets : panel + live-edge | surface-step, no shadow, green left-edge | §6/§8 | conformant | **added** |
| css-snippets : nav-rail | rack/instrument, green left-rail | §8 | conformant | **added** |
| css-snippets : status-pulse | green 0.7→1.0 1.6s, RM→static | §7 | conformant | **added** |
| css-snippets : npl-token | mono ID pill, 2px | §4/§8 | conformant | **added** |
| css-snippets : log-stream | mono, 1.5, 80ch | §4/§5 | conformant | **added** |

## 2. Claim Coverage (treatise → YAML)

| § | Claim (condensed) | Status | Where encoded / rationale |
|---|-------------------|--------|---------------------------|
| §1 | Identity, mono-first intent | realized | branding.yaml, meta.yaml |
| §3 | Dark-native palette, never pure #000/#fff | realized | white/black seeds |
| §3 | Phosphor-green "live" signal | realized | brand-red #3fb950 (light + dark) |
| §3 | success ≡ signal green | realized | success=#3fb950 + dark re-point |
| §3 | Link cyan (navigational) | realized | brand-blue + info=#58a6ff |
| §3 | Amber rare (warning glow) | realized (dark tint on base cascade — caution) | brand-yellow/warning |
| §3 | No true light mode (dimmed slate) | realized / waived | both color-modes dark, by design |
| §4 | Mono co-equal voice | realized | font-mono seed + token/log/input mono snippets |
| §4 | Inter for UI | realized | font-sans seed |
| §5 | Dense multi-panel; protect log legibility | partial | log-stream 80ch snippet; base 8px inherited (no spacing facet) |
| §6 | 4px radius (2px small chips) | realized | radius seed + token 2px |
| §6 | Surface-step elevation, no resting shadow | realized | panel box-shadow:none; shadow-color overlay-only |
| §6 | No glow / gradient / scanlines | realized | absent in YAML; render negatives enforce |
| §7 | Motion 100/180ms; nothing >220ms | realized | focus-motion tokens |
| §7 | Green status pulse (only on running) | realized | status-pulse snippet |
| §7 | Focus 2px green 2px offset; hover lift; active 1px | realized | focus-motion + btn/panel |
| §8 | Green primary button, near-black label | realized | btn-primary |
| §8 | Recessed mono inputs | realized | input snippet |
| §8 | Cards/panels + green live-edge | realized | panel snippet |
| §8 | Nav rack/instrument, green left-rail | realized | nav snippet |
| §8 | Tables/toasts/breadcrumbs/modals at base | waived | inherit base with dark tokens (deliberate) |
| §9 | AA min, body AAA on dark | realized | see §4 contrast below |
| §9 | Focus never removed | realized | :focus-visible on every focusable |
| §9 | Reduced-motion disables pulse + >100ms | realized | RM guards in focus-motion + status-pulse |

## 3. Mode-Verification Matrix Results

| # | Check | Light (dimmed slate) | Dark (canvas) | RM / HC | Notes |
|---|-------|------|------|------|-------|
| 1 | Body text vs surface (AAA) | PASS ~14:1 | PASS ~16:1 | — | #e6edf3; resolves via white seed cascade |
| 2 | Secondary/muted ≥4.5 | PASS (muted #768390 ≈ **4.5:1, on floor**) | PASS (#909dab ≈6:1) | — | dimmed-muted is the near-line pair |
| 3 | Accent as text/UI ≥4.5 | PASS green ≈8:1, cyan ≈7:1 | PASS (green/cyan CSS-verified in dark) | — | hard signal confirmed from compiled CSS |
| 4 | Semantic not hue-alone | PASS | PASS | n/a | §7 state pairs surface-lift/outline, never green alone |
| 5 | Meaningful borders ≥3:1 | WAIVED | WAIVED | — | §6: elevation via surface steps, borders are quiet accents |
| 6 | Focus indicator ≥3:1 | PASS | PASS (green on raised ≈6.8:1) | PASS | 2px green, 2px offset |
| 7 | Mode distinctness | — | PASS (subtle: #010409 vs #0d1117) | — | both dark by design (§3) |
| 8 | Reduced-motion per §9 | — | — | PASS | pulse→static dot, transitions→instant |
| 9 | Exclusions sweep (no #000/#fff/glow/gradient) | PASS | PASS | — | canvas #010409, ink #e6edf3; no glow tokens |
| 10 | Validator (no ✗, ⚠ explained) | PASS | PASS | — | legacy exit 0; base ⚠ pre-existing, none from nocturne |

## 4. Contrast Measurements (near-the-line pairs)

| Pair | Mode | Required | Measured | Result |
|------|------|----------|----------|--------|
| #768390 muted on #0d1117 | dimmed "light" | 4.5:1 | ≈4.5:1 | PASS (on floor — caution) |
| #3fb950 green on #010409 | both | 4.5:1 (3:1 large) | ≈8.0:1 | PASS |
| #010409 label on #3fb950 button | — | 4.5:1 | ≈8.0:1 | PASS |
| #58a6ff cyan on #010409 | both | 4.5:1 | ≈7:1 | PASS |
| #d29922 amber on #010409 | both | 3:1 (large/icon) | ≈7:1 | PASS |
| #21262d border on #0d1117 | both | 3:1 (if boundary) | ≈1.4:1 | WAIVED (not the boundary mechanism) |

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale | Approved by |
|------|-----------------|-----------|-----------|-------------|
| No true light mode | §3 (honest flag) | both color-modes dark | Treatise-sanctioned: "meant to be lived in at night" | treatise author (self-declared) |
| Low-contrast borders (<3:1) | §6 | borders below 3:1 | §6: separation comes from surface-step ladder, not lines; borders are accents | treatise §6 |
| Dark brand-red kept flat `#3fb950` | §3/§8 | not brightened `75%,white` like base/Minimal | green is already dark-tuned (8:1); brightening washes the phosphor quality and drifts off the committed exact hex | Loom (documented) |

## 6. Standing Cautions

| Caution | Trigger to recheck |
|---------|--------------------|
| brand-yellow / warning / error dark tints left on base cascade (gold/amber/brick) | if amber or error moves onto heavy working chrome (currently rare / semantic-only) |
| color-modes literal light/dark maps unverifiable on legacy generate-css path | when `npx @noizu/styleguide serve` becomes available — confirm literal maps (surfaces resolve equivalently via white/black seed cascade meanwhile) |
| dimmed-slate muted #768390 on #0d1117 exactly on 4.5:1 floor | any change to that text or surface value |

## 7. Escalations to trl-user-experience-engineer / base-theme owner

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | Base `theme-style-guide/style-guide.scoped-vars.yaml` brightens dark brand tints from LITERAL `#e20613`/`#0047ab`/`#f5c518`, not `var(--brand-*)` — forces every non-Bauhaus theme to ship a scoped-vars dark re-point. Same defect tracked in conformance-npl-minimal §7. | base | open — worked around per-theme |
| 2 | Base pins `brand-*-light` seeds to `color-mix()` with the old literal Bauhaus hex, not `var(--brand-*)` — every theme must re-point its `-light` siblings. | base | open — worked around in vars.yaml |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| 2026-07-17 | tune-facets (Stage C) | Fixed seed-trap (bare→brand-* + -light), added dark-leak scoped-vars, css-snippets (8 self-scoped inflections), shadow-color; 6 render prompts. CSS-verified green in both modes. | CONFORMANT |
