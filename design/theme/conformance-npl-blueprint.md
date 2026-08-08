# Theme Conformance — npl-blueprint (2026-07-17)

Treatise-vs-YAML audit record. Lives at
`projects/NoizuPromptLingo/design/theme/conformance-npl-blueprint.md`.

- **Treatise**: treatise-npl-blueprint.md @ rev 2 (status: full)
- **Theme**: theme-npl-blueprint/ (6 files) · base chain: theme-npl-blueprint → theme-style-guide
- **Audited by / workflow**: Loom Stage-C agent / new-theme build (extract-seeds + tune-facets, uplift pilot 1)
- **Serve state**: legacy `generate-css` path only (public `@noizu/styleguide` 404s; `npx serve`
  unavailable). Generation clean (exit 0, no error/exception). Remaining `⚠` are benign and
  listed in §3 row 10. Literal dark color-modes maps are **not** serve-verified on this path.

## Verdict

**CONFORMANT** (renders deferred — infra 429 storm)

Fresh, forward-authored theme (no prior YAML to remediate). Every treatise §1–§9
commitment is realized in YAML, waived with rationale, or escalated. Built v3-correct from
the first pass: accents on the real `brand-red`/`brand-blue`/`brand-yellow` slots (not the
bare-key no-op), each `-light` re-pointed to `var(--brand-*)`, and a `scoped-vars` delta that
pre-empts the base's dark-mode Bauhaus-red leak for all three accent families. The compiled
CSS confirms the hard signals: `--brand-red: #245ea8` / `--brand-blue: #0e9bd6` /
`--brand-yellow: #c05a3e` / `--radius: 2px` / IBM Plex Sans+Mono in light, the three dark
`--theme-brand-*` families re-pointed to their own hexes, and **zero `#e20613` under any
`npl-blueprint` rule** (scope-tracked parse of the generated CSS). All css-snippets are
hand-self-scoped — no bare/leaking selectors. One treatise contrast figure was wrong (redline
on sheet claimed ≈4.6:1, measured ≈4.1:1 — below the body floor) and is corrected in treatise
rev 2 + handled in YAML (redline is a rule/tint with ink text, never small redline-colored
body). **Two standing limitations, neither a conformance defect:** (1) the 5 screen renders
are deferred — a sustained shared 429 rate-limit storm (four other NPL Stage-C agents
rendering concurrently) failed every attempt within the 12-call cap; prompts are complete and
top-up is idempotent (§8). (2) literal dark color-modes maps are unverifiable on the legacy
path (see §3/§6).

## 1. Value Trace (YAML → treatise)

| File : key | Value | Treatise § | Disposition | Action taken |
|------------|-------|-----------|-------------|--------------|
| vars : white | `#f5f8fc` | §3 pale cool sheet | conformant | set explicit; tints gray ramp ~4% cool |
| vars : black | `#14263f` | §3 navy drafting ink | conformant | set explicit (reads as ink, not `#000`) |
| vars : brand-red | `#245ea8` | §3 primary = blueprint blue ~213° | conformant | on real `brand-red` slot; `-light` → `var(--brand-red)` |
| vars : brand-blue | `#0e9bd6` | §3 secondary = drafting cyan ~196° | conformant | on `brand-blue`; rules/large-UI only (§4/§5); `-light` re-pointed |
| vars : brand-yellow | `#c05a3e` | §3 tertiary = redline ~14° (markup) | conformant | on `brand-yellow`; rule/tint/ink only; `-light` re-pointed |
| vars : success/warning/error/info | `#2e8b6f`/`#c98a2b`/`#bd3b34`/`#245ea8` | §3 semantics; info≡primary | conformant | technical set; error≠redline; info shares blue by design |
| vars : font-sans / font-mono | IBM Plex Sans / IBM Plex Mono | §4 mono-forward | conformant | matches branding font-url |
| vars : radius | `2px` | §6 near-square | conformant | set explicit |
| scoped-vars : brand-red/-blue/-yellow[-light/-mid] (dark) | `color-mix(#245ea8 / #0e9bd6 / #c05a3e …)` | §3 cyanotype = brighter own accents | conformant | **new delta — overrides base dark `#e20613`/navy/gold leak for all 3 families** |
| color-modes : light map | cool sheet/ink/slate rules | §3 mode strategy | conformant | explicit cool-tinted surfaces/text/borders |
| color-modes : dark map | cyanotype navy `#0a1a2f`, cyan-white ink | §3 designed cyanotype | conformant (unverified on legacy path) | authored; realized only under `npx serve` (§3 row 1–2 caveat) |
| css-snippets (7, self-scoped) | grid canvas / focus+motion / buttons / title-block card / field+mono label / scope-tree+redline / structural table | §6/§7/§8 | conformant | project-specific sample elements (authz/scope surfaces); every selector under `html[data-design-theme="npl-blueprint"]` |
| branding : name / logo-text / font-url | "NPL — Blueprint" / "NPL" / IBM Plex Sans+Mono | §1/§4 | conformant | sibling-convention name; font-url loads font-sans+font-mono |

