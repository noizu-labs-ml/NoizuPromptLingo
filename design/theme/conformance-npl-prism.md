# Theme Conformance — npl-prism (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-prism.md`.

- **Treatise**: treatise-npl-prism.md @ rev 2 (render + contrast validated, 2026-07-17)
- **Theme**: theme-npl-prism/ (5 files) · base chain: theme-npl-prism → theme-style-guide
- **Audited by / workflow**: Loom tasker (project-uplift Stage C, pilot 1) / extract-seeds + tune-facets
- **Serve state**: legacy `generate-css` path (npx `@noizu/styleguide serve` unavailable in this env). `npm run generate-css` exit 0, **no error/exception**. All ⚠ warnings are base-scoped or benign target-section notices (see §3 row 10).

## Verdict

**CONFORMANT** (with documented standing cautions)

The five-file delta faithfully realizes the prism treatise: the controlled violet→cyan→fuchsia spectrum, cool near-white/indigo-charcoal neutrals, pinned flat semantics, Sora/JetBrains type, 16px radius, and the signature frosted-glass + gradient-CTA + spectrum-mesh inflections are all encoded as seeds + accumulating css-snippets and compile cleanly into the generated CSS. All six Stage-C renders read as unmistakably prism (34/47 premium-grade). The single most important accessibility check — white text on the gradient CTA across its whole sweep — **passes** (5.70:1 at the violet start, 5.36:1 at the darkened-cyan terminal) because the cyan terminal is intentionally darkened to `#0e7490` (raw brand-blue `#06b6d4` fails at 2.43:1, exactly as the treatise §9 predicted). Standing cautions cover three treatise-consistent design choices (decorative sub-3:1 glass-edge borders; bright success/warning fills that rely on ink-text chips + icon/label; and the legacy generate-css path not emitting the authored per-mode color maps).

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action taken |
|------------|-------|-----------|-------------|--------------|
| vars : white | `#f7f8ff` | §3 neutrals | conformant | cool near-white canvas seed |
| vars : black | `#1a1730` | §3 neutrals | conformant | indigo-charcoal ink seed (tints whole gray ramp cool) |
| vars : brand-red | `#7c3aed` | §3 primary | conformant | PRIMARY accent slot = spectrum violet |
| vars : brand-red-light | `color-mix(var(--brand-red)…)` | §3 derivation | conformant | re-pointed to seed (base pinned it to literal `#e20613` — trap avoided) |
| vars : brand-blue | `#06b6d4` | §3 secondary | conformant | SECONDARY slot = spectrum cyan |
| vars : brand-blue-light | `color-mix(var(--brand-blue)…)` | §3 derivation | conformant | re-pointed to seed |
| vars : brand-yellow | `#d946ef` | §3 tertiary | conformant | TERTIARY slot = spectrum fuchsia |
| vars : brand-yellow-light | `color-mix(var(--brand-yellow)…)` | §3 derivation | conformant | re-pointed to seed |
| vars : success/warning/error/info | `#10b981` / `#f59e0b` / `#f43f5e` / `#3b82f6` | §3 semantics (rev2) | conformant | pinned literal to break base aliases so violet can't swallow status |
| vars : font-sans | `'Sora', -apple-system, …` | §4 | conformant | matches branding.yaml font-url |
| vars : font-mono | `'JetBrains Mono', 'Menlo', …` | §4 | conformant | generated content + IDs |
| vars : radius | `16px` | §6 | conformant | generous/premium |
| color-modes : light/dark | full maps | §3 modes | conformant (authored); **not emitted by legacy path** (Caution 4) | real light + dark maps authored per template |
| css-snippets : prism-btn-gradient | violet→`#0e7490` | §8 + §9 | conformant | signature CTA; AA-safe across sweep |
| css-snippets : prism-glass | 78% fill + blur + gradient edge | §6 + §9 | conformant | ≥70% fill keeps body ≥4.5:1; reduced-transparency fallback |
| css-snippets : prism-text-gradient | violet→fuchsia clip | §4 + §8 | conformant | display-only |
| css-snippets : prism-mesh | violet/cyan/fuchsia radial mesh | §3 + §6 | conformant | the luminous field |
| css-snippets : prism-focus | 2px violet ring | §7 + §9 | conformant | on solid backing |
| branding.yaml : intent/perception/audience/tone/keywords/font-url | verbatim §1 | §1 | conformant | mirrors treatise §1 |

