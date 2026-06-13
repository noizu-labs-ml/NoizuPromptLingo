# Echo of Manifestation — Room Templates

Survival horror roguelite room template catalogue. 8 zones, 5 templates each, 40 rooms total.

# Room Templates — Echo of Manifestation

> Survival horror roguelite room template catalogue. 8 zones, 5 templates each, 40 rooms total.
> Used by the procedural assembler to construct dungeon runs.

---

## Zone 1 — Faded Chapel

### RT-01-01: Collapsed Nave — Combat
**Zone:** 1 | **Dimensions:** 24m x 10m | **Entry:** S | **Exit:** N
**Features:** Long hall with crumbled pew rows forming waist-high cover. Stained glass fractures leak pale resonance light. A collapsed choir loft blocks the western flank.
**Essence Nodes:** 3 — behind altar, under loft debris, eastern pew cluster
**Shadow Nodes:** 2 — loft rafters, confessional alcove
**Hazards:** Falling masonry — 10% chance per combat round of rubble strike in random tile column
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Pew arrangement shifts between grid and diagonal; loft collapse point randomizes western cover.

### RT-01-02: Sealed Confessional — Puzzle
**Zone:** 1 | **Dimensions:** 8m x 8m | **Entry:** W | **Exit:** E
**Features:** Four confession booths with glyph-locked doors. Each booth whispers a fragmented resonance phrase. Solving the phrase sequence unlocks the eastern reliquary gate.
**Essence Nodes:** 1 — center of room floor mosaic
**Shadow Nodes:** 3 — inside each of three wrong-sequence booths
**Hazards:** Wrong glyph order triggers a resonance spike — 15% HP damage and brief disorientation
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Phrase fragments and correct booth order shuffle each run; one booth may contain a bonus item.

### RT-01-03: Reliquary Antechamber — Loot
**Zone:** 1 | **Dimensions:** 12m x 10m | **Entry:** W | **Exit:** N
**Features:** Dusty alcoves line the walls holding deteriorated relics. A central stone plinth holds the primary loot cache behind a faded ward. Side alcoves offer secondary pickups.
**Essence Nodes:** 2 — central plinth, northern alcove
**Shadow Nodes:** 1 — behind collapsed southern wall
**Hazards:** Ward decay pulse — standing near plinth too long drains 2 HP/sec
**TDP:** Yes — northwest corner, barely visible behind crumbling statuary
**Secret:** N/A
**Procedural Variance:** Relic quality tiers randomize; 30% chance one alcove contains a mimic instead of loot.

### RT-01-04: Undercroft Passage — Secret
**Zone:** 1 | **Dimensions:** 6m x 18m | **Entry:** E (hidden) | **Exit:** N (locked)
**Features:** Narrow subterranean corridor beneath the chapel floor. Ancient burial niches line both walls. The air is thick with resonance dust and the distant sound of chanting.
**Essence Nodes:** 2 — end of passage, behind central burial niche
**Shadow Nodes:** 4 — scattered among niches
**Hazards:** Resonance dust clouds — reduced visibility, 20% chance of shadow ambush
**TDP:** No
**Secret:** Access by striking the baptismal font in RT-01-01 three times during TDP activation. Exit requires solving the burial niche glyph pattern.
**Procedural Variance:** Niche glyph pattern randomizes; passage length varies 14-22m.

### RT-01-05: Desecrated Sanctuary — Boss
**Zone:** 1 | **Dimensions:** 20m x 20m | **Entry:** S | **Exit:** N (sealed until boss defeat)
**Features:** The chapel's inner sanctum warped by resonance corruption. The altar is inverted, suspended mid-air. Cracked pillars provide limited cover. Boss: The Hollow Deacon.
**Essence Nodes:** 4 — four cardinal pillars
**Shadow Nodes:** 6 — overhead rafters, behind altar, under floor grates
**Hazards:** Resonance well at center — standing on it drains HP and empowers the boss
**TDP:** Yes — northeast corner, activates only after boss reaches 50% HP
**Secret:** N/A
**Procedural Variance:** Pillar layout shifts between square and diamond arrangement; boss phase timings vary +/-15%.

---

## Zone 2 — Sunken Market

### RT-02-01: Flooded Stalls — Combat
**Zone:** 2 | **Dimensions:** 22m x 16m | **Entry:** N | **Exit:** S
**Features:** Waist-deep murky water fills a ruined marketplace. Collapsed stall awnings create islands of walkable terrain. Water currents shift debris and loot between rounds.
**Essence Nodes:** 2 — atop a floating stall platform, submerged in southeast corner
**Shadow Nodes:** 3 — underwater along eastern wall, beneath collapsed awning, inside a sunken cart
**Hazards:** Contaminated water — wading drains 1 HP/sec; deep pockets cause 3 HP/sec
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Water level varies ankle-to-chast high; stall positions and floating platforms rearrange.