## 2. Claim Coverage (treatise → YAML)

| § | Claim (condensed) | Status | Where encoded / rationale |
|---|-------------------|--------|---------------------------|
| §1 | Identity: intent/perception/audience/tone/keywords | realized | branding.yaml verbatim |
| §2 | Anchors: blueprint/CAD, IBM Plex, dot-grid; anti-refs editorial/nocturne/neon-grid | realized | cool palette + Plex fonts + faint static grid; no glow/animation |
| §3 | Cool neutrals tinted ~4% blue (not pure gray) | realized | white/black cool seeds; color-modes cool surfaces/text/borders |
| §3 | Blueprint blue primary, cyan rules, redline markup | realized | brand-red/blue/yellow seeds; snippets |
| §3 | error distinct from primary blue AND from redline | realized | error `#bd3b34` vs primary `#245ea8` vs redline `#c05a3e` |
| §3 | Faint grid ~1.1:1; rules ~3:1; ink ~13:1 | realized | grid snippet ≤6%/≤10% alpha; border-strong ~3:1; ink ~14:1 |
| §3 | Dark = designed cyanotype (navy canvas, cyan/white lines) | realized (unverified on legacy) | color-modes dark + scoped-vars dark accents (see §3 caveat) |
| §4 | IBM Plex Sans UI + Plex Mono for every precise value; no serif | realized | vars fonts; mono labels/scope-paths/coords in snippets |
| §5 | 8px grid made visible; mid density; mono readouts truncate | realized | grid snippet (8/40px); table snippet nowrap mono column |
| §6 | 2px radius; borders are the drawing; nearly flat (no resting shadow); grid texture | realized | radius seed; cyan-rule snippets; `box-shadow:none` cards; grid canvas |
| §7 | Micro 100ms / panel 180ms; blueprint-blue focus (cyan on dark); reduced-motion | realized | focus-motion snippet + `.dark` cyan + reduced-motion guard |
| §8 | Blueprint-blue primary, cyan-rule ghost, title-block cards, mono breadcrumbs, scope tree | realized | buttons/card/scope-tree snippets |
| §8 | Toasts/modal mechanics left at base | realized (inherited) | not overridden |
| §9 | WCAG 2.2 AA both modes; glyph-paired status; focus never removed; grid ≠ focus | realized (see §4) | seeds + snippets; status glyph-paired in render prompts; grid low-alpha |

## 3. Mode-Verification Matrix Results

Light = seed-cascade + generated-CSS verified. Dark = **reasoned from generated CSS tokens +
contrast math, not serve-verified** (legacy path does not emit literal color-modes maps, so the
cyanotype canvas `#0a1a2f` is unrealized on this path — the seed cascade falls back to the
base `slate-800` dark surface). Renders = **deferred** (429 storm), so no image evidence for
soft signals this pass.

