import type { Generation } from "@/types/generation";

export const generations: Generation[] = [
  // ── COMPLETE, PENDING REVIEW ────────────────

  {
    id: "gen-founding-of-thornwall",
    prompt:
      "Write the founding myth of Thornwall, told as an oral history by elders of the Blacksmith Guild. Approx. 600 words. In-universe voice.",
    entryType: "event",
    status: "complete",
    outputTitle: "The Founding of Thornwall",
    outputBody: `In the telling of the elders, seven families came to the river-mouth in the same season, and each of them brought a weight.

Not a light weight. Not a traveling weight. A forge-weight — the kind that does not come with you unless you mean it to stay. An anvil-stone, or a hammer-block, or in one family's case a bronze pouring-block so heavy that their cart had broken an axle crossing the northern pass and three grown men had carried it the remaining distance in shifts. They brought these weights because weights are what make a place. You can camp anywhere. You live somewhere when you are willing to carry your heaviest thing there and set it down.

The wall came from the thorn-wood that grew in abundance along the river bank in those years — a dense, close-grained wood that, properly woven into palisade stakes, makes an obstacle even a determined man will think twice about. The seven families built it together in thirty-nine days. Each family's section is still remembered by name, though the original wood is long gone and the stone that replaced it does not carry the names.

The first forge fire was lit on the fortieth day, in what would become the Guild's founding hall. There is disagreement in the elder-telling about whose fire it was. The Ashward line says it was their ancestors'. The Valdec line says it was theirs. The Merren line, which died out before the War of Stones, had a third version that placed the fire at a compromise forge built by all seven families together. The elders who tell it now generally use the Merren version, because it keeps the peace and because no one can contradict it.

What is agreed: the fire did not go out. Through winter and through the first flooding of the river and through the fever season that took two of the original thirty-one adults in that first year — the forge fire stayed lit. It was a practical decision as much as a ceremonial one. Iron requires heat that you cannot build quickly from nothing; a maintained forge fire means you are always four hours from a working blade. In the years before there were walls that could be trusted and treaties that meant something, four hours was a strategic advantage.

The Guild, in the elder-telling, was not founded. It was recognized. There came a point — the elders place it at Year 52, when the ferry crossing was first established and the first merchants from the lowlands arrived — when the seven families' shared maintenance of the forge fire, shared standards for the work that came out of it, and shared liability for that work's quality had become, functionally, a guild. They named it what it already was.

The Thornwall stamp was designed by the second generation: a simplified rendering of the original palisade wall pressed into the iron at the point of completion. Its meaning, according to the elder tradition: this thing was made here, by people who built something worth staying for.

Whether this is history or story, the elders who tell it do not always distinguish. They will tell you, if you ask, that the difference is smaller than you think. History is what happened. Story is what we carry forward. The town is proof that someone carried it.

*[Generated from: Thornwall, Blacksmith Guild, Northern Reach, Iron Trade Routes]*`,
    sourceEntryIds: [
      "thornwall",
      "blacksmith-guild",
      "northern-reach",
      "iron-trade-routes",
    ],
    createdAt: "2026-03-13T12:10:00Z",
  },

  // ── PROMOTED TO CANON ───────────────────────

  {
    id: "gen-northern-reach-climate",
    prompt:
      "Write a geographic and climate entry for the Northern Reach — what the terrain is like, why it's cold, how that shapes the culture. Reference the iron deposits and the guild system.",
    entryType: "location",
    status: "promoted",
    outputTitle: "Northern Reach",
    outputBody: `The Northern Reach is not a kingdom in the conventional sense — it has no throne, no hereditary ruler, and no single capital. It is a region defined by geography: the bowl of highlands running north of the Ashward River valley, cold enough for most of the year that agriculture is secondary to mining and craft. Its political unit is the town, and the town's political unit is the guild.

The Reach's iron deposits are among the richest in the known world, running in thick seams through the granite uplift that forms the region's spine. For three hundred years of the Third Age, this made the Reach indispensable — every lowland kingdom needed Reach iron, and the iron trade routes running south through Thornwall and the pass towns generated wealth enough to fund the fortifications that made the Reach genuinely difficult to conquer.

The War of Stones broke this equilibrium. The war was not primarily about the Reach — it was a lowland dispute over river navigation rights that the Reach was drawn into through its treaty obligations — but the Reach paid a disproportionate cost. Its pass fortifications were dismantled under the Treaty of Dusk, and its southern trade routes were rerouted through Coastal Federation ports, cutting Reach merchants out of the iron trade's most profitable segment.

The Reach today is geographically unchanged and economically diminished. The highlands are as iron-rich as they ever were. The capacity to turn that iron into political power has not returned.

*[Generated from: Northern Reach, Iron Trade Routes, War of Stones, Treaty of Dusk — promoted to canon 2026-02-15]*`,
    sourceEntryIds: [
      "northern-reach",
      "iron-trade-routes",
      "war-of-stones",
      "treaty-of-dusk",
    ],
    createdAt: "2026-02-14T16:30:00Z",
  },

  // ── PENDING (GENERATION IN PROGRESS / QUEUED) ──

  {
    id: "gen-guild-hierarchy",
    prompt:
      "Write an entry describing the internal hierarchy of the Thornwall Blacksmith Guild — the rank structure from apprentice through master, the certification process, and what each rank means practically.",
    entryType: "faction",
    status: "pending",
    outputTitle: undefined,
    outputBody: undefined,
    sourceEntryIds: [
      "blacksmith-guild",
      "kael-ashward",
      "edric-ashward",
      "thornwall",
      "reach-guild-law",
    ],
    createdAt: "2026-03-13T14:18:00Z",
  },

  // ── DISCARDED ───────────────────────────────

  {
    id: "gen-war-of-stones-timeline",
    prompt:
      "Generate a detailed year-by-year timeline of the War of Stones (Years 312–318), covering major military engagements, political turning points, and the final negotiation period leading to the Treaty of Dusk.",
    entryType: "event",
    status: "discarded",
    outputTitle: "War of Stones: Year-by-Year Timeline",
    outputBody: `Year 312: The Coastal Federation closes the three major river crossing points on the lower Ashward, citing unresolved toll arrears from River Compact merchants. The River Compact formally protests. The Northern Reach, bound by the Ashward Treaty, issues a supportive declaration without yet mobilizing.

Year 313: The River Compact calls on the Reach under the treaty's materiel support clause. Reach towns debate; five commit to logistics support, three decline. The Thornwall Blacksmith Guild begins emergency production of militarily-specified ironwork, its first such commission since the Border Wars of the Second Age.

Year 314: The Coastal Federation's naval forces blockade the Ashward River delta. River Compact river traffic effectively ceases. The Reach's overland iron routes remain nominally open but Federation-allied patrol forces begin imposing informal tolls at two of the three pass crossings, claiming customs authority the Reach does not recognize.

Year 315: Strategic collapse of the River Compact. Its southern cities negotiate separate terms with the Coastal Federation, leaving its treaty obligations to the Reach unilaterally suspended. The Reach is now supplying a war effort that the primary party has exited. Thornwall debates whether to continue materiel support or withdraw. The Guild continues production under existing contracts.

Year 316: Reach forces shift to defensive posture at the pass crossings. The Coastal Federation, now free to concentrate force, begins systematic pressure on Reach border towns. Three smaller pass towns surrender customs authority in exchange for protection guarantees.

Year 317: The siege of Thornwall's lower harbor. Federation naval forces block the river mouth for eleven weeks. Approximately three hundred civilians killed. The Guild's three harbor-side forges are reduced to one operational. Edric Ashward dies on the third day of the siege.

Year 318: Duskford negotiation. Eight months. The terms are dictated, not negotiated. Kael Ashward is present as a Guild representative's assistant.

*[Discarded — too summary. The year-by-year structure flattens what should be dramatized differently. Will generate separately: the harbor siege and the Duskford negotiation as distinct entries.]*`,
    sourceEntryIds: [
      "war-of-stones",
      "treaty-of-dusk",
      "thornwall",
      "blacksmith-guild",
      "northern-reach",
      "iron-trade-routes",
    ],
    createdAt: "2026-03-10T11:00:00Z",
  },
];
