# Theme Conformance — npl-aurora (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-aurora.md`.

- **Treatise**: treatise-npl-aurora.md @ rev 2 (status: full)
- **Theme**: theme-npl-aurora/ (6 files) · base chain: theme-npl-aurora → theme-style-guide
- **Audited by / workflow**: Loom Stage-C agent / new-theme build-from-treatise (uplift pilot 1)
- **Serve state**: legacy `generate-css` path only (public `@noizu/styleguide` 404s; `npx serve`
  unavailable). Generation clean (exit 0, no error/exception). Remaining `⚠` are benign and
  base-inherited (listed in §3 row 10). Literal dark color-modes maps are **not** serve-verified
  on this path.

## Verdict

**CONFORMANT**

Aurora was built fresh from a sound treatise (the set's only soft-elevation / warm-rounded
direction). Every non-inherited value traces to a treatise clause. The two accent slots the
base gets wrong for non-Bauhaus themes are handled proactively: seeds sit on the real
`brand-red`/`brand-blue`/`brand-yellow` slots (not the bare `red`/`blue`/`yellow` no-op keys),
`-light` siblings re-point to `var(--brand-*)`, and a `scoped-vars` delta re-points the dark
brand tints for all three families so the accents stay violet/coral/gold in dark mode instead
of reverting to Bauhaus red/navy/gold. Compiled CSS confirms `--brand-red: #6b4de6` (light) and
`--theme-brand-red: color-mix(#6b4de6 75%, white)` (dark) with **zero** `#e20613`/`#0047ab`/
`#f5c518` anywhere in the `npl-aurora` scope. The one accessibility subtlety — the lightened
dark violet carries white at only ~3.4:1 — is resolved by swapping the dark primary-button label
to plum-ink (~4.8:1). Renders confirmed the soft signals; 3 of 5 screens rendered (06, 44
render-deferred under a shared image-API 429, prompts authored). Dark color-modes literal maps
are unverifiable on the legacy path (Standing Caution).

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action taken |
|------------|-------|-----------|-------------|--------------|
| vars : white | `#fff9f4` | §3 warm cream canvas | conformant | warm seed carries the tint (not neutralized) |
| vars : black | `#37303a` | §3 warm plum-charcoal ink | conformant | never pure `#000` |
| vars : brand-red | `#6b4de6` | §3/§8 primary = grape violet ~255° | conformant | on real `brand-red` slot (seed-trap avoided) |
| vars : brand-red-light | `color-mix(var(--brand-red) 70%, surface)` | §3 accent tint | conformant | re-pointed off base's literal-`#e20613` mix |
| vars : brand-blue | `#f4776b` (coral) | §3 decorative accent, fill/illustration only | conformant | moved off bare `blue`; `-light` re-pointed; never status |
| vars : brand-yellow | `#f2b054` (gold) | §3 decorative accent, fill/illustration only | conformant | moved off bare `yellow`; `-light` re-pointed |
| vars : success/warning/error/info | `#2fa980`/`#e8952f`/`#e23d51`/`#5b8def` | §3/§9 soft semantics; error deeper than coral, icon-paired | conformant | kept; error `#e23d51` saturated/deeper vs decorative coral `#f4776b` |
| vars : font-sans / font-mono | Nunito / JetBrains Mono | §4 rounded humanist; mono for literals only | conformant | matches branding `font-url` |
| vars : radius | `14px` | §6 softest radius in the set | conformant | pills handled per-component in css-snippets |
| scoped-vars : brand-red/-blue/-yellow[-light/-mid] (dark) | `color-mix(#6b4de6/#f4776b/#f2b054 …)` | §3 dark = warm translation, violet lightened to `#8f78f2` | conformant | **new delta — overrides base dark literal leak for all 3 chrome families** |
| color-modes : light | cream/plum-ink + warm neutrals + warm shadow-color | §3 light = design home | conformant | surface `#fff9f4`, alt `#fdf3ea`, warm text ramp, `rgba(120,80,90,0.10)` |
| color-modes : dark | plum-charcoal `#221d29` + warm near-white + deep shadow | §3 dark = cozy plum, not cold slate | conformant (dark reasoned, not serve-verified) | surface `#221d29`, alt `#2c2634`, deeper shadow for float |
| css-snippets (6, self-scoped) | card / btn / aurora-wash / input / nav / focus | §6/§7/§8 | conformant | project-specific sample elements; every selector scoped under `html[data-design-theme="npl-aurora"]` (incl. `.dark` + `@media`) — no bleed |
| branding : name | "NPL — Aurora" | §1 | conformant | §1 intent/perception/audience/tone verbatim; keywords warm/soft/welcoming/rounded/humane |
| meta : slug/base-theme | `npl-aurora` / `theme-style-guide` | §1 | conformant | slug = dir suffix |