| # | Check | Light | Dark | HC / reduced-motion | Notes |
|---|-------|-------|------|---------------------|-------|
| 1 | Body text vs surface | PASS (ink ~14:1) | PASS reasoned (`#dbe7f5`/navy ~13.9:1) | n/a (no HC mode) | dark canvas serve-only |
| 2 | Secondary/muted text | PASS (sec ~7.5:1, muted ~5.3:1) | PASS reasoned (sec ~9.5:1, muted `#7f9bbd` ~5.9:1) | — | cool slate ramp |
| 3 | Accent as text/UI | PASS (blue ~6:1 body; white-on-blue btn ~6.4:1) | PASS reasoned (brightened blue on navy) | — | cyan is rules-only ~2.9:1 (§5) |
| 4 | Semantic not hue-alone | PASS (glyph-paired) | reasoned | icon/glyph present | success/warning large+glyph only |
| 5 | Meaningful borders ≥3:1 | PASS (border-strong ~3.0:1; cyan rules ~2.9:1 large-UI) | reasoned | routine border ~1.8:1 by design (§5 waiver) |
| 6 | Focus indicator visible | PASS (blueprint-blue 2px/2px) | PASS reasoned (cyan `#4fc3e8` ~8.5:1) | never removed | grid kept low-alpha ≠ focus |
| 7 | Mode distinctness | — | PASS reasoned (sheet vs cyanotype navy) | — | full proof needs serve |
| 8 | Reduced-motion | — | — | PASS | button transition → none |
| 9 | Exclusions sweep (Bauhaus red, gradients, glow, animation) | PASS | PASS | — | **0×`#e20613` in npl-blueprint scope** (scope-tracked parse); no gradient/glow/anim facets |
| 10 | Validator (no ✗, ⚠ explained) | PASS | PASS | — | exit 0, 0 error/exception. ⚠: 6× css-snippet `target-section` not in page-sections (benign placement metadata, same class as base `card-glow`; CSS emits & verified present), 1× `font-size-base` false-positive (token inherited from base), 2× base-inherited jsx `demo` warnings |
| — | PNG render per prompt | **DEFERRED** | — | — | 429 storm; 0/5 landed within 12-call cap; top-up idempotent (§8) |

## 4. Contrast Measurements (near-the-line pairs)

