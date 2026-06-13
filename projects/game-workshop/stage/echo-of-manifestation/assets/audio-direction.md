# Echo of Manifestation — Audio Direction

Sound design bible covering per-zone audio, adaptive music systems, voice direction, and accessibility features.

This document merges the Visual/Audio Progression audio column from the main GDD with the full Sound Design Bible (docs/sound-design.md).

## Audio Engine: Wwise

| Component | Implementation |
|-----------|---------------|
| **Event System** | All sounds triggered via Wwise events (not Unreal Audio) |
| **State Machine** | Music states: Explore -> Alert -> Combat -> Boss -> Death |
| **RTPC Controllers** | Resonance meter (0-200), Player HP (0-100), Zone Depth (1-8), Combat Proximity (0-40m) |
| **Switch Containers** | Surface type (6), Weapon category (8), Chimera tier (5), Zone theme (8) |
| **Dialogue** | Wwise Dialogue Event system with random containers for variation |
| **Spatialization** | 3D positioning for all diegetic sounds, 2D for UI/music |

## Audio Progression by Zone

| Zone | Ambient Audio | Music Intensity |
|------|--------------|----------------|
| 1 — Faded Chapel | Distant hymn fragments, creaking wood, wind through broken stained glass | Solo pipe organ, sparse |
| 2 — Sunken Market | Dripping, muffled market sounds from a past that isn't yours, gurgling drains | Hurdy-gurdy, off-key, occasional dissonant chord |
| 3 — Bleached Asylum | Heartbeat monitor beeps, distant screams, wheelchair squeaks, static | Prepared piano, atonal, breathing rhythm |
| 4 — Petrified Forest | Absolute silence punctuated by cracking stone, single bird call (wrong species) | Solo cello, slow, deliberate, each note final |
| 5 — Shattered Observatory | Cosmic hum, grinding gears, glass cracking, reversed speech | Glass armonica, ethereal and unsettling, building to crescendo |
| 6 — Resonance Core | Machinery, steam release, rhythmic thudding (syncs to player heartbeat) | Industrial percussion + string quartet, relentless |
| 7 — Plane of Echoes | All previous ambient sounds layered simultaneously, reversed | All previous instruments layered, contrapuntal, overwhelming |
| 8 — The Threshold | Near-silence, then deafening resonance, then silence in 30-second cycles | Full orchestra to silence to full orchestra, no transition |

## Adaptive Music System

5 States with transition rules:

| From -> To | Transition | Crossfade |
|-----------|-----------|-----------|
| Explore -> Alert | Chimera detected within 30m | 2s crossfade |
| Alert -> Combat | Player takes damage or attacks | 1s hard cut |
| Combat -> Alert | No damage for 8s, chimera alive | 3s crossfade |
| Alert -> Explore | No chimera within 40m for 12s | 4s fade |
| Combat -> Death | Player HP reaches 0 | 0.5s hard cut to death sting |
| Any -> Boss | Boss arena entered | 2s crossfade to boss theme |
| Boss -> Explore | Boss defeated | 4s victory crossfade |

## Voice Direction

| Actor | Character | Line Count | Sessions | Tone |
|-------|-----------|-----------|----------|------|
| **A1** | The Survivor | ~20 (effort sounds) | 1 session (2h) | Gender-neutral, weary, determined |
| **A2** | Echo (Amara) | 80-120 | 3 sessions (2h each) | 9-year-old, innocent <-> ancient |
| **A3** | The Librarian | 40-60 | 2 sessions (2h each) | Older male, erudite, warm but tired |
| **A4** | The Hollow Alchemist (Caelum) | 30-50 | 2 sessions (2h each) | Male, composed -> manic -> fragmented |

## Casting Notes

