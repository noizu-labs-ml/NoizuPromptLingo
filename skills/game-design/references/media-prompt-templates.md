# Game Media Prompt Templates

Ready-to-use `.media.prompt` templates organized by game asset type. Templates use schema v0.4 quality-based selection by default — adapt the `prompt.text`, `quality`, and `output.dimensions` to match your game's style and requirements. Service pinning (`service:`) remains available for advanced cases (e.g., pinning a specific text provider for SVG/diagram types).

> For the full media-tools reference and provider options, see the `content-media-engine` skill or the media-tools README.

---

## Character Art

### Character Portrait (Base Reference)

```yaml
# characters/<name>-base.media.prompt
schema: "0.4"
id: char-<name>-base
type: image
quality: high             # high for hero/key characters; medium for supporting cast

prompt:
  text: "Fantasy RPG character portrait, <description>, detailed digital art, dark background, dramatic lighting"
  negative: "modern, sci-fi, cartoon, anime, low detail"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"

eval:
  pass_threshold: 0.7
  required_pass: [anatomy]
  criteria:
    anatomy:
      weight: 3
      description: "Correct proportions, no extra limbs, natural pose"
      fail_signals: ["extra limbs", "malformed hands"]
    style_consistency:
      weight: 3
      description: "Matches the game's visual style — consistent art direction"
    technical:
      weight: 2
      description: "Sharp focus on face, no compression artifacts"
  reject_if:
    - "extra limbs or malformed anatomy"
    - "watermark or signature"

tags: [character, portrait, rpg]
```

### Character Action Pose (Depends on Base)

```yaml
# characters/<name>-action.media.prompt
schema: "0.4"
id: char-<name>-action
type: image
quality: high

depends_on:
  - ref: char-<name>-base
    as: base_portrait
    collapse: file

attachments:
  - path: ${base_portrait}
    role: style
    description: "Character design reference for consistency"

prompt:
  text: "The same character from the reference, dynamic combat pose, <action description>, dramatic action scene"
  negative: "static, calm, inconsistent design"

output:
  formats:
    - format: png
  dimensions:
    width: 1920
    height: 1080
    aspect_ratio: "16:9"

tags: [character, action, rpg, key-art]
```

### Character Sprite Sheet Concept

```yaml
# characters/<name>-sprites.media.prompt
schema: "0.4"
id: char-<name>-sprites
type: image
quality: medium

prompt:
  text: "Pixel art sprite sheet, <character description>, 16x16 grid, 8 directional walk cycle, attack animation 6 frames, idle 4 frames, white background, clean pixel art style, no anti-aliasing"
  negative: "realistic, blurry, anti-aliased, 3D"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"

eval:
  pass_threshold: 0.7
  criteria:
    anatomy:
      weight: 3
      description: "All animation frames have correct proportions, no extra limbs or malformed pixels"
      fail_signals: ["extra limbs", "distorted frames"]
    style_consistency:
      weight: 3
      description: "Consistent pixel style and color palette across all frames"
    technical:
      weight: 2
      description: "Clean pixel art — no anti-aliasing, correct grid layout"
  reject_if:
    - "anti-aliased edges"
    - "inconsistent character scale across frames"

tags: [character, sprite-sheet, pixel-art]
```

---

## Environment Art

### Background / Level Art

```yaml
# environments/<scene>.media.prompt
schema: "0.4"
id: env-<scene>
type: image
quality: high

prompt:
  text: "Game background art, <scene description>, parallax layers, <art style>, no characters, wide panoramic, game-ready"
  negative: "characters, UI, text, photorealistic"

output:
  formats:
    - format: png
  dimensions:
    width: 1920
    height: 1080
    aspect_ratio: "16:9"

eval:
  pass_threshold: 0.7
  criteria:
    composition:
      weight: 3
      description: "Clear foreground/midground/background separation, strong focal point"
    style_consistency:
      weight: 3
      description: "Matches the game's art direction — color palette, lighting, and tone are consistent"
    technical:
      weight: 2
      description: "Correct 16:9 aspect ratio, no compression artifacts"
  reject_if:
    - "UI elements or text visible"
    - "characters present in environment-only scene"

tags: [environment, background, level-art]
```

### Tile Set