| Pair | Mode | Required | Measured | Result |
|------|------|----------|----------|--------|
| ink `#14263f` on sheet `#f5f8fc` | light | 4.5 | ≈ **14:1** | PASS (body) |
| blueprint-blue `#245ea8` on sheet | light | 4.5 body / 3.0 large | ≈ **6.0:1** | PASS body-safe (text/links/focus) |
| white on primary button `#245ea8` | light | 4.5 | ≈ **6.4:1** | PASS — no fill-darkening needed |
| cyan `#0e9bd6` on sheet | light | 3.0 large-UI | ≈ **2.9:1** | rules/large-UI/borders only — **never body or small text** |
| redline `#c05a3e` on sheet | light | 4.5 body | ≈ **4.1:1** | **below body** — rule/tint/large-UI/attention only, ink carries note (treatise's 4.6:1 corrected → rev 2) |
| error `#bd3b34` on sheet | light | 4.5 | ≈ **5.1:1** | PASS (body-safe; distinct from redline) |
| success `#2e8b6f` on sheet | light | 3.0 large | ≈ **3.9:1** | large/icon + glyph only |
| warning `#c98a2b` on sheet | light | 3.0 large | ≈ **2.8:1** | large/icon + glyph only (amber floor) |
| text-secondary `#3a5170` / muted `#556983` on sheet | light | 4.5 | ≈ 7.5 / 5.3:1 | PASS |
| border-strong `#7e93ad` on sheet | light | 3.0 | ≈ **3.0:1** | PASS (structural boundary) |
| text `#dbe7f5` on cyanotype `#0a1a2f` | dark | 4.5 | ≈ **13.9:1** | PASS reasoned |
| muted `#7f9bbd` on cyanotype | dark | 4.5 | ≈ **5.9:1** | PASS reasoned |
| focus cyan `#4fc3e8` on cyanotype | dark | 3.0 | ≈ **8.5:1** | PASS reasoned |

## 5. Deviations & Waivers

| Item | Treatise clause | Deviation | Rationale | Approved by |
|------|-----------------|-----------|-----------|-------------|
| Cyan `#0e9bd6` rules/large-UI only | §3 contrast (~3:1) | not used for body/small text (~2.9:1) | treatise §3/§4 self-authorizes cyan as rule color; blue primary carries text | treatise §3 |
| Redline `#c05a3e` rule/tint/ink-only | §9 (implied body) | not small redline-colored text (~4.1:1) | below 4.5 body floor; rendered as left-rule + faint tint with ink note | this audit (+ §7 correction, folded to rev 2) |
| Routine border `#a9bdd4` ~1.8:1 | §3 rules ~3:1 | faint on routine cell dividers | treatise §3 splits grid (~1.1) / rules (~3): structural rules use cyan/border-strong ≥3:1; routine dividers intentionally quiet | treatise §3 |
| success/warning large+glyph only | §9 | not body-size text on sheet | ~3.9 / ~2.8:1; always paired with a glyph in prompts/snippets | §9 self-authorizes glyph-pairing |

## 6. Standing Cautions

Re-check these after ANY seed or color-mode change.

| Caution | Trigger to recheck |
|---------|--------------------|
| redline `#c05a3e` ≈4.1:1 (not body-safe) | any new redline-colored text; any lightening of redline or canvas |
| cyan `#0e9bd6` ≈2.9:1 (rules/large-UI only) | any cyan-as-body-text usage |
| dark color-modes cyanotype `#0a1a2f` map unverified | re-run full matrix under `npx @noizu/styleguide serve` once available |
| grid alpha (≤6% light / ≤10% dark) vs text/focus legibility | any grid-density or accent change |
| 5 screen renders deferred (0/5) | re-run `generate-media-prompt --no-eval -n 1 <file>` per §8 once the 429 storm clears |

## 7. Escalations to trl-user-experience-engineer

| # | Issue | § | Status |
|---|-------|---|--------|
| 1 | Treatise §9 stated redline `#c05a3e` on sheet ≈4.6:1 ("just clears body"); measured ≈**4.1:1** — below the 4.5 body floor. Corrected in treatise **rev 2**; YAML uses redline as rule/tint with ink text. | §9 | resolved (rev 2) |
| 2 | **Base-cascade defect (affects ALL non-Bauhaus themes):** `theme-style-guide/style-guide.scoped-vars.yaml` brightens dark `brand-red/-blue/-yellow` from **literal** `#e20613`/`#0047ab`/`#f5c518` instead of `var(--brand-*)`, so every theme reverts its accents to Bauhaus red/navy/gold in dark mode. Worked around here per-theme via a `scoped-vars` override (all 3 families); durable fix belongs in the base file. | engine | open (shared with npl-minimal esc. 2) |
| 3 | Legacy `generate-css` fallback does not emit `style-guide.color-modes.yaml` literal maps; the authored cyanotype dark canvas is unverifiable until `npx @noizu/styleguide serve` (or a private registry) is available. | engine/tooling | open |

## 8. Session History

| Date | Workflow | Summary | Verdict after |
|------|----------|---------|---------------|
| 2026-07-17 | new-theme build | Authored theme-npl-blueprint/ (6 files) from treatise: cool drafting-sheet seeds, IBM Plex Sans+Mono, 2px radius, 3-family scoped-vars dark fix, cyanotype color-modes, 7 self-scoped css-snippets (grid canvas / title-block cards / MCP scope tree / structural tables). Validated legacy path (exit 0; compiled-CSS scope parse confirmed accents + zero Bauhaus-red leak + no bare selectors). Wrote 5 render prompts. Amended treatise rev 2 (redline contrast correction). Renders deferred by 429 storm. | CONFORMANT (renders deferred) |