| NPC | Voice Archetype | Reference Performance | Vocal Quality |
|-----|----------------|----------------------|---------------|
| Echo | Precocious child with ancient grief | Similar to Luna Mothews (spirit-medium child archetype) — breathy, measured, occasionally too calm | Light, slightly reverberant as if speaking from a hollow space. No regional accent. Vocabulary shifts from childlike to archaic as memories return. |
| The Librarian | Exhausted Oxford don | Anthony Hopkins as the quiet scholar — precise, unhurried, heavy with resignation | Deep baritone, Received Pronunciation with occasional lapses into muttered asides. Pauses before emotional words. |
| The Hollow Alchemist | Charismatic fallen mentor | Similar energy to a younger Alan Rickman villain — intelligent, seductive, wrong | Resonant mid-range, elongated vowels on key words. Voice gains layered distortion (like two people speaking nearly in unison) in later encounters. |

## Accessibility Audio

### Threat Level Audio Encoding

| Threat Level | Pitch | Rhythm | Duration |
|-------------|-------|--------|----------|
| **Faint (Weak)** | 440Hz (A4) | Single tone | 0.5s |
| **Shimmer (Moderate)** | 660Hz (E5) | Two quick pulses | 0.8s |
| **Pulse (Strong)** | 880Hz (A5) | Three pulses, accelerating | 1.0s |
| **Dark (Deadly)** | 1100Hz (C#6) | Rapid pulse train | 1.2s |
| **Void (Boss-tier)** | 220Hz + 1100Hz simultaneously | Slow low pulse + rapid high pulse | 1.5s |

### Environmental Hazard Proximity Audio

| Hazard | Warning Sound | Distance Range | Urgency |
|--------|-------------|----------------|---------|
| Collapsing floor | Low crack + descending tone | 3m | 1s before collapse |
| Rising shadow-water | Gurgling + low-pass filter | 5m | Gradual over 30s |
| Gravity inversion | Whoosh + pitch drop | 4m | 2s before flip |
| Essence node explosion | Pressure whistle ascending | 5m | 20s before detonation |

## Memory Budgets

| Platform | Audio Memory | Streaming Budget | Voice Count |
|----------|-------------|-----------------|-------------|
| PC (Recommended) | 512 MB | 100 MB/s | 128 virtual voices |
| PlayStation 5 | 512 MB | 100 MB/s | 128 virtual voices |
| Xbox Series X | 512 MB | 100 MB/s | 128 virtual voices |
| Nintendo Switch | 128 MB | 40 MB/s | 48 virtual voices |

**Switch Reductions**: Ambient beds reduced to 2 layers (from 3-4). Chimera sounds use shared base samples with pitch-shift. Music uses stereo stems (no discrete layers). 32 virtual voices max simultaneous.

## Per-Zone Sound Design Details

### Zone 1: Faded Chapel

**Ambient Bed Layers:**
- Layer A: Low wind drone through broken stained glass (C2 fundamental, slow modulation)
- Layer B: Distant hymn fragments — all-female choir, Latin, half-heard (triggers every 20-40s, 3-6s duration)
- Layer C: Creaking wood and settling stone (physical modeling, random intervals 8-15s)

**Music Direction:**
- Solo pipe organ, sparse
- Tempo: 40-60 BPM, Key: D minor
- Near-silence in safe rooms, single sustained note in corridors, full chords in combat

### Zone 2: Sunken Market

**Ambient Bed Layers:**
- Layer A: Lapping shadow-water against wood and stone (looped, slight randomization)
- Layer B: Dripping from multiple heights (randomized timing, spatialized at 4-6 positions)
- Layer C: Muffled market sounds from "the past" — distant voices, coins, haggling — as if through water

**Music Direction:**
- Hurdy-gurdy, off-key
- Tempo: 55-70 BPM, Key: A minor with frequent diminished intervals

### Zone 3: Bleached Asylum

**Ambient Bed Layers:**
- Layer A: Fluorescent light hum (60Hz + harmonics, intermittent flicker via random mute)
- Layer B: Heartbeat monitor beep (synced to 72 BPM, occasional missed beat)
- Layer C: Distant screams and wheelchair squeaks (randomized, spatialized far away)

**Music Direction:**
- Prepared piano, atonal
- Tempo: Variable (60-120 BPM, fluctuates based on Resonance)
- Breathing rhythm — music syncs to a breathing pattern (inhale = silence, exhale = chord)

### Zone 4: Petrified Forest

**Ambient Bed Layers:**
- Layer A: Absolute silence (dead air — intentional, uncomfortable)
- Layer B: Occasional cracking stone (single sharp crack, 20-40s intervals)
- Layer C: A single bird call — wrong species for any known forest (triggers 30-60s intervals, always from behind the player)

**Music Direction:**
- Solo cello, slow, deliberate
- Tempo: 30-45 BPM, Key: C minor
- Each note held until it dies completely — no vibrato, no sustain pedal

### Zone 5: Shattered Observatory

**Ambient Bed Layers:**
- Layer A: Cosmic hum (deep broadband, 20Hz + 60Hz + 200Hz blend, 15s loop)
- Layer B: Grinding telescope gears (mechanical, intermittent, 4-8s every 15-25s)
- Layer C: Reversed speech fragments (whispered, incomprehensible, spatialized at distance)

**Music Direction:**
- Glass armonica, ethereal and unsettling
- Tempo: 50-65 BPM, Key: F# minor with augmented intervals
- Music builds to crescendo that never resolves — tension without release

### Zone 6: Resonance Core

**Ambient Bed Layers:**
- Layer A: Industrial machinery (rhythmic, mechanical, 120 BPM pulse)
- Layer B: Steam release (broadband burst, random intervals 10-20s)
- Layer C: Rhythmic thudding synced to player's in-game heartbeat (60-120 BPM based on HP/Resonance)

**Music Direction:**
- Industrial percussion + string quartet
- Tempo: 120 BPM (synced to machinery), Key: E minor, modal

### Zone 7: Plane of Echoes

**Ambient Bed Layers:**
- Layer A: ALL previous zone ambient beds layered simultaneously, at reduced volume
- Layer B: ALL previous ambient sounds layered, reversed
- Layer C: Reversed versions of music from all previous zones

**Music Direction:**
- ALL previous instruments layered, contrapuntal
- Tempo: 70-90 BPM (conflicting rhythms from different zone tempi)
- Polytonal (all previous keys simultaneously)

### Zone 8: The Threshold

**Ambient Bed Layers:**
- Layer A: Near-silence (30s) -> Deafening full-orchestra resonance (30s) — cycling
- Layer B: During silence: player's own breathing (amplified, uncomfortable intimacy)
- Layer C: During resonance: all chimera sounds simultaneously at full volume

**Music Direction:**
- Full orchestra <-> silence, 30-second cycles
- During orchestra: 80 BPM, Key: C major
- During silence: 0 BPM
- The orchestra and silence are equal partners — the silence is as composed as the music

## UI Sounds

| Element | Sound | Duration | Character |
|---------|-------|----------|-----------|
| Achievement Unlock | Unique sting — 4-note fanfare in game's key | 1.5s | Celebratory but restrained |
| Insight Level Up | Resonant tone + harmonics building | 2s | Progression, satisfying |
| Lore Fragment Found | Soft musical motif matching the fragment's zone | 1s | Nostalgic, inviting |
| Run Complete | Zone-specific victory motif | 3s | Triumphant but bittersweet |
| Run Death Summary | Descending tone + heartbeat slow | 2s | Somber |
| Codex Entry Unlock | Ascending 3-note chime | 0.8s | Rewarding |
| Menu Open/Close | Soft shadow-rustle / reverse | 0.3s | Unobtrusive |
| Inventory Slot | Gentle crystalline click | 0.15s | Tactile |

## Subtitle / Caption System

- All dialogue subtitled with character name color-coded:
  - The Survivor: White
  - Echo (innocent register): Light blue
  - Echo (ancient register): Dark purple
  - The Librarian: Gold
  - The Hollow Alchemist: Red (Encounters 1-3), Dark red (4-7)
- Environmental sounds captioned with directional indicator: `[Footsteps - Left]`, `[Glass breaking - Behind]`
- Chimera vocalizations captioned with type: `[Shadow Blade - Aggro growl]`
- Music changes captioned: `[Music intensifies]`, `[Music: Silence]`
- Adjustable caption size (3 settings)
- Captions persist for 4 seconds or until next caption
