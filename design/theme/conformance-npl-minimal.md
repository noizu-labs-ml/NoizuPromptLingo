# Theme Conformance — npl-minimal (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-minimal.md`.

- **Treatise**: treatise-npl-minimal.md @ rev 2 (status: full)
- **Theme**: theme-npl-minimal/ (6 files) · base chain: theme-npl-minimal → theme-style-guide
- **Audited by / workflow**: Loom Stage-C agent / tune-facets (uplift pilot 1)
- **Serve state**: legacy `generate-css` path only (public `@noizu/styleguide` 404s; `npx serve`
  unavailable). Generation clean (exit 0, no error/exception). Remaining `⚠` are benign and
  listed in §3 row 10. Literal dark color-modes maps are **not** serve-verified on this path.

## Verdict

**DRIFTED → remediated**

The theme carried a real, load-bearing drift: `style-guide.vars.yaml` pinned the sky accent on
the bare keys `red`/`blue`/`yellow`, which the base cascade does **not** wire as accent slots —
a silent no-op that left the working accent on the base's Bauhaus red `#e20613` in **both**
modes. Remediated this session by moving the accents onto the real `brand-red`/`brand-blue`/
`brand-yellow` slots (with `-light` siblings re-pointed to `var(--brand-*)`), and by adding a
`scoped-vars` delta that fixes a **second, deeper** dark-mode leak (the base brightens dark
brand tints from a literal `#e20613`, not `var(--brand-red)`). Post-fix the generated CSS shows
`--brand-red: #0284c7` in light and `--theme-brand-red: color-mix(#0284c7 75%, white)` in dark,
with **zero** `#e20613` anywhere in the `npl-minimal` scope. One treatise contrast figure was
found wrong (sky-on-white claimed ≈4.6:1, actually ≈4.1:1) and is handled via a darkened
primary-button fill + escalation (§7). Every treatise commitment is realized, waived, or
escalated; the YAML is correct.

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action taken |
|------------|-------|-----------|-------------|--------------|
| vars : white | `#ffffff` | §3 pure-white canvas | conformant | kept explicit |
| vars : black | `#0a0a0b` | §3 near-black ink, whisper cool | conformant | kept |
| vars : brand-red | `#0284c7` | §3/§8 primary accent = sky ~200° | conformant | **moved off bare `red` → `brand-red` (seed-trap fix)** |
| vars : brand-red-light | `color-mix(var(--brand-red) 70%, surface)` | §3 accent tint | conformant | re-pointed off base's literal-`#e20613` mix |
| vars : brand-blue | `#4f46e5` (indigo) | §3 secondary, reserved/off-chrome | conformant | moved off bare `blue`; `-light` re-pointed |
| vars : brand-yellow | `#0d9488` (teal) | §3 tertiary, reserved/off-chrome | conformant | moved off bare `yellow`; `-light` re-pointed |
| vars : success/warning/error/info | `#16a34a`/`#d97706`/`#dc2626`/`#0284c7` | §3/§9 standard semantics; error≠accent | conformant | kept (correct keys already) |
| vars : font-sans / font-mono | Inter / JetBrains Mono | §4 | conformant | kept; matches branding font-url |
| vars : radius | `6px` | §6 soft-default | conformant | kept |
| scoped-vars : brand-red[-light/-mid] (dark) | `color-mix(#0284c7 …)` | §3 dark = same theme, brighter accent | conformant | **new delta — overrides base dark #e20613 leak** |
| color-modes : light/dark maps | white/gray + slate dark | §3 mode strategy | conformant | added surface/text-inverse + neutral shadow-color; dark text-muted → `#8b9099` (§4 fix) |
| branding : name | "NPL — Minimal" | §1 | conformant | aligned to sibling convention + §10 (was "NoizuPromptLingo") |
| css-snippets (5, self-scoped) | btn/card/token/table/focus | §6/§7/§8 | conformant | project-specific sample elements; self-scoped (no bleed) |