## 2. Claim Coverage (treatise → YAML)

| § | Claim (condensed) | Status | Where encoded / rationale |
|---|-------------------|--------|---------------------------|
| §1 | Identity: intent/perception/audience/tone/keywords | realized | branding.yaml verbatim |
| §3 | Warm cream canvas + one violet primary; coral/gold decorative (never status) | realized | vars seeds; coral/gold used only in aurora-wash + decorative btn |
| §3 | Warm-tinted neutrals (never Minimal's pure gray) | realized | white `#fff9f4`, plum-ink `#37303a`, warm text ramp |
| §3 | error deeper/saturated + icon-paired vs decorative coral (watch-pair) | realized | error `#e23d51` vs coral `#f4776b`; §9 render prompts glyph-pair status |
| §3 | Dark = cozy warm plum translation, violet lightened, warm-glow shadows | realized (reasoned) | color-modes dark + scoped-vars dark accent + deep shadow-color |
| §4 | Nunito rounded humanist all UI/body; JetBrains Mono literals only; no serif | realized | vars fonts; branding font-url loads both |
| §5 | 8px base, airy; single focused task per viewport | realized (inherited) | base spacing; card padding 24px in snippet; render prompts airy |
| §6 | 14px radius, pills the norm, borderless, **resting soft shadows** (signature) | realized | radius seed; 3-step warm shadow card snippet; 999px pills; borderless |
| §6 | One sanctioned aurora wash (coral→gold→violet, ≤12% alpha, empty states only) | realized | `.aurora-wash` snippet at 12% color-mix; usage discipline documented |
| §7 | Micro 140ms / card 240ms soft-ease; violet focus ring 3px offset; reduced-motion | realized | snippet timings + `cubic-bezier(.22,.61,.36,1)`; reduced-motion guards |
| §8 | Pill violet primary, soft-tint secondary, coral decorative; soft-shadow cards; pill nav; data grids left at base | realized | btn/card/nav snippets; tables inherit base (§8 deliberate) |
| §9 | WCAG 2.2 AA both modes; onboarding AAA; coral/gold fill-only; focus never removed | realized (see §3/§4) | seeds + snippets; ink-on-cream ≈12:1 (AAA); focus ring baseline snippet |

## 3. Mode-Verification Matrix Results

Light = seed-cascade + generated-CSS verified. Dark = **reasoned from generated-CSS tokens,
not serve-verified** (legacy path does not emit literal color-modes maps).

| # | Check | Light | Dark | HC / reduced-motion | Notes |
|---|-------|-------|------|---------------------|-------|
| 1 | Body text vs surface | PASS (~12:1 AAA) | PASS (~14:1) | n/a (no HC mode v1) | ink `#37303a`/cream; `#f4ecf3`/plum |
| 2 | Secondary/muted text | PASS (sec ~8.5:1, muted ~5.0:1) | PASS (sec ~9:1, muted ~5.3:1) | — | warm plum-grays |
| 3 | Accent as text/UI | PASS (violet on cream ~5.2:1 — body-safe) | PASS (lightened violet ~4.8:1) | — | white-on-violet button ~5.5:1 light; ink label in dark |
| 4 | Semantic not hue-alone | PASS (large/icon + glyph) | (reasoned) | glyph present | success/warning/error large/icon only; §3 watch-pair coral≠error |
| 5 | Meaningful borders ≥3:1 | WAIVER (soft warm hairlines intentional) | WAIVER | — | §3/§6 shadow-does-separating; focus ring ≥3:1 carries meaning |
| 6 | Focus indicator visible | PASS (violet ring 3px offset, ~5.2:1 on cream) | PASS (lightened violet) | never removed | btn/input/baseline focus snippets |
| 7 | Mode distinctness | — | PASS | — | cream `#fff9f4` vs warm plum `#221d29` |
| 8 | Reduced-motion | — | — | PASS | card/btn/input snippets → transitions collapse; wash never animates |
| 9 | Exclusions sweep (Bauhaus red/navy/gold, gradients on chrome, serif) | PASS | PASS | — | 0×`#e20613`/`#0047ab`/`#f5c518` in npl-aurora scope; only sanctioned wash gradient; no serif |
| 10 | Validator (no ✗, ⚠ explained) | PASS | PASS | — | exit 0, 0 error/exception. ⚠: base-inherited only (base `card-glow` cards-target, 2× base jsx `demo`, 2× empty base HUI vars-groups) — none from aurora files |

## 4. Contrast Measurements (near-the-line pairs)

| Pair | Mode | Required | Measured | Result |
|------|------|----------|----------|--------|
| ink `#37303a` on cream `#fff9f4` | light | 4.5 body / 7 AAA | ≈ **12:1** | PASS (AAA — onboarding target) |
| text-secondary `#4f4757` on cream | light | 4.5 | ≈ 8.5:1 | PASS |
| text-muted `#726879` on cream | light | 4.5 | ≈ 5.0:1 | PASS (body-safe) |
| violet `#6b4de6` as text on cream | light | 4.5 body / 3 large-UI | ≈ **5.2:1** | PASS — body-safe (unlike Minimal's sky ~4.1) |
| white on violet button `#6b4de6` | light | 4.5 | ≈ 5.5:1 | PASS (label AA) |
| error `#e23d51` on cream | light | 3.0 large | ≈ 4.0:1 | large-UI / icon + glyph only (NOT body) |
| info `#5b8def` on cream | light | 3.0 large | ≈ 3.3:1 | large-UI only |
| success `#2fa980` / warning `#e8952f` on cream | light | 3.0 large | ≈ 2.8 / 2.6:1 | fill/icon + glyph only (never body/large-text) |
| plum-ink `#221d29` on lightened violet `#9079ec` | dark | 4.5 | ≈ **4.8:1** | PASS — why the dark primary-button label is ink, not white |
| plum-ink `#37303a` on coral `#f4776b` | light | 4.5 | ≈ 4.7:1 | PASS (decorative accent-button label AA) |
| text `#f4ecf3` on plum `#221d29` | dark | 4.5 | ≈ 14:1 | PASS |
| muted `#9a8ea6` on plum `#221d29` | dark | 4.5 | ≈ 5.3:1 | PASS (reasoned) |
| lightened violet accent-text `#9079ec` on plum | dark | 4.5 | ≈ 4.8:1 | PASS (reasoned) |

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale | Approved by |
|------|-----------------|-----------|-----------|-------------|
| Soft warm hairlines below 3:1 | §3/§6 contrast stance | separators not ≥3:1 | intentional "borders barely exist, shadow does the separating"; cards carry tonal + shadow separation; meaningful boundaries use the violet focus ring ≥3:1 | treatise §6 self-authorizes |
| Dark primary-button label = plum-ink (not white) | §8 "white text" default | white swapped to ink in dark only | lightened dark violet `#9079ec` carries white at only ~3.4:1; ink clears ~4.8:1 (AA) | this audit |
| Semantics large-UI/icon + glyph only | §9 | not used for small body text | success/warning/info/error < 4.5 on cream; §3/§9 keep them fill/icon + glyph, body uses ink | treatise §3/§9 |

## 6. Standing Cautions

Re-check these after ANY seed or color-mode change.

| Caution | Trigger to recheck |
|---------|--------------------|
| Dark color-modes literal maps unverified | re-run full matrix under `npx @noizu/styleguide serve` once available |
| Dark primary-button ink label depends on lightened-violet fill | any change to `brand-red` dark value or primary-button fill/label |
| error `#e23d51` ≈4.0:1 on cream (not body) | any lightening of the canvas or new small-text-in-error usage |
| Base `.btn` primary (raw base markup, not `.btn-pill`) | if base primary buttons render in dark without the `.primary` label-swap selector, white-on-lightened-violet ~3.4:1 — the theme ships its own pill buttons, but recheck if base button markup is used directly |
| coral/gold as fill-only | if either is ever promoted to status or small text (coral ~2.6:1, gold ~1.9:1 on cream) |
| 06 / 44 renders deferred | re-run `generate-media-prompt` when image-API traffic clears |

## 7. Escalations to trl-user-experience-engineer

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | **Base-cascade defect (affects ALL non-Bauhaus themes):** `theme-style-guide/style-guide.scoped-vars.yaml` brightens dark `brand-red/-blue/-yellow` from **literal** `#e20613`/`#0047ab`/`#f5c518` instead of `var(--brand-*)`, so every theme's accents silently revert to Bauhaus red/navy/gold in dark mode. Worked around here per-theme via a `scoped-vars` override (all 3 families); the durable fix belongs in the base file. Same escalation as conformance-npl-minimal §7 / conformance-npl-prism. | engine | open |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| 2026-07-17 | new-theme (build from treatise) | Built theme-npl-aurora fresh (6 files) from treatise rev 1: violet/coral/gold on real brand slots (`-light` re-pointed), scoped-vars dark fix for all 3 chrome families, 6 self-scoped css-snippets (card/btn/aurora-wash/input/nav/focus), color-modes light+dark. Verified compiled CSS: `--brand-red #6b4de6`, dark re-points present, 0× Bauhaus leak. generate-css clean (exit 0). 3/5 renders (06/44 deferred under shared 429). Amended treatise → rev 2 / status full (render calibration). | CONFORMANT |
