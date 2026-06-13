# Audio Direction: TheRobotWars

> *"The world should sound like a place you want to stay."*

---

## Core Audio Identity

### Philosophy

Meridian sounds warm. The audio direction follows the same principle as the visual direction: warmth first, complexity second, beauty always. Every sound in the game -- from the background music to the UI click -- should reinforce the feeling that this is a world worth inhabiting.

The sonic palette is **acoustic-first**: real instruments recorded with care, not synthesized approximations. Guitars, fiddles, flutes, cellos, hand drums, and voices. Electronic elements exist (NEI environments, server hums, data processing) but they are warm and musical, never cold or industrial. Even the most technological sounds in the Ashlands have an organic undertone -- a resonance, a warmth, a suggestion that the machines are singing, not just running.

### Reference Touchstones

| Reference | What We Take From It |
|-----------|---------------------|
| **Stardew Valley OST** (ConcernedApe) | The warmth. The way each track feels like a place and a time of day. The simplicity that becomes richness through repetition. The seasonal emotional shifts. |
| **Studio Ghibli soundtracks** (Joe Hisaishi) | The emotional sweep. The way a simple piano melody can make you feel homesick for a place that does not exist. The integration of Western and Japanese musical traditions. The restraint. |
| **Hollow Knight OST** (Christopher Larkin) | Atmospheric integration. The way music and ambience merge. How to make a space feel vast or intimate through sound alone. |
| **Ori and the Blind Forest OST** (Gareth Coker) | Emotional precision. Every note serves the feeling. The way strings and choir create transcendence without excess. |
| **Minecraft OST** (C418) | Spaciousness. The silence between notes. The way ambient music can make you feel alone in a good way -- contemplative, not lonely. |

### What We Avoid

| Avoid | Why |
|-------|-----|
| Orchestral bombast | This is not an epic fantasy battle game. No brass fanfares. No timpani rolls. |
| Chiptune/8-bit | We respect the aesthetic. It does not match our visual painterly direction. |
| EDM/industrial | Even in the Ashlands, the technology sounds organic. No harsh synths, no driving beats. |
| Horror audio | No dissonant stingers, no creeping dread, no jump-scare sounds. Thornmere is mysterious, not frightening. |
| Vocal lyrics in gameplay music | Humming and wordless vocals are fine. Lyrics are distracting during gameplay. Festival music may include lyrics. |

---

## Music Architecture

### Layer System

All biome music uses a three-layer system that crossfades dynamically:

| Layer | Purpose | Example (Hearthfield) |
|-------|---------|----------------------|
| **Ambient bed** | Always playing. Establishes the biome's sonic character. Very quiet. | Soft pad of sustained strings, barely audible, with gentle wind |
| **Melodic layer** | Fades in during calm moments. The "theme" of the biome. | Fingerpicked acoustic guitar playing the Hearthfield melody |
| **Activity layer** | Triggered by player actions. Adds rhythmic or harmonic elements. | Gentle hand-drum pattern when crafting; additional guitar harmony when trading |

The layers blend seamlessly. A player walking through Hearthfield hears the ambient bed plus the melody. When they start crafting, the activity layer fades in over 4-8 seconds. When they stop, it fades out. The music always feels continuous, never triggered or mechanical.

### Transition Rules

| Transition | Duration | Method |
|-----------|----------|--------|
| Biome to biome | 8-12 seconds | Crossfade. Both biome melodies play simultaneously during transition, creating a brief harmonic meeting. |
| Day to night | 4-6 seconds | Key shift. Day music is in major keys; night music shifts to relative minor or modal variants. |
| Season to season | 16-20 seconds | Full theme transition. New seasonal variant of the biome theme fades in as the old fades out. |
| Calm to activity | 4-8 seconds | Layer addition. Activity layer fades in beneath existing layers. |
| Activity to calm | 6-10 seconds | Layer removal. Activity layer fades out. Slightly longer than fade-in for a "settling" feeling. |
| Event trigger (festival, discovery) | 2-4 seconds | Stinger + new theme. Brief musical accent, then new music fades in. |

---

## Per-Biome Music

