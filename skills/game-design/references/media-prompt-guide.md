# Media Prompt Guide for Game Assets

How to write `.media.prompt` files that produce consistent, usable game art assets, audio direction, and marketing materials. These files are structured generation requests — not raw prompts — designed to be processed by AI image, audio, and video generation tools.

> **Schema v0.4:** Lead with `quality:` (low/medium/high) and an `eval:` block. The tool selects the best available provider automatically and retries with fallback providers until output passes your criteria. Pinning a specific `service:` is available for advanced cases but is no longer the default authoring pattern.

## File Naming Convention

```
assets/prompts/{category}/{asset-name}.media.prompt
```

**Categories:** `characters/`, `environments/`, `creatures/`, `items/`, `ui/`, `marketing/`, `audio/`

**Naming rules:**
- Kebab-case: `shadow-blade-chimera.media.prompt`
- Match the in-game name when possible
- Append `-sheet` for turnaround/reference sheets: `alchemist-sheet.media.prompt`
- Append `-detail` for close-up/prop details: `twilight-zone-detail.media.prompt`
- Append `-variant` for alternate versions: `shadow-chimera-corrupted-variant.media.prompt`

## Frontmatter Schema

```yaml
---
type: image | audio | video | 3d          # What kind of asset
style: concept-art | pixel-art | painterly | photorealistic | flat-vector | low-poly | anime | comic
aspect: 16:9 | 1:1 | 9:16 | 4:3 | 2:1   # Output aspect ratio
resolution: 1024x1024 | 1920x1080         # Target resolution
tool: midjourney | dall-e | stable-diffusion | flux | suno | udio | runway | any
tags: [category, subject, mood, genre]     # For indexing and batch processing
game: {game-slug}                          # Links prompt to its game concept
priority: critical | high | medium | low   # Production priority
---
```

## Body Sections

Every `.media.prompt` file has four required sections and one optional:

### 1. Context (Required)
Where this asset appears in the game and what it communicates to the player. This grounds the artist (human or AI) in the gameplay purpose.

```markdown
## Context
This is the player's first view of the Twilight Zone — the tutorial area where they learn
scavenging and transmutation. It needs to feel liminal and unsettling but not overwhelming.
The player should feel curious enough to explore but aware that safety is temporary.
```

### 2. Subject (Required)
The detailed visual/audio description. Be compositionally specific.

**For images:**
- Composition: foreground / midground / background
- Focal point: where the eye should land
- Pose/gesture (for characters): what they're doing, not just how they look
- Lighting: direction, color temperature, intensity, shadows
- Environment: specific props, textures, weather, time of day

**For audio:**
- Tempo and key (for music)
- Instrumentation or sound source
- Emotional arc: how the piece evolves
- Duration target

```markdown
## Subject
A ruined stone courtyard at perpetual dusk. Cracked flagstones with faintly glowing essence
nodes (blue-white, pulsing) growing through the gaps like bioluminescent moss. In the
midground, a collapsed Alchemy Shrine — a circular stone altar with a shattered crystal
ball, its fragments still faintly refracting twilight. Background: a horizon where the sky
is split between amber twilight (left) and deep indigo shadow (right), with no visible sun.
Fog curls at ankle height. Camera angle: slightly elevated, looking down at 15° into the
courtyard. Focal point: the glowing essence nodes.
```

### 3. Style Notes (Required)
Art direction constraints that ensure the asset matches the game's visual identity.

```markdown
## Style Notes
Color palette: desaturated amber, indigo, blue-white for essence. No pure blacks — darkest
value is deep indigo (#1a1a2e). Line weight: none (painterly blending). Texture: weathered
stone, organic glow, volumetric fog. Comparable references: Hollow Knight's aesthetic
translated to painterly realism. Detail level: high in the focal area (essence nodes),
medium in midground (shrine), low in background (sky gradient, fog).
```

### 4. Negative Constraints (Required)
What to avoid — prevents common AI generation failures.

```markdown
## Negative Constraints
- No characters or creatures in this scene (environment-only)
- No modern elements (no metal, glass, electronics)
- No gore, blood, or body horror
- No text or UI elements
- Avoid oversaturation — this is a muted, twilight palette
- Avoid symmetrical composition — the ruin should feel natural, not designed
```

### 5. Variants (Optional)
Alternative versions of the same asset for different game states.