## 2. Claim Coverage (treatise → YAML)

| § | Claim (condensed) | Status | Where encoded / rationale |
|---|-------------------|--------|---------------------------|
| §1 | Identity (vibrant/luminous/spectrum/premium/glass) | realized | branding.yaml + meta |
| §3 | Controlled violet→cyan→fuchsia spectrum | realized | brand-red/blue/yellow seeds |
| §3 | Cool neutrals (canvas #f7f8ff, ink #1a1730) | realized | white/black seeds |
| §3 | Semantics flat, opaque, pinned | realized | Semantic seeds (literal) |
| §3 | Light primary / dark = designed translation | realized (authored); partially unrealized via legacy path | color-modes.yaml authored; generate-css emits seed-derived modes (Caution 4) |
| §4 | Sora + JetBrains Mono; gradient text ≥28px | realized | seeds + prism-text-gradient |
| §4 | Expressive ~1.333 scale | **waived** | typography.yaml intentionally not authored (Deviation 1) |
| §5 | 8px base, marketing-airy | realized (inherit) | base spacing cascade |
| §6 | 16px radius | realized | seed |
| §6 | Frosted glass, backdrop-blur, gradient edge, violet shadow | realized | prism-glass |
| §6 | Gradient policy (one axis, glass/CTA/display only) | realized | snippets + conventions |
| §7 | Micro 140ms; reduced-motion guard | realized (core) | button/glass transitions + reduced-motion media query (hero gradient-drift animation left to frontend) |
| §8 | Gradient primary button | realized | prism-btn-gradient |
| §8 | Glass secondary / cards | realized | prism-glass |
| §8 | Data grids opt out of glass (solid) | realized (convention) | snippet note; render-verified (47/46/29 tables solid) |
| §9 | White-on-gradient AA across sweep | realized | darkened `#0e7490` terminal; measured 5.36:1 |
| §9 | Glass ≥70% fill behind text | realized | prism-glass 78% fill |
| §9 | 2px violet focus ring, solid backing | realized | prism-focus |
| §9 | Semantic chips carry ink text; never color-alone | realized (convention) | treatise §9 rev2 + measured 4.7–8.1:1 ink-on-fill |
| §9 | prefers-reduced-transparency fallback | realized | prism-glass fallback |

## 3. Mode-Verification Matrix Results

| # | Check | Light | Dark | HC / reduced-motion | Notes |
|---|-------|-------|------|---------------------|-------|
| 1 | Body text vs surface (≥4.5:1) | PASS 16.4:1 | PASS ~15:1 | — | ink `#1a1730` on `#f7f8ff`; light text on deep-indigo dark |
| 2 | Secondary/muted text (≥4.5:1) | PASS 9.8 / 6.4:1 | PASS 10.8 / 6.6:1 | — | designed-value measurements |
| 3 | Accent as text/UI (≥4.5:1 / ≥3:1 large) | PASS 5.38:1 | PASS 3.25:1 (large-UI) | — | violet; dark large-UI only (Caution 3) |
| 4 | Semantic classes text-on-fill; not hue-alone | PASS | PASS | not color-alone | ink-on-fill 4.7–8.1:1; icon+label mandatory |
| 5 | Meaningful borders (≥3:1) | N/A by design | N/A by design | — | decorative glass-edges (§6); separation via fill+shadow+focus (Deviation 3 / Caution 2) |
| 6 | Focus indicator (visible, ≥3:1) | PASS | PASS | required | 2px violet ring, 5.38:1, solid backing |
| 7 | Mode distinctness | — | PASS | — | cool near-white vs deep indigo — genuinely distinct |
| 8 | Reduced-motion / reduced-transparency per §9 | — | — | PASS | media-query guards in prism-btn-gradient + prism-glass |
| 9 | Treatise exclusions sweep (no neon-void, no gradient body/semantics) | PASS | PASS | — | gradients confined to CTA/glass-edge/display; semantics flat |
| 10 | Validator (no error/exception; ⚠ explained) | PASS | PASS | — | generate-css exit 0; ⚠ = base-wide font-size-base fallback (all 5 themes) + target-section notices mirroring base card-glow — cosmetic, CSS still emits |

## 4. Contrast Measurements (near-the-line pairs)

| Pair | Mode | Required | Measured | Result |
|------|------|----------|----------|--------|
| white on gradient CTA — violet start `#7c3aed` | light | 4.5:1 | 5.70:1 | PASS |
| white on gradient CTA — darkened cyan end `#0e7490` | light | 4.5:1 | 5.36:1 | PASS |
| white on RAW cyan `#06b6d4` (why terminal darkened) | light | 4.5:1 | 2.43:1 | (rejected — rationale) |
| violet accent `#7c3aed` as link text | light | 4.5:1 | 5.38:1 | PASS |
| violet accent `#7c3aed` large-UI on dark surface | dark | 3.0:1 | 3.25:1 | PASS (large-UI) |
| ink `#1a1730` on success `#10b981` chip | light | 4.5:1 | 6.85:1 | PASS |
| ink `#1a1730` on warning `#f59e0b` chip | light | 4.5:1 | 8.09:1 | PASS |
| ink `#1a1730` on error `#f43f5e` chip | light | 4.5:1 | 4.73:1 | PASS |
| ink `#1a1730` on info `#3b82f6` chip | light | 4.5:1 | 4.72:1 | PASS |
| success/warning fill vs canvas (bare shape) | light | 3.0:1 | 2.39 / 2.03:1 | below (Caution 1 — never sole signal) |
| text-muted `#5b567e` vs canvas | light | 4.5:1 | 6.44:1 | PASS |
| muted `#9a94c6` vs designed dark surface | dark | 4.5:1 | 6.55:1 | PASS |

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale | Approved by |
|------|-----------------|-----------|-----------|-------------|
| typography.yaml not authored | §4 expressive ~1.333 scale | Inherit base type scale | typography.yaml is a **wholesale-replace** facet — a partial override would drop the base's 11 typography-classes. Sora is carried by the font-sans seed; gradient display via prism-text-gradient snippet. Expressive scale can ride base font-size-* tokens. | Loom tasker (pilot) |
| design-sections / page-sections not overridden | plan "project-specific sample sections" | Express prism's per-surface inflections via css-snippets instead | Both section files are wholesale-replace; a minimal NPL override would nuke all base sections. css-snippets **accumulate**, so prism's gradient button / glass card / mesh live there safely. | Loom tasker (pilot) |
| color-modes literal maps not emitted | §3 dark = designed translation | Legacy generate-css resolves modes via seed cascade, not the authored per-mode hexes | Verified path-wide: **no** theme's color-modes-only literal reaches the CSS (nocturne's `#0d1117` etc. also absent). The authored map is kept for the npx serve path when it returns. | Loom tasker (pilot) |