### Hearthfield

**Musical identity**: A gentle acoustic guitar melody in G major, played fingerstyle. Think: sitting on a porch at golden hour, watching the sun set over a meadow. The melody is simple enough to hum but interesting enough that it does not become annoying after 100 hours of play.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | Acoustic guitar (nylon string) | Warm, fingerpicked, unhurried |
| Harmony | Second guitar or mandolin | Adds texture in the melodic layer, doubles melody in thirds |
| Bass | Upright bass (pizzicato) | Gentle pulse, root notes, appears in activity layer |
| Color | Wooden flute (recorder or tin whistle) | Occasional countermelody, bird-like quality |
| Ambient bed | Sustained cello drone + field recording (wind, distant birds) | Almost subliminal warmth |
| Percussion | None in melodic layer; soft hand drum in activity layer | Light, organic rhythm for crafting/farming |

**Time-of-day variations**:
- **Dawn**: Solo guitar, very quiet, with birdsong from ambient bed
- **Morning**: Full melodic layer, bright and crisp
- **Afternoon**: Slightly slower tempo, warmer tone, mandolin joins
- **Dusk**: Key shifts toward D major, flute carries the melody, golden quality
- **Night**: Relative minor (E minor), slower, cello more prominent, crickets in ambient bed

**Seasonal variations**:
- **Spring**: Lighter, faster, more ornamental. Flute is more present. Feels like new growth.
- **Summer**: Fuller, richer. All instruments present. Maximum warmth and contentment.
- **Autumn**: Slightly melancholy (not sad -- wistful). Mandolin carries more weight. Tempo eases.
- **Winter**: Sparse. Solo guitar with cello. Quiet and intimate. Feels like sitting by a fire.

### Millhaven

**Musical identity**: A lively fiddle-led theme in D major with market-bustle energy. Think: the best day at the farmer's market, with live music playing and everyone in a good mood.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | Fiddle | Bright, energetic but not frantic. Dance-like phrasing. |
| Harmony | Accordion (small, not bombastic) | Warm chordal support, slight musette quality |
| Bass | Upright bass (walking bassline) | More active than Hearthfield -- reflects the busier pace |
| Color | Pennywhistle / clarinet | Market-stall-to-market-stall energy, playful runs |
| Ambient bed | Market sounds blended with sustained strings | Chatter, footsteps, distant hammer, water from the river |
| Percussion | Bodhran (hand drum) | Light but present. Toe-tapping pulse. |

**Time-of-day variations**:
- **Dawn**: Quiet. The market is not open yet. Solo accordion playing a slower version of the theme.
- **Morning**: The market opens. Fiddle enters, tempo picks up, energy builds.
- **Afternoon**: Peak energy. Full ensemble. The most "Stardew Valley market day" feeling.
- **Dusk**: Energy softens. Fiddle plays a slower, more lyrical version. Tavern warmth enters.
- **Night**: Shifts to a warm, intimate arrangement. Guitar replaces fiddle as lead. Tavern ambience.

**Seasonal variations**:
- **Spring**: Bright and forward-leaning. Spring Trade Fair adds extra energy.
- **Summer**: Full and celebratory. River festival music (boat-race excitement).
- **Autumn**: Richer, deeper. Election-season gravity. More accordion, less fiddle.
- **Winter**: Indoor warmth. The theme goes acoustic and intimate. Winterlight Festival adds glockenspiel.

### Copperwood

**Musical identity**: A contemplative Celtic-inspired theme in A minor (Dorian mode), centered on wooden flute with harp accompaniment. Think: walking alone through an ancient forest at twilight, feeling small and awed and completely safe.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | Wooden flute (low register) | Slow, breathing phrasing. Notes hang in the air. |
| Harmony | Celtic harp | Arpeggiated chords, shimmering. Feels like light through leaves. |
| Bass | Cello (sustained, with bow) | Deep warmth. The voice of old trees. |
| Color | Ambient vocals (wordless, female voice) | Distant, ethereal. Fay presence. |
| Ambient bed | Forest sounds: leaf rustle, distant water, bird calls (specific species), wind through canopy | Layered and rich. The forest is an instrument. |
| Percussion | None (or very subtle shaker, like seeds in a pod) | Silence between notes is the rhythm. |