```yaml
# environments/<biome>-tiles.media.prompt
schema: "0.4"
id: env-<biome>-tiles
type: image
quality: medium

prompt:
  text: "Top-down tile set for <biome> biome, 32x32 pixel tiles, includes: ground, walls, water, trees, rocks, path, 4x4 grid layout, seamless edges, pixel art style, consistent lighting"
  negative: "realistic, 3D, anti-aliased, inconsistent scale"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"

tags: [environment, tileset, pixel-art]
```

---

## UI Assets

### UI Icon (SVG)

```yaml
# ui/<icon-name>.media.prompt
schema: "0.4"
id: ui-<icon-name>
type: svg
# service: pins to a text-capable provider — required for SVG/text output types
service: anthropic

prompt:
  system: "Generate a clean SVG icon. Output only the SVG markup, no explanation."
  text: "Game UI icon for <ability/item>, <style description>, single color, 64x64 viewBox, clean lines"
  provider_options:
    text_format: svg

output:
  formats:
    - format: svg

tags: [ui, icon, svg]
```

### UI Screen Mockup

```yaml
# ui/<screen-name>.media.prompt
schema: "0.4"
id: ui-<screen-name>
type: html
# service: pins to anthropic — required for HTML text-output types
service: anthropic

prompt:
  system: |
    Generate a complete, self-contained HTML file with inline CSS.
    Create a game UI mockup screen. Modern, polished visual design.
  text: |
    Game <screen-name> screen mockup for a <genre> game:
    - <layout description>
    - <interactive elements>
    - <color scheme and style>
  provider_options:
    text_format: html
    max_tokens: 4096

output:
  formats:
    - format: html

tags: [ui, mockup, screen]
```

---

## Mini-Game Prototypes

### HTML5 Canvas Prototype

```yaml
# prototypes/<mechanic>.media.prompt
schema: "0.4"
id: proto-<mechanic>
type: html
# service: pins to z.ai — required for HTML text-output; z.ai is fast and cost-effective for prototypes
service: z.ai

prompt:
  system: |
    Generate a complete, self-contained HTML file with inline JavaScript.
    No external dependencies except a single CDN script tag if needed.
    Use HTML5 Canvas for rendering. Clean, well-structured code.
    The game must be playable immediately on opening the HTML file in a browser.
  text: |
    Create a <game type> prototype:
    - <mechanic descriptions>
    - <controls>
    - <win/lose conditions>
    - <visual style>
  provider_options:
    max_tokens: 8192
    temperature: 0.3

output:
  formats:
    - format: html

tags: [game, prototype, <mechanic-tag>]
```

### Prototype Examples by Genre

**Match-3:**
```
Create a Match-3 puzzle prototype:
- 8x8 grid of colored gems (6 colors)
- Click to swap adjacent gems, match 3+ in a row/column
- Matched gems disappear, new ones fall from top
- Score counter, combo multiplier
- Timer (60 seconds)
- Bright, candy-colored aesthetic on dark background
```

**Endless Runner:**
```
Create an endless runner prototype:
- Character auto-runs right, player jumps (spacebar/click)
- Procedurally generated obstacles (gaps, spikes, walls)
- Parallax scrolling background (3 layers)
- Score = distance traveled
- Speed increases every 500 points
- Pixel art style, 60fps via requestAnimationFrame
```

**Turn-Based Combat:**
```
Create a turn-based combat prototype:
- Player party of 3 characters vs 1-3 enemies
- Each character has: Attack, Defend, Special (cooldown)
- HP bars above each unit
- Simple AI: enemies attack random player
- Damage formula: ATK - DEF/2 + random(0, ATK/4)
- Victory/defeat screen with restart
- Dark fantasy aesthetic, side-view layout
```

**Card Battler:**
```
Create a card battler prototype:
- Player hand of 5 cards, draw 1 per turn
- 10 mana per turn, cards cost 2-6 mana
- Cards: minion (ATK/HP), spell (direct damage), buff (+ATK/+HP)
- Play cards to a 5-slot battlefield
- Minions auto-attack at end of turn
- Enemy AI plays random valid cards
- Hearthstone-inspired clean UI
```

---

## Game Audio

### Background Music

Use `type: music` — the tool selects a music provider (Suno etc.) by quality tier. Note: audio is not yet auto-gradable; omit `eval` blocks for music tracks.