### RT-02-02: Tide-Locked Vault — Puzzle
**Zone:** 2 | **Dimensions:** 10m x 10m | **Entry:** W | **Exit:** E
**Features:** A merchant's strongroom with three drainage valves. Solving the valve rotation sequence lowers the water level in stages, revealing the exit mechanism and submerged chests.
**Essence Nodes:** 1 — revealed only after full drainage, floor center
**Shadow Nodes:** 2 — behind valve mechanisms, emerge during drainage
**Hazards:** Valve misalignment floods the room rapidly — 5 HP/sec until corrected
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Valve sequence length 3-5 steps; water chemistry randomizes (some runs add poison damage to flood).

### RT-02-03: Drowned Warehouse — Loot
**Zone:** 2 | **Dimensions:** 18m x 12m | **Entry:** N | **Exit:** E
**Features:** Tilting warehouse with crates half-submerged. Upper shelving holds salvageable goods reachable by climbing chain hoists. A trapped office room in the corner holds premium loot.
**Essence Nodes:** 3 — office safe, top shelf cluster, submerged crate stack
**Shadow Nodes:** 1 — inside a sealed crate
**Hazards:** Structural instability — explosive attacks may collapse shelving, blocking paths
**TDP:** Yes — inside the office, behind a false wall panel
**Secret:** N/A
**Procedural Variance:** Crate contents shuffle between runs; 25% chance office is already ransacked with reduced loot.

### RT-02-04: Smuggler's Sump — Secret
**Zone:** 2 | **Dimensions:** 8m x 14m | **Entry:** S (underwater grate) | **Exit:** W
**Features:** A hidden drainage tunnel converted into a smuggling cache. Dry ledges line the walls above the waterline. Damp crates contain contraband-grade equipment.
**Essence Nodes:** 2 — behind false crate wall, under water at north end
**Shadow Nodes:** 2 — on submerged ledges
**Hazards:** Periodic tide surge — water rises for 10 seconds every 45 seconds, submerging ledges
**TDP:** No
**Secret:** Access by pulling three submerged chains in RT-02-01 in order (marked by faint resonance glows). Exit leads to a shortcut to Zone 3.
**Procedural Variance:** Chain order changes; tide surge timing varies 35-55 second intervals.

### RT-02-05: Auction House Ruin — Boss
**Zone:** 2 | **Dimensions:** 24m x 18m | **Entry:** N | **Exit:** S (sealed until boss defeat)
**Features:** A grand auction hall now flooded to knee height. The auction podium is a raised island. Tiered seating creates elevation changes. Boss: The Broker of Tides.
**Essence Nodes:** 3 — podium, west balcony, east seating tier
**Shadow Nodes:** 5 — underwater throughout seating, under podium, behind stage curtain
**Hazards:** Boss controls water level — can flash-flood the room, forcing players to elevated positions
**TDP:** Yes — behind the auction stage, accessible only when boss initiates water drain phase
**Secret:** N/A
**Procedural Variance:** Water starting depth varies; seating arrangement shifts between amphitheater and flat-floor layouts.

---

## Zone 3 — Bleached Asylum

### RT-03-01: Dayroom Ward — Combat
**Zone:** 3 | **Dimensions:** 16m x 14m | **Entry:** E | **Exit:** W
**Features:** A communal patient dayroom with overturned tables and bolted-down furniture. Faded murals on the walls depict distorted faces. Linoleum floor is slick with a chalky residue.
**Essence Nodes:** 2 — behind a collapsed vending machine, inside a mural alcove
**Shadow Nodes:** 4 — inside ceiling light fixtures, under bolted tables, behind murals, inside a locker
**Hazards:** Chalk residue — movement speed reduced 20%; residue patches cause coughing (interrupts actions)
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Furniture arrangement varies; 40% chance a murals hides a shadow node vs an essence node.

### RT-03-02: Pharmacy Grid — Puzzle
**Zone:** 3 | **Dimensions:** 12m x 8m | **Entry:** S | **Exit:** N
**Features:** A medication dispensary with rows of labeled cabinets. Patient file fragments hint at which cabinet holds the correct compound. Mixing wrong compounds creates toxic gas.
**Essence Nodes:** 1 — inside the correct compound cabinet
**Shadow Nodes:** 2 — behind wrong-compound cabinets that release gas when opened
**Hazards:** Toxic gas — 3 HP/sec in affected area; lingers for 20 seconds
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Cabinet labels shuffle; patient file clues change phrasing; 20% chance an extra cabinet holds a bonus item.

