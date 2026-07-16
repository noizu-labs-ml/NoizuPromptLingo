# Theme Conformance — npl-brutalist (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-brutalist.md`.

- **Treatise**: treatise-npl-brutalist.md @ rev 2 (status: full)
- **Theme**: theme-npl-brutalist/ (6 files) · base chain: theme-npl-brutalist → theme-style-guide
- **Audited by / workflow**: Stage C agent (uplift) / tune-facets + render-reflect
- **Serve state**: legacy `generate-css` path (public `@noizu/styleguide` 404s; `styleguide_serve` off). `generate-css` exit 0, **zero error/exception**; surviving `⚠` are target-section notices, all explained in §3/§5 below. The npx `✗`/`⚠` severity split is unavailable on this path.

## Verdict

**DRIFTED → remediated** (one open escalation, mitigated in YAML)

The **incoming shipped theme was silently drifted**: its `style-guide.vars.yaml` set bare
`red`/`blue`/`yellow` keys, which the base never wires as accent-driving keys, so every
`--brand-*`-driven surface was painting the base **Bauhaus** palette
(`#e20613`/`#0047ab`/`#f5c518`), not the treatise's electric triad — in **both** modes. This
pass re-pointed the accents onto the base's real keys (`brand-red`/`brand-blue`/`brand-yellow`
+ their `-light` siblings) and fixed a **second, dark-only** trap (the engine re-derives
`--theme-brand-*` from the old hex in `.dark`) via a scoped-vars override. Both fixes are
**verified in the generated CSS**, light and dark. The theme now realizes the treatise.
One treatise defect surfaced by the mode matrix — §9's claim that the ultramarine focus ring
"exceeds 3:1 against both canvases" is inaccurate for pure black (~2.48:1) — is **mitigated**
in dark mode with a white hairline co-signal (treatise §7's own "never rides on hue alone"
principle) and **escalated** to trl-user-experience-engineer for a §9 wording correction (§7).

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action |
|---|---|---|---|---|
| vars : brand-red / -light | `#ff2d00` / `color-mix(var(--brand-red) 70%, surface)` | §3 primary accent | conformant | **fixed seed trap** (was no-op bare `red`) |
| vars : brand-blue / -light | `#1500ff` / `color-mix(var(--brand-blue) 70%, surface)` | §3 secondary / focus | conformant | fixed seed trap |
| vars : brand-yellow / -light | `#ffe600` / `color-mix(var(--brand-yellow) 70%, surface)` | §3 tertiary | conformant | fixed seed trap |
| vars : red/blue/yellow | `var(--brand-*)` aliases | §10 appendix names | conformant | kept as raw handles, re-pointed off hex |
| vars : success/warning/error/info | `#00c853 / #ffe600 / #ff2d00 / #1500ff` | §3 collision flag, §9 | conformant | error≡red seed kept (not desaturated) |
| vars : font-sans / font-mono | Space Grotesk / Space Mono | §4 | conformant | matches branding.yaml font-url |
| vars : font-size-base | `var(--size-md)` | §4 | conformant | re-asserted to clear a fallback ⚠ |
| vars : radius | `0px` | §6 | conformant | — |
| color-modes : light/dark (+inverse, shadow-color) | pure #fff/#000 mirror, solid shadow | §3, §6 | conformant (literal map **unverified on legacy path** — see §5) | completed missing inverse/shadow keys |
| scoped-vars : .dark theme-brand-* | electric triad | §3 dark = hard mirror | conformant | **fixed dark-only seed trap**; verified |
| css-snippets : brut-surfaces/buttons/inputs/tables-nav | 0 radius, 2px hard border, hard-offset block shadow, invert/press | §6, §7, §8 | conformant | accumulating, self-scoped |
| css-snippets : brut-focus-motion | 3px ultramarine outline + dark white co-signal; 80ms linear; reduced-motion guard | §7, §9 | conformant (co-signal added) | see §5/§9 |
| css-snippets : brut-npl-samples | .glyph-cell, .npl-token | §5, §8 | conformant | project-specific sample elements |
| css-snippets : brut-headings | uppercase 700, mono eyebrows | §4 | conformant | — |

## 2. Claim Coverage (treatise → YAML)

| § | Claim | Status | Where / rationale |
|---|-------|--------|-------------------|
| §1 | Intent/perception/audience/tone/keywords | realized | branding.yaml (unchanged, mirrors §1) |
| §3 | Electric RYB triad at full chroma, both modes | realized | vars + scoped-vars; verified light **and** dark |
| §3 | error ≡ brand-red (collision, not desaturated) | realized | vars semantic + brand-red both `#ff2d00` |
| §3 | Pure untinted neutrals | realized | color-modes (literal map unverified on legacy path) |
| §4 | Space Grotesk UPPERCASE 700 headings; Space Mono | realized | vars + brut-headings; **rendered reliably** (strongest tell) |
| §5 | Dense grid, hard dividers | realized (structure) | brut-tables-nav 1px grid; glyph-cell density |
| §6 | radius 0 everywhere; hard borders; hard-offset block shadow only; no gradient/glow/soft shadow | realized | radius seed + brut-surfaces/buttons (blurred elevation flattened) |
| §7 | Invert hover, press-translate, 3px ultramarine focus, reduced-motion, disabled keeps border | realized | brut-buttons + brut-focus-motion |
| §8 | Buttons/inputs/cards/nav/tables inflections | realized | css-snippets set |
| §9 | AA min; near-line pairs respected; focus ≥3:1 both canvases | **partially — see §4/§5** | dark focus ring ~2.48:1 on black → co-signal added; §9 wording escalated |

## 3. Mode-Verification Matrix Results