```yaml
# audio/<track-name>.media.prompt
schema: "0.4"
id: audio-<track-name>
type: music
quality: medium           # low=Suno V4; medium/high=Suno V4_5ALL

prompt:
  text: "<genre/mood description>"
  provider_options:
    customMode: true
    instrumental: true
    style: "<style tag>"
    title: "<track title>"
    negativeTags: "<excluded styles>"

output:
  duration: 120            # target duration in seconds
  formats:
    - format: mp3

# eval: omitted — audio is not yet auto-gradable; generation accepts first successful output

tags: [audio, music, <track-type>]
```

### Style Examples

| Game Scene | Style | Negative |
|-----------|-------|----------|
| Town/hub | "Peaceful Fantasy Town, Lute, Flute, Warm" | "Combat, Dark, Electronic" |
| Battle | "Epic Orchestral Battle, Heavy Drums, Brass" | "Peaceful, Acoustic, Ambient" |
| Boss | "Intense Dark Orchestral, Choir, Building Tension" | "Happy, Pop, Light" |
| Dungeon | "Dark Ambient, Eerie, Dripping Water Echo" | "Bright, Upbeat, Vocals" |
| Menu | "Calm Fantasy, Harp, Strings, Welcoming" | "Combat, Dark, Heavy" |
| Victory | "Triumphant Orchestral Fanfare, Brass, Timpani" | "Sad, Dark, Ambient" |

### Voice / Dialogue Lines

Use `type: voice` for TTS. Provider is selected by quality tier (medium = openai-tts first, high = elevenlabs first). Note: audio is not yet auto-gradable; omit `eval` blocks.

```yaml
# audio/npc-<name>-<line>.media.prompt
schema: "0.4"
id: voice-npc-<name>-<line>
type: voice
quality: medium

prompt:
  text: "<dialogue text>"
  provider_options:
    voice: <voice>
    instructions: "<tone/delivery direction>"
    speed: 0.9

output:
  formats:
    - format: mp3

# eval: omitted — audio is not yet auto-gradable; generation accepts first successful output

tags: [audio, voice, npc, dialogue]
```

### Voice Selection Guide

| NPC Archetype | OpenAI Voice | Direction |
|--------------|-------------|-----------|
| Wise mentor | sage | "Speak slowly, with gravitas and warmth" |
| Young hero | coral | "Energetic, determined, slightly breathless" |
| Villain | onyx | "Cold, calculating, with subtle menace" |
| Shopkeeper | echo | "Jovial, welcoming, slightly theatrical" |
| Commander | ash | "Sharp, commanding, clipped military delivery" |
| Mysterious NPC | fable | "Ethereal, dreamy, hinting at hidden knowledge" |
| Comic relief | shimmer | "Bubbly, cheerful, slightly sarcastic" |

---

## Video Assets

### Game Trailer Clip

```yaml
# video/<trailer-name>.media.prompt
schema: "0.4"
id: video-<trailer-name>
type: video
quality: high

depends_on:
  - ref: <key-art-id>
    as: key_art
    collapse: file

attachments:
  - path: ${key_art}
    role: base
    description: "Key art for trailer opening"

prompt:
  text: "<cinematic description, camera movement, mood>"

output:
  duration: 6              # seconds — mapped to provider-specific param automatically
  formats:
    - format: mp4
  dimensions:
    aspect_ratio: "16:9"

eval:
  pass_threshold: 0.7
  criteria:
    motion_quality:
      weight: 3
      description: "Smooth camera movement, no warping or temporal artifacts"
    prompt_adherence:
      weight: 3
      description: "Key described elements visible — character, environment, action"
    technical:
      weight: 2
      description: "Correct aspect ratio, full duration rendered"
  reject_if:
    - "abrupt cut or black frames"
    - "watermark visible"

tags: [video, trailer, cinematic]
```

### B-Roll / Gameplay Mockup

```yaml
# video/<clip-name>.media.prompt
schema: "0.4"
id: video-<clip-name>
type: video
quality: medium

prompt:
  text: "<gameplay scene description, action, effects>"

output:
  duration: 10             # seconds
  formats:
    - format: mp4
  dimensions:
    aspect_ratio: "16:9"

tags: [video, gameplay, b-roll]
```

---

## Game Design Diagrams

### Core Loop Diagram

