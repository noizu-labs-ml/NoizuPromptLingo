import type { Entry } from "@/types/entry";

// ─────────────────────────────────────────────
// THE ASHWARD CHRONICLES
// ─────────────────────────────────────────────

export const ashwardEntries: Entry[] = [
  // ── CHARACTERS ──────────────────────────────

  {
    id: "kael-ashward",
    type: "character",
    status: "canon",
    title: "Kael Ashward",
    excerpt:
      "The last master swordsmith of the Thornwall Blacksmith Guild, trained by his grandfather before the War of Stones disrupted the iron trade routes from the Northern Reach.",
    body: `Kael Ashward is the last master swordsmith of the ⌈Thornwall⌉ ⌈Blacksmith Guild⌉, trained by his grandfather Edric before the ⌈War of Stones⌉ disrupted the ⌈iron trade routes⌉ from the Northern Reach. He was fourteen when the war began — old enough to understand what was being lost, young enough to be barred from the fighting.

His primary technique, ⌈cold-singing⌉, is considered a dead art by most smiths in the Reach. Where conventional forging relies on heat and hammer to restructure metal, cold-singing uses sustained vibrational resonance to align the crystalline structure of iron at lower temperatures, producing blades of unusual resilience and a faint harmonic ring when struck. Edric called the technique "listening to what the metal wants to become." Kael has spent thirty years deciding whether that is philosophy or metallurgy.

After the ⌈Treaty of Dusk⌉ formalized the Northern Reach's territorial losses, Kael returned to Thornwall to find his workshop looted and his apprentices scattered. He rebuilt alone. He is now in his mid-forties — the README lists his age at the War as 14, which conflicts with the birth year recorded in the guild registry, which would make him 11. This discrepancy has not been resolved. — and his reputation for quality has outlasted his reputation for temperament.

His daughter ⌈Mira Ashward⌉ is the only person he has taught cold-singing to, though she came to it reluctantly and left Thornwall at seventeen. Their relationship is the quiet center of the novel's second act.`,
    tags: ["protagonist", "swordsmith", "Northern Reach", "cold-singing"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 265,
    version: 3,
    createdAt: "2026-01-08T10:00:00Z",
    updatedAt: "2026-03-11T16:45:00Z",
    connectionIds: [
      "thornwall",
      "blacksmith-guild",
      "war-of-stones",
      "iron-trade-routes",
      "treaty-of-dusk",
      "mira-ashward",
      "cold-singing",
    ],
  },

  {
    id: "mira-ashward",
    type: "character",
    status: "canon",
    title: "Mira Ashward",
    excerpt:
      "Kael's daughter, trained reluctantly in cold-singing, who left Thornwall at seventeen and has not returned. Now works as a courier for the Dusk Compact in the Southern Lowlands.",
    body: `Mira Ashward is the daughter of ⌈Kael Ashward⌉ and, to date, the only living person outside the Ashward bloodline to be trained in ⌈cold-singing⌉. She did not want the training. She accepted it the way a child accepts a wound — understanding only later what it has changed in them.

She left ⌈Thornwall⌉ at seventeen, two years after the ⌈Treaty of Dusk⌉ reshaped the Northern Reach's borders and severed the overland route to the Coastal Federation. The official version she tells is that there was nothing left for her in the town. The truer version is that she and Kael spent three months not speaking after she cold-sang a blade to its own destruction — something he said was impossible, and that she did intentionally.

By the time the novel begins, Mira is twenty-eight. She runs courier routes for the Dusk Compact, an organization that emerged after the ⌈War of Stones⌉ to maintain communication between isolated communities in the Reach. She carries no weapons she has made herself. She carries the one her father made her when she was twelve, which she has never used.

She is introduced through her absence — characters in Thornwall speak of her before she appears. When she does return, it is not to reconcile with Kael but because the ⌈Blacksmith Guild⌉ has been asked to produce weapons for a faction Mira knows to be dangerous, and Kael does not.`,
    tags: ["protagonist", "courier", "cold-singing", "Dusk Compact"],
    era: "Third Age",
    region: "Southern Lowlands",
    wordCount: 258,
    version: 2,
    createdAt: "2026-01-09T11:30:00Z",
    updatedAt: "2026-02-20T09:15:00Z",
    connectionIds: [
      "kael-ashward",
      "thornwall",
      "cold-singing",
      "treaty-of-dusk",
      "war-of-stones",
      "blacksmith-guild",
    ],
  },

  {
    id: "edric-ashward",
    type: "character",
    status: "generated",
    title: "Edric Ashward",
    excerpt:
      "Kael's grandfather and the penultimate master of cold-singing, who trained Kael in the years before the War of Stones. Died during the siege of Thornwall's lower harbor.",
    body: `Edric Ashward was the third-generation master of the ⌈Thornwall⌉ ⌈Blacksmith Guild⌉ and the second-to-last practitioner of ⌈cold-singing⌉ before the technique was passed to his grandson ⌈Kael Ashward⌉. Guild records describe him as exacting, slow to praise, and possessed of an almost religious relationship with iron. He is reported to have refused a commission from the Northern Reach council because the iron "did not want to be a sword."

Edric began training Kael when the boy was seven — unusually early, even within the Ashward tradition. By the time Kael was twelve, he could hold a sustained resonance tone for the duration of a short blade. Edric described this as adequate. He was not a warm man, but he was a thorough one, and Kael's technique reflects that thoroughness.

During the ⌈War of Stones⌉, Edric refused to evacuate Thornwall's lower harbor district when the siege began. Guild accounts conflict on whether this was defiance, confusion, or the simple preference of an old man to die among his tools. He was killed during the third day of the harbor siege, age seventy-one, working at his forge. His body was found with iron filings on his hands, as though he had been working until the moment he stopped.

Kael never speaks of him directly. He speaks of the technique. In the Ashward tradition, the craft and the man who taught it are not separable.

*[Generated from: Kael Ashward, Thornwall, Blacksmith Guild, Cold-singing, War of Stones]*`,
    tags: ["deceased", "swordsmith", "cold-singing", "Third Age elder"],
    era: "Second Age / Third Age",
    region: "Thornwall",
    wordCount: 272,
    version: 1,
    createdAt: "2026-02-14T08:20:00Z",
    updatedAt: "2026-02-14T08:20:00Z",
    connectionIds: [
      "kael-ashward",
      "thornwall",
      "blacksmith-guild",
      "cold-singing",
      "war-of-stones",
    ],
  },

  // ── LOCATIONS ───────────────────────────────

  {
    id: "thornwall",
    type: "location",
    status: "canon",
    title: "Thornwall",
    excerpt:
      "A coastal fortified town in the Northern Reach, built at the mouth of the Ashward River. Known historically for iron trade, now known for its diminished guild and its proximity to contested border territory.",
    body: `Thornwall sits at the mouth of the Ashward River where it meets the Reach Sea, its name derived from the original defensive wall of thorn-wood palisades that predated the stone fortifications now enclosing the lower harbor. The town grew from a crossing point to a trade hub over the course of the early Third Age, its position at the river mouth making it the natural terminus for ⌈iron trade routes⌉ running south from the ore-bearing uplands of the Northern Reach interior.

The town's architecture reflects its two economies: the upper district is built in dressed stone, with the civic buildings and ⌈Blacksmith Guild⌉ hall in the Reach vernacular of wide eaves and deep-set windows against the coastal wind. The lower harbor district is older and denser, built on reclaimed riverbank, with structures that lean toward the water as though reluctant to be on land at all. It is the lower harbor that the ⌈War of Stones⌉ damaged most severely, and it is the lower harbor that has not fully recovered.

Current population: roughly three thousand, down from a high of nearly seven thousand before the war. The decline is partly casualties, partly emigration — after the ⌈Treaty of Dusk⌉ severed the overland route south, merchants found it easier to move operations to the Coastal Federation's ports than to wait for Thornwall's infrastructure to rebuild. The town that remains is skilled, stubborn, and growing insular.

The ⌈Blacksmith Guild⌉ hall still dominates the upper district's skyline, though it currently operates at a fraction of its historical capacity. Three of its seven forges are cold.`,
    tags: ["coastal", "trade hub", "Northern Reach", "fortified"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 288,
    version: 2,
    createdAt: "2026-01-08T10:15:00Z",
    updatedAt: "2026-02-28T14:00:00Z",
    connectionIds: [
      "kael-ashward",
      "mira-ashward",
      "blacksmith-guild",
      "war-of-stones",
      "iron-trade-routes",
      "treaty-of-dusk",
    ],
  },

  {
    id: "northern-reach",
    type: "location",
    status: "canon",
    title: "Northern Reach",
    excerpt:
      "A semi-autonomous highland region defined by its iron deposits, cold climate, and a tradition of craft guilds that have historically resisted the authority of the lowland kingdoms to the south.",
    body: `The Northern Reach is not a kingdom in the conventional sense — it has no throne, no hereditary ruler, and no single capital. It is a region defined by geography: the bowl of highlands running north of the Ashward River valley, cold enough for most of the year that agriculture is secondary to mining and craft. Its political unit is the town, and the town's political unit is the guild.

The Reach's iron deposits are among the richest in the known world, running in thick seams through the granite uplift that forms the region's spine. For three hundred years of the Third Age, this made the Reach indispensable — every lowland kingdom needed Reach iron, and the ⌈iron trade routes⌉ running south through ⌈Thornwall⌉ and the pass towns generated wealth enough to fund the fortifications that made the Reach genuinely difficult to conquer.

The ⌈War of Stones⌉ broke this equilibrium. The war was not primarily about the Reach — it was a lowland dispute over river navigation rights that the Reach was drawn into through its treaty obligations — but the Reach paid a disproportionate cost. Its pass fortifications were dismantled under the ⌈Treaty of Dusk⌉, and its southern trade routes were rerouted through Coastal Federation ports, cutting Reach merchants out of the iron trade's most profitable segment.

The Reach today is geographically unchanged and economically diminished. The highlands are as iron-rich as they ever were. The capacity to turn that iron into political power has not returned.`,
    tags: ["highland", "iron deposits", "autonomous region", "guild culture"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 282,
    version: 2,
    createdAt: "2026-01-10T09:00:00Z",
    updatedAt: "2026-02-15T11:30:00Z",
    connectionIds: [
      "thornwall",
      "iron-trade-routes",
      "war-of-stones",
      "treaty-of-dusk",
      "blacksmith-guild",
    ],
  },

  // ── FACTIONS ─────────────────────────────────

  {
    id: "blacksmith-guild",
    type: "faction",
    status: "canon",
    title: "Thornwall Blacksmith Guild",
    excerpt:
      "The oldest continuously operating craft guild in the Northern Reach, historically responsible for the training of master smiths and the quality-certification of iron goods leaving Thornwall.",
    body: `The Thornwall Blacksmith Guild was founded in the early Third Age by a collective of seven smiths who pooled their tools, their apprentices, and their credibility to negotiate a unified price floor with Coastal Federation merchants — an arrangement that proved so economically effective that it was replicated in seventeen other Reach towns within a generation. The Guild model became the template for Northern Reach civic organization, which is why the Reach has towns but not kingdoms.

At its height, the Guild maintained seven master forges, a school for apprentices, a materials testing laboratory, and a certified mark — the Thornwall stamp — that commanded a premium price in lowland markets because buyers knew it meant the iron had been quality-assessed by the Guild's assay masters. This certification function made the Guild as much an institution of trust as of craft.

The ⌈War of Stones⌉ reduced the Guild's masters from nine to four in three years. Two were killed in the harbor siege. Two emigrated when it became clear the reconstruction would take longer than their working years. One — ⌈Edric Ashward⌉ — died at his forge. Of the four who remained, two have since retired from active smithing. ⌈Kael Ashward⌉ is the last full master currently working.

The Guild still technically controls the Thornwall stamp, but with iron arriving irregularly and no apprentices in active training, the certification means less than it once did. There is a question, not yet asked aloud in the novel's early chapters, of whether an institution can survive the loss of its function while retaining its form.`,
    tags: ["craft guild", "Northern Reach", "iron certification", "Third Age"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 288,
    version: 2,
    createdAt: "2026-01-11T14:00:00Z",
    updatedAt: "2026-03-01T10:00:00Z",
    connectionIds: [
      "kael-ashward",
      "mira-ashward",
      "edric-ashward",
      "thornwall",
      "war-of-stones",
      "iron-trade-routes",
    ],
  },

  {
    id: "dusk-compact",
    type: "faction",
    status: "generated",
    title: "The Dusk Compact",
    excerpt:
      "A courier and communication network that emerged in the Northern Reach after the War of Stones, maintaining contact between isolated communities cut off from the lowland trade routes.",
    body: `The Dusk Compact has no charter, no founding document, and no membership list. It grew from a loose association of couriers, displaced traders, and town criers who found themselves, in the years following the ⌈War of Stones⌉, in possession of a skill the ⌈Northern Reach⌉ desperately needed: the ability to move between isolated communities through disrupted terrain.

The name is commonly attributed to the practice of night travel — post-war patrols from the Coastal Federation operated mostly during daylight hours, making the dusk-to-dawn window the safest for overland movement in contested territory. Whether this etymology is accurate or post-hoc is debated by the few historians who have written about the Compact. Its members tend not to care.

By the time the novel opens, the Compact has evolved from a wartime necessity into a quasi-institutional infrastructure. It maintains relay points at seventeen locations across the Reach, runs a loose code-marking system for road conditions, and commands something close to neutrality from most of the Reach's factions — the Compact carries messages for everyone and sells information to no one, which is either integrity or very careful brand management.

⌈Mira Ashward⌉ runs courier routes for the Compact's eastern circuit, which brings her through ⌈Thornwall⌉'s territory twice yearly. She has held this position for six years. Her father knows she works for the Compact. He does not know that the Compact also carries intelligence.

*[Generated from: Mira Ashward, Northern Reach, War of Stones, Treaty of Dusk]*`,
    tags: ["courier network", "post-war", "neutral faction", "information"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 274,
    version: 1,
    createdAt: "2026-02-18T13:00:00Z",
    updatedAt: "2026-02-18T13:00:00Z",
    connectionIds: ["mira-ashward", "war-of-stones", "northern-reach", "treaty-of-dusk"],
  },

  // ── EVENTS ───────────────────────────────────

  {
    id: "war-of-stones",
    type: "event",
    status: "canon",
    title: "The War of Stones",
    excerpt:
      "A six-year conflict between the Coastal Federation and the River Compact over navigation rights on the Ashward River, in which the Northern Reach was drawn as a treaty-obligated ally of the River Compact.",
    body: `The War of Stones (Third Age, Years 312–318) was nominally a dispute over river navigation rights on the lower Ashward, where the Coastal Federation and the River Compact both claimed authority over toll collection at the three major crossing points. In practice, it was a proxy conflict over control of the iron trade: whoever controlled the crossings controlled the pricing on ⌈iron trade routes⌉ running south from the ⌈Northern Reach⌉.

The Reach entered the war in Year 313 under the terms of the Ashward Treaty, which obligated Reach towns to provide materiel support to the River Compact in exchange for tariff protections that had, for sixty years, made Reach iron profitable in lowland markets. This calculus proved badly wrong. The River Compact collapsed strategically in Year 315, leaving Reach forces holding supply lines for an ally that was no longer fighting. The Reach towns fought a defensive war for the remaining three years, sustaining losses — in forges destroyed, smiths killed, and trade infrastructure dismantled — that far exceeded anything their treaty obligations had contemplated.

The siege of ⌈Thornwall⌉'s lower harbor in Year 317 is the conflict's most frequently cited atrocity. Coastal Federation forces blocked the river mouth for eleven weeks, destroying two of the Guild's three harbor-side forges and killing approximately three hundred civilians in the district. ⌈Edric Ashward⌉ died on the third day of the siege.

⌈Kael Ashward⌉ was fourteen when the war began. He was twenty when it ended with the ⌈Treaty of Dusk⌉.`,
    tags: ["war", "Northern Reach", "Coastal Federation", "Third Age"],
    era: "Third Age · Years 312–318",
    region: "Northern Reach / River Compact",
    wordCount: 276,
    version: 2,
    createdAt: "2026-01-12T10:00:00Z",
    updatedAt: "2026-03-05T09:30:00Z",
    connectionIds: [
      "kael-ashward",
      "thornwall",
      "iron-trade-routes",
      "northern-reach",
      "treaty-of-dusk",
      "blacksmith-guild",
      "edric-ashward",
    ],
  },

  {
    id: "treaty-of-dusk",
    type: "event",
    status: "canon",
    title: "The Treaty of Dusk",
    excerpt:
      "The peace agreement ending the War of Stones, negotiated at the border town of Duskford over eight months in Year 318. Its terms permanently restructured trade rights in the Northern Reach.",
    body: `The Treaty of Dusk was signed at the border crossing of Duskford on the twenty-second day of Harvest Month, Third Age Year 318, by representatives of the Coastal Federation, the surviving River Compact signatories, and five towns of the ⌈Northern Reach⌉ — including ⌈Thornwall⌉. The eight-month negotiation was by most accounts a settlement in name only: the Coastal Federation dictated terms to parties too exhausted and depleted to refuse them.

The treaty's key provisions, as they affected the Reach: dismantlement of the pass fortifications at three northern crossing points; rerouting of iron certification authority from the Reach guild network to a new Coastal Federation Bureau of Standards; and a fifteen-year prohibition on the Ashward Treaty alliance structure, effectively ensuring the Reach could not form the same bloc that had drawn it into the war in the first place.

The Bureau of Standards provision was the one that broke the ⌈Blacksmith Guild⌉'s economic model. The Thornwall stamp — the quality certification that had made ⌈Reach iron⌉ command a premium — was not abolished, but it was no longer recognized as a legal basis for tariff categories. Reach smiths could still mark their work. Buyers in Coastal Federation markets no longer had to pay for that mark.

⌈Kael Ashward⌉ was present at Duskford as a Guild representative's assistant, too junior to speak but senior enough to observe. He has described the signing — to the one person he described it to — as "watching someone fold a map so that your town no longer appears on it."`,
    tags: ["treaty", "peace", "Northern Reach", "Coastal Federation"],
    era: "Third Age · Year 318",
    region: "Duskford / Northern Reach",
    wordCount: 282,
    version: 2,
    createdAt: "2026-01-13T11:00:00Z",
    updatedAt: "2026-02-22T14:00:00Z",
    connectionIds: [
      "kael-ashward",
      "mira-ashward",
      "northern-reach",
      "thornwall",
      "war-of-stones",
      "blacksmith-guild",
      "iron-trade-routes",
    ],
  },

  {
    id: "founding-of-thornwall",
    type: "event",
    status: "generated",
    title: "The Founding of Thornwall",
    excerpt:
      "The establishment of Thornwall as a permanent settlement at the mouth of the Ashward River, traditionally dated to Third Age Year 47, according to the oral histories of the Blacksmith Guild.",
    body: `The founding of ⌈Thornwall⌉ is fixed in Guild oral history at Third Age Year 47, though modern historians place the actual continuous occupation somewhat earlier — the site was in seasonal use as a river-mouth fishing camp for at least thirty years before the first permanent structures were built. The date 47 marks the construction of the original thorn-wood palisade wall, which is why the town remembers it as the founding rather than the settlement: walls, in the ⌈Northern Reach⌉ tradition, are what make a place.

The oral history of the founding, as preserved by the ⌈Blacksmith Guild⌉ in its elder-telling tradition, describes seven families arriving at the river mouth in the same season, each with a forge-weight in their carts — a portable anvil or hammer-stone too heavy to be anything but intentional. The story is almost certainly apocryphal, but it establishes the Guild's foundational claim: the smiths were here first, building the wall, setting the weight. The merchants came later, after the wall was standing.

The first Ashward River ferry crossing was established in Year 52, five years after the founding, by a family whose descendants would eventually become the core of the early Guild. The town's name at this stage was simply "the wall at the river-mouth," rendered in the old Reach dialect as a single compound word that eventually contracted to Thornwall.

Whether the thorn-wood palisades were practical or ceremonial — the site has no significant military value at Year 47 — remains an open question in Thornwall historiography.

*[Generated from: Thornwall, Blacksmith Guild, Northern Reach, Iron Trade Routes]*`,
    tags: ["founding", "historical", "oral history", "Third Age early"],
    era: "Third Age · Year 47",
    region: "Thornwall",
    wordCount: 283,
    version: 1,
    createdAt: "2026-03-13T12:10:00Z",
    updatedAt: "2026-03-13T12:10:00Z",
    connectionIds: ["thornwall", "blacksmith-guild", "northern-reach", "iron-trade-routes"],
  },

  // ── CONCEPTS ─────────────────────────────────

  {
    id: "iron-trade-routes",
    type: "concept",
    status: "canon",
    title: "Iron Trade Routes",
    excerpt:
      "The network of overland and river-based trade paths that carried Northern Reach iron south to the lowland kingdoms, forming the economic backbone of Reach prosperity for three centuries before the War of Stones.",
    body: `The iron trade routes of the ⌈Northern Reach⌉ were not a single road but a system: a branching network of overland paths connecting the ore-mining towns of the Reach interior to the river crossings, and from the crossings to the coastal markets of the Coastal Federation and the inland cities of the River Compact. The routes were maintained by guild-licensed carriers, and the condition of a town's section of route was considered a matter of civic honor — poorly maintained roads meant spoiled loads, spoiled loads meant penalties under the carrier contracts, and penalties meant the kind of reputational damage that followed a town for generations.

At the system's peak — roughly Third Age Years 250 to 310 — the routes carried not just iron but everything the iron trade made profitable: Guild-certified metalwork, specialist tools, weapons pre-ordered by lowland militaries, and the return loads of food, textile goods, and luxury materials that Reach towns could not produce themselves. The routes were, effectively, the reason the Reach did not need to be conquered: it was too profitable as a trade partner.

The ⌈War of Stones⌉ disrupted the routes in ways that were difficult to repair quickly. The pass fortifications that protected the northern crossing points were military assets as much as infrastructure, and their dismantlement under the ⌈Treaty of Dusk⌉ left those routes vulnerable to seasonal banditry and, more consequentially, to the Coastal Federation's new toll authority.

The routes still exist. Iron still moves south. It moves at prices that no longer make the ⌈Blacksmith Guild⌉'s certification model economically rational, which is a structural problem that roads alone cannot solve.`,
    tags: ["trade", "infrastructure", "Northern Reach", "economics"],
    era: "Third Age",
    region: "Northern Reach / Lowlands",
    wordCount: 284,
    version: 2,
    createdAt: "2026-01-14T09:00:00Z",
    updatedAt: "2026-02-10T16:00:00Z",
    connectionIds: [
      "northern-reach",
      "thornwall",
      "blacksmith-guild",
      "war-of-stones",
      "treaty-of-dusk",
    ],
  },

  {
    id: "cold-singing",
    type: "concept",
    status: "canon",
    title: "Cold-Singing",
    excerpt:
      "A metalworking technique unique to the Ashward family tradition, using sustained vibrational resonance rather than high heat to align the crystalline structure of iron, producing blades of unusual resilience with a faint harmonic ring.",
    body: `Cold-singing is a forging technique developed within the ⌈Ashward⌉ family tradition over at least three generations, though whether it was invented by the first Ashward smith or inherited from an older Northern Reach practice is not documented. The ⌈Blacksmith Guild⌉'s own records classify it as an "Ashward proprietary method" — a designation that means no other guild member has been trained in it, not that it is formally protected.

The technique diverges from standard smithing at the point of heat. Conventional bladesmithing uses high-temperature forging — heating iron to a workable temperature, then shaping it under hammer while hot — to achieve the metal's final structure. Cold-singing works the metal at a temperature significantly lower, using a sustained resonance tone produced by the smith (vocally, or in some accounts through a purpose-built instrument) to excite the metal's internal crystalline structure into alignment without requiring the same degree of thermal energy.

The practical results: blades made by cold-singing are measurably harder than conventionally forged equivalents at the same carbon content, and they maintain a sharpened edge longer under comparable use. They also emit a faint harmonic ring when struck — not loud enough to be a tactical disadvantage, but distinctive enough that experienced fighters who have faced cold-sung blades recognize the sound.

The cost: cold-singing is significantly slower than conventional forging. ⌈Kael Ashward⌉ produces roughly a third the blade volume of a conventional master in the same time. ⌈Mira Ashward⌉ is the only other living practitioner.

The open question in the novel is whether cold-singing is a physical technique or something else. ⌈Edric Ashward⌉ believed it was the second thing.`,
    tags: ["metalworking", "Ashward tradition", "technique", "magic-adjacent"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 292,
    version: 2,
    createdAt: "2026-01-15T10:00:00Z",
    updatedAt: "2026-03-02T11:00:00Z",
    connectionIds: ["kael-ashward", "mira-ashward", "edric-ashward", "blacksmith-guild"],
  },

  {
    id: "reach-guild-law",
    type: "concept",
    status: "generated",
    title: "Reach Guild Law",
    excerpt:
      "The customary legal framework governing craft guilds throughout the Northern Reach, codified informally across three centuries into a body of precedent that sits between civic law and professional regulation.",
    body: `Reach Guild Law is not a written code but a living body of precedent, maintained by each guild's senior members through oral tradition and, since approximately Third Age Year 200, through a registry of recorded disputes and their resolutions. It governs the relationship between guilds and the towns that host them, between masters and apprentices, between competing guilds operating in the same trade, and between guild-certified goods and the markets that receive them.

The law's core concepts are: the quality-bond (a guild's collective responsibility for the work produced under its mark), the master-right (the authority of a working master to refuse commissions without explanation), and the succession rule (the requirement that a guild have at minimum one master in active practice to maintain its charter rights).

This last provision has become relevant to the ⌈Blacksmith Guild⌉ of ⌈Thornwall⌉. With ⌈Kael Ashward⌉ as the sole active master, the Guild is technically in compliance with the succession rule — but only just. If Kael were to die, retire, or formally resign his mastership, the Guild would have a period of two years under Guild Law to either certify a new master or formally dissolve. Two years is a short time to train a master smith from nothing.

The Guild Law has no enforcement mechanism beyond collective reputation and trade partnership. In the pre-war era, this was sufficient — no town wanted to be known as the place where Guild Law was violated. In the post-⌈Treaty of Dusk⌉ environment, with the Coastal Federation's Bureau of Standards holding formal certification authority, the question of whether Guild Law still carries the same weight is unresolved.

*[Generated from: Blacksmith Guild, Thornwall, Northern Reach, Treaty of Dusk]*`,
    tags: ["law", "custom", "guild system", "Northern Reach"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 295,
    version: 1,
    createdAt: "2026-02-25T15:00:00Z",
    updatedAt: "2026-02-25T15:00:00Z",
    connectionIds: [
      "blacksmith-guild",
      "kael-ashward",
      "thornwall",
      "northern-reach",
      "treaty-of-dusk",
    ],
  },

  // ── OBJECTS ──────────────────────────────────

  {
    id: "kaels-bench-hammer",
    type: "object",
    status: "canon",
    title: "Kael's Bench Hammer",
    excerpt:
      "The primary working hammer Kael Ashward has used for twenty years, cold-sung to its own handle to prevent loosening — an act his grandfather called 'a smith marrying his work.'",
    body: `Kael's bench hammer is a three-pound cross-peen of the type standard in the ⌈Northern Reach⌉ smith tradition, distinguished primarily by the fact that ⌈Kael Ashward⌉ has ⌈cold-sung⌉ the head to its haft — a resonance-bonding technique that fuses the iron of the head to the ash-wood handle at the molecular level, eliminating the micro-movement that eventually loosens any conventionally fitted hammer.

The hammer is visually unremarkable. A stranger picking it up would notice only that it is unusually well-balanced for its size, and that the handle has a faint harmonic vibration in certain grips — not enough to feel significant, but enough, for someone trained in ⌈cold-singing⌉, to suggest that the iron is active.

⌈Edric Ashward⌉ called the practice of cold-singing a tool to its own handle "a smith marrying his work." He meant it as a warning. The cold-singing process, once completed, cannot be reversed without destroying both the head and the haft — the bond is more permanent than the tool's useful life. Kael understood the warning and did it anyway when he was twenty-three, the year after the ⌈Treaty of Dusk⌉.

The hammer appears in three scenes in the novel: once in the opening chapter as Kael is working, once when ⌈Mira Ashward⌉ returns to the forge and picks it up without asking, and once at the novel's end in a context that would be a spoiler to describe here. The author has noted that it is not a symbol. It is a hammer.`,
    tags: ["tool", "cold-sung", "Ashward", "personal object"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 270,
    version: 2,
    createdAt: "2026-01-20T14:00:00Z",
    updatedAt: "2026-03-08T10:00:00Z",
    connectionIds: ["kael-ashward", "cold-singing", "edric-ashward", "mira-ashward"],
  },

  // ── RULES ────────────────────────────────────

  {
    id: "resonance-law",
    type: "rule",
    status: "canon",
    title: "The Rule of Resonance",
    excerpt:
      "The physical and metaphysical principle underlying cold-singing: that materials have inherent resonant frequencies, and that sustained attunement to those frequencies can produce structural changes without the introduction of external heat.",
    body: `The Rule of Resonance is not a rule in the civic or legal sense — it is the foundational physical principle of ⌈cold-singing⌉ as practiced by the ⌈Ashward⌉ line, and the closest thing the technique has to a theoretical framework. It was articulated, so far as the novel's lore records, by ⌈Edric Ashward⌉, who described it as the observation that "every made thing has a sound it wants to make, and if you can make that sound first, the thing will follow."

In practical terms: all materials vibrate at characteristic frequencies determined by their composition and structure. When a skilled cold-singer produces a sustained tone that matches the resonant frequency of a metal at its grain-boundary level, the metal's internal structure begins to align with the vibration — grains rotate, defects migrate, stress concentrations release. This is the mechanism by which cold-singing achieves the same results as high-temperature forging without the heat: it applies energy at the right frequency rather than at the right temperature.

The rule has one corollary that ⌈Kael Ashward⌉ discovered independently and did not find in any Ashward record: if a material is cold-sung to a frequency higher than its structural tolerance, it will align itself to destruction. This is what ⌈Mira Ashward⌉ did with the demonstration blade that ended her apprenticeship. She cold-sang it to its own failure point — not by accident, but deliberately, as a test of whether the rule was absolute.

It is. The blade fractured along perfectly aligned grain boundaries. Edric's framework did not address this case. Kael has never resolved whether it means the rule is incomplete or only that Mira understood it better than he did.`,
    tags: ["physics", "metaphysics", "cold-singing", "Ashward theory"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 288,
    version: 2,
    createdAt: "2026-01-22T09:00:00Z",
    updatedAt: "2026-03-03T16:00:00Z",
    connectionIds: ["cold-singing", "kael-ashward", "mira-ashward", "edric-ashward"],
  },
];

// ─────────────────────────────────────────────
// IRONLIGHT CAMPAIGN
// ─────────────────────────────────────────────

export const ironlightEntries: Entry[] = [
  {
    id: "ironlight-city",
    type: "location",
    status: "canon",
    title: "Ironlight",
    excerpt:
      "A city-state powered by industrialized aetheric infrastructure, where the Artificer Guilds control the power conduits running beneath the streets and the working class is beginning to organize.",
    body: `Ironlight is a city of approximately ninety thousand, built over the course of two centuries on the bones of an older settlement whose name has been largely forgotten. The city's defining feature is its conduit network: forty miles of aetheric power lines running beneath the streets, distributing manufactured magical energy to factories, streetlamps, transit rail, and the workshops of the three Artificer Guilds.

The conduit network is the city's circulatory system and its primary political fault line. The Guilds built it, own it, and charge for access to it. Every factory, every transit operator, every building that wants light after dark pays the Guilds for conduit access. This has made the Guilds extraordinarily wealthy and given them a structural power over city life that no elected council can fully counterbalance.

The tension the campaign explores: the Conduit Workers' Union has been organizing for three years and is approaching a general strike that could shut down significant portions of the city's infrastructure. The party has been hired, depending on session context, by either the Guilds (to prevent the strike) or the Union (to protect strike organizers from Guild-sponsored intimidation). The GM notes that both sides have legitimate grievances and neither has clean hands.`,
    tags: ["city-state", "industrial magic", "aetheric", "political"],
    era: "Age of Conduits",
    region: "Ironlight City-State",
    wordCount: 224,
    version: 1,
    createdAt: "2026-01-25T10:00:00Z",
    updatedAt: "2026-02-05T14:00:00Z",
    connectionIds: ["artificer-guilds", "conduit-workers-union"],
  },
  {
    id: "artificer-guilds",
    type: "faction",
    status: "canon",
    title: "The Artificer Guilds",
    excerpt:
      "The three organizations that built and collectively control Ironlight's aetheric conduit network: the Foundry Guild, the Signal Guild, and the Binding Guild. Allied on infrastructure, competing on everything else.",
    body: `The Artificer Guilds — the Foundry Guild, the Signal Guild, and the Binding Guild — are the three organizations that designed, built, and now operate Ironlight's aetheric conduit network. They share ownership of the conduit infrastructure under a tri-party compact negotiated at the city's founding, divide conduit revenue according to their original capital contributions, and cooperate just enough to prevent the network from failing and no more.

The Foundry Guild handles physical infrastructure: conduit laying, node maintenance, and the manufacturing of aetheric-compatible equipment. It is the largest and oldest of the three, and its leadership tends toward conservative political positions — the current system is profitable, and they see no reason to change it.

The Signal Guild manages aetheric flow regulation and metering — effectively, they decide how much power flows where and at what price. This makes them the most politically exposed of the three, since every business with a conduit complaint talks to the Signal Guild. They have the most to gain from a negotiated settlement with the Union and the most political flexibility to offer one.

The Binding Guild is the smallest and least understood of the three. Its original function was binding aetheric energy into physical objects — creating the enchanted components that make conduit devices possible — but its current operations are opaque even to the other two Guilds. There are persistent rumors that the Binding Guild has been doing something with the conduit network's unused capacity that isn't in the tri-party compact.`,
    tags: ["industrial magic", "guild", "conduit network", "political faction"],
    era: "Age of Conduits",
    region: "Ironlight City-State",
    wordCount: 256,
    version: 1,
    createdAt: "2026-01-26T09:00:00Z",
    updatedAt: "2026-02-06T11:00:00Z",
    connectionIds: ["ironlight-city", "conduit-workers-union"],
  },
  {
    id: "conduit-workers-union",
    type: "faction",
    status: "canon",
    title: "Conduit Workers' Union",
    excerpt:
      "The labor organization representing the workers who maintain Ironlight's aetheric conduit network — the skilled tradespeople without whom the Guilds' infrastructure would stop functioning within weeks.",
    body: `The Conduit Workers' Union was chartered three years before the campaign begins by a group of conduit maintenance workers who had grown tired of the Guild practice of classifying maintenance labor as "non-specialized" to avoid paying the rates mandated for skilled Guild work. The classification was technically defensible — conduit maintenance does not require Guild certification — and practically dishonest, since maintaining live aetheric conduits without incident requires training that the Guilds themselves provided.

The Union currently represents approximately six thousand workers across all three Artificer Guilds' maintenance operations. Its core demands: reclassification of maintenance work as skilled labor, a 40% wage increase from current rates, and a seat on the Conduit Safety Board that currently operates as a Guild-only body despite its city-wide mandate.

The Union's leverage is real. The conduit network requires continuous maintenance — the aetheric charge degrades conduit material at a rate that, without regular treatment, would render sections of the network unusable within six weeks. Union members know exactly which sections are most vulnerable. The Guild leadership knows that they know.

The campaign doesn't take sides on whether the strike is justified. Both the pay disparity and the Guild's concern about infrastructure safety during a strike are presented as legitimate. The party's job is to navigate the situation, and the GM's intent is that their choices will affect which of several possible futures Ironlight ends up in.`,
    tags: ["labor", "union", "working class", "political"],
    era: "Age of Conduits",
    region: "Ironlight City-State",
    wordCount: 262,
    version: 1,
    createdAt: "2026-01-27T10:00:00Z",
    updatedAt: "2026-02-07T09:00:00Z",
    connectionIds: ["ironlight-city", "artificer-guilds"],
  },
  {
    id: "veln-the-unmeasured",
    type: "character",
    status: "canon",
    title: "Veln the Unmeasured",
    excerpt:
      "The Union's lead organizer — a former Signal Guild meter-reader who quit after witnessing a conduit accident that killed two workers and was officially recorded as 'equipment failure due to operator error.'",
    body: `Veln (family name withheld from Guild records by personal choice) worked for the Signal Guild as a conduit meter-reader for eleven years before witnessing the collapse of Conduit Node 7 in the eastern industrial district. Two workers were killed in the collapse. The Guild incident report, filed six weeks later, attributed the failure to "operator error resulting in aetheric overload." Veln, who was present, knows the operators did nothing wrong — the node had been flagged for maintenance for four months and the work order had been deprioritized.

She has been organizing the Union for three years. She is effective, specific, and uninterested in publicity. She does not want to be the face of the movement; she wants the face of the movement to be the list of forty-seven outstanding maintenance deferrals she obtained through a sympathetic contact in the Foundry Guild's records office.

The party will almost certainly interact with Veln in the campaign's first act, either as a contact who can provide information about the Guilds' internal operations or as a target of Guild-sponsored investigation. The GM has noted that Veln is not a villain, but she is also not above using the party if it serves the Union's interests.

Her epithet — "the Unmeasured" — is Guild slang for someone who reads conduit meters without being measurable in return. Her former colleagues mean it as a compliment. The Guilds mean it differently.`,
    tags: ["NPC", "organizer", "former Guild worker", "Union"],
    era: "Age of Conduits",
    region: "Ironlight City-State",
    wordCount: 252,
    version: 1,
    createdAt: "2026-01-28T11:00:00Z",
    updatedAt: "2026-02-08T10:00:00Z",
    connectionIds: ["conduit-workers-union", "artificer-guilds", "ironlight-city"],
  },
  {
    id: "aetheric-conduit-law",
    type: "rule",
    status: "canon",
    title: "Aetheric Conduit Law",
    excerpt:
      "The physical rules governing aetheric energy flow in Ironlight's conduit network — not magic as traditionally understood, but a set of consistent physical principles that determine what the network can and cannot do.",
    body: `Aetheric energy in the Ironlight setting behaves according to consistent physical rules, distinguishing it from the classical fantasy model of magic as arbitrary power. The conduit network is an engineered system, not a mystical one, and it has failure modes that engineers understand and plan for.

Core principles: aetheric charge is quantifiable and measurable (this is the Signal Guild's primary function); it flows from higher to lower potential across conductive materials (conduit maintenance involves keeping conductivity consistent); it degrades non-conductive materials at a rate proportional to exposure intensity (this is why maintenance workers are necessary); and it cannot be stored indefinitely — aetheric charge dissipates from storage nodes at roughly 3% per day without active maintenance.

What the law does NOT permit: spontaneous generation of aetheric energy (it must be produced at aetheric generators, of which Ironlight has four), transmission through biological tissue without significant harm (which is why conduit maintenance workers wear insulating gear), or stable operation above the network's designed load capacity (the conduit equivalent of overloading a circuit).

The campaign uses these rules to create engineering-adjacent encounters: the party may need to reroute power flow around a damaged section, stabilize an overloading node, or understand why a conduit failure happened in a specific way. The GM has a simple calculator for load and flow that keeps these challenges tractable without becoming math homework.`,
    tags: ["aetheric", "magic rules", "engineering", "system"],
    era: "Age of Conduits",
    region: "Ironlight City-State",
    wordCount: 261,
    version: 1,
    createdAt: "2026-01-29T09:00:00Z",
    updatedAt: "2026-02-09T11:00:00Z",
    connectionIds: ["ironlight-city", "artificer-guilds"],
  },
];

// ─────────────────────────────────────────────
// MERIDIAN SECTOR
// ─────────────────────────────────────────────

export const meridianEntries: Entry[] = [
  {
    id: "meridian-gate",
    type: "location",
    status: "canon",
    title: "Meridian Gate",
    excerpt:
      "The artificial transit structure at the center of the Meridian Sector, enabling faster-than-light travel between the three inhabited systems. No human built it. No one knows who did.",
    body: `Meridian Gate is a stable transit aperture of unknown construction located at the gravitational midpoint between the three inhabited systems of the Meridian Sector. Its operational diameter is 4.2 kilometers. Its material composition does not match any known element. It has been in continuous operation for longer than humanity has been in space.

The Gate was discovered in 2241 by the survey vessel HMCS Perseverance during a routine deep-scan of the transit corridor between Kessel Station and the New Adriatic colony. The discovery was immediately significant — the Perseverance's crew understood within hours that they were looking at a manufactured structure that predated humanity's spaceflight by at minimum several hundred thousand years.

Transit through the Gate takes approximately 11 seconds regardless of destination — the three "mouths" of the Gate connect the three inhabited systems in a triangle, and the transit time is identical across all three routes. The physics of this are not understood. The ⌈Gate Authority⌉ has been collecting transit telemetry for eighty years and has produced forty-seven papers describing what the Gate does without adequately explaining how.

The alien signal that forms the campaign's central plot device was received through the Gate's communication channels — a passive monitoring system that the Gate Authority maintains to detect any transmission the Gate might be using as a carrier wave. It has never received anything. Until three months before the campaign begins.`,
    tags: ["alien artifact", "transit gate", "FTL", "unknown origin"],
    era: "2320s CE",
    region: "Meridian Sector / Deep Space",
    wordCount: 248,
    version: 1,
    createdAt: "2026-02-01T10:00:00Z",
    updatedAt: "2026-03-01T14:00:00Z",
    connectionIds: ["gate-authority", "alien-signal", "kessel-station"],
  },
  {
    id: "gate-authority",
    type: "faction",
    status: "canon",
    title: "The Gate Authority",
    excerpt:
      "The supranational body that administers transit rights through Meridian Gate, collecting tolls, maintaining telemetry, and theoretically preventing any single government from monopolizing access to the FTL connection.",
    body: `The Gate Authority was established by the Meridian Accords of 2249, eight years after the Gate's discovery, as a compromise between the three inhabited systems' competing claims over transit access. No one system could be trusted to control a resource this strategically significant. The Authority was designed as a neutral administrative body with sufficient enforcement capacity to police the Gate approaches and insufficient political power to leverage that position into broader authority.

Whether the design has worked depends on who you ask. The Authority has maintained nominal neutrality for eighty years, and no single system has monopolized Gate access. What has happened is a more complex capture: the Gate's economic value has made the Authority itself a prize, and its board seats are traded as political currency among the three systems' governments in ways that the Accords' original framers didn't anticipate.

The Authority's secondary function — monitoring the Gate's communication channels for carrier-wave transmissions — was originally a scientific footnote. It has become the most important function the Authority has ever had.

The ⌈alien signal⌉ received three months before the campaign opens has been classified above the Authority's standard confidentiality tier by a vote of the board that was not unanimous. Two board members are known to be passing information about the signal to their home governments. The Authority's director has not publicly confirmed the signal exists. Every government in the Sector knows about it anyway.`,
    tags: ["supranational", "transit administration", "political", "alien signal"],
    era: "2320s CE",
    region: "Meridian Sector",
    wordCount: 258,
    version: 1,
    createdAt: "2026-02-02T11:00:00Z",
    updatedAt: "2026-03-02T10:00:00Z",
    connectionIds: ["meridian-gate", "alien-signal", "kessel-station"],
  },
  {
    id: "alien-signal",
    type: "concept",
    status: "canon",
    title: "The Alien Signal",
    excerpt:
      "A structured transmission received through Meridian Gate's carrier-wave monitoring system three months before the campaign begins — the first confirmed non-human communication in human history.",
    body: `The alien signal was received on a carrier wave embedded in the Gate's own operational frequency — a channel that the ⌈Gate Authority⌉'s monitoring equipment has been watching since 2260, on the theory that whatever built the Gate might occasionally use it to communicate. The theory was considered speculative enough to be a minor budget line. The monitoring system was maintained primarily as a scientific credibility measure.

The signal is 4,096 bits in length. It is structured — the information-theoretic analysis confirms this with a probability approaching certainty, because random noise does not produce the specific kind of repetitive patterning the signal contains. It has been decoded to the extent that the underlying structure can be described: it appears to be a coordinate system, or an index, or possibly both. The semantic content — what the coordinates point to, or what is being indexed — has not been determined.

The signal has been received seventeen times, at irregular intervals averaging approximately four days. Each instance is identical. The transmitter is, by triangulation, located somewhere beyond the Gate's known transit capacity — further than any of the Gate's three current connections reach.

The campaign begins with the party being briefed on the signal by a contact within the Gate Authority. The briefing is unofficial. The party's job, officially, is something else entirely. The signal is meant to be discovered, not assigned.`,
    tags: ["alien", "first contact", "signal", "mystery"],
    era: "2320s CE",
    region: "Meridian Sector / Unknown Origin",
    wordCount: 262,
    version: 1,
    createdAt: "2026-02-03T09:00:00Z",
    updatedAt: "2026-03-03T09:00:00Z",
    connectionIds: ["meridian-gate", "gate-authority", "kessel-station"],
  },
  {
    id: "kessel-station",
    type: "location",
    status: "canon",
    title: "Kessel Station",
    excerpt:
      "The largest transit hub in the Meridian Sector, a deep-space platform built around one of the Gate's three aperture approaches, serving as the Sector's primary trade and information exchange node.",
    body: `Kessel Station is a habitat-plus-infrastructure platform of approximately 340,000 square meters of pressurized volume, built in successive expansions over sixty years at the approach vector for Gate Aperture Alpha — the connection to the New Adriatic colony system. Its permanent population is around 22,000; its transient population on any given day is approximately three times that.

The station's economy is transit: every ship moving through Gate Aperture Alpha passes within sensor range of Kessel, and most stop. The Gate Authority maintains its operational headquarters here, which makes Kessel simultaneously a neutral administrative hub and a political target — the governments of all three inhabited systems maintain embassies, intelligence offices, and shadow operations on the station.

The station's layout reflects its history of expedient expansion: the original core is orderly, well-lit, and spacious, built to a plan by the first Gate Authority contracts. The outer rings are chaotic, cramped, and run by whoever built them. The outer rings are also where most of the interesting things in the sector happen, since the Authority's enforcement capacity drops off sharply beyond the core perimeter.

The campaign begins on Kessel Station. Most campaigns set in the Meridian Sector begin on Kessel Station. There is a reason for this that the GM usually describes as "it's where the threads are."`,
    tags: ["space station", "transit hub", "Gate approach", "political nexus"],
    era: "2320s CE",
    region: "Meridian Sector / Aperture Alpha",
    wordCount: 254,
    version: 1,
    createdAt: "2026-02-04T10:00:00Z",
    updatedAt: "2026-03-04T11:00:00Z",
    connectionIds: ["meridian-gate", "gate-authority", "alien-signal"],
  },
];

// ─────────────────────────────────────────────
// ALL ENTRIES COMBINED
// ─────────────────────────────────────────────

export const allEntries: Entry[] = [
  ...ashwardEntries,
  ...ironlightEntries,
  ...meridianEntries,
];