| # | Check | Light | Dark | HC / reduced-motion | Notes |
|---|-------|-------|------|---------------------|-------|
| 1 | Body text vs surface | PASS 21:1 | PASS 21:1 | AAA | pure #000/#fff mirror |
| 2 | Secondary/muted text | PASS ~7.4:1 (#4d4d4d) | PASS ~9:1 (#b3b3b3) | pass | — |
| 3 | Accent as text/UI | PASS (ultramarine 5.6:1 text; vermilion 3.5:1 large/UI) | mixed (see §4) | — | yellow fill-only on light |
| 4 | Semantic not hue-alone | PASS | PASS | co-signal via label + hard border (§3 collision) | error≡red carried by label/position |
| 5 | Meaningful borders ≥3:1 | PASS (#000 21:1) | PASS (#fff 21:1) | pass | full-strength borders |
| 6 | Focus indicator | PASS (ultramarine/white 8.5:1) | **PASS via co-signal** (raw ring 2.48:1 → +1px white hairline 21:1) | visible | treatise §9 wording escalated |
| 7 | Mode distinctness | — | PASS | — | hard mirror, genuinely distinct |
| 8 | Reduced motion | — | — | PASS | `prefers-reduced-motion` guard disables transitions + press-translate |
| 9 | Treatise exclusions sweep | PASS | PASS | — | no gradient/glow/soft-shadow authored; blurred base elevation flattened; **no old Bauhaus hex in npl-brutalist scope** (grep-verified) |
| 10 | Validator | PASS | PASS | — | generate-css exit 0, 0 error/exception; ⚠ = benign target-section (base's own snippets trigger identical) |

## 4. Contrast Measurements (near-the-line pairs)

| Pair | Mode | Required | Measured | Result |
|------|------|----------|----------|--------|
| hazard yellow `#ffe600` on white | light | 4.5:1 text | ~1.1:1 | **fill/highlight only — never text on light** (treatise §9); honored |
| vermilion `#ff2d00` on white | light | 3:1 large/UI | ~3.5:1 | large text & UI borders only; honored |
| ultramarine `#1500ff` on white | light | 4.5:1 | ~8.5:1 (treatise said 5.6) | safe for text |
| ultramarine `#1500ff` on black (focus ring) | dark | 3:1 focus | **~2.48:1** | **below 3:1** → mitigated with white hairline co-signal (21:1); §9 wording escalated |
| success green `#00c853` on white | light | 3:1 | ~2.0:1 | icon/fill only, not text on light; honored |
| hazard yellow `#ffe600` on black | dark | 4.5:1 | ~19:1 | safe as text/fill on dark |
| vermilion `#ff2d00` on black | dark | 4.5:1 | ~5.9:1 | safe as text/large/fill on dark |

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale |
|------|-----------------|-----------|-----------|
| color-modes literal dark map | §3 dark mirror | **unverified** on legacy path | `generate-css` does not emit color-modes.yaml literal light/dark maps (only the white/black seed cascade resolves modes — documented template limitation). Seed cascade gives the same intent since white=#fff/black=#000 are pure; full verification needs the unavailable `npx serve` path. |
| dark focus white hairline | §7 "3px ultramarine outline" | added a 1px white `box-shadow` co-signal in dark only | Realizes §9 focus-visibility (raw ring is 2.48:1 on black) via §7's own "never rides on hue alone" mandate; ultramarine remains the primary ring. |
| css-snippets target-section ⚠ | — | 6 snippets target sections not in page-sections | Benign: CSS still generates and applies; only affects showcase demo placement. The **base theme's own** `card-glow`/demo snippets emit identical ⚠. No page-section id exists that avoids it. |

## 6. Standing Cautions

| Caution | Trigger to recheck |
|---------|--------------------|
| Re-check both light **and** dark brand resolution after ANY seed change | the base re-derives `--theme-brand-*` from OLD hex in `.dark`; a light-scope override alone silently reverts dark to lightened Bauhaus |
| Any NEW use of raw `var(--brand-blue)` as text/thin-line on dark | ultramarine on pure black is ~2.48:1 — needs brightening or a co-signal (base brightens brand-blue *text* at component level via color-mix, but raw uses do not) |
| yellow-as-text on light; vermilion-as-body on light; success-green-as-text on light | all fail on light — fill/large/UI only |
| color-modes dark map correctness | unverifiable until `npx @noizu/styleguide serve` is available; re-verify then |

## 7. Escalations to trl-user-experience-engineer

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | §9 claims the ultramarine focus ring "exceeds 3:1 against both canvases" — inaccurate for pure black (measured ~2.48:1). Mitigated with a dark-mode white hairline co-signal; treatise wording should be corrected (or the dark focus treatment blessed). | §9 | open — mitigated in YAML |
| 2 | §3 "no muting in dark, full chroma" vs §9 "ultramarine safe for text" conflict on pure black: raw ultramarine text/thin-lines are ~2.48:1 on black. Theme uses ultramarine chiefly as **fill** (fine) + co-signaled focus; UXE should confirm ultramarine is fill/large-only in dark, or bless a brighter dark ultramarine for text roles. | §3/§9 | open |
| 3 | §10 Facet Mapping Appendix names accents `red`/`blue`/`yellow`, but the engine drives accents off `brand-red`/`brand-blue`/`brand-yellow`. Appendix should be corrected to prevent the seed trap recurring. | §10 | open |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| 2026-07-17 | tune-facets + render-reflect | Fixed light+dark seed trap (electric triad now drives accents, verified in CSS); completed color-modes; added css-snippets (§6/§7/§8) + scoped-vars (dark brand) + project-specific samples; rendered 6 screens, reflected (renders drift to rounded/soft SaaS — model prior, not treatise defect); treatise → rev 2 / status full. | DRIFTED → remediated (1 escalation mitigated) |