```yaml
# diagrams/core-loop.media.prompt
schema: "0.4"
id: diag-core-loop
type: diagram
# service: pins to anthropic — required for diagram text-output types
service: anthropic

prompt:
  system: "Generate a Mermaid flowchart diagram. Output only the .mmd content, no fences."
  text: |
    Game core loop for a <genre> game:
    - <action> → <reward> → <upgrade path> → <new challenge>
    - Include meta loop: <daily activities> → <seasonal progression>
  provider_options:
    text_format: mermaid

output:
  formats:
    - format: svg

tags: [diagram, core-loop, game-design]
```

### Economy Flow Diagram

```yaml
# diagrams/economy-flow.media.prompt
schema: "0.4"
id: diag-economy
type: diagram
# service: pins to anthropic — required for diagram text-output types
service: anthropic

prompt:
  system: "Generate a Mermaid flowchart. Output only the .mmd content, no fences."
  text: |
    Game economy flow for <game>:
    - Currencies: <list currencies and types>
    - Sources: <how players earn each currency>
    - Sinks: <what players spend each currency on>
    - Conversion points: <any exchange rates>
    - IAP entry points: <where real money enters the flow>
  provider_options:
    text_format: mermaid

output:
  formats:
    - format: svg

tags: [diagram, economy, game-design]
```

### Progression Tree

```yaml
# diagrams/progression-tree.media.prompt
schema: "0.4"
id: diag-progression
type: diagram
# service: pins to anthropic — required for diagram text-output types
service: anthropic

prompt:
  system: "Generate a Mermaid graph (TD or LR). Output only the .mmd content, no fences."
  text: |
    Player progression tree for <game>:
    - Starting state → unlock milestones
    - <list key unlocks and their prerequisites>
    - Branching paths: <list paths>
    - Endgame content gates
  provider_options:
    text_format: mermaid

output:
  formats:
    - format: svg

tags: [diagram, progression, game-design]
```

---

## Item & Icon Art

### Item Icon Grid

```yaml
# items/<category>-icons.media.prompt
schema: "0.4"
id: items-<category>
type: image
quality: medium

prompt:
  text: "Game item icon sheet, <category> items, <list items>, arranged in a grid, <art style>, consistent size and lighting, transparent-style background, game-ready assets"
  negative: "realistic, photographic, inconsistent style, blurry"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"

tags: [items, icons, game-assets]
```

### App Store / Marketing Art

```yaml
# marketing/app-icon.media.prompt
schema: "0.4"
id: mkt-app-icon
type: image
quality: high

prompt:
  text: "Mobile game app icon, <game description>, bold readable at small sizes, vibrant colors, <art style>, no text, rounded square composition"
  negative: "text, realistic, dark, cluttered"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 1024
    aspect_ratio: "1:1"

tags: [marketing, app-icon, store]
```

```yaml
# marketing/feature-graphic.media.prompt
schema: "0.4"
id: mkt-feature-graphic
type: image
quality: high

prompt:
  text: "Google Play feature graphic, <game> gameplay showcase, dynamic action scene, <key characters>, vibrant, exciting, game title area on left"
  negative: "static, boring, text-heavy, realistic"

output:
  formats:
    - format: png
  dimensions:
    width: 1024
    height: 500
    aspect_ratio: "1024:500"

tags: [marketing, feature-graphic, store]
```

---

## Batch Generation Patterns

### Generate All Assets for a Game Project

```bash
# Preview the full generation plan
generate-media-prompt --dry-run --verbose prompts/

# Generate all assets (respects dependency ordering)
generate-media-prompt prompts/

# Generate only character art (tag filtering when implemented)
generate-media-prompt --tag character prompts/

# Generate 3 variants of each art asset
generate-media-prompt -n 3 prompts/characters/

# Interactive refinement on a specific asset
generate-media-prompt --refine prompts/characters/knight-base.media.prompt
```

### Dependency Chain Example

```
prompts/
├── characters/
│   ├── knight-base.media.prompt        # Tier 0 (no deps)
│   ├── knight-action.media.prompt      # Tier 1 (depends: knight-base)
│   └── knight-portrait.media.prompt    # Tier 1 (depends: knight-base)
├── environments/
│   └── castle-exterior.media.prompt    # Tier 0
├── marketing/
│   └── key-art.media.prompt            # Tier 2 (depends: knight-action, castle-exterior)
├── video/
│   └── teaser.media.prompt             # Tier 3 (depends: key-art)
└── audio/
    └── main-theme.media.prompt         # Tier 0 (no deps)
```

The engine resolves this DAG and generates tier-by-tier: all tier 0 in parallel, then tier 1, then tier 2, then tier 3.