### RT-03-03: Electrotherapy Chamber — Loot
**Zone:** 3 | **Dimensions:** 10m x 12m | **Entry:** E | **Exit:** N
**Features:** Abandoned shock therapy room with a still-humming generator. Electrodes dangle from the ceiling. A locked medicine cabinet on the far wall holds the primary cache.
**Essence Nodes:** 3 — medicine cabinet, inside generator housing, under treatment chair
**Shadow Nodes:** 1 — attached to a live electrode cluster
**Hazards:** Live electrodes — touching one deals 25 HP electric damage and stuns 2 seconds
**TDP:** Yes — behind the generator, accessible only after disabling it via power switch
**Secret:** N/A
**Procedural Variance:** Electrode positions and active/inactive pattern randomize; generator may be already disabled on easier runs.

### RT-03-04: Forgotten Basement Ward — Secret
**Zone:** 3 | **Dimensions:** 14m x 10m | **Entry:** N (hidden elevator shaft) | **Exit:** W
**Features:** A sealed-off basement ward not on any floor plan. Padded cells line the corridor, some with scratch marks. A resonance anomaly in the center room distorts perception.
**Essence Nodes:** 2 — inside the most damaged cell, center anomaly
**Shadow Nodes:** 3 — inside padded cells, behind peeling wallpaper
**Hazards:** Perception distortion — minimap inverts, enemy positions appear offset by 2-3 meters
**TDP:** No
**Secret:** Access by finding the patient file in RT-03-02 with the "Basement Patient" name and reading it near the elevator in RT-03-01. The anomaly in this room reveals a hidden shop NPC.
**Procedural Variance:** Cell contents and distortion severity vary; anomaly shop inventory changes per run.

### RT-03-05: Director's Operating Theater — Boss
**Zone:** 3 | **Dimensions:** 18m x 16m | **Entry:** S | **Exit:** N (sealed until boss defeat)
**Features:** A surgical theater with observation galleries. The operating table is the arena center. Surgical tools line the walls. Overhead lights flicker with resonance interference. Boss: The Whitecoat Architect.
**Essence Nodes:** 3 — observation gallery left, gallery right, behind surgical tool rack
**Shadow Nodes:** 5 — inside overhead lights, under table, among tools, in drainage grates, behind gallery glass
**Hazards:** Surgical tools — boss can animate instruments as projectiles; standing near tool racks increases risk
**TDP:** Yes — behind the observation gallery, accessible when boss enters phase 2
**Secret:** N/A
**Procedural Variance:** Tool rack positions shift; gallery access may be blocked on some runs forcing ground-level only combat.

---

## Zone 4 — Petrified Forest

### RT-04-01: Stone Canopy Thicket — Combat
**Zone:** 4 | **Dimensions:** 20m x 20m | **Entry:** S | **Exit:** N
**Features:** A dense grove of petrified trees frozen mid-growth. Branches form a canopy ceiling blocking overhead movement. Roots create natural barriers and chokepoints across the forest floor.
**Essence Nodes:** 3 — hollow trunk center, root cluster east, petrified bird nest overhead
**Shadow Nodes:** 4 — canopy branches, root hollows, behind bark formations, inside a split trunk
**Hazards:** Root grasp — standing still for 3+ seconds triggers root tendrils that root the player (2 sec immobilize)
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Tree density varies 12-24 trunks; root chokepoint positions randomize; 30% chance of a clearing in center.

### RT-04-02: Growth Ring Labyrinth — Puzzle
**Zone:** 4 | **Dimensions:** 16m x 16m | **Entry:** W | **Exit:** E
**Features:** Concentric rings of a massive petrified stump form a maze. Each ring has gaps at different angles. The player must navigate through gaps in the correct sequence to reach the center and the exit.
**Essence Nodes:** 1 — center of the stump
**Shadow Nodes:** 3 — between ring gaps, hidden in bark textures
**Hazards:** Ring contraction — every 30 seconds the innermost ring shifts, potentially blocking progress
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Ring gap positions randomize each run; number of rings varies 4-6; contraction timing shifts +/-10 seconds.

### RT-04-03: Amber Cache Hollow — Loot
**Zone:** 4 | **Dimensions:** 14m x 12m | **Entry:** S | **Exit:** E
**Features:** A hollow formed by three enormous petrified trunks growing together. Amber deposits in the walls contain preserved relics. A fallen trunk creates a bridge to an elevated loot platform.
**Essence Nodes:** 4 — amber deposits (2), elevated platform, root hollow
**Shadow Nodes:** 1 — embedded in amber, breaks free when deposit is mined
**Hazards:** Amber resin — mining deposits sprays resin that slows movement 40% for 5 seconds
**TDP:** Yes — on the elevated platform, hidden behind amber deposits
**Secret:** N/A
**Procedural Variance:** Amber deposit count varies 3-6; fallen trunk bridge may be intact or requiring parkour; shadow node presence in amber is 50/50.

