import type { Entry, Connection } from "@/types/entry";
import type { ConsistencyFlag } from "@/components/entries/entry-detail";

// ---------------------------------------------------------------------------
// Mock entries — Ashward Chronicles universe
// ---------------------------------------------------------------------------

export const MOCK_ENTRIES: Entry[] = [
  {
    id: "kael-ashward",
    type: "character",
    status: "canon",
    title: "Kael Ashward",
    excerpt:
      "The last master swordsmith of the Thornwall Blacksmith Guild, trained by his grandfather before the War of Stones shattered the iron trade of the Northern Reach.",
    body: `Kael Ashward was born in the thirty-seventh year of the Third Age to a family of smiths whose lineage stretched back to the original founders of ⌈Thornwall⌉. His grandfather, Edric Ashward, was himself a master of the forge — one of fewer than a dozen practitioners of cold-singing, an ancient technique that bound whisper-thin resonance channels into finished blades, allowing the steel to carry sound the way water carries light. Edric passed the method to Kael in secret, sensing that the ⌈Blacksmith Guild⌉ elders would never sanction its revival after the guild's long fracture with the Coastal Federation's smithing orders.

The ⌈War of Stones⌉ reached Thornwall when Kael was fourteen. He was not a soldier — the guild forbade apprentices from taking up arms — but he watched the city's iron reserves vanish into the conflict's furnace while the ⌈iron trade routes⌉ from the Northern Reach closed one by one under the weight of the blockade. When the war ended under the ⌈Treaty of Dusk⌉, Thornwall's smithing culture was a ghost of itself: seven of the nine guild masters had fled or died, the apprenticeship rolls had been suspended for four years, and the cold-singing technique existed in a single living practitioner.

That practitioner was Kael. He spent the following decades rebuilding the guild's ledgers, re-apprenticing young smiths from families that had fled and returned, and quietly producing the blades that made his name in the coastal markets. He never advertised the cold-singing, but collectors who knew what to listen for would press a finished Ashward blade flat against a stone wall in a silent room and hear it hum — a barely perceptible note, different for every blade, which Kael said was the steel "learning its own voice." His daughter ⌈Mira Ashward⌉ has shown no aptitude for smithing and considerable aptitude for politics, a combination Kael regards with resigned affection.

His workshop sits in the lower quarter of Thornwall near the old harbor gate, identifiable from the street by the faint singing that emerges when the wind comes off the sea at the right angle. The guild's records list him as "Senior Master, Unaffiliated Tradition" — a bureaucratic compromise that allows him to operate under guild protections without formally acknowledging that the technique he practices was never officially re-sanctioned.`,
    tags: ["protagonist", "swordsmith", "cold-singing", "guild master"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 347,
    version: 4,
    createdAt: "2026-01-12T09:00:00Z",
    updatedAt: "2026-03-01T14:22:00Z",
    connectionIds: [
      "thornwall",
      "blacksmith-guild",
      "war-of-stones",
      "iron-trade-routes",
      "mira-ashward",
      "treaty-of-dusk",
      "cold-singing",
    ],
  },

  {
    id: "thornwall",
    type: "location",
    status: "canon",
    title: "Thornwall",
    excerpt:
      "A coastal fortified city in the Northern Reach, built atop the ruins of an older settlement destroyed in the First Age. Known for its iron industry and the guild that made it prosperous.",
    body: `Thornwall occupies a long peninsula on the northern coast, its seaward face protected by a natural basalt shelf that makes direct naval approach nearly impossible. The city's name derives from the iron thorn-brackets that line its landward wall — a distinctive fortification technique developed by the ⌈Blacksmith Guild⌉ in the Second Age, in which curved iron spurs are set into the stone at intervals, angled to deflect siege equipment while allowing defenders to sight along the wall's surface.

The city's economy has been organized around iron since its refounding. The ⌈Northern Reach iron deposits⌉ lie three days inland, and Thornwall grew around the infrastructure needed to move ore to the coast: the smelting quarter in the city's west, the guild houses clustered near the harbor, and the merchant rows that line the old harbor road. For most of the Second Age and early Third Age, Thornwall's position made it the primary iron exporter for the entire coastal trade network.

The ⌈War of Stones⌉ damaged Thornwall less in material terms than in human ones. The city's walls held; the guild did not. What the war destroyed was the network of relationships — apprentices, trading partners, the guild's political standing with the Coastal Federation — that had made Thornwall's smith culture function. Recovery has been slow, and the city's current position in the iron trade is a fraction of what it held before the conflict.`,
    tags: ["coastal city", "iron trade", "Northern Reach", "fortified"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 238,
    version: 2,
    createdAt: "2026-01-10T10:30:00Z",
    updatedAt: "2026-02-14T11:00:00Z",
    connectionIds: ["blacksmith-guild", "war-of-stones", "kael-ashward", "iron-trade-routes"],
  },

  {
    id: "blacksmith-guild",
    type: "faction",
    status: "canon",
    title: "Blacksmith Guild",
    excerpt:
      "The oldest continuously operating guild in the Northern Reach. Governs smithing practice, apprenticeship, trade standards, and the certification of techniques including the disputed cold-singing method.",
    body: `The Blacksmith Guild of ⌈Thornwall⌉ was chartered in the forty-second year of the Second Age under the joint authority of the city's founding council and the Coastal Federation's merchant compact. Its founding mandate was narrow — regulate iron quality standards and prevent price manipulation between smithing houses — but its authority expanded across the following centuries as Thornwall's smith culture grew more complex.

By the late Second Age the guild held authority over: apprenticeship rolls and certification, the right to operate a forge within city limits, the standards for any blade sold into Coastal Federation markets under a Thornwall mark, and a small standing force of guild inspectors with legal authority to inspect any forge in the city on twelve hours' notice. It also maintained the definitive written record of all sanctioned techniques — the "Codex of Practices" — which was updated by guild conclave every fifteen years.

The ⌈War of Stones⌉ fractured the guild along the same lines that fractured Thornwall's broader society: those who saw the war as a Coastal Federation aggression became hardliners who wanted to close the guild to Federation-trained smiths indefinitely, while those who had commercial ties to the south argued for rapid normalization. Seven of the nine guild masters fled or died during the war years. The guild's current structure reflects these tensions: it has formal authority over most of Thornwall's smithing but exercises that authority with considerable caution, aware that its legitimacy is still contested.`,
    tags: ["guild", "smithing", "Thornwall", "Second Age founding"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 264,
    version: 3,
    createdAt: "2026-01-10T11:00:00Z",
    updatedAt: "2026-02-20T09:45:00Z",
    connectionIds: ["thornwall", "war-of-stones", "kael-ashward", "cold-singing"],
  },

  {
    id: "war-of-stones",
    type: "event",
    status: "canon",
    title: "War of Stones",
    excerpt:
      "A six-year conflict between the Northern Reach and the Coastal Federation that ended with the Treaty of Dusk. Precipitated by a disputed iron tariff and ended with the destruction of the Northern Reach's guild infrastructure.",
    body: `The War of Stones began in the twelfth year of the Third Age over what began as a tariff dispute — the Coastal Federation imposed a twenty-percent surcharge on Northern Reach iron exports, citing quality irregularities in a shipment that the Northern Reach council argued had been deliberately contaminated by Federation agents. Within eight months, the tariff dispute had expanded into a blockade, and within eighteen months the blockade had drawn in two of the inland kingdoms who had treaty obligations to both sides.

The name derives not from the conflict's cause but from its character: most of the fighting took place in the rocky highland passes that connect the Northern Reach to the Federation's northern territories, and most of the casualties occurred in grinding sieges rather than open battle. The ⌈Blacksmith Guild⌉ of ⌈Thornwall⌉ lost most of its leadership in the third year of the war, when guild masters who had traveled to a neutral territory for ceasefire negotiations were detained by Federation forces and held for the remainder of the conflict.

The war ended under the ⌈Treaty of Dusk⌉, which the Northern Reach negotiators regarded as a forced settlement and the Federation regarded as a reasonable resolution. The actual fighting had concluded eight months before the treaty was signed — a period of armed truce during which both sides argued over terms while the Northern Reach's iron infrastructure quietly collapsed from lack of investment and guild supervision.`,
    tags: ["war", "Third Age", "Northern Reach", "Coastal Federation"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 258,
    version: 2,
    createdAt: "2026-01-11T08:00:00Z",
    updatedAt: "2026-02-10T16:00:00Z",
    connectionIds: ["blacksmith-guild", "thornwall", "treaty-of-dusk", "kael-ashward", "iron-trade-routes"],
  },

  {
    id: "iron-trade-routes",
    type: "concept",
    status: "canon",
    title: "Iron Trade Routes",
    excerpt:
      "The network of overland and coastal shipping lanes that connected Northern Reach iron deposits to coastal and inland markets. Severely disrupted by the War of Stones; partially restored under the Treaty of Dusk.",
    body: `The Northern Reach's iron deposits — centered on the Ashward Highlands, from which the Ashward family takes its name — were connected to coastal markets through a trade route network that had evolved over roughly two centuries of Second Age commerce. The main artery ran from the highland mining settlements down to ⌈Thornwall⌉, where ore was smelted and finished goods were loaded onto coastal vessels. Secondary routes branched east and south, serving the inland kingdoms and the highland townships that were too small to maintain their own smelting infrastructure.

The ⌈War of Stones⌉ disrupted the routes in two distinct phases. First, the Coastal Federation's blockade cut the sea routes, forcing overland shipments that were slower, more expensive, and more vulnerable to the conflict's fighting. Second, as the war continued, the overland routes themselves became contested — raiding parties on both sides targeted supply trains, and the inland kingdoms that had hosted waystation infrastructure began to demand payment for continued access. By the war's fourth year, iron from the Northern Reach was arriving at its traditional markets at a fraction of pre-war volume and at dramatically elevated prices.

Partial restoration came under the ⌈Treaty of Dusk⌉, but the trade network that resumed bore little resemblance to its predecessor. Many of the smaller waystation operators had gone out of business; several of the inland kingdoms had built their own, inferior smelting capacity and no longer needed to import finished iron; and the coastal market had developed alternative suppliers during the disruption. The routes that remained carried Thornwall iron to a smaller, more specialized market — primarily weapons buyers and specialist craftsmen who valued the quality difference — rather than the broad commodity market the network had served before.`,
    tags: ["trade", "economics", "Northern Reach", "iron"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 295,
    version: 1,
    createdAt: "2026-01-13T14:00:00Z",
    updatedAt: "2026-01-13T14:00:00Z",
    connectionIds: ["thornwall", "war-of-stones", "treaty-of-dusk", "kael-ashward"],
  },

  {
    id: "treaty-of-dusk",
    type: "event",
    status: "generated",
    title: "Treaty of Dusk",
    excerpt:
      "The diplomatic agreement that ended the War of Stones. Signed at the border settlement of Dusk's Crossing, it restored trade relations between the Northern Reach and the Coastal Federation under significantly modified terms.",
    body: `The Treaty of Dusk was signed in the eighteenth year of the Third Age at the border settlement that gives the agreement its name — a small waystation town called Dusk's Crossing, chosen for its exact position at the territorial midpoint between the two parties. The settlement's neutrality was its only distinction; it had no political significance of its own, which was precisely why the negotiators chose it.

The treaty's core provisions restored trade access between the Northern Reach and the Coastal Federation under a revised tariff structure that the Northern Reach accepted as a practical necessity rather than a fair settlement. The ⌈Blacksmith Guild⌉ of ⌈Thornwall⌉ was explicitly referenced in the treaty's third article, which restored the guild's right to certify iron under the Coastal Federation's merchant standards — a provision that mattered primarily because the Federation had, during the war, begun certifying a competing Thornwall-mark standard that would have made the guild's existing certification worthless.

⌈Kael Ashward⌉, who attended the signing as a guild observer rather than a negotiator, later described the proceedings as "a ceremony of organized regret." Neither side believed the treaty resolved the underlying tensions; both sides believed war had become too expensive to continue. The ⌈iron trade routes⌉ resumed within six months of signing, though at diminished volume. The treaty has held for over two decades, which most historians attribute less to its quality as a document than to the fact that neither party has recovered enough to risk another conflict.`,
    tags: ["treaty", "diplomacy", "Third Age", "Northern Reach"],
    era: "Third Age",
    region: "Northern Reach",
    wordCount: 272,
    version: 1,
    createdAt: "2026-02-05T10:00:00Z",
    updatedAt: "2026-02-05T10:00:00Z",
    connectionIds: ["blacksmith-guild", "kael-ashward", "iron-trade-routes", "war-of-stones"],
  },

  {
    id: "cold-singing",
    type: "concept",
    status: "canon",
    title: "Cold-Singing",
    excerpt:
      "An ancient smithing technique that binds resonance channels into finished blades, allowing the steel to emit a faint, unique tone when placed against a resonant surface. Currently practiced by a single known living master.",
    body: `Cold-singing is a smithing technique of disputed origin — the ⌈Blacksmith Guild⌉'s historical records attribute it to a smith named Harvel who worked in Thornwall during the late First Age, while a competing tradition in the Coastal Federation claims the technique was developed independently in the southern highlands and brought north by itinerant smiths. The dispute has never been resolved and probably never will be, as both sets of historical records are fragmentary.

The technique involves working the steel at temperatures below what conventional smithing requires — hence "cold" — and introducing a series of controlled stress points in the blade's interior that create acoustic resonance chambers. When the finished blade is placed flat against a hard surface in a quiet environment, the steel vibrates at a frequency specific to its composition and the pattern of stress points introduced during forging. No two cold-sung blades sound identical, and an experienced practitioner can identify their own work by ear.

The functional purpose, beyond its aesthetic quality, is that the resonance pattern serves as an unforgeable maker's mark. Federation merchants who traded in Thornwall iron during the Second Age regarded a cold-sung blade as effectively self-certifying — a claim that could be verified without the guild's certification apparatus, which made the technique simultaneously valuable to buyers and threatening to the guild's institutional authority. This may explain why the ⌈Blacksmith Guild⌉ declined to formally re-sanction the technique after the ⌈War of Stones⌉, even as it tacitly permitted ⌈Kael Ashward⌉ to continue practicing it under the ambiguous designation "unaffiliated tradition."`,
    tags: ["smithing technique", "acoustic", "rare art", "guild politics"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 281,
    version: 2,
    createdAt: "2026-01-15T09:30:00Z",
    updatedAt: "2026-02-28T13:00:00Z",
    connectionIds: ["kael-ashward", "blacksmith-guild"],
  },

  {
    id: "mira-ashward",
    type: "character",
    status: "generated",
    title: "Mira Ashward",
    excerpt:
      "Kael Ashward's daughter. A minor functionary in Thornwall's civic administration who has navigated the city's post-war politics with considerable skill. No interest in smithing; considerable interest in what the guild represents politically.",
    body: `Mira Ashward is thirty-one years old and holds the position of Second Registrar in Thornwall's civic administration — a title that understates her actual influence, since the First Registrar has been in declining health for three years and Mira has quietly absorbed most of his substantive responsibilities. Her father ⌈Kael Ashward⌉ regards her administrative career with a mixture of pride and mild bewilderment; the two have an affectionate relationship complicated by the fact that they approach every political situation from opposite directions.

She grew up in the workshop's margins, doing her lessons at a corner desk while her father worked, and developed an early facility for the kind of patient observation that serves equally well in a forge and in a council chamber. Where Kael reads steel, Mira reads people — a talent she developed partly from watching her father's interactions with guild members, merchants, and buyers, and partly from temperament.

Her current political concern is the ⌈Blacksmith Guild⌉'s ongoing legitimacy dispute. She has no stake in the technical arguments about certification or sanctioned practice; she cares about the guild as a political institution because its weakening has created a vacuum in Thornwall's economic governance that several outside interests are positioning to fill. She has not told her father this. He would not disagree with her analysis. He would simply ask why it was her problem to solve.`,
    tags: ["civic administrator", "Ashward family", "Thornwall politics"],
    era: "Third Age",
    region: "Thornwall",
    wordCount: 241,
    version: 1,
    createdAt: "2026-02-08T11:00:00Z",
    updatedAt: "2026-02-08T11:00:00Z",
    connectionIds: ["kael-ashward", "blacksmith-guild"],
  },
];

// ---------------------------------------------------------------------------
// Connections
// ---------------------------------------------------------------------------

export const MOCK_CONNECTIONS: Connection[] = [
  { id: "conn-1", sourceId: "kael-ashward", targetId: "thornwall", relationship: "resident" },
  { id: "conn-2", sourceId: "kael-ashward", targetId: "blacksmith-guild", relationship: "last master" },
  { id: "conn-3", sourceId: "kael-ashward", targetId: "war-of-stones", relationship: "survivor" },
  { id: "conn-4", sourceId: "kael-ashward", targetId: "iron-trade-routes", relationship: "dependent on" },
  { id: "conn-5", sourceId: "kael-ashward", targetId: "mira-ashward", relationship: "daughter" },
  { id: "conn-6", sourceId: "kael-ashward", targetId: "treaty-of-dusk", relationship: "reluctant witness" },
  { id: "conn-7", sourceId: "kael-ashward", targetId: "cold-singing", relationship: "practitioner" },
  { id: "conn-8", sourceId: "blacksmith-guild", targetId: "thornwall", relationship: "based in" },
  { id: "conn-9", sourceId: "blacksmith-guild", targetId: "war-of-stones", relationship: "devastated by" },
  { id: "conn-10", sourceId: "blacksmith-guild", targetId: "cold-singing", relationship: "tacitly permits" },
  { id: "conn-11", sourceId: "war-of-stones", targetId: "treaty-of-dusk", relationship: "ended by" },
  { id: "conn-12", sourceId: "war-of-stones", targetId: "iron-trade-routes", relationship: "disrupted" },
  { id: "conn-13", sourceId: "thornwall", targetId: "iron-trade-routes", relationship: "hub of" },
  { id: "conn-14", sourceId: "mira-ashward", targetId: "blacksmith-guild", relationship: "monitors politically" },
  { id: "conn-15", sourceId: "cold-singing", targetId: "blacksmith-guild", relationship: "unsanctioned by" },
  { id: "conn-16", sourceId: "treaty-of-dusk", targetId: "iron-trade-routes", relationship: "partially restored" },
];

// ---------------------------------------------------------------------------
// Consistency flags for Kael
// ---------------------------------------------------------------------------

export const KAEL_FLAGS: ConsistencyFlag[] = [
  {
    id: "flag-1",
    severity: "error",
    title: "Age at War of Stones conflicts with birth year",
    detail:
      "This entry states Kael was fourteen when the War of Stones reached Thornwall (Third Age year 12). His birth year, derived from the Chapter 3 manuscript note ('born thirty-seventh year'), places him at eleven in year twelve. Difference: 3 years.",
  },
  {
    id: "flag-2",
    severity: "suggestion",
    title: "Cold-singing origin not cross-referenced",
    detail:
      "The Cold-Singing entry notes a disputed First Age origin. Kael's training is attributed to his grandfather Edric, but Edric does not yet have an entry. Consider creating a Character entry for Edric Ashward to anchor the lineage.",
  },
];

// ---------------------------------------------------------------------------
// Utility: indexed lookups
// ---------------------------------------------------------------------------

export const ENTRIES_BY_ID: Record<string, Entry> = Object.fromEntries(
  MOCK_ENTRIES.map((e) => [e.id, e])
);

export function getConnectionsForEntry(entryId: string): Connection[] {
  return MOCK_CONNECTIONS.filter(
    (c) => c.sourceId === entryId || c.targetId === entryId
  );
}
