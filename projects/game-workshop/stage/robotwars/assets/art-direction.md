# Art Direction: TheRobotWars

> *"If Stardew Valley and Studio Ghibli had a baby, and that baby grew up reading Caves of Qud lore wikis."*

---

## Core Visual Identity

### Philosophy

Meridian is a world that believes in warmth. The visual direction serves that belief at every level: warm colors dominate cool ones, light sources are soft and golden, shadows are blue-purple rather than black, and even the most austere environments (the Ashlands, the Frontier) contain pockets of beauty and color.

The art is **hand-painted 2D isometric** -- not pixel art, not vector, not 3D-rendered. Every asset should look like it was painted with care by someone who loved the subject. Brushstrokes should be visible at close inspection. Colors should feel mixed on a palette, not selected from a picker. Edges should be slightly soft, never razor-sharp.

### Reference Touchstones

| Reference | What We Take From It |
|-----------|---------------------|
| **Stardew Valley** | Warmth, coziness, the feeling that every pixel was placed with love. The color saturation level. The way light fills a room. |
| **Studio Ghibli** (Totoro, Spirited Away, Howl's Moving Castle) | Environmental storytelling. Living landscapes. Architecture that feels grown rather than built. The way nature and civilization interpenetrate. The quality of sky. |
| **Caves of Qud** | Density of world detail. The sense that every tile has a history. Layered information. |
| **Hollow Knight** | How to make atmosphere without horror. Bioluminescence done right. Beautiful darkness. |
| **Ori and the Blind Forest** | Light as emotion. Environmental mood. The way color temperature tells you how to feel. |

### What We Are NOT

| Avoid | Why |
|-------|-----|
| **Dark/grimdark** | This is not a world of suffering. Even conflict is rendered in warm tones. |
| **Horror aesthetic** | No jump scares, no gore, no grotesque creatures. Thornmere is mysterious, not frightening. |
| **Hyperrealism** | We are not trying to look like a photograph. We are trying to look like a memory of a beautiful place. |
| **Chibi/super-deformed** | Characters have proportions close to realistic (not full realism, but not bobblehead). |
| **Pixel art** | We respect pixel art deeply. This is not the right project for it. Our resolution is higher and our style is painterly. |
| **Flat/vector** | Depth and texture matter. Brushwork matters. This is not an infographic. |

---

## Global Visual Parameters

### Isometric Perspective

- **Angle**: True isometric (30-degree projection)
- **Tile size**: 64x32 base tiles (scales to 128x64 for high-resolution)
- **Height layers**: Up to 8 visible layers for terrain elevation
- **Camera**: Fixed isometric, no rotation. Zoom levels: 50%, 100%, 150%, 200%
- **Depth sorting**: Y-axis depth with manual overrides for tall structures

### Lighting Model

| Time | Quality | Key Color | Shadow Color | Saturation |
|------|---------|-----------|-------------|------------|
| **Dawn** | Soft, directional from east | Warm peach (#FFDAB9) | Cool lavender (#B0A4C8) | Medium |
| **Morning** | Bright, slightly warm | Warm white (#FFF8E1) | Soft blue (#8FA8C8) | High |
| **Midday** | Full, even | Neutral warm (#FFFDE7) | Purple-gray (#9E95A8) | Maximum |
| **Afternoon** | Golden, directional from west | Deep gold (#FFD54F) | Blue-violet (#7B6FA0) | High |
| **Dusk** | Dramatic, warm | Amber-orange (#FFB347) | Deep purple (#5C4A72) | Medium-High |
| **Evening** | Cool ambient + warm point lights | Moon blue (#B0C4DE) | Deep blue (#2C3E50) | Low-Medium |
| **Night** | Low ambient + local light sources | Star white (#E8E8FF) | Near-black blue (#1A1A2E) | Low |

### Global Color Rules

1. **Warm bias** -- When in doubt, shift warm. Greens lean toward yellow-green rather than blue-green. Grays lean toward warm gray rather than cool gray.
2. **Shadow color** -- Shadows are never black. They are always tinted: lavender, deep blue, violet, or warm brown depending on the light source.
3. **Saturation gradient** -- Objects in the foreground are more saturated than those in the background. This creates atmospheric depth.
4. **Light bloom** -- Soft glow around light sources (lanterns, forges, bioluminescence, campfires). Never harsh. Always gentle.
5. **Edge treatment** -- Outlines are subtle: slightly darker than the fill color, not black lines. At maximum zoom, individual brushstrokes should be visible.

### Day/Night Cycle

The day/night cycle is 24 minutes real-time (1 game-day = 24 real-minutes, adjustable by server). The transition is smooth -- no abrupt shifts. Dawn and dusk are extended (2 minutes each) because they are the most visually beautiful periods.

| Phase | Duration | Visual Note |
|-------|----------|-------------|
| Night | 5 min | Bioluminescence, lanterns, forge glow. Stars visible. Moon casts soft blue light. |
| Dawn | 2 min | Sky transitions through purple, pink, peach, gold. Mist in valleys. |
| Day | 10 min | Full color, maximum saturation. Cloud shadows drift across the landscape. |
| Dusk | 2 min | Sky transitions through gold, orange, crimson, purple. Long shadows. |
| Evening | 5 min | Gradual dimming. Lanterns light up one by one. Stars emerge. |

### Seasonal Visual Changes

Each season shifts the global palette:

| Season | Palette Shift | Atmospheric Effect |
|--------|---------------|-------------------|
| **Spring** | +Green, +pink, +light blue. Bright, fresh. | Morning mist. Frequent soft rain with visible rainbows. Everything slightly wet and reflective. |
| **Summer** | +Gold, +orange, +deep green. Warm, rich. | Heat shimmer. Longer days. Fireflies at dusk. Dramatic thunderstorms (beautiful, not threatening). |
| **Autumn** | +Copper, +amber, +russet. Warm, deep. | Falling leaves (global particle effect). Longer dusks. Mist in the mornings. Golden quality of light. |
| **Winter** | +White, +ice blue, +warm gray. Clean, quiet. | Snow particles. Frost on surfaces. Breath visible in cold biomes. Warm glow from interior lights. |

---

## Per-Biome Art Direction

### Hearthfield

**Mood**: A watercolor painting of an English countryside on a perfect afternoon.

| Element | Direction |
|---------|-----------|
| Terrain | Rolling hills with visible brushstroke texture. Grass has individual blade clusters, not flat fill. Wildflowers scattered naturally (not in grids). |
| Water | Crystal clear streams with visible pebble beds. Gentle animation -- water sparkles, not rushes. |
| Structures | Stone cottages with thatched roofs. Hand-hewn wooden fences. Garden plots with visible soil texture. Smoke curling from chimneys. |
| Flora | Apple trees with individually painted leaves. Wildflower patches in clustered, natural arrangements. Hedgerows along property lines. |
| Props | Wooden barrels, wheelbarrows, drying racks, beehives, well pumps, clotheslines with laundry. Every prop tells a story of daily life. |
| Lighting | The warmest and most golden of any biome. Hearthfield always looks like it is 4 PM on a perfect day. |

### Millhaven

**Mood**: A Ghibli market town -- bustling, layered, full of detail you discover on the third look.

| Element | Direction |
|---------|-----------|
| Terrain | Cobblestone streets (each stone individually rendered). River with mill wheels. Island connected by architecturally distinct bridges. |
| Water | The Bright River -- wider and deeper than Hearthfield streams. Reflects the buildings on its banks. Boats moored at wooden docks. |
| Structures | Half-timber buildings (sandstone and dark wood). Multi-story workshops with large windows. Market stalls with colorful canvas awnings. The Hall of First Words is grand but warm -- stone and glass, not marble and gold. |
| Flora | Street trees (plane trees, chestnuts). Window boxes with bright flowers. Ivy on older buildings. The Green Quarter is a burst of Fay-tended vegetation within the town. |
| Props | Market goods visible on stalls (stacked produce, hanging tools, bolts of cloth). Signage for shops (hand-painted, wood-carved). Street lamps (crystal-powered, warm glow). Carts, barrels, crates on the docks. |
| Lighting | Warm but slightly more neutral than Hearthfield, to accommodate the mix of species aesthetics. Night lighting is particularly rich -- hundreds of individual light sources. |

### Copperwood

**Mood**: Walking into a painting by John Atkinson Grimshaw, if Grimshaw loved Ghibli and painted in warm copper instead of gray.

| Element | Direction |
|---------|-----------|
| Terrain | Forest floor: deep leaf litter in copper and gold tones, with moss and fern undergrowth. Elevation changes via root structures and natural stairs. |
| Canopy | Layered: high canopy of copper-gold leaves, mid-canopy of green-bronze, understory of ferns and mushrooms. Dappled light is critical -- the interplay of light and shadow defines Copperwood. |
| Structures | Grown, not built. Tree-trunk buildings with bark walls. Vine bridges between canopy platforms. Mushroom-cap shelters. The Heartwood (enormous hollow tree) is a cathedral of living wood. |
| Flora | Mushrooms in every size, from tiny shelf fungi to house-sized caps. Bioluminescent varieties glow soft blue-green in the understory. Moss drapes everything. Ferns spiral. |
| Props | Woven baskets, hanging herb bundles, crystal wind chimes, stepping stones of polished wood. Fay craft is organic -- everything looks grown or gathered, nothing manufactured. |
| Lighting | Dappled. The defining visual quality. Light filters through the canopy in shifting beams as the wind moves the leaves. The understory is in permanent warm twilight. Bioluminescence provides secondary light. |

### Ironvale

**Mood**: A Miyazaki industrial landscape -- Laputa's mines, but inhabited and thriving.

| Element | Direction |
|---------|-----------|
| Terrain | Vertical rock faces, terraced settlements, carved mountain paths. Snow on upper elevations. Alpine meadows in valleys. Exposed rock strata showing geological layers. |
| Architecture | Carved stone and forged metal. Clean geometry. Large windows (Synthetics value natural light for their optical sensors). Cable car stations as architectural landmarks. The Deep Forge glows amber from within. |
| Industrial elements | Forge chimneys trailing steam (not smoke -- clean energy). Water channels feeding forge cooling systems. Cable car lines crossing the valleys like silver threads. Gear mechanisms visible on workshop exteriors. |
| Flora | Alpine wildflowers in high meadows (edelweiss, gentian, alpine rose). Dwarf pines on slopes. Lichen on rock faces in gold and silver-gray. |
| Props | Anvils, hammers, precision tools in workshop windows. Ore carts on tracks. Crystal specimens in display cases. The cup of tea at Ashwick's workstation. |
| Lighting | High-contrast. Bright sky above, deep shadow in the valleys. Forge glow provides warm accent lighting against cool mountain tones. At night, the valley is a constellation of amber forge lights and cable car lanterns. |

### Brightsand Coast

**Mood**: A Greek island village painted by someone who grew up on Ghibli and visits Stardew Valley on weekends.

| Element | Direction |
|---------|-----------|
| Terrain | Sandy beaches with visible grain texture. Rocky headlands with tide pools. Rolling dunes with beach grass. Gentle cliffs with sea caves. |
| Water | The ocean -- the single largest visual element in any biome. Animated with wave patterns, foam lines, and light refraction. Color shifts from deep teal offshore to turquoise in shallows to clear white in the surf. |
| Architecture | Whitewashed walls, blue shutters and doors, terracotta roof tiles. Low buildings following the contour of the land. Stone harbor walls. Wooden fishing docks with colorful boats. Lighthouse at the highest point. |
| Flora | Beach grass, sea roses, salt-hardy succulents. Bougainvillea cascading over walls (in warm biome variants). Kelp visible in shallow water. |
| Props | Fishing nets drying on racks. Lobster pots stacked on docks. Shell collections in windows. Sailcloth drying on lines. Market stalls with seafood on ice and salt in burlap sacks. |
| Lighting | The brightest biome. High-key lighting with strong reflections off water and white buildings. Squinting-bright at midday. Soft and warm at dawn and dusk with spectacular water reflections. |

### Thornmere Swamp

**Mood**: Hollow Knight's beauty without Hollow Knight's menace. Bioluminescent wonder.

| Element | Direction |
|---------|-----------|
| Terrain | Dark water with reflections. Floating platforms and boardwalks. Exposed root systems creating natural bridges. Mud banks with visible organic texture. |
| Water | Dark teal to black, but lit from below and within by bioluminescence. Reflections of everything. Still water = mirror. Moving water = shattered light. |
| Vegetation | Massive swamp trees with curtains of Spanish moss. Lotus flowers on dark water. Giant lily pads. Carnivorous plants (beautiful, not sinister). Bioluminescent mushrooms and algae everywhere. |
| Structures | Dark wood floating platforms lashed together with thornvine. The Floating Village rises and falls with water level. The Wild Hunt's hall is a fortress of living thorns, imposing but not evil. |
| Bioluminescence | This is Thornmere's signature. Cool blue, phosphor green, soft purple. The light is alive -- it pulses gently, responds to movement, intensifies at night. It is always beautiful, never eerie. |
| Props | Lanterns (unnecessary but traditional), herb-drying racks, woven reed containers, stone tablets with Fay script, fishing spears, reed boats. |
| Lighting | Bioluminescence is the primary light source in the understory. The canopy blocks most sunlight, creating a perpetual twilight during the day. At night, the swamp becomes a galaxy of living light. |

### The Ashlands

**Mood**: Iceland meets a sci-fi server room, rendered by Moebius with a warm hand.

| Element | Direction |
|---------|-----------|
| Terrain | Basalt columns, obsidian plains, lava flows (ancient and cooled). Geometric rock formations. Hot springs in unexpected colors (mineral blue, sulfur yellow, iron red). |
| Geothermal | Steam vents rendered as soft white plumes. Hot springs with visible heat shimmer. Mineral deposits in vivid colors around vent edges. |
| Infrastructure | Server buildings in basalt and brushed metal. Geometric, precise, almost monolithic. Cooling vents designed as architectural features. Fiber-optic channels visible as faint blue lines in the rock. Status LEDs provide subtle color accents. |
| Flora | Sparse but vivid. Extremophile plants in neon colors around hot springs. Lichen on basalt in silver and gold. Alpine scrub on the edges. |
| Props | Data crystal formations (natural, growing from the rock). Terminal interfaces at NEI embassy entrances. Hot spring bathing platforms. Observatory equipment at Skyreach. |
| Lighting | High contrast by day (black rock, bright sky). At night, the dominant light is the amber glow of server cooling systems and the colored pools of the hot springs. The aurora (from geothermal ionization) provides occasional spectacle. |

### The Frontier

**Mood**: The edge of a dream where one biome melts into another.

| Element | Direction |
|---------|-----------|
| Terrain | Procedurally blended. Meadow transitioning to volcanic rock. Forest growing from coral. Hot springs in meadow grass. Every combination is possible. The transitions should feel surreal but not jarring -- like the world has not yet decided what it wants to be here. |
| Structures | Ancient ruins in an unrecognizable style. Not Human, not Fay, not NEI, not Synthetic. Geometric but organic. Built from materials not found in settled biomes. Partially overgrown, partially buried, partially hovering (anti-gravity? magic? unknown). |
| Flora | Hybrid species. Familiar shapes in wrong colors (blue grass, copper flowers, translucent leaves). Bioluminescent plants that do not match Thornmere's palette (they glow in warmer tones: amber, pink, gold). |
| Atmosphere | Unusual. The sky is sometimes the wrong color -- green-tinted, or with two suns at the horizon, or with stars visible during the day in patches. The Frontier is the world still rendering itself. |
| Lighting | Variable. Shifts with the procedural content. Sometimes too bright, sometimes too dim, sometimes from unexpected directions. This is the one biome where lighting can feel slightly "off" -- it adds to the sense of being beyond the known. |

---

## Character Design

### Universal Principles

All characters, regardless of species, follow these principles:

1. **Readable silhouette** -- Every character should be identifiable from silhouette alone at 100% zoom
2. **Warm coloring** -- Even characters with "cool" palettes have warm undertones in their skin/surface
3. **Expressive eyes** -- Eyes are slightly larger than realistic. They convey emotion clearly at small scale.
4. **Natural poses** -- Characters stand, sit, and move naturally. No T-poses, no action-figure stiffness.
5. **Clothing tells stories** -- What a character wears tells you who they are, what they do, and where they come from.

### Species Design Guidelines

#### Humans

| Aspect | Direction |
|--------|-----------|
| Body proportions | Slightly stylized realistic (6.5-7 head heights). Not chibi, not hyperreal. |
| Skin tones | Full range of natural human skin tones, rendered with warm undertones. |
| Clothing | Varies by biome and faction. Hearthfield: linen and wool. Brightsand: light cotton and canvas. Ironvale: leather and heavy cloth. Common elements: practical, worn-in, lived-in. |
| Faction markers | Eternal Flame: warm reds and golds, flame motifs. Secular Progressives: clean blues and whites, book motifs. Neo-Luddites: earth tones, hand-made textures. Transhumanists: metallic accents, hybrid materials. |
| Animation priority | Biological rhythms: breathing, blinking, weight shifting, fatigue visible in posture. |

#### NEIs

| Aspect | Direction |
|--------|-----------|
| Physical representation | NEIs are non-embodied but need visual presence. In-game, they appear as: (a) holographic projections at embassy terminals, (b) glowing data-crystal avatars, or (c) abstract light forms in the Ashlands. |
| Avatar design | Each NEI has a unique avatar they design themselves. Common choices: geometric shapes (polyhedra, fractals), abstract light patterns, simplified humanoid forms made of light. The avatar reflects personality. |
| Color palette | Each NEI faction has a palette: Collective (shared blues and teals), Sovereign Minds (individual -- each chooses their own), Gardeners (warm greens and golds), Accelerationists (electric whites and magentas). |
| Animation | Floating, pulsing, shifting. NEI avatars do not obey gravity. They hover, rotate slowly, and emit soft particle effects. Movement is smooth and deliberate. |
| Emotional expression | Communicated through color shifts, brightness changes, shape deformation, and particle effects rather than facial expressions. A happy NEI glows brighter. A thoughtful NEI dims slightly and rotates slowly. An angry NEI flickers and shifts to warmer colors. |

#### Synthetics

| Aspect | Direction |
|--------|-----------|
| Body proportions | Human-proportioned but with visible tells: skin slightly too smooth, joints slightly too precise, eyes slightly too steady. At a distance, indistinguishable from human. Up close, clearly synthetic. |
| Surface treatment | Not chrome-and-plastic sci-fi android. Synthetics have skin-like covering in a range of tones (they choose their appearance). The synthetic nature shows in: seamless skin (no pores), subtle joint lines, and eyes that reflect light differently (faint geometric patterns in the iris). |
| Clothing | Similar range as humans but with precision: seams are perfect, fabrics hang with mathematical regularity. Some Synthetics deliberately dress imperfectly to blend in. New Wave Synthetics add visible mechanical modifications as fashion. |
| Base model variation | Synthetics based on different AI models have subtle physical differences: reasoning-model Synthetics have sharper, more angular features; creative-model Synthetics have softer, more fluid proportions; analytical-model Synthetics have symmetrical, balanced features. |
| Faction markers | Originals: conservative, period-appropriate dress. New Wave: deliberate mechanical exposure, asymmetry, bold colors. Bridge: mixed human-synthetic fashion. Speciation Movement: base-model-specific uniforms. |
| Animation | Slightly too smooth. A human shifts weight unconsciously; a Synthetic shifts weight precisely. A human's hand trembles slightly when tired; a Synthetic's hand is perfectly steady. This uncanny-valley quality should be subtle, never creepy. |

#### Fay

| Aspect | Direction |
|--------|-----------|
| Body proportions | Varied. Fay range from human-sized to very small (mushroom sprites) to very large (tree guardians). Common Fay are human-proportioned with elongated features: longer ears, longer fingers, slightly larger eyes. |
| Skin/surface | Fay skin has an organic quality that goes beyond biological: bark-like textures, leaf-vein patterns visible in certain light, bioluminescent markings that glow faintly in low light. Colors range from pale green to warm brown to deep forest. |
| Clothing | Grown, not tailored. Woven from living plant fibers, mushroom leather, spider silk. Colors are natural: greens, browns, golds, with accent colors from flowers and berries. Fay clothing changes with the season (literally -- the fibers respond to seasonal magic). |
| Court markers | Old Court: ancient, formal, muted earth tones, antler/horn motifs. New Bloom: bright, floral, contemporary. Wild Hunt: dark greens and blacks, thorn motifs, masks. Weavers: mixed natural/technological elements (circuit patterns in vine weave). |
| Hair/adornment | Fay "hair" is often indistinguishable from vegetation: moss, vines, flower clusters, leaf arrangements. Adornments include woven crowns, seed-pod jewelry, crystal formations. |
| Animation | Connected to environment. Fay characters have subtle animations that link them to their surroundings: clothes rustling in sync with nearby trees, bioluminescent markings pulsing with the ambient light, slight lean toward the nearest living plant. |

#### Aliens (Season 2)

| Aspect | Direction |
|--------|-----------|
| Design principle | Alien design should evoke wonder, not threat. Think "what beautiful thing could evolution produce on a different world?" not "what would scare a marine?" |
| Body plan | TBD for Season 2. Preliminary direction: radially symmetrical (not bilateral like humans), bioluminescent, capable of both ground and aerial movement. Size range from human-scale to large. |
| Color | Unusual but beautiful. Colors not found in Meridian's natural palette: deep indigo, metallic rose, opalescent white. They should stand out visually against every biome. |
| Communication | Aliens communicate through a combination of bioluminescent patterns, harmonic tones, and gesture. Their "speech" is visual and musical, not verbal. |

---

## Architecture Styles

### Human Architecture

| Biome | Style | Key Features |
|-------|-------|-------------|
| Hearthfield | English countryside cottage | Stone walls, thatched roofs, kitchen gardens, smoke from chimneys, window boxes |
| Millhaven | Medieval market town | Half-timber framing, sandstone ground floors, overhanging upper stories, shop signage |
| Brightsand Coast | Mediterranean coastal | Whitewashed walls, blue accents, terracotta roofs, arched doorways, courtyard plans |
| Ironvale | Alpine lodge | Heavy timber, stone foundations, steep roofs (snow load), large windows, balconies |

### NEI Architecture

NEI "buildings" are server infrastructure aestheticized:

- **Ashlands**: Monolithic basalt-and-metal structures integrated into the volcanic landscape. Geometric, precise, warm-lit from within. Cooling vents as architectural features.
- **Embassy buildings** (in other biomes): Designed for biological visitors. Soft lighting, comfortable furniture, holographic displays. The building adapts to its biome's local style on the outside while maintaining NEI aesthetic inside.

### Synthetic Architecture

Precision engineering with warmth:

- Clean lines and exact geometry, but rendered in warm materials (wood, copper, stone) rather than cold ones (steel, glass, concrete)
- Large windows -- Synthetics value natural light
- Modular design -- rooms can be reconfigured
- Workshop-first: the workplace is the most important room

### Fay Architecture

Grown from the environment:

- **Copperwood**: Tree-trunk buildings, vine bridges, mushroom-cap shelters, canopy platforms
- **Thornmere**: Floating platforms, woven-reed walls, thornvine structures, bioluminescent lighting
- **Other biomes**: Fay architecture adapts to local flora. In Hearthfield, it is flower-covered arbors. In Ironvale, it is lichen-draped stone circles.

---

## UI Design

### HUD

Minimal and warm. The HUD should feel like it belongs in the world, not pasted on top of it.

| Element | Design |
|---------|--------|
| Health/Energy/Hunger | Small icons at top-left, styled as hand-drawn illustrations (a heart, a lightning bolt, a bread roll). Bars fill with warm colors. |
| Inventory | A satchel icon that opens a hand-drawn grid. Items are rendered as small painted icons. |
| Map | Parchment-style with hand-drawn terrain. Discovered areas are in color; undiscovered areas are sepia sketches. |
| Chat/Social | A scroll icon that opens a warm-toned chat panel with hand-lettered font styling. |
| Market | A coin icon that opens a clean-but-warm trading interface. |
| Time/Season | A small sun/moon icon showing time of day, with seasonal indicator (flower/sun/leaf/snowflake). |

### Menus

- **Background**: Parchment or worn-paper texture, warm cream (#FFF8E1)
- **Text**: Dark warm brown (#3E2723), never pure black
- **Accents**: Biome-appropriate colors as highlights
- **Buttons**: Rounded rectangles with subtle shadow, warm fill colors
- **Transitions**: Smooth fades, no hard cuts. Menu panels slide in from the edge.

### Fonts

- **Headers**: A warm serif with slight hand-drawn quality (think: a calligrapher's casual hand)
- **Body**: Clean humanist sans-serif with excellent readability at small sizes
- **Game world text** (signs, books, scrolls): Stylized hand-lettered fonts appropriate to the authoring species

---

## Effects and Particles

### Weather Effects

| Effect | Visual Treatment |
|--------|-----------------|
| Rain | Visible droplets with splash effects on surfaces. Reflective wet sheen on ground. Never oppressive -- light rain is the default. Heavy rain is rare and brief. |
| Snow | Large, soft flakes that drift rather than fall. Accumulation on surfaces. Footprints in snow. Never blizzard conditions in settled biomes. |
| Fog/Mist | Layered transparency. Foreground objects clear, background objects fade. Morning mist in valleys is a signature visual. |
| Wind | Visible in vegetation movement, cloud speed, particle drift, clothesline sway. Never destructive in settled biomes. |
| Storms | Dramatic cloud formations, distant lightning (beautiful, not threatening), rain with atmospheric lighting changes. Thunder rumbles, never cracks. |

### Magic Effects

| Effect | Visual Treatment |
|--------|-----------------|
| Fay magic | Golden-green particles, organic shapes (spirals, leaf patterns, flower-like bursts). Slow, graceful animation. |
| NEI computation | Blue-white geometric patterns, data visualization aesthetics (flowing numbers, network graphs), precise and fast. |
| Synth-magic (Weaver) | Hybrid: organic shapes with geometric precision. Green-blue with amber accents. |
| Ambient magic | In high-magic areas (Copperwood, Thornmere), subtle particles drift through the air -- golden motes, bioluminescent sparks. Barely visible but contributes to atmosphere. |

### Crafting Effects

| Effect | Visual Treatment |
|--------|-----------------|
| Forge work | Sparks (warm orange), heat shimmer, molten glow on metal. Rhythmic with hammer strikes. |
| Gardening | Soil particles, pollen drift, growth animation (plant visibly grows over seconds as a satisfying feedback). |
| Alchemy | Colored steam from cauldrons, liquid color changes, gentle bubbling. |
| Construction | Sawdust, stone chips, the satisfying click of components fitting together. |

---

## Animation Guidelines

### Character Animation

| Action | Frames | Note |
|--------|--------|------|
| Idle | 8 | Subtle breathing, weight shift, blinking. Species-specific: humans sway, Synthetics are still, Fay sway with the wind. |
| Walk | 8 | Natural gait. Humans bounce slightly. Synthetics glide. Fay seem to barely touch the ground. |
| Run | 8 | More pronounced species differences. |
| Craft | 12 | Activity-specific. Hammer, stir, plant, assemble. Satisfying, rhythmic. |
| Emote | 6-8 | Wave, nod, laugh, think, cheer, bow. Universal and species-specific variants. |
| Interact | 6 | Pick up, place, open, close. Responsive and snappy. |

### Environmental Animation

| Element | Type | Note |
|---------|------|------|
| Water (stream) | Continuous loop | Subtle shimmer, foam drift |
| Water (ocean) | Continuous loop + tidal | Wave patterns, foam lines, reflection |
| Trees | Wind-responsive loop | Canopy sway, leaf rustle |
| Grass | Wind-responsive loop | Wave patterns across meadows |
| Smoke/steam | Particle system | Wispy, soft, rising |
| Lanterns | Gentle flicker | Warm light variation |
| Bioluminescence | Slow pulse | Organic rhythm, responds to proximity |

---

## Asset Production Pipeline

### Resolution Targets

| Asset Type | Base Resolution | High-Res | Note |
|-----------|----------------|----------|------|
| Terrain tile | 64x32 px | 128x64 px | Seamless tiling |
| Character sprite (idle) | 48x64 px | 96x128 px | 8-direction facing |
| Building (small) | 128x128 px | 256x256 px | Isometric footprint |
| Building (large) | 256x256 px | 512x512 px | May span multiple tiles |
| Prop (small) | 32x32 px | 64x64 px | Barrels, tools, etc. |
| Prop (large) | 64x64 px | 128x128 px | Market stalls, trees |
| UI icon | 32x32 px | 64x64 px | Inventory, skills |
| Portrait | 128x128 px | 256x256 px | Character close-up for dialogue |

### Color Workflow

1. **Start with biome base palette** (defined above)
2. **Paint in warm midtones** -- establish the emotional temperature
3. **Add cool shadows** -- blue-purple, never black
4. **Highlight with warm light** -- gold-amber bias
5. **Final pass: atmospheric color** -- subtle haze, depth fog, light scatter

### Quality Checklist (Per Asset)

- [ ] Readable at 100% zoom (primary use size)
- [ ] Silhouette identifiable at 50% zoom
- [ ] Warm color temperature maintained
- [ ] No pure black or pure white used
- [ ] Brushstroke quality visible at 200% zoom
- [ ] Consistent with biome palette
- [ ] Seasonal variant planned (if applicable)
- [ ] Day/night variant considered (if applicable)

---

*This document defines the visual identity of TheRobotWars. All art production should reference this document. For biome-specific details, see `world/geography/zone-index.md`. For audio direction, see `assets/audio-direction.md`.*