### RT-04-04: Mycelium Network Chamber — Secret
**Zone:** 4 | **Dimensions:** 10m x 16m | **Entry:** E (beneath root arch) | **Exit:** N
**Features:** An underground chamber where petrified mycelium forms glowing patterns on every surface. The network pulses with resonance energy. Interconnected nodes can be activated to reveal hidden paths.
**Essence Nodes:** 2 — at mycelium junction points
**Shadow Nodes:** 2 — dormant within the network, emerge when wrong nodes are activated
**Hazards:** Spore release — activating wrong mycelium nodes releases petrified spores (damage + slow)
**TDP:** No
**Secret:** Access by finding the resonance-matched petrified flower in RT-04-01 and placing it at the root arch. The mycelium network in this room maps the optimal path through the next two rooms in the zone.
**Procedural Variance:** Mycelium node pattern generates fresh each run; correct activation path varies; spore intensity scales with difficulty.

### RT-04-05: The Heartwood Arena — Boss
**Zone:** 4 | **Dimensions:** 22m x 22m | **Entry:** S | **Exit:** N (sealed until boss defeat)
**Features:** A massive circular clearing around the petrified heartwood of the forest's oldest tree. Root tendrils radiate outward like a sunburst. The heartwood itself splits open during combat. Boss: The Timber Sovereign.
**Essence Nodes:** 4 — at cardinal root tips
**Shadow Nodes:** 6 — embedded in root tendrils, inside heartwood cavity, canopy perimeter
**Hazards:** Root surge — boss sends waves of petrifying roots across the arena floor; contact = 15 HP + petrify buildup
**TDP:** Yes — inside the heartwood cavity, accessible after boss phase 2 begins
**Secret:** N/A
**Procedural Variance:** Root tendril pattern shifts between radial and spiral; arena may have standing water in patches (additional slow hazard).

---

## Zone 5 — Shattered Observatory

### RT-05-01: Fragmented Star Gallery — Combat
**Zone:** 5 | **Dimensions:** 18m x 14m | **Entry:** W | **Exit:** E
**Features:** A gallery of broken telescopes and shattered star charts. Gravity behaves erratically — sections of floor are at different orientations. Floating debris creates mobile cover.
**Essence Nodes:** 2 — attached to a floating star chart, embedded in a tilted wall section
**Shadow Nodes:** 3 — inside telescope housings, among floating debris, behind inverted floor panel
**Hazards:** Gravity flux — every 20 seconds, a random 4m x 4m section shifts orientation, flinging anything on it
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Gravity shift patterns vary; floating debris orbit changes; number of tilted floor sections ranges 2-5.

### RT-05-02: Orrery Calibration Chamber — Puzzle
**Zone:** 5 | **Dimensions:** 14m x 14m | **Entry:** S | **Exit:** N
**Features:** A massive orrery dominates the center, its celestial bodies frozen mid-rotation. Three control pedestals allow manual repositioning. Aligning the celestial bodies to match a star chart on the ceiling unlocks the exit.
**Essence Nodes:** 1 — center of the orrery (accessible only after alignment)
**Shadow Nodes:** 2 — orbiting with celestial bodies, emerge when wrong alignment attempted
**Hazards:** Celestial collision — wrong alignment sends a model planet on a collision trajectory (20 HP, knockback)
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Target star chart pattern on ceiling changes each run; number of celestial bodies to align varies 3-5; orrery may be partially damaged, limiting some adjustments.

### RT-05-03: Lens Forge Workshop — Loot
**Zone:** 5 | **Dimensions:** 12m x 10m | **Entry:** N | **Exit:** W
**Features:** An abandoned lens-grinding workshop with rare optical components. Crystalline lens fragments litter the workbenches. A reinforced optic vault in the corner holds high-tier loot.
**Essence Nodes:** 3 — optic vault, workbench lens pile, polishing station
**Shadow Nodes:** 1 — trapped inside a large focusing lens
**Hazards:** Focused light beams — some lens fragments redirect ambient resonance into damaging beams (10 HP/sec in beam path)
**TDP:** Yes — inside the optic vault behind a false back panel
**Secret:** N/A
**Procedural Variance:** Lens fragment positions shift, changing beam paths; vault contents scale with difficulty; 25% chance the focusing lens shadow node drops a unique weapon.

### RT-05-04: Celestial Archive — Secret
**Zone:** 5 | **Dimensions:** 10m x 18m | **Entry:** E (through broken telescope aperture) | **Exit:** N
**Features:** A hidden archive behind the main telescope array. Star charts and observation logs fill floating shelves. A resonance telescope at the far end reveals hidden doors in other rooms.
**Essence Nodes:** 2 — archive shelves, resonance telescope
**Shadow Nodes:** 2 — concealed in star chart rolls, behind floating shelf
**Hazards:** Zero-gravity zone — center of room has no gravity; unanchored players drift until grabbing a shelf
**TDP:** No
**Secret:** Access by aligning the largest telescope in RT-05-01 toward the eastern wall during a gravity flux. The resonance telescope in this room reveals all Secret room entrances on the current floor.
**Procedural Variance:** Archive shelf contents and revealed secrets vary; zero-gravity zone size fluctuates; telescope may show different future room previews.