## 2. Claim Coverage (treatise → YAML)

| § | Claim (condensed) | Status | Where encoded / rationale |
|---|-------------------|--------|---------------------------|
| §1 | Identity: intent/perception/audience/tone/keywords | realized | branding.yaml verbatim |
| §3 | Monochrome + one sky accent; indigo/teal reserved off-chrome | realized | vars seeds; brand-blue/yellow set but unused on chrome |
| §3 | Pure-gray neutrals, no tint (light) | realized | white `#ffffff`, base `--gray-*` ramp |
| §3 | error(red) distinct from accent(sky) | realized | error `#dc2626` vs accent `#0284c7` |
| §3 | Soft gray hairline borders (~1.4:1), felt not seen | realized (waiver §5) | color-modes border = gray-200/300 |
| §3 | Dark = faithful cool-slate translation | realized | color-modes dark + scoped-vars dark accent |
| §4 | Inter UI/body, JetBrains Mono literals, no serif | realized | vars fonts; NPL-token snippet mono |
| §5 | 8px base, comfortable-efficient density | realized (inherited) | base spacing; admin-table snippet row height |
| §6 | 6px radius; hairline over shadow; flat, no gradient/glow | realized | radius seed; card snippet `box-shadow:none`; no gradient facets |
| §6 | One soft shadow on overlays only | realized | color-modes `shadow-color` (base overlays consume) |
| §7 | Micro 120ms / panel 180ms; sky focus ring; reduced-motion | realized | focus-motion snippet + reduced-motion guard |
| §8 | Sky primary button; hairline card; base tables/toasts/modals left alone | realized | btn/card snippets; rest inherited |
| §9 | WCAG 2.2 AA both modes; glyph-paired status; focus never removed | realized (see §3/§4) | seeds + snippets; status glyph-paired in render prompts |

## 3. Mode-Verification Matrix Results

Light = seed-cascade + generated-CSS verified. Dark = **reasoned from generated CSS tokens,
not serve-verified** (legacy path does not emit literal color-modes maps).