```markdown
## Variants
- **Pristine (flashback):** Same courtyard before the ruin — intact altar, no fog, warm
  golden hour light. Used in lore fragment #12.
- **Deep corruption:** Essence nodes are red instead of blue-white, fog is thicker and
  darker, shrine is completely destroyed. Used in zone 7 revisit.
- **After boss clear:** Fog lifts, ambient light brightens 20%, essence nodes glow steadily
  instead of pulsing. Used as post-boss reward atmosphere.
```

## Prompt Templates by Asset Category

### Characters

```markdown
---
type: image
style: concept-art
aspect: 2:3
resolution: 1024x1536
tool: any
tags: [character, portrait, {role}]
game: {slug}
priority: high
---

# {Character Name} — {Role}

## Context
{Where the player first meets this character. What impression they need to make.}

## Subject
**Build:** {height, body type, posture}
**Face:** {features, expression, distinguishing marks}
**Clothing/Armor:** {detailed outfit description with materials and wear}
**Pose:** {what they're doing — not "standing" but "leaning on a cracked staff, one hand
shielding a flickering flame"}
**Props:** {weapon, tool, companion creature, held item}
**Lighting:** {direction + color + intensity}
**Background:** {simple environment context, not detailed}

## Style Notes
{Art direction: color association, silhouette goals, readability at game camera distance}

## Negative Constraints
{Avoid: wrong genre cues, anachronisms, visual noise}

## Variants
- **Combat stance:** {action pose for in-game sprite/model reference}
- **Injured/corrupted:** {late-game visual evolution}
- **Portrait (UI):** {bust crop for dialogue boxes, 1:1 aspect}
```

### Environments

```markdown
---
type: image
style: concept-art
aspect: 16:9
resolution: 1920x1080
tool: any
tags: [environment, {biome}, {zone-name}]
game: {slug}
priority: {critical for key zones, medium for variants}
---

# {Zone Name} — {Biome Type}

## Context
{Zone's role in the game: what level of play, what emotions, what gameplay}

## Subject
**Composition:** {foreground / midground / background breakdown}
**Key landmarks:** {2-3 prominent features with spatial relationships}
**Lighting:** {time of day, light source, color temperature, shadow behavior}
**Weather/atmosphere:** {fog, rain, dust, particles, volumetric effects}
**Scale indicators:** {something that shows how big the space is}
**Points of interest:** {gameplay-relevant elements the player will interact with}

## Style Notes
{Palette, texture, detail falloff, comparable visual references}

## Negative Constraints
{Avoid: clutter, wrong biome elements, characters (unless crowd scene)}

## Variants
- **Day/night:** {if the zone has time-of-day changes}
- **Pre-event / post-event:** {if a story event changes the zone}
- **Seasonal:** {if applicable}
```

### Creatures / Enemies

```markdown
---
type: image
style: concept-art
aspect: 1:1
resolution: 1024x1024
tool: any
tags: [creature, enemy, {threat-tier}, {biome}]
game: {slug}
priority: medium
---

# {Creature Name} — {Threat Tier}

## Context
{Where and when the player encounters this creature. What it teaches mechanically.}

## Subject
**Silhouette:** {overall shape — must be readable at game camera distance}
**Size:** {relative to player character — "twice the height" or "knee-high swarm"}
**Key features:** {the 2-3 details that make it instantly recognizable}
**Movement suggestion:** {how it moves — slithering, lunging, hovering, shambling}
**Threat display:** {what it looks like when aggressive vs. passive}
**Material/texture:** {skin, shell, fur, shadow, crystal, etc.}

## Style Notes
{How scary/cute/alien, color coding for threat level, readability constraints}

## Negative Constraints
{Avoid: too similar to another creature in the roster, unclear silhouette}

## Variants
- **Idle:** {neutral/patrol state}
- **Aggro:** {attack/chase state — visual tells for player to read}
- **Death:** {dissolution, explosion, loot drop visual}
```

### UI Mockups