### RT-05-05: The Astrolabe Apex — Boss
**Zone:** 5 | **Dimensions:** 20m x 20m | **Entry:** S | **Exit:** N (sealed until boss defeat)
**Features:** The observatory's peak chamber, open to a fractured sky. A giant astrolabe dominates the center, slowly rotating. The floor is a transparent star map with visible void beneath. Boss: The Astral Curator.
**Essence Nodes:** 3 — on astrolabe arms (move with rotation), star map north point
**Shadow Nodes:** 5 — embedded in astrolabe structure, below floor in void, at star map constellation points
**Hazards:** Astrolabe rotation — arms sweep the arena, dealing 30 HP and knockback; void floor sections crack and drop players into damage pits
**TDP:** Yes — at the star map north point, accessible during boss phase 3 astrolabe pause
**Secret:** N/A
**Procedural Variance:** Astrolabe rotation speed varies; void floor crack patterns differ; constellation positions on floor shift between runs.

---

## Zone 6 — Resonance Core

### RT-06-01: Harmonic Conduit Hall — Combat
**Zone:** 6 | **Dimensions:** 24m x 12m | **Entry:** W | **Exit:** E
**Features:** A long hall lined with humming resonance conduits. Energy pulses travel along the walls in visible waves. The conduits overload periodically, sending energy arcs across the corridor.
**Essence Nodes:** 2 — mounted on conduit junctions
**Shadow Nodes:** 4 — inside conduit housings, at energy pulse apexes, behind junction panels
**Hazards:** Conduit overload — energy arcs deal 20 HP and chain to nearby players/enemies within 3m
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Conduit overload pattern shifts; pulse frequency varies 8-15 second intervals; conduit junction positions along walls change.

### RT-06-02: Frequency Lock Chamber — Puzzle
**Zone:** 6 | **Dimensions:** 10m x 10m | **Entry:** S | **Exit:** N
**Features:** A cube-shaped room with resonance tuning forks at each corner. Each fork emits a tone when struck. The correct tone sequence opens the exit — wrong sequences create resonance feedback.
**Essence Nodes:** 1 — revealed in center after correct sequence
**Shadow Nodes:** 3 — behind incorrect forks, spawn on feedback events
**Hazards:** Resonance feedback — wrong notes create a harmonic cascade dealing 10 HP per wrong note and vibrating the player's controls (input lag)
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Tuning fork positions may rotate; correct sequence length varies 3-6 notes; room may have acoustic dampeners that reduce feedback damage on some runs.

### RT-06-03: Crystal Amplifier Vault — Loot
**Zone:** 6 | **Dimensions:** 14m x 12m | **Entry:** N | **Exit:** E
**Features:** Raw resonance crystals grow from every surface. Central amplifier focuses energy into crystalline storage containers. Overcharged crystals contain premium loot but are unstable.
**Essence Nodes:** 4 — three crystal clusters, one amplifier core
**Shadow Nodes:** 2 — embedded in overcharged crystals, break free when mined
**Hazards:** Crystal resonance burst — mining crystals has 30% chance of resonant explosion (15 HP, 5m radius)
**TDP:** Yes — behind the amplifier, reachable only by mining a specific crystal cluster
**Secret:** N/A
**Procedural Variance:** Crystal growth patterns randomize; overcharged crystal count varies 2-5; amplifier may be active or dormant (dormant = safer mining, less loot).

### RT-06-04: The Silent Frequency — Secret
**Zone:** 6 | **Dimensions:** 8m x 8m | **Entry:** Floor center hatch (resonance-locked) | **Exit:** W
**Features:** A perfectly sound-dampened chamber. All resonance is absorbed here, creating total silence. The absence of resonance allows perception of normally hidden resonance patterns elsewhere.
**Essence Nodes:** 1 — center of the room, pure silence essence
**Shadow Nodes:** 0 — shadow nodes cannot manifest in this room
**Hazards:** Sensory deprivation — minimap disabled; audio cues absent; orientation relies on visual only
**TDP:** No
**Secret:** Access by achieving a specific resonance frequency in RT-06-02 and maintaining it while moving to RT-06-01's nearest conduit junction. The silent chamber reveals the exact room layout of the next 3 rooms.
**Procedural Variance:** Hatch location shifts between runs; sensory deprivation severity varies; revealed future rooms may be partially obscured on harder difficulties.

### RT-06-05: Resonance Engine Core — Boss
**Zone:** 6 | **Dimensions:** 22m x 22m | **Entry:** S | **Exit:** N (sealed until boss defeat)
**Features:** The central resonance engine, a massive pulsating sphere of contained energy. Conductive walkways extend like spokes around it. The engine's energy distorts the arena. Boss: The Resonance Pariah.
**Essence Nodes:** 4 — at the end of each cardinal spoke walkway
**Shadow Nodes:** 6 — orbiting the engine sphere, inside walkway supports, manifested in energy distortions
**Hazards:** Resonance pulse — the engine emits expanding energy rings every 15 seconds (25 HP, knockback); walkways can retract
**TDP:** Yes — beneath the engine sphere, accessible only during boss phase 2 when the sphere lifts
**Secret:** N/A
**Procedural Variance:** Spoke walkway count varies 4-6; engine pulse timing shifts +/-5 seconds; walkway retraction pattern changes between runs.