| # | Check | Light | Dark | HC / reduced-motion | Notes |
|---|-------|-------|------|---------------------|-------|
| 1 | Body text vs surface | PASS (~20.6:1) | PASS (~15:1) | n/a (no HC mode v1) | ink/#e8eaed |
| 2 | Secondary/muted text | PASS (sec ~10:1, muted ~4.6:1) | PASS (sec ~7:1, muted ~5.5:1) | — | dark muted fixed gray-500→`#8b9099` |
| 3 | Accent as text/UI | PASS large/UI (~4.1:1); button fill darkened | PASS (brightened sky ~6:1) | — | see §4 + Deviations |
| 4 | Semantic not hue-alone | PASS | (reasoned) | icon/glyph present | success/warning large+glyph only |
| 5 | Meaningful borders ≥3:1 | WAIVER (soft hairlines intentional) | WAIVER | — | §3 "felt not seen"; selection uses sky ≥3:1 |
| 6 | Focus indicator visible | PASS (~4.1:1 white, ~3.8:1 gray-50) | PASS (brighter) | never removed | sky ring, 2px offset |
| 7 | Mode distinctness | — | PASS | — | white canvas vs `#0f1115` slate |
| 8 | Reduced-motion | — | — | PASS | snippet transitions → none |
| 9 | Exclusions sweep (Bauhaus red, gradients) | PASS | PASS | — | 0×`#e20613` in npl-minimal scope; no gradient facets |
| 10 | Validator (no ✗, ⚠ explained) | PASS | PASS | — | 0 error/exception. ⚠: 4× css-snippet `target-section` not in page-sections (same benign class the base's own `card-glow` emits — placement metadata; CSS emits & verified present), 2× base-inherited jsx-snippet `demo` warnings, 1× `font-size-base` false-positive (token IS emitted, inherited from base) |

## 4. Contrast Measurements (near-the-line pairs)

| Pair | Mode | Required | Measured | Result |
|------|------|----------|----------|--------|
| sky `#0284c7` on white | light | 4.5 body / 3.0 large-UI | ≈ **4.1:1** | large-text/UI/border/focus only — **not** body (treatise's "≈4.6:1" is wrong) |
| white on primary button `#0369a1` | light | 4.5 | ≈ **5.9:1** | PASS — fill darkened one sky step for AA |
| white on button hover `#075985` | light | 4.5 | ≈ 7.5:1 | PASS |
| muted `#757575` on white | light | 4.5 | ≈ 4.6:1 | PASS (just clears) |
| error `#dc2626` on white | light | 4.5 | ≈ 4.8:1 | PASS (body-safe) |
| success `#16a34a` / warning `#d97706` on white | light | 3.0 large | ≈ 3.5 / 3.6:1 | large/icon only + glyph (never body) |
| muted `#8b9099` on `#0f1115` | dark | 4.5 | ≈ 5.5:1 | PASS (gray-500 would be ~4.1:1 — fixed) |
| brightened sky on `#0f1115` | dark | 4.5 | ≈ 6:1 | PASS (reasoned) |

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale | Approved by |
|------|-----------------|-----------|-----------|-------------|
| Soft gray hairlines ~1.4:1 | §3 contrast stance | below 3:1 for separators | intentional "felt not seen"; cards also carry tonal white→gray-50 separation; meaningful selection uses sky border ≥3:1 | treatise §3 self-authorizes |
| Sky accent large/UI-only on white | §9 (claims body) | not used for small body text on white | ≈4.1:1 < 4.5; button fill darkened to `#0369a1` for white-on-fill AA | this audit (+ escalation §7-1) |
| Reserved brand-blue/brand-yellow dark tints left on base cascade | §3 reserved accents | dark indigo/teal still brighten from base navy/gold literals | off-chrome (data-viz only), not on any working surface; low impact | this audit (Standing Caution) |

## 6. Standing Cautions

| Caution | Trigger to recheck |
|---------|--------------------|
| sky-on-white ≈4.1:1 (not body-safe) | any lightening of the accent or canvas; any new small-text-in-sky usage |
| primary-button fill `#0369a1` white-label AA | any change to button fill or label color |
| dark muted `#8b9099` ≈5.5:1 | any dark-surface or muted-text change (serve-verify when available) |
| reserved brand-blue/yellow dark = base navy/gold | if either is ever promoted onto chrome or data-viz |
| dark color-modes map unverified | re-run full matrix under `npx @noizu/styleguide serve` once available |

## 7. Escalations to trl-user-experience-engineer

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | Treatise states sky `#0284c7` on white ≈4.6:1; measured ≈**4.1:1** — it does NOT clear the 4.5 body floor. §9 wording implying it "clears body" should read "large-text / UI / border / focus only (≥3:1)." Handled in YAML via darkened button fill; treatise text still needs the figure corrected. | §3/§9 | open |
| 2 | **Base-cascade defect (affects ALL non-Bauhaus themes, incl. shipped theme-npl-prism):** `theme-style-guide/style-guide.scoped-vars.yaml` brightens dark `brand-red/-blue/-yellow` from **literal** `#e20613`/`#0047ab`/gold instead of `var(--brand-*)`, so every theme's accent silently reverts to Bauhaus red/navy in dark mode. Worked around here per-theme via a `scoped-vars` override; the durable fix belongs in the base file. | engine | open |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| 2026-07-17 | tune-facets | Fixed seed-trap (light + dark accent → sky); added self-scoped css-snippets, scoped-vars dark fix, color-modes inverse/shadow tokens + dark-muted; corrected primary-button AA; amended treatise rev 2 (render-calibration). | DRIFTED → remediated |
