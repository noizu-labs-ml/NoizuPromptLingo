# NPL Theme Directions — Similitude Gate & Roster

Stage B similitude analysis for NoizuPromptLingo. Target: **7 effective theme
directions**. Four named themes already shipped under `design/theme/`; this file
scores how *distinct* they actually are (effective count `E`), then records the
new directions authored to reach the target.

> Scope note: `design/themes/` (plural, legacy) holds only a `starter/` scaffold —
> it is **not** a theme and is not counted here. The four scored themes are the
> `theme-npl-*` directories under `design/theme/` (singular). `theme-style-guide`
> is the shared base and is excluded from scoring.

## Existing themes (n = 4)

| slug | register | accents | type | radius | mode |
|---|---|---|---|---|---|
| npl-brutalist | loud / raw / structural | pure RYB primaries (max chroma) | Space Grotesk + Space Mono | 0px | light+dark, hard |
| npl-editorial | literate / craft / spec | muted claret / petrol / ochre (warm) | **Source Serif 4** + IBM Plex Mono | 2px | light-primary (warm) |
| npl-minimal | precise / calm / default | one cool accent (sky blue), pure gray | Inter + JetBrains Mono | 6px | light-primary (cool) |
| npl-nocturne | terminal / signal / focus | phosphor green + cyan, near-black | Inter + JetBrains Mono | 4px | dark-native |

## Pairwise similitude `s(i,j) ∈ [0,1]`

Scored by eye across seeds (accent hue/value), palette temperature, typography
family, radius/shape language, and branding tone/keywords. `0` = no meaningful
resemblance, `1` = essentially the same theme. Symmetric matrix (diagonal n/a):

|            | brutalist | editorial | minimal | nocturne |
|------------|:---------:|:---------:|:-------:|:--------:|
| **brutalist** |   —    |   0.12    |  0.20   |   0.18   |
| **editorial** |  0.12  |    —      |  0.15   |   0.08   |
| **minimal**   |  0.20  |   0.15    |   —     | **0.42** |
| **nocturne**  |  0.18  |   0.08    | **0.42**|    —     |

Rationale for the notable scores:

- **minimal ↔ nocturne = 0.42** (the only close pair): *identical* type stack
  (Inter + JetBrains Mono), both cool tech-console registers, similar radius
  (6 vs 4), overlapping "precise / focused / expert" positioning. They diverge on
  light-primary vs dark-native and sky-blue vs phosphor-green — real, but this is
  the least-distinct pair, and it is what pulls `E` below 4.
- **editorial ↔ nocturne = 0.08** (most distinct): warm serif print-spec vs cool
  mono dark terminal — opposite on every axis.
- All other pairs 0.12–0.20: the four are archetype-distinct (brutalist maximalism,
  editorial print, minimal calm, nocturne terminal), just not perfectly orthogonal.

## Effective-direction count `E`

```
E = Σ_i [ Σ_{j≠i} (1 − s(i,j)) ] / (n − 1)          (n = 4)

Σ over unordered pairs of (1 − s):
  (1−0.12) + (1−0.20) + (1−0.18) + (1−0.15) + (1−0.08) + (1−0.42)
  = 0.88 + 0.80 + 0.82 + 0.85 + 0.92 + 0.58
  = 4.85
Ordered double sum = 2 × 4.85 = 9.70

E = 9.70 / (4 − 1) = 9.70 / 3 = 3.23
```

**E = 3.23** — the four shipped themes are worth ~3.2 effective directions (just
above 3, dragged down from a theoretical 4 by the minimal↔nocturne overlap).

**New directions needed = ceil(7 − E) = ceil(7 − 3.23) = ceil(3.77) = 4.**

(Aside: the Stage A state note guessed "E likely close to or above 7"; that is not
reachable for n=4 — the formula caps `E` at `n`, so max possible here is 4.0. The
scored value is 3.23, hence 4 new themes, not 0–3.)

## New directions authored (4) — chosen for low similitude

Each new direction deliberately claims aesthetic territory **none of the four
shipped themes occupy** (none use soft-shadow elevation, grid texture,
glass/gradient, or warm-dark), and stays low-similitude against the others.

| slug | territory it owns (unoccupied) | register | why distinct |
|---|---|---|---|
| **npl-aurora** | resting soft-shadow elevation + high radius + pills | warm / soft / welcoming | only rounded, shadowed, warm-cream theme; serves onboarding & newcomers |
| **npl-blueprint** | visible grid texture + thin cyan rules | cool / schematic / drafting | only texture-positive theme; cyanotype dark mode; serves schemas/policies/scopes |
| **npl-prism** | translucent glass + spectrum gradients | vibrant / luminous / premium | only theme allowed gradients + blur; serves landing & creative suite |
| **npl-meridian** | warm-dark + brass metallic + display serif | refined / luxe / executive | only *warm* dark (vs Nocturne's cool); serves exec dashboards/leads/owners |

Estimated max-similitude of each new direction to the union of all others
(existing + new) stays ≤ ~0.30 — spread across surface treatment (soft-shadow /
grid / glass / tonal-brass), temperature (warm / cool / cool-spectrum / warm-dark),
type (rounded-humanist / engineered-mono / modern-grotesk / display-serif), radius
(14 / 2 / 16 / 6), and mood (friendly / precise / premium / luxe).

## Final roster (8 themes → treatises)

Existing (reverse-engineered): `npl-brutalist`, `npl-editorial`, `npl-minimal`,
`npl-nocturne`.
New (authored forward): `npl-aurora`, `npl-blueprint`, `npl-prism`, `npl-meridian`.

Each has a `treatise-{slug}.md` sibling in this directory (`status: sketch`; Stage C
flips to `full` and builds the `theme-{slug}/` engine YAML for the four new ones).
Screen distribution across all eight is in
`design/asset-prompts/screens/allocation.yaml`.