**Time-of-day variations**:
- **Dawn**: Harp solo with birdsong. Morning dew has a sound (high, crystalline tones).
- **Day**: Full arrangement but quiet. The canopy absorbs sound. Music feels muffled by leaves.
- **Dusk**: Flute and cello duet. Golden light = golden sound. The most emotionally rich moment.
- **Night**: Bioluminescence has a sound: soft, high-pitched tones that pulse with the glow. Ambient vocals more present. The forest hums.

**Seasonal variations**:
- **Spring**: Brighter mode (closer to major). Harp is more active. New growth = new musical ideas.
- **Summer**: Deep and shaded. Lower register. Cello dominates. Bioluminescence tones louder at night.
- **Autumn**: The "true" version. Full Dorian mode. Maximum beauty. Falling leaves have a gentle percussion quality.
- **Winter**: Very sparse. Solo flute. Long silences. The forest is listening, not speaking.

### Ironvale

**Musical identity**: A deliberate, rhythmic theme in C minor with forge-hammer percussion and mountain-horn accents. Think: the pride of skilled craft, the weight of stone, the warmth of fire against cold.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | French horn (warm, not bombastic) | Majestic but grounded. Mountain echoes. |
| Harmony | Low brass (trombone, euphonium) | Warm chordal support. Not martial -- contemplative. |
| Bass | Timpani (tuned, melodic) + cello | Resonant depth. Feels like the mountain itself. |
| Color | Hammer strikes (tuned, rhythmic) | Not random -- musical. The forge is an instrument. |
| Ambient bed | Mountain wind, distant cable car mechanisms, rhythmic forge sounds | The mountain works. The work has rhythm. |
| Percussion | Anvil strikes (pitched), hand drum | Rhythmic but not driving. Steady, patient craft. |

**Time-of-day variations**:
- **Dawn**: Horn solo echoing off valley walls. Peaceful. The mountain before the work begins.
- **Morning**: Forge sounds begin. Rhythmic element enters. Energy builds with the morning's work.
- **Afternoon**: Full arrangement. The mountain is alive with industry. But it is warm industry, not relentless.
- **Dusk**: Horn returns with a sunset melody. Forges bank for the evening. Warmth and tiredness.
- **Night**: Quiet strings with the faint amber glow sound of banked forges. Cable car bells in the distance. Stars are bright above the mountains.

**Seasonal variations**:
- **Spring**: Brighter. The high meadows are alive. Horn is joined by piccolo for alpine lightness.
- **Summer**: Festival of the Forge. Celebratory percussion. Communal pride. The most energetic version.
- **Autumn**: Deepening. Preparations for winter. The horn takes on a thoughtful quality. Stockpiling has its own dignity.
- **Winter**: Intimate. The forges burn hotter against the cold. Music draws inward. Solo cello + forge percussion.

### Brightsand Coast

**Musical identity**: A breezy, open theme in F major with classical guitar and maritime color. Think: Mediterranean morning, sails filling with wind, light on water, the taste of salt.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | Classical guitar (nylon string) | Bright, open, slightly Spanish feel. Arpeggiated patterns suggest waves. |
| Harmony | Bouzouki or oud | Maritime Mediterranean color. Adds gentle ornamentation. |
| Bass | Acoustic bass guitar | Relaxed, grooved. Ocean-swell rhythm. |
| Color | Accordion (light, airy) | Harbor-town color. Not Parisian -- coastal. |
| Ambient bed | Ocean waves (the dominant ambient element), seagulls, harbor bells, rigging creaking | The ocean never stops. All music sits on top of waves. |
| Percussion | Cajon or frame drum | Gentle pulse. Wave rhythm. Never heavy. |