```markdown
---
type: image
style: flat-vector
aspect: 16:9
resolution: 1920x1080
tool: any
tags: [ui, {screen-name}, hud]
game: {slug}
priority: high
---

# {Screen Name} — UI Mockup

## Context
{When the player sees this screen. What information they need. What actions they take.}

## Subject
**Layout:** {grid/zone description: header, sidebar, main area, footer}
**Primary elements:** {the 3-5 most important elements with approximate positions}
**Data displayed:** {what numbers, icons, bars, text the player reads}
**Interactive elements:** {buttons, tabs, sliders, drag targets}
**Typography:** {heading size vs. body vs. labels — relative, not exact}

## Style Notes
{UI art direction: glass morphism, flat, neumorphic, pixel, parchment, sci-fi, etc.
Color system: primary, secondary, accent, danger, success, muted.
Readability requirements: minimum font size, contrast ratio, icon clarity.}

## Negative Constraints
{Avoid: information overload, tiny tap targets (if mobile), color-only signaling}
```

### Marketing Assets

```markdown
---
type: image
style: {painterly | photorealistic | stylized}
aspect: {varies by platform}
resolution: {platform-dependent}
tool: any
tags: [marketing, {asset-type}]
game: {slug}
priority: critical
---

# {Asset Name} — {Platform/Purpose}

## Context
{Where this appears: Steam store page, App Store listing, social media ad, trailer thumbnail.
What it needs to accomplish in 2 seconds of viewer attention.}

## Subject
{Hero composition: the single most compelling image of the game.
Must include: protagonist or iconic element + primary environment + sense of action/mood.
Must communicate genre within 2 seconds.}

## Style Notes
{Must match in-game art direction. Text-safe zones for title overlay. Platform-specific
aspect ratios and safe areas.}

## Negative Constraints
{Avoid: spoilers, confusing composition, generic fantasy/sci-fi that could be any game}
```

### Audio Direction

```markdown
---
type: audio
style: {orchestral | electronic | ambient | hybrid | chiptune | acoustic}
tool: {suno | udio | any}
tags: [audio, {music|sfx|ambient}, {context}]
game: {slug}
priority: {critical for main theme, medium for zone music, low for ambient}
---

# {Track Name} — {Context}

## Context
{When this plays: main menu, combat, exploration, boss fight, cutscene, shop.
Emotional target: what the player should feel.
Gameplay state: is the player relaxed, tense, triumphant, grieving?}

## Subject
**Tempo:** {BPM range}
**Key/Mode:** {e.g., D minor, Dorian mode — sets the emotional color}
**Instrumentation:** {specific instruments or synthesis types}
**Structure:** {intro → verse → chorus → bridge or loop point}
**Duration:** {target length, loop-friendly?}
**Dynamic layers:** {if adaptive: what layers add/remove based on gameplay state}

## Style Notes
{Reference tracks (not to copy, but for vibe). How this relates to other tracks in the
soundtrack — shared motifs, key relationships, instrumentation evolution.}

## Negative Constraints
{Avoid: genre-inappropriate instruments, tempo mismatches with gameplay pacing,
lyrics (unless intentional), ear fatigue on loops.}
```

## Batch Generation Strategy

For efficiency, generate media prompts in this priority order:

| Priority | Assets | Count | Rationale |
|----------|--------|-------|-----------|
| 1 — Identity | Key art, protagonist, main theme music | 3 | Defines the game's visual/audio identity |
| 2 — First Impression | Main menu UI, tutorial zone, first NPC | 3 | What the player sees first |
| 3 — Core Experience | 3-5 key environments, 3-5 core enemies, HUD | 6-10 | The gameplay loop's visual vocabulary |
| 4 — Depth | Remaining characters, zones, items, boss encounters | 10-20 | Full world coverage |
| 5 — Marketing | Store screenshots, trailer storyboard, social media assets | 3-5 | Launch-readiness |
| 6 — Polish | Variants, seasonal themes, DLC teasers | Variable | Post-launch |

## Quality Checklist for Media Prompts

- [ ] Every prompt has all 4 required sections (Context, Subject, Style Notes, Negative Constraints)
- [ ] Frontmatter `game:` field matches the concept's slug
- [ ] Art direction is consistent across all prompts for the same game
- [ ] Character prompts specify pose and expression, not just appearance
- [ ] Environment prompts specify composition (foreground/mid/back), not just description
- [ ] Creature prompts specify silhouette readability at game camera distance
- [ ] UI prompts specify information hierarchy, not just layout
- [ ] Audio prompts specify tempo, key, and emotional target
- [ ] No two prompts in the same game produce visually confusable assets
- [ ] Priority tagging reflects actual production needs
