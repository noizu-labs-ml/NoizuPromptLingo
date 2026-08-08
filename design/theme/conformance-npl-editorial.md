# Theme Conformance — npl-editorial (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-editorial.md`.

- **Treatise**: treatise-npl-editorial.md @ rev 2 (render + contrast validated, 2026-07-17)
- **Theme**: theme-npl-editorial/ (5 files) · base chain: theme-npl-editorial → theme-style-guide
- **Audited by / workflow**: Loom tasker (project-uplift Stage C, pilot 1) / tune-facets (existing theme)
- **Serve state**: legacy `generate-css` path (npx `@noizu/styleguide serve` unavailable in this env). `npm run generate-css` exit 0, **no error/exception**. The legacy path has no `✗`/`⚠` severity nuance — only pass/fail on error/exception.

## Verdict

**CONFORMANT — light mode** (with documented standing cautions; dark-mode fidelity deferred to the npx path)

The five-file delta faithfully realizes the editorial treatise **in the theme's design-target light mode**: warm paper `#fbf8f1` / warm ink `#1c1917` neutrals, the muted claret / petrol / ochre print pigments, a serif in the sans slot (Source Serif 4), IBM Plex Mono for literals, 2px cut-paper radius, and the claret-primary-button / petrol-ghost / claret-top-rule-card / ToC-nav / permanent-underline / paper-grain inflections all compile cleanly into the generated CSS (self-scoped, non-bleeding). **This tuning fixed a live seed-trap bug**: the prior file pinned bare `red`/`blue`/`yellow` keys (silent no-ops in the base cascade), so the theme's accents were *not actually driving* — they are now on `brand-red`/`brand-blue`/`brand-yellow` with re-pointed `-light` siblings (verified `--brand-red: #9a2c3f` + `color-mix(... var(--brand-red) ...)` under the editorial scope). Every light-mode contrast pair clears its floor with margin except the intentionally-decorative warm hairlines and the muted-meta text, both treatise-sanctioned. **Two dark-mode gaps** are honestly unverifiable on the legacy path (see Deviation 3 / Caution 4): the authored warm dark color-map is not emitted, and the base's `.dark` block re-derives `--theme-brand-red` from the base literal `#e20613` rather than `var(--brand-red)`, so the dark accent would revert to base red on this path. Both require the (currently unavailable) npx serve path to verify; light is the treatise's stated design target and is conformant.

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action taken |
|------------|-------|-----------|-------------|--------------|
| vars : white | `#fbf8f1` | §3 neutrals | conformant | warm paper canvas seed (tints gray ramp warm) |
| vars : black | `#1c1917` | §3 neutrals | conformant | warm near-black ink seed |
| vars : brand-red | `#9a2c3f` | §3 primary | conformant | PRIMARY slot = claret; **seed-trap fixed** (was bare `red:`, a no-op) |
| vars : brand-red-light | `color-mix(var(--brand-red)…)` | §3 derivation | conformant | re-pointed to seed (base pinned it to literal `#e20613` — trap avoided) |
| vars : brand-blue | `#1d4e5f` | §3 secondary | conformant | SECONDARY slot = deep petrol (links/info) |
| vars : brand-blue-light | `color-mix(var(--brand-blue)…)` | §3 derivation | conformant | re-pointed to seed |
| vars : brand-yellow | `#b45309` | §3 tertiary | conformant | TERTIARY slot = burnt ochre (sparing highlight) |
| vars : brand-yellow-light | `color-mix(var(--brand-yellow)…)` | §3 derivation | conformant | re-pointed to seed |
| vars : success/warning/error/info | `#3f6212`/`#b45309`/`#9a2c3f`/`#1d4e5f` | §3 semantics | conformant (error≡claret) | harmonized to print pigments; error≡brand-red is a flagged deliberate collision (Deviation 4) |
| vars : font-sans | `'Source Serif 4', 'Iowan Old Style', Georgia, serif` | §4 | conformant | serif in the sans slot — the theme's whole thesis; matches branding.yaml font-url |
| vars : font-mono | `'IBM Plex Mono', 'Menlo', monospace` | §4 | conformant | literal tokens / NPL glyphs / IDs only |
| vars : radius | `2px` | §6 | conformant | near-square cut-paper edge |
| color-modes : light | full warm map | §3 modes | conformant (authored) | surface/alt/text/border warm map |
| color-modes : dark | full warm map | §3 modes | conformant (authored); **not emitted by legacy path** (Caution 4) | leather-bound warm dark authored per treatise §3 |
| css-snippets : editorial-btn-primary | claret fill, paper label, 2px | §8 + §9 | conformant | one saturated element; paper-on-claret 7.06:1 |
| css-snippets : editorial-btn-ghost | petrol hairline ghost | §8 | conformant | quiet secondary; petrol 8.58:1 |
| css-snippets : editorial-card-featured | surface-alt + claret top-rule | §8 + §6 | conformant | featured mark by rule, not tint; flat (no shadow) |
| css-snippets : editorial-nav-toc | claret left-rule + 600 weight | §8 | conformant | ToC active mark, not a filled pill |
| css-snippets : editorial-link-underline | permanent petrol underline + focus | §7 + §9 | conformant | underline never removed; 2px petrol focus |
| css-snippets : editorial-paper-grain | ≤3% SVG fractal-noise | §6 | conformant | self-contained data-URI grain on canvas only |
| css-snippets : npl-token-chip | mono chip on beige hairline | §4/§8 (project-specific) | conformant | NPL literal-token domain element |
| css-snippets : npl-spec-pullquote | surface-alt + claret top-rule, 68ch | §6/§8 (project-specific) | conformant | printed-spec convention block, reading measure |
| branding.yaml : intent/perception/audience/tone/keywords/font-url | verbatim §1 | §1 | conformant | mirrors treatise §1; Source Serif 4 + IBM Plex Mono |