## 6. Standing Cautions

| Caution | Trigger to recheck |
|---------|--------------------|
| 1. Bright success `#10b981` / warning `#f59e0b` fills are <3:1 vs the light canvas as bare shapes | If ever used as a standalone canvas icon/dot with no label — must pair icon **and** label; chips already carry ink text (AA). Consider a darker `-strong` semantic token if standalone use appears. |
| 2. Borders are decorative glass-edges (<3:1) | If a form-field rest state must rely on the border alone as its boundary — add a dedicated ≥3:1 field-border token (~`#8f8caf` light). |
| 3. Dark-mode violet accent ~3:1 (large-UI only) | On any change to the `black` seed or when accents are used as dark-mode body text (needs brightening then). |
| 4. Authored color-modes map is not verified by the legacy path | Re-run the mode matrix against real rendered surfaces once npx `@noizu/styleguide serve` is available. |

## 7. Escalations to trl-user-experience-engineer

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | Confirm whether success/warning need a darker standalone-icon token, or whether the chip-fill + icon + label convention (currently documented) is sufficient. | §9 | open, non-blocking |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| 2026-07-17 | extract-seeds + tune-facets (Stage C pilot 1) | Authored 5-file delta from treatise rev2; rendered 6/6 screens (7 API calls); amended treatise to rev2/full from render+contrast evidence; verified via generate-css (exit 0) + WCAG matrix | CONFORMANT (with 4 standing cautions) |
