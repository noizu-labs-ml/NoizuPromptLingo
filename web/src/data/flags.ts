import type { Flag } from "@/types/flag";

// ─────────────────────────────────────────────
// THE ASHWARD CHRONICLES — FLAGS
// ─────────────────────────────────────────────

export const ashwardFlags: Flag[] = [
  {
    id: "flag-kael-age-contradiction",
    severity: "error",
    title: "Kael's age at the War of Stones is inconsistent",
    detail:
      "The Kael Ashward entry states he was fourteen when the War of Stones began (Year 312). The Thornwall Blacksmith Guild registry — referenced in the Blacksmith Guild entry — records Kael's birth year as Year 304. If the birth year is correct, Kael would have been eight at the war's start, not fourteen. The Treaty of Dusk entry further states Kael was twenty when the war ended (Year 318), which would require a birth year of Year 298 — a six-year discrepancy from the guild registry. At least one of these three figures must be wrong. Suggested resolutions: (1) correct the birth year in the guild registry to Year 298, (2) correct the age-at-war-start in the Kael entry to eleven, or (3) accept the Treaty of Dusk figure and update both other entries.",
    entryIds: ["kael-ashward", "war-of-stones", "treaty-of-dusk"],
    resolved: false,
  },
  {
    id: "flag-coldsinging-anachronism",
    severity: "warning",
    title: "Cold-singing technique may predate its earliest documented practitioner",
    detail:
      "The Cold-singing entry notes the technique was 'developed within the Ashward family tradition over at least three generations,' which would place its origin in the late Second Age or early Third Age. However, the Founding of Thornwall entry (Year 47) describes the founding smiths arriving with 'forge-weights' and establishing the Blacksmith Guild — and makes no mention of any unusual technique. If cold-singing existed by the founding generation, it would likely appear in founding-era oral history. If it does not appear, either the technique was developed after the founding (contradicting the 'three generations' claim if Edric Ashward is the second-to-last practitioner), or it was developed outside the Thornwall tradition and adopted later. This does not require an immediate resolution but the origin timeline should be made explicit.",
    entryIds: ["cold-singing", "edric-ashward", "founding-of-thornwall"],
    resolved: false,
  },
  {
    id: "flag-compact-gap",
    severity: "suggestion",
    title: "The Dusk Compact has no leadership structure defined",
    detail:
      "The Dusk Compact entry establishes the organization as an important post-war institution with seventeen relay points, a code-marking system for road conditions, and a courier network. The entry notes that Mira Ashward 'runs courier routes for the Compact's eastern circuit.' However, no entry defines who runs the Compact at an organizational level — there is no named leadership, no defined command structure, and no explanation of how decisions are made for an organization that maintains seventeen locations across contested territory. If the Compact plays a significant role in the novel's second act (as implied by the Mira Ashward entry), this gap may become a plot liability. Suggested addition: a short entry defining the Compact's organizational structure, or a character entry for a Compact senior figure.",
    entryIds: ["dusk-compact", "mira-ashward"],
    resolved: false,
  },
];

// ─────────────────────────────────────────────
// MERIDIAN SECTOR — FLAGS
// ─────────────────────────────────────────────

export const meridianFlags: Flag[] = [
  {
    id: "flag-gate-physics-conflict",
    severity: "error",
    title: "Gate transit time contradicts stated physics rules",
    detail:
      "The Meridian Gate entry states that transit through the Gate 'takes approximately 11 seconds regardless of destination' across all three apertures. The Alien Signal entry states that the signal's origin 'is located somewhere beyond the Gate's known transit capacity — further than any of the Gate's three current connections reach.' If the Gate connects three specific systems and transit takes 11 seconds regardless of destination, it is physically unclear how the Gate could have a 'transit capacity' that some signals originate beyond — either the Gate has apertures that are not the three described, or 'transit capacity' needs to be defined separately from the three current connections. Recommended: clarify whether the Gate can connect to other, as-yet-unused apertures, or define 'transit capacity' as something other than the established aperture system.",
    entryIds: ["meridian-gate", "alien-signal"],
    resolved: false,
  },
  {
    id: "flag-authority-suppression",
    severity: "warning",
    title: "Gate Authority's suppression of the alien signal may be implausible given described structure",
    detail:
      "The Gate Authority entry states the alien signal 'has been classified above the Authority's standard confidentiality tier by a vote of the board that was not unanimous,' and that 'two board members are known to be passing information about the signal to their home governments.' The Kessel Station entry describes the station as hosting embassies and intelligence offices from all three inhabited systems. Given that the signal was received through monitoring equipment that the Authority has maintained for sixty years — and that the equipment is presumably staffed by workers from multiple systems — the claim that the suppression is even partially effective may require more explanation. Either the suppression is theatrical (all governments know and are pretending otherwise) or the mechanism of suppression needs to be established. The current entries leave this ambiguous in a way that may cause confusion.",
    entryIds: ["gate-authority", "alien-signal", "kessel-station"],
    resolved: false,
  },
];

// ─────────────────────────────────────────────
// ALL FLAGS COMBINED
// ─────────────────────────────────────────────

export const allFlags: Flag[] = [...ashwardFlags, ...meridianFlags];