---

## Zone 7 — Plane of Echoes

### RT-07-01: Mirror Gallery — Combat
**Zone:** 7 | **Dimensions:** 18m x 16m | **Entry:** N | **Exit:** S
**Features:** A hall of cracked mirrors that create echo clones of everything in the room. Each clone mirrors actions with a 2-second delay. Some mirrors are portals to echo-space.
**Essence Nodes:** 2 — in echo-space (visible through mirrors, must enter mirror to collect)
**Shadow Nodes:** 4 — inside mirrors, as echo clones of shadow nodes from previous rooms
**Hazards:** Mirror shatter — destroying mirrors releases glass shards (10 HP) and spawns echo clones of enemies
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Mirror count and portal status changes; echo clone delay varies 1-3 seconds; 20% chance an echo clone drops real loot on death.

### RT-07-02: Memory Lattice — Puzzle
**Zone:** 7 | **Dimensions:** 14m x 14m | **Entry:** W | **Exit:** E
**Features:** Floating memory fragments form a 3D lattice. Each fragment shows a replay of a room the player previously visited. Arranging fragments to match the zone progression sequence opens the exit.
**Essence Nodes:** 1 — attached to the correct final fragment
**Shadow Nodes:** 3 — disguised as memory fragments, activate when wrong fragment is placed
**Hazards:** Memory cascade — wrong placement triggers replay of all previous damage taken in the run (25% of original damage)
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Memory fragment count varies 5-9; fragment positions in lattice randomize; some fragments may be corrupted (showing false memories that mislead).

### RT-07-03: Echo Hoard — Loot
**Zone:** 7 | **Dimensions:** 16m x 12m | **Entry:** S | **Exit:** N
**Features:** A treasure room where loot exists as resonance echoes. Items flicker between real and echo state. Real-state items can be collected; echo-state items pass through the player.
**Essence Nodes:** 3 — in phase with real state on different timers
**Shadow Nodes:** 2 — trapped in echo items, materialize when item is collected during echo phase
**Hazards:** Phase mismatch — collecting an item during echo phase causes resonance backlash (15 HP + item is lost)
**TDP:** Yes — always in real state, behind a phased wall that shifts every 8 seconds
**Secret:** N/A
**Procedural Variance:** Phase timing varies 4-12 second cycles; item quality peaks at different cycle points; some runs have a stabilizer that locks items in real state.

### RT-07-04: The First Reflection — Secret
**Zone:** 7 | **Dimensions:** 12m x 12m | **Entry:** W (through a specific mirror in RT-07-01) | **Exit:** Floor (drops to RT-07-05 antechamber)
**Features:** A perfect copy of the very first room the player entered on the run, but reversed and saturated with resonance. An echo of the player stands in the center, performing their first actions.
**Essence Nodes:** 2 — held by the player echo, embedded in the reversed architecture
**Shadow Nodes:** 3 — the player echo spawns shadow copies if disturbed, hidden in reversed furniture
**Hazards:** Ontological paradox — staying too close to your echo for 5+ seconds causes existence erosion (5 HP/sec, increasing)
**TDP:** No
**Secret:** Access by identifying the one mirror in RT-07-01 that shows the player's first room and stepping through during echo phase. The echo in this room offers a unique trade: sacrifice 25% max HP for a resonance weapon tuned to the player's run history.
**Procedural Variance:** The reflected room changes based on actual first room visited; echo behavior mirrors actual player actions from first room; trade offer weapon type scales with run progress.

### RT-07-05: The Grand Resonance — Boss
**Zone:** 7 | **Dimensions:** 24m x 24m | **Entry:** S | **Exit:** N (sealed until boss defeat)
**Features:** An infinite-feeling chamber where every action creates persistent echoes. Past boss attacks replay as ghost images. The floor reflects an impossible sky. Reality layers stack visibly. Boss: The Echo Prime.
**Essence Nodes:** 4 — at stability anchors in each corner
**Shadow Nodes:** 7 — layered across reality echoes, each representing a previous zone boss shadow
**Hazards:** Echo decay — every action permanently adds an echo; after 30 echoes accumulated, echoes begin attacking independently
**TDP:** Yes — at the north stability anchor, accessible during phase 2 when Echo Prime absorbs echoes
**Secret:** N/A
**Procedural Variance:** Echo decay rate varies; previous boss echoes that manifest depend on which bosses the player fought; arena may tilt between flat and multidimensional geometry.

---