## 2. Claim Coverage (treatise → YAML)

| § | Claim (condensed) | Status | Where encoded / rationale |
|---|-------------------|--------|---------------------------|
| §1 | Identity (spec/literate/craft/durable/considered) | realized | branding.yaml + meta |
| §3 | Warm-paper neutrals (paper `#fbf8f1`, ink `#1c1917`) | realized | white/black seeds |
| §3 | Muted triad claret/petrol/ochre, claret dominant | realized | brand-red/blue/yellow seeds (**trap fixed**) |
| §3 | Warm beige hairline borders | realized | color-modes border `#e3d9c6`/`#cdc0a8` + card snippets |
| §3 | Semantics harmonized; error≡claret collision | realized (flagged) | Semantic seeds; Deviation 4 |
| §3 | Light primary / dark = warm translation | realized light (authored dark); **dark unverified on legacy path** | color-modes.yaml; Caution 4 |
| §4 | Serif body/UI (Source Serif 4); mono for literals | realized | font-sans seed (serif in sans slot) + npl-token snippet |
| §4 | Tight ~1.2 editorial scale, opsz axis | **waived** | typography.yaml is wholesale-replace; scale rides base font-size tokens (Deviation 1) |
| §5 | 8px base, protected ~68ch reading measure | realized (inherit + snippet) | base spacing cascade + npl-spec-pullquote max-width 68ch |
| §6 | 2px near-square radius | realized | seed |
| §6 | Flat/tonal, no resting drop shadow | realized | card/button snippets `box-shadow: none` |
| §6 | ≤3% paper-grain canvas | realized | editorial-paper-grain snippet |
| §7 | Permanent link underline; 150–240ms motion; reduced-motion | realized | editorial-link-underline + reduced-motion guards |
| §7 | 2px petrol focus, 2px offset | realized | button + link focus-visible |
| §8 | Claret primary / petrol-ghost secondary | realized | editorial-btn-primary / -ghost |
| §8 | Claret top-rule featured card | realized | editorial-card-featured |
| §8 | ToC nav claret left-rule | realized | editorial-nav-toc |
| §8 | Tables/toasts/modals inherit base (warm palette only) | realized (inherit) | base cascade under editorial scope |
| §9 | Body AAA (≥7:1); 4.5:1 body / 3:1 large | realized (light) | ink-on-paper 16.5:1; see §4 measurements |
| §9 | ochre near-line, muted-text large-only, decorative borders | realized (flagged) | Cautions 1–3 |

## 3. Mode-Verification Matrix Results

| # | Check | Light | Dark | HC / reduced-motion | Notes |
|---|-------|-------|------|---------------------|-------|
| 1 | Body text vs surface (≥4.5:1; AAA committed) | PASS 16.49:1 | unverified (legacy) | — | warm ink `#1c1917` on paper `#fbf8f1`; AAA with margin |
| 2 | Secondary/muted text (≥4.5:1) | PASS 7.09 / **3.69** | unverified (legacy) | — | secondary passes; muted `#8a7f72` = 3.69:1 → large/meta only (Caution 1) |
| 3 | Accent as text/UI (≥4.5:1 / ≥3:1 large) | PASS claret 7.06 / petrol 8.58 / ochre 4.73 | unverified — base `.dark` reverts to `#e20613` (Caution 4) | — | ochre just over body floor (Caution 3) |
| 4 | Semantic classes; not hue-alone | PASS (error≡claret flagged) | unverified (legacy) | not color-alone | destructive must carry label/icon (Deviation 4) |
| 5 | Meaningful borders (≥3:1) | N/A by design 1.32 / 1.69:1 | unverified | — | warm hairlines decorative; separation via type+margin (Caution 2) |
| 6 | Focus indicator (visible, ≥3:1) | PASS 7.94:1 | unverified (legacy) | required | 2px petrol ring, 2px offset |
| 7 | Mode distinctness | — | unverified — authored warm dark not emitted by legacy path | — | light↔dark distinctness needs npx serve (Caution 4) |
| 8 | Reduced-motion behavior per §9 | — | — | PASS | reduced-motion guards on button + link transitions |
| 9 | Treatise exclusions sweep (no cold-white, no hard-black borders, no shouting caps, no web-blue links) | PASS | unverified | — | canvas warm; links petrol not web-blue; labels title-case; borders beige not black |
| 10 | Validator (no error/exception) | PASS | PASS | — | generate-css exit 0; legacy path has no ⚠ nuance |