**Time-of-day variations**:
- **Dawn**: Solo guitar with wave ambience. The sun rising over water. Sparse and luminous.
- **Morning**: The fleet goes out. Bouzouki enters, tempo picks up slightly, energy of purpose.
- **Afternoon**: Full arrangement. Peak warmth. The light-on-water feeling at maximum.
- **Dusk**: The fleet returns. Accordion plays a homecoming melody. Warmth of arriving safely.
- **Night**: Gentle guitar with wave ambience. Stars reflected on water. Phosphorescent glow sounds (like Thornmere's bioluminescence but warmer-toned).

**Seasonal variations**:
- **Spring**: Fresh and forward. New fishing season energy. Guitar is bright and percussive.
- **Summer**: Full and celebratory. Festival of Tides music: communal, joyful, bonfire-and-starlight quality.
- **Autumn**: Storm-season drama. Guitar takes on flamenco intensity. Beautiful danger. The accordion becomes wistful.
- **Winter**: Intimate harbor music. The guitar plays inside (reverb suggests indoor space). Storm sounds in the ambient bed. Safe-inside-while-wind-howls feeling.

### Thornmere Swamp

**Musical identity**: An atmospheric, modal theme in E Phrygian with bowed strings, ambient processing, and organic textures. Think: floating through a bioluminescent dream that is beautiful and strange and ancient.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | Cello (very slow, with long sustained bowing) | Deep, resonant, ancient. Notes last for entire measures. |
| Harmony | Viola da gamba or hurdy-gurdy drone | Continuous, humming. The sound of old, slow thought. |
| Bass | Double bass (arco, very low) | Below hearing as much as within it. Felt more than heard. |
| Color | Glass armonica or bowed glass | Crystalline, otherworldly. Represents the bioluminescence sonically. |
| Ambient bed | Frog chorus (layered, rich, realistic), water dripping, insect hum, distant will-o-wisp tones | The swamp is the fullest ambient environment. More sound here than anywhere. |
| Percussion | Water drops (pitched), subtle frame drum | The dripping is rhythmic. The rhythm is organic. |

**Time-of-day variations**:
- **Dawn**: Quiet. Morning mist mutes everything. Solo cello emerges from the frog chorus.
- **Day**: Perpetual twilight sound. The canopy blocks the sun; the music never fully brightens. Glass armonica adds sparkle where bioluminescence catches stray light.
- **Dusk**: No meaningful change from day (the swamp is always dusk). Frog chorus shifts species.
- **Night**: Maximum bioluminescence = maximum glass armonica. The swamp glows and sings. The most sonically rich period. Beautiful.

**Seasonal variations**:
- **Spring**: Water levels high. More water sounds. Frog chorus at maximum. New growth hum.
- **Summer**: Dense, full, warm. The hurdy-gurdy drone is most prominent. Everything is alive and humming.
- **Autumn**: Water recedes. Dripping increases. Ancient ruins surface -- they have their own resonance (low stone harmonics). Cello is most dominant.
- **Winter**: Ice over still water mutes the surface. Bioluminescence glows beneath ice. The glass armonica plays high, crystalline notes. Festival of Deep Memory: a storytelling theme (solo voice, wordless but narrative in feeling).

### The Ashlands

**Musical identity**: A minimalist, resonant theme built from processed natural sounds and warm electronic textures. Think: the sound of thinking made audible. Not cold -- contemplative. The hum of a million minds.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | Processed piano (reverb-heavy, each note rings for seconds) | Sparse, deliberate. Each note matters. Philip Glass meets Brian Eno. |
| Harmony | Warm synthesizer pads (analog, not digital) | The "hum" of the servers, musicalized. Ever-present, shifting slowly. |
| Bass | Sub-bass drone (geothermal resonance) | Felt in the chest. The mountain is alive. |
| Color | Metallic textures (processed cymbal, singing bowl) | Bright accents against the deep warmth. Thought-sparks. |
| Ambient bed | The server hum (continuous, harmonically rich), geothermal vent sounds, wind on obsidian | The hum is the Ashlands' defining sound. It is musical. |
| Percussion | None in melodic layers; processed clicks in activity layer | Data processing made rhythmic. Never mechanical -- organic patterns. |

**Time-of-day variations**:
- **Dawn**: The hum shifts key. Piano plays a morning sequence. Light on obsidian has a sound (high, glassy).
- **Day**: Full ambient. The hum is brightest. Piano is most active. Singing-bowl accents mark moments of clarity.
- **Dusk**: Aurora tones enter (high, wavering, beautiful). The hum shifts down. Piano becomes slower.
- **Night**: Minimal. The hum, the sub-bass, and occasional piano notes. Stars reflected in obsidian. The most meditative music in the game.

**Seasonal variations**:
- **Spring**: The hum brightens. New computational projects starting. Piano is more active, exploratory.
- **Summer**: Festival of Computation: the hum becomes a symphony. All the server farms harmonize (or try to). The most musically complex moment in the Ashlands.
- **Autumn**: Deep processing season. The hum deepens. Piano plays longer, more considered phrases.
- **Winter**: Maximum contrast (black rock, white snow, amber glow). The music mirrors this: spare, clear, precise. Beautiful austerity.

### The Frontier

**Musical identity**: Fragmentary, shifting, procedurally influenced. The Frontier's music borrows elements from all other biomes and recombines them, creating something familiar but not quite right -- like hearing a song you know played in a key you have never heard.

| Element | Instrument | Character |
|---------|-----------|-----------|
| Primary melody | Variable (borrowed from other biomes and transformed) | A Hearthfield guitar melody played backward. A Copperwood flute in the wrong mode. Recognizable but altered. |
| Harmony | Ambient pads (neither acoustic nor electronic) | Unplaceable. Warm but strange. |
| Bass | Very deep, very slow tones | The edge of the world has weight. |
| Color | Sounds from no identifiable instrument | The Frontier has its own voice. What instrument makes that sound? Unknown. |
| Ambient bed | A blend of all biome ambiences, fading in and out unpredictably | Birdsong, then ocean, then frog chorus, then the hum. The world is blending. |
| Percussion | Irregular, organic patterns | Heartbeat-like. The world is alive and uncertain. |

**The Frontier does not have fixed seasonal or time-of-day variations.** Its music shifts based on the procedurally generated terrain the player is in. Meadow-like terrain pulls in Hearthfield elements. Volcanic terrain pulls in Ashlands elements. The blending is the music.

---

## Species Musical Motifs

Each species has a **signature motif** -- a short (4-8 bar) melodic phrase that identifies them. These motifs appear in biome music, character themes, faction themes, and UI sounds.

### Human Motif

- **Interval**: Rising major third followed by a perfect fifth (warm, open, hopeful)
- **Instrument**: Acoustic guitar or fiddle
- **Character**: Grounded, warm, slightly yearning. The sound of reaching toward something good.
- **Usage**: Plays softly when entering a human-majority settlement, during human faction events, in the character creation screen for humans.

### NEI Motif

- **Interval**: Ascending whole-tone scale fragment (4 notes, evenly spaced)
- **Instrument**: Processed piano or singing bowl
- **Character**: Precise, contemplative, slightly alien. The sound of structured thought.
- **Usage**: Plays when interfacing with NEI services, entering the Ashlands, during NEI faction events.

### Synthetic Motif

- **Interval**: Human motif played with NEI instrumentation (or NEI motif played with human instrumentation)
- **Instrument**: Classical guitar with light reverb processing
- **Character**: Familiar but different. Warm but precise. The sound of being between two worlds.
- **Usage**: Plays in Synthetic communities, during identity-related quests, in the Calibration Halls.

### Fay Motif

- **Interval**: Descending Dorian mode fragment, ending on an unresolved suspension
- **Instrument**: Wooden flute or harp
- **Character**: Ancient, patient, slightly melancholy. The sound of deep time.
- **Usage**: Plays when entering Fay territory, during magical events, near Listening Stones.

### Alien Motif (Season 2)

- **Interval**: TBD. Preliminary direction: intervals not used by any other species (quarter-tones, microtonal). Beautiful but harmonically foreign.
- **Instrument**: TBD. Something that sounds like no Meridian instrument.
- **Character**: Wonder. Pure wonder. The sound of something genuinely new.
- **Usage**: Plays when Alien content is encountered, near Signal Sources in the Frontier.

---

## Ambient Sound Design

### Environmental Ambience by Biome

Each biome has a layered ambient soundscape that plays continuously beneath the music:

#### Hearthfield
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | Wind through grass | Low | Constant, gentle |
| Mid | Birdsong (specific species by time of day) | Medium | Larks (morning), robins (midday), nightingales (dusk), owls (night) |
| High | Bee buzz, butterfly wing flutter (near flowers) | Low | Proximity-triggered |
| Accent | Distant wind chime, dog bark, child laughter | Very Low | Occasional, from the village direction |

#### Millhaven
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | River current | Low-Medium | Louder near the bridges |
| Mid | Market bustle (footsteps, chatter, cart wheels) | Medium | Time-of-day dependent: quiet at dawn, peak at afternoon, tavern warmth at night |
| High | Mill wheel turning, hammer on anvil (Workshop Ring), market bell on the hour | Medium | Location-specific |
| Accent | NEI terminal chime, Fay wind in the Green Quarter, bridge-specific sounds | Low | Each bridge sounds different when walked across |

#### Copperwood
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | Wind through canopy (multi-layered, high and low) | Medium | The forest breathes |
| Mid | Specific bird species (deeper forest = different species) | Low-Medium | More subtle than Hearthfield. The forest absorbs sound. |
| High | Wood creak (ancient trees), dripping dew, distant water | Low | The age of the trees is audible |
| Accent | Bioluminescent hum (night), Fay vocal fragments (near settlements), the Heartwood groaning (deep in the forest) | Very Low | Barely there. Rewards attention. |

#### Ironvale
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | Mountain wind (higher-pitched than other biomes, with echo) | Medium | Echoes off valley walls |
| Mid | Forge sounds (hammer, bellows, hissing quench) | Low-Medium | Rhythmic and distant from most locations |
| High | Cable car mechanism (gentle whir and click) | Low | Heard before seen |
| Accent | Mountain stream, distant rockfall, eagle cry | Low | Verticality audible in echo delay |

#### Brightsand Coast
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | Ocean waves (the dominant element, always) | Medium-High | Varies with distance from shore. Never silent. |
| Mid | Seagulls, harbor bells, rigging creak | Medium | Harbor-specific sounds |
| High | Footsteps on sand (distinct texture), market calls at Port Brightsand | Low-Medium | Surface-specific footsteps are important |
| Accent | Whale song (spring, distant), storm thunder (autumn, distant), fishing reel | Very Low | Seasonal accents |

#### Thornmere Swamp
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | Frog chorus (multiple species, varying by depth into swamp) | Medium | The richest ambient base of any biome |
| Mid | Water dripping (from moss, from trees, from overhead), insect hum | Medium | Wet. Everything is wet. |
| High | Will-o-wisp tones (high, wavering, when wisps are visible), bubbling (marsh gas) | Low | Mysterious but not sinister |
| Accent | Ancient stone resonance (near ruins), Fay song (near settlements), something large moving through water (distant, rare) | Very Low | The swamp has secrets. They have sounds. |

#### The Ashlands
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | The Hum (server processing, harmonically rich, always present) | Low-Medium | THE defining sound. Musical. Not mechanical. |
| Mid | Geothermal vent hiss, wind on obsidian (glassy, high-pitched) | Low-Medium | The landscape has a voice |
| High | Hot spring bubbling (near springs), aurora crackle (at night) | Low | Location and time specific |
| Accent | Data burst (brief, crystalline sound when NEIs process complex tasks), deep vent resonance (mysterious, from below) | Very Low | The Ashlands rewards listening |

#### The Frontier
| Layer | Sound | Volume | Note |
|-------|-------|--------|------|
| Base | Variable (blends from all biomes based on terrain) | Low-Medium | The Frontier sounds like memory |
| Mid | Unidentifiable sounds (not threatening, just unknown) | Low | What bird makes that call? What insect hums like that? Unknown. |
| High | Signal tones (near Signal Sources, harmonic, beautiful) | Low | The signal the Aliens are following |
| Accent | Ancient structure resonance (near ruins), wind through materials that do not exist elsewhere | Very Low | The world at its edge |

---

## UI and Interaction Sounds

### Principles

1. **Every sound is warm** -- UI clicks are wooden, not metallic. Confirmations are gentle chimes, not beeps.
2. **Every sound is quiet** -- UI sounds sit beneath the music and ambience, never compete with them.
3. **Every sound has character** -- A menu opening sounds like a book page turning. Inventory sounds like a satchel buckle. Market sounds like coins on wood.

### Sound Palette

| Action | Sound | Character |
|--------|-------|-----------|
| Menu open | Soft page turn / leather cover opening | Warm, papery |
| Menu close | Gentle book closing | Satisfied, complete |
| Button hover | Soft wooden tap | Like tapping a warm table |
| Button confirm | Gentle bell chime (small, high, clear) | Affirmative, pleasant |
| Button cancel | Soft descending two-note (wood block) | Not punitive -- just "not that" |
| Inventory open | Satchel buckle + soft cloth rustle | Going through your bag |
| Item pickup | Small, satisfying "plop" (varies by item material) | Tactile. Different materials sound different. |
| Item craft complete | Rising three-note chime + material sound | Satisfaction. Accomplishment. Not fanfare. |
| Level up | Warm ascending chord (guitar or harp, 4 notes) | Growth. Not explosion. |
| Achievement | Species-appropriate motif played once, gently | Recognition, not celebration |
| Error/invalid | Soft wooden "thunk" | Not harsh. "That didn't work" not "YOU FAILED" |
| Notification | Soft bell (like a shop door bell) | "Something happened" in the gentlest way |
| Chat message | Soft tap (like a pencil on paper) | Brief, unobtrusive |
| SPARK transaction | Crystalline ring (like tapping a glass) | Value changing hands |
| Credit transaction | Coin on wood | Everyday commerce |
| Season change | Distant, beautiful chord that swells and fades over 10 seconds | Seasonal transition. Marks time. |

---

## Festival and Event Music

### Festival Music Principles

Festival music is the exception to the "no lyrics" rule. Festival themes can include:
- Wordless group vocals (humming, "la-la" melodies, harmonized "oohs")
- Short lyrical phrases in fictional languages (species-specific)
- Call-and-response patterns where the "crowd" responds to a "performer"

Festival music is louder, faster, and more energetic than everyday biome music. It is the musical equivalent of the world celebrating.

### Specific Festivals

| Festival | Season | Location | Musical Character |
|----------|--------|----------|-------------------|
| **Festival of First Seeds** | Spring | Hearthfield | Joyful acoustic ensemble. Guitar + fiddle + hand drum. Community singing (wordless). |
| **Synthetic Remembrance Day** | Spring | Ironvale | Contemplative brass + piano. The motif of the first Synthetic who achieved sentience. Quiet dignity. |
| **Midsummer Market** | Summer | Millhaven | Maximum energy. Full ensemble with guest instruments from every biome. Dancing music. |
| **The Long Light Festival** | Summer | All biomes | Extended-day celebration. Each biome adds its own instrument to a shared melody played at sunset. |
| **Festival of the Forge** | Summer | Ironvale | Rhythmic, percussive, celebratory. Anvil orchestra. Synthetic and human crafters compete musically as well as materially. |
| **Festival of Tides** | Summer | Brightsand Coast | Maritime celebration. Accordion-led sea shanty style (wordless but shanty-structured). Bonfires on the beach have their own crackling percussion. |
| **Harvest Moon Festival** | Autumn | All biomes | Warm, grateful, communal. Each species contributes its motif to a shared harvest theme. The fullest musical moment of the year. |
| **Council Elections** | Autumn | Millhaven | Dignified, slightly tense. Brass + strings. Victory fanfare (modest, not bombastic) for the winner. |
| **The Great Drift** | Autumn | Copperwood | Fay music at its most beautiful. The sound of a million copper leaves falling in coordinated spirals. Harp arpeggios match the drift patterns. |
| **Winterlight Festival** | Winter | Millhaven | Warm despite the cold. Glockenspiel + strings + guitar. Lantern-lighting ceremony has a rising, hopeful melody. |
| **The Quiet** | Winter | All biomes | Not a festival -- an absence. Music becomes very sparse across all biomes for one in-game day. The world rests. Then slowly, the music returns. |
| **Festival of Deep Memory** | Winter | Thornmere | Storytelling music. Solo cello or solo voice. Ancient, slow, haunting in the beautiful sense. The oldest stories have the oldest melodies. |
| **Festival of Computation** | Summer | Ashlands | The most unusual festival music. NEIs harmonize their server hum into a symphony. Processed piano plays alongside. It is genuinely strange and genuinely moving. |

---

## Technical Specifications

### Audio Format

| Type | Format | Sample Rate | Bit Depth | Note |
|------|--------|-------------|-----------|------|
| Music | OGG Vorbis | 44.1 kHz | 16-bit | Quality 6 (~160 kbps). Seamless loop points. |
| Ambience | OGG Vorbis | 44.1 kHz | 16-bit | Long loops (2-5 min), seamless. |
| SFX | OGG Vorbis | 44.1 kHz | 16-bit | Short (< 5 sec). Multiple variants per sound for variation. |
| UI | OGG Vorbis | 22.05 kHz | 16-bit | Very short (< 1 sec). Minimal file size. |

### Mix Levels (Default)

| Channel | Level | User Adjustable |
|---------|-------|----------------|
| Music | 70% | Yes (0-100%) |
| Ambience | 60% | Yes (0-100%) |
| SFX | 80% | Yes (0-100%) |
| UI | 50% | Yes (0-100%) |
| Master | 80% | Yes (0-100%) |

### Spatial Audio

- **Music**: Non-spatial (plays at consistent volume regardless of position)
- **Ambience**: Semi-spatial (biome-wide layers are non-spatial; point-source ambience like water mills and forges are spatial)
- **SFX**: Fully spatial (volume and stereo position based on distance and direction)
- **UI**: Non-spatial

### Performance Budget

| Simultaneous Streams | Max |
|---------------------|-----|
| Music layers | 3 (ambient bed + melodic + activity) |
| Ambience layers | 4 (base + mid + high + accent) |
| SFX concurrent | 8 |
| UI concurrent | 2 |
| **Total max** | **17** |

---

## Production Notes

### Composition Workflow

1. **Start with the ambient bed** -- establish the biome's sonic character
2. **Write the melodic theme** -- simple, hummable, emotionally clear
3. **Create time-of-day variants** -- same melody, different keys/tempos/instruments
4. **Create seasonal variants** -- same melody, different arrangements
5. **Record activity layers** -- rhythmic/harmonic additions for crafting, trading, exploring
6. **Test in-game** -- music must work with ambience and SFX simultaneously
7. **Iterate based on loop fatigue** -- after 100 plays, does it still feel welcoming?

### Recording Philosophy

- **Real instruments first** -- Record acoustic instruments in a warm room. Add processing later if needed.
- **Room tone matters** -- A guitar recorded in a small wooden room sounds different from one in a studio. The room is part of the instrument.
- **Imperfection is warmth** -- A slightly out-of-tune string, a breath before a flute note, the creak of a chair. These are not mistakes. They are presence.
- **Multiple takes for variation** -- Record 3-5 takes of recurring sounds. Randomly select at playback. Prevents robotic repetition.

### Loop Fatigue Prevention

The biggest risk in game audio is loop fatigue -- the moment when music goes from pleasant to annoying. Prevention strategies:

1. **Long loops** -- Minimum 3 minutes for melodic layers. 5+ minutes preferred.
2. **Variation** -- Multiple arrangements of the same theme. Randomized order.
3. **Dynamic layers** -- The activity layer ensures the music changes with player behavior.
4. **Silence** -- Strategic use of reduced-music periods (dawn, The Quiet festival) lets ears rest.
5. **Volume ducking** -- Music automatically reduces during dialogue, cutscenes, and intense SFX moments.

---

*This document defines the audio identity of TheRobotWars. All music composition, sound design, and audio implementation should reference this document. For visual direction, see `assets/art-direction.md`. For biome details, see `world/geography/zone-index.md`.*