## Zone 8 — The Threshold

### RT-08-01: The Narthex — Combat
**Zone:** 8 | **Dimensions:** 20m x 14m | **Entry:** S | **Exit:** N
**Features:** The antechamber to the final domain. Reality frays at the edges — walls dissolve into static at the periphery. Resonance density is suffocating. Enemies here are amalgams of all previous zone types.
**Essence Nodes:** 2 — embedded in the last stable wall sections
**Shadow Nodes:** 5 — in the static-frayed edges, inside amalgam enemies, at the threshold of visibility
**Hazards:** Reality erosion — the arena contracts 0.5m every 30 seconds as edges dissolve into the void; touching the void = instant death
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Contraction rate varies; enemy amalgam composition draws from zones the player spent the most time in; static edge patterns shift.

### RT-08-02: The Resonance Equation — Puzzle
**Zone:** 8 | **Dimensions:** 12m x 12m | **Entry:** W | **Exit:** E
**Features:** A floating equation written in pure resonance spans the room. The player must walk the path of the solution across floating symbol platforms. Incorrect paths drop into void.
**Essence Nodes:** 1 — at the equation's solution point
**Shadow Nodes:** 3 — attached to incorrect symbol platforms, manifest when stepped on
**Hazards:** Void fall — incorrect path drops player into void; respawn at start with 20% HP loss; three fails = forced combat encounter
**TDP:** No
**Secret:** N/A
**Procedural Variance:** Equation complexity scales with run performance; symbol platform layout regenerates; some platforms have delayed collapse requiring speed.

### RT-08-03: The Final Armory — Loot
**Zone:** 8 | **Dimensions:** 16m x 10m | **Entry:** S | **Exit:** N
**Features:** The last supply cache before the final encounter. Weapons and items from every zone line the walls, each resonating at peak power. The room itself is unstable — collect fast or lose access.
**Essence Nodes:** 5 — distributed across weapon racks, each tied to a different zone's power
**Shadow Nodes:** 2 — disguised as high-tier items, reveal themselves when touched
**Hazards:** Room collapse — 60-second timer before the room destabilizes; each item taken accelerates collapse by 5 seconds
**TDP:** Yes — behind the northern wall, accessible only after taking at least 3 items (reveals the hidden pocket)
**Secret:** N/A
**Procedural Variance:** Available items draw from player's run history (zones visited, bosses defeated); timer varies 45-90 seconds based on difficulty; shadow item ratio varies 0-3.

### RT-08-04: Between the Frames — Secret
**Zone:** 8 | **Dimensions:** 10m x 10m | **Entry:** N (through a tear in reality in RT-08-01) | **Exit:** E (connects to RT-08-05 directly)
**Features:** A space that exists between moments of reality. Time is frozen — everything hangs suspended. The player can see the final boss arena through a translucent wall, studying its layout and attack patterns.
**Essence Nodes:** 2 — floating in the frozen time, freely collectible
**Shadow Nodes:** 0 — shadow nodes cannot exist outside of time
**Hazards:** Temporal drag — staying too long (90+ seconds) begins to pull the player into the timestream, dealing 3 HP/sec
**TDP:** No
**Secret:** Access by finding the reality tear in RT-08-01's static edge during a reality erosion cycle and stepping through before the edge dissolves. This room allows scouting the final boss arena and provides a shortcut bypassing RT-08-02.
**Procedural Variance:** Reality tear position shifts; boss arena preview may show different phase patterns; temporal drag threshold varies 60-120 seconds.

### RT-08-05: The Manifestation — Boss (Final)
**Zone:** 8 | **Dimensions:** 26m x 26m | **Entry:** S | **Exit:** N (victory exit)
**Features:** The final arena at the boundary of existence. The room IS the boss — walls, floor, and ceiling are the Manifestation's body. The space shifts geometry between phases. All resonance in the game converges here. Boss: The Manifestation.
**Essence Nodes:** 5 — at survival anchors that keep the arena stable; destroying them empowers the boss but reveals the TDP
**Shadow Nodes:** 8 — woven into the arena geometry; each represents a zone and has that zone's hazard properties
**Hazards:** Arena mutation — the boss reshapes the room every phase: walls close, floor opens, gravity reverses, zones of previous hazards manifest; resonance overload — standing near shadow nodes triggers their zone's hazard
**TDP:** Yes — revealed at center only after all 5 essence nodes are destroyed (sacrifice stability for the TDP power-up before final phase)
**Secret:** N/A
**Procedural Variance:** Phase order randomizes; arena mutations draw from zones the player struggled in most; shadow node hazard intensity scales with how many of that zone's rooms the player cleared; the Manifestation's form shifts to counter the player's most-used damage type.

---

## Procedural Assembly Rules

### Socket Compatibility

Each room template defines directional sockets (Entry/Exit) as cardinal directions. Rooms connect when their sockets align:

- **N-S compatible:** Room A exits N, Room B enters S
- **E-W compatible:** Room A exits E, Room B enters W
- **Multi-socket rooms** (combat, boss) may have 2+ exits, enabling branching paths
- **Adapter corridors** (3m x 3m transitional tiles, no encounters) auto-generate between incompatible socket pairs

Socket rules by type:
| Type | Entry Sockets | Exit Sockets | Notes |
|------|--------------|-------------|-------|
| Combat | 1 (any) | 1-2 (any) | May branch; branch paths converge within 2 rooms |
| Puzzle | 1 (any) | 1 (any) | Linear, never branches |
| Loot | 1 (any) | 1-2 (any) | Side-path candidate; optional |
| Secret | 1 (hidden/conditional) | 1 (any) | Never on main path; accessed via trigger condition |
| Boss | 1 (S only) | 1 (N only) | Always on main path; entry seals on enter |
| Safe (TDP rooms) | 1 (any) | 1 (any) | TDP pocket is sub-room, not the room itself |

### Guaranteed vs Optional Rooms

**Per zone, guaranteed:**
- 1x Combat room (selected randomly from the zone's combat templates)
- 1x Puzzle room
- 1x Boss room (always the zone's last room)
- 1x Safe room (the TDP-containing room, which is the Loot room)

**Optional per zone (probability-based):**
- 1x Secret room — 40% base chance, +10% per zone cleared (capped at 80%)
- 1x additional Combat room — 50% chance, increases to 75% on higher difficulties
- Loot rooms may duplicate — 25% chance of a second loot room from the same template with scaled-up contents

**Zone 8 special rules:**
- All 5 rooms are guaranteed
- RT-08-04 (Secret) triggers only if the player has discovered at least 2 Secret rooms in previous zones
- RT-08-03 (Final Armory) is skipped if the player has not defeated at least 4 zone bosses

### Difficulty Scaling

Difficulty modifies room parameters across three axes:

| Parameter | Easy | Normal | Hard | Nightmare |
|-----------|------|--------|------|-----------|
| Enemy count multiplier | 0.7x | 1.0x | 1.4x | 1.8x |
| Shadow node density | 0.5x | 1.0x | 1.3x | 1.5x |
| Essence node count | 1.2x | 1.0x | 0.8x | 0.6x |
| Hazard damage | 0.6x | 1.0x | 1.5x | 2.0x |
| TDP duration | 20s | 15s | 12s | 8s |
| Room timer (where applicable) | 1.5x | 1.0x | 0.8x | 0.6x |
| Secret room trigger difficulty | Easy | Normal | Hard | Very Hard |
| Boss HP multiplier | 0.8x | 1.0x | 1.3x | 1.7x |
| Boss phase count | 2 | 3 | 3 | 4 |

**Run-length scaling:** For each zone beyond zone 4, all parameters shift one column toward Nightmare. Zone 7 on Normal uses Hard parameters. Zone 8 on Normal uses Nightmare parameters for non-boss rooms.

**Performer adaptation:** After 3 consecutive deaths in the same room, the room's difficulty drops one tier for the next attempt (shadow nodes reduce, hazard damage decreases). This degrades after clearing — the next room spikes +1 tier.

### Entry and Threshold Placement

**Entry Room (Zone 1 start):**
- Always RT-01-01 or RT-01-02 (Combat or Puzzle)
- Entry socket is always S-facing, spawning the player at the room's southern edge
- First room has no shadow nodes on the first visit of a new run
- A resonance fountain near the entry point fully heals and replenishes resonance

**Threshold Placement (inter-zone transitions):**
- Between each zone pair, a Threshold Corridor (8m x 4m) generates
- The corridor displays resonance echoes of the zone just completed
- A Zone Gate at the corridor's end requires resonance key (earned from zone boss)
- Safe zone between corridors — no enemies, no hazards, full heal
- NPC "The Witness" appears at Threshold corridors with 60% chance, offering trades or lore

**Final Threshold (pre-Zone 8):**
- Extended to 20m x 8m
- Contains a memory review sequence showing the player's run highlights
- One final NPC encounter guaranteed — The Remnant, who offers a choice: extra power for the final boss OR a shortcut to the ending (skips boss, reduced ending rewards)
- After this threshold, no retreat — previous zone rooms are inaccessible

### Room Density and Path Length

- **Minimum path per zone:** 3 rooms (Combat -> Puzzle -> Boss)
- **Maximum path per zone:** 6 rooms (Combat -> Loot -> Puzzle -> Combat -> Secret -> Boss)
- **Average run total:** 24-30 rooms across all 8 zones
- **Branching:** Each zone may have 1 side-branch of 1-2 rooms that dead-ends at a Loot or Secret room
- **Backtracking:** Never required on the critical path; optional backtracking for secrets may be needed
- **Dead-end penalty:** Rooms beyond a dead-end have 1.3x loot quality multiplier to reward exploration