## 4. Contrast Measurements (near-the-line pairs, light mode)

| Pair | Required | Measured | Result |
|------|----------|----------|--------|
| warm ink `#1c1917` on paper `#fbf8f1` (body) | 7.0:1 (AAA) | 16.49:1 | PASS |
| claret `#9a2c3f` on paper (primary/error text) | 4.5:1 | 7.06:1 | PASS |
| paper `#fbf8f1` on claret fill (button label) | 4.5:1 | 7.06:1 | PASS |
| petrol `#1d4e5f` on paper (links/info) | 4.5:1 | 8.58:1 | PASS |
| burnt ochre `#b45309` on paper (highlight) | 4.5:1 | 4.73:1 | PASS (near line — Caution 3) |
| moss `#3f6212` on paper (success) | 4.5:1 | 6.67:1 | PASS |
| secondary text `#5c534a` on paper | 4.5:1 | 7.09:1 | PASS |
| muted text `#8a7f72` on paper | 4.5:1 | 3.69:1 | below → large/meta only (Caution 1) |
| beige hairline `#e3d9c6` on paper (border) | 3.0:1 | 1.32:1 | decorative (Caution 2) |
| border-strong `#cdc0a8` on paper (section rule) | 3.0:1 | 1.69:1 | decorative (Caution 2) |
| focus ring petrol `#1d4e5f` on surface-alt `#f4efe4` | 3.0:1 | 7.94:1 | PASS |

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale | Approved by |
|------|-----------------|-----------|-----------|-------------|
| typography.yaml not authored | §4 tight ~1.2 scale + opsz | Inherit base type scale | typography.yaml is a **wholesale-replace** facet — a partial override drops the base's typography classes. Serif is carried by the font-sans seed; the ~1.2 scale can ride base font-size tokens. | Loom tasker (pilot) |
| design-sections / page-sections not overridden | plan "project-specific sample sections" | Express NPL sample elements via css-snippets | Both are wholesale-replace; a minimal override would nuke all base sections. css-snippets **accumulate**, so npl-token + npl-spec-pullquote live there safely, self-scoped. | Loom tasker (pilot) |
| color-modes literal maps + dark accent not emitted | §3 dark = warm translation | Legacy generate-css resolves modes via base seed cascade; base `.dark` re-derives `--theme-brand-red` from literal `#e20613`, not `var(--brand-red)` | Verified path-wide (prism found the same no-emit). Editorial additionally loses its dark **accent** to the base literal on this path. Authored map kept for the npx serve path; light mode (the design target) is correct. | Loom tasker (pilot) |
| error ≡ brand-red (claret) | §3 semantic collision | error and primary share the claret hue | Deliberate per treatise §3 — muted so the clash is gentle; destructive intent separated by label/icon, never hue alone. | treatise author (rev 1) |

## 6. Standing Cautions

| Caution | Trigger to recheck |
|---------|--------------------|
| 1. Muted text `#8a7f72` = 3.69:1 (below 4.5 body) | If ever used as body copy — it is large-text/meta only. Consider a darker muted token if body use appears. |
| 2. Warm hairlines `#e3d9c6` (1.32:1) / `#cdc0a8` (1.69:1) are decorative (<3:1) | If a form-field rest state must rely on the border alone as its boundary — add a dedicated ≥3:1 field-border token (~`#a9997e` on paper). |
| 3. Burnt ochre `#b45309` on paper = 4.73:1 (just over body floor) | On any lightening of the `white`/paper seed — ochre breaks the 4.5:1 body floor first; treat as large-text/UI by preference. |
| 4. Authored warm dark color-map + dark accent unverified on legacy path | Re-run the mode matrix under `npx @noizu/styleguide serve` when available; confirm dark surface = warm `#1c1917`/`#262220` and dark accent = claret, not base slate/`#e20613`. |
| 5. error ≡ claret (same hue as primary) | On any new destructive affordance — verify it carries a non-hue label/icon, not color alone. |

## 7. Escalations to trl-user-experience-engineer

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | Base `theme-style-guide` `.dark` color-mode block hard-codes `--theme-brand-red: color-mix(#e20613 …)` (base literal) instead of `var(--brand-red)` — every child theme's **dark** accent reverts to base red on the legacy path (light is fine via the seed). Same class as the `-light` seed trap, one layer down. Recommend the base read `var(--brand-*)` in its dark map. | §3 | open, non-blocking (base-theme defect, not a delta fix) |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| (pre-pilot) | initial author | Shipped theme-npl-editorial/ (4 files) with bare `red`/`blue`/`yellow` seeds — accents were silent no-ops | — |
| 2026-07-17 | tune-facets (Stage C pilot 1) | Fixed seed trap (brand-* + re-pointed -light); added self-scoped css-snippets (6 inflections + 2 NPL samples); rendered 5 screens / 6 API calls; amended treatise to rev2/full recording render-model limits (serif/claret/2px not honored by image model); verified via generate-css (exit 0) + WCAG light matrix | CONFORMANT — light (dark deferred to npx path; 5 standing cautions) |
