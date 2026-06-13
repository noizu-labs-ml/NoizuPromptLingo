import type { Connection } from "@/types/entry";

// ─────────────────────────────────────────────
// THE ASHWARD CHRONICLES — CONNECTIONS
// ─────────────────────────────────────────────

export const ashwardConnections: Connection[] = [
  // Kael Ashward
  {
    id: "conn-kael-thornwall",
    sourceId: "kael-ashward",
    targetId: "thornwall",
    relationship: "resident of",
  },
  {
    id: "conn-kael-guild",
    sourceId: "kael-ashward",
    targetId: "blacksmith-guild",
    relationship: "last master of",
  },
  {
    id: "conn-kael-war",
    sourceId: "kael-ashward",
    targetId: "war-of-stones",
    relationship: "survivor of",
  },
  {
    id: "conn-kael-iron",
    sourceId: "kael-ashward",
    targetId: "iron-trade-routes",
    relationship: "dependent on",
  },
  {
    id: "conn-kael-treaty",
    sourceId: "kael-ashward",
    targetId: "treaty-of-dusk",
    relationship: "reluctant witness to",
  },
  {
    id: "conn-kael-mira",
    sourceId: "kael-ashward",
    targetId: "mira-ashward",
    relationship: "father of",
  },
  {
    id: "conn-kael-coldsinging",
    sourceId: "kael-ashward",
    targetId: "cold-singing",
    relationship: "practitioner of",
  },
  {
    id: "conn-kael-edric",
    sourceId: "kael-ashward",
    targetId: "edric-ashward",
    relationship: "trained by",
  },
  {
    id: "conn-kael-hammer",
    sourceId: "kael-ashward",
    targetId: "kaels-bench-hammer",
    relationship: "maker of",
  },
  {
    id: "conn-kael-resonance",
    sourceId: "kael-ashward",
    targetId: "resonance-law",
    relationship: "applies",
  },

  // Mira Ashward
  {
    id: "conn-mira-kael",
    sourceId: "mira-ashward",
    targetId: "kael-ashward",
    relationship: "daughter of",
  },
  {
    id: "conn-mira-coldsinging",
    sourceId: "mira-ashward",
    targetId: "cold-singing",
    relationship: "practitioner of",
  },
  {
    id: "conn-mira-compact",
    sourceId: "mira-ashward",
    targetId: "dusk-compact",
    relationship: "courier for",
  },
  {
    id: "conn-mira-thornwall",
    sourceId: "mira-ashward",
    targetId: "thornwall",
    relationship: "left at seventeen",
  },
  {
    id: "conn-mira-guild",
    sourceId: "mira-ashward",
    targetId: "blacksmith-guild",
    relationship: "trained by",
  },
  {
    id: "conn-mira-hammer",
    sourceId: "mira-ashward",
    targetId: "kaels-bench-hammer",
    relationship: "handled",
  },
  {
    id: "conn-mira-resonance",
    sourceId: "mira-ashward",
    targetId: "resonance-law",
    relationship: "tested to its limit",
  },

  // Edric Ashward
  {
    id: "conn-edric-kael",
    sourceId: "edric-ashward",
    targetId: "kael-ashward",
    relationship: "trained",
  },
  {
    id: "conn-edric-guild",
    sourceId: "edric-ashward",
    targetId: "blacksmith-guild",
    relationship: "master of",
  },
  {
    id: "conn-edric-coldsinging",
    sourceId: "edric-ashward",
    targetId: "cold-singing",
    relationship: "practitioner of",
  },
  {
    id: "conn-edric-war",
    sourceId: "edric-ashward",
    targetId: "war-of-stones",
    relationship: "died in",
  },
  {
    id: "conn-edric-thornwall",
    sourceId: "edric-ashward",
    targetId: "thornwall",
    relationship: "resident of",
  },

  // Blacksmith Guild
  {
    id: "conn-guild-thornwall",
    sourceId: "blacksmith-guild",
    targetId: "thornwall",
    relationship: "headquartered in",
  },
  {
    id: "conn-guild-iron",
    sourceId: "blacksmith-guild",
    targetId: "iron-trade-routes",
    relationship: "certified goods on",
  },
  {
    id: "conn-guild-war",
    sourceId: "blacksmith-guild",
    targetId: "war-of-stones",
    relationship: "disrupted by",
  },
  {
    id: "conn-guild-treaty",
    sourceId: "blacksmith-guild",
    targetId: "treaty-of-dusk",
    relationship: "certification undermined by",
  },

  // Thornwall
  {
    id: "conn-thornwall-reach",
    sourceId: "thornwall",
    targetId: "northern-reach",
    relationship: "located in",
  },
  {
    id: "conn-thornwall-iron",
    sourceId: "thornwall",
    targetId: "iron-trade-routes",
    relationship: "southern terminus of",
  },
  {
    id: "conn-thornwall-war",
    sourceId: "thornwall",
    targetId: "war-of-stones",
    relationship: "harbor besieged during",
  },
  {
    id: "conn-thornwall-founding",
    sourceId: "thornwall",
    targetId: "founding-of-thornwall",
    relationship: "subject of",
  },

  // War of Stones
  {
    id: "conn-war-treaty",
    sourceId: "war-of-stones",
    targetId: "treaty-of-dusk",
    relationship: "ended by",
  },
  {
    id: "conn-war-iron",
    sourceId: "war-of-stones",
    targetId: "iron-trade-routes",
    relationship: "disrupted",
  },
  {
    id: "conn-war-reach",
    sourceId: "war-of-stones",
    targetId: "northern-reach",
    relationship: "drew in",
  },

  // Treaty of Dusk
  {
    id: "conn-treaty-iron",
    sourceId: "treaty-of-dusk",
    targetId: "iron-trade-routes",
    relationship: "rerouted",
  },
  {
    id: "conn-treaty-reach",
    sourceId: "treaty-of-dusk",
    targetId: "northern-reach",
    relationship: "demilitarized",
  },

  // Iron Trade Routes
  {
    id: "conn-iron-reach",
    sourceId: "iron-trade-routes",
    targetId: "northern-reach",
    relationship: "ran through",
  },

  // Dusk Compact
  {
    id: "conn-compact-war",
    sourceId: "dusk-compact",
    targetId: "war-of-stones",
    relationship: "emerged from aftermath of",
  },
  {
    id: "conn-compact-reach",
    sourceId: "dusk-compact",
    targetId: "northern-reach",
    relationship: "operates in",
  },
  {
    id: "conn-compact-treaty",
    sourceId: "dusk-compact",
    targetId: "treaty-of-dusk",
    relationship: "fills communication gap created by",
  },

  // Cold-singing / Rule of Resonance
  {
    id: "conn-coldsinging-resonance",
    sourceId: "cold-singing",
    targetId: "resonance-law",
    relationship: "governed by",
  },
  {
    id: "conn-coldsinging-hammer",
    sourceId: "cold-singing",
    targetId: "kaels-bench-hammer",
    relationship: "applied to",
  },

  // Founding of Thornwall
  {
    id: "conn-founding-guild",
    sourceId: "founding-of-thornwall",
    targetId: "blacksmith-guild",
    relationship: "origin story of",
  },
  {
    id: "conn-founding-iron",
    sourceId: "founding-of-thornwall",
    targetId: "iron-trade-routes",
    relationship: "precedes",
  },

  // Reach Guild Law
  {
    id: "conn-guildlaw-guild",
    sourceId: "reach-guild-law",
    targetId: "blacksmith-guild",
    relationship: "governs",
  },
  {
    id: "conn-guildlaw-kael",
    sourceId: "reach-guild-law",
    targetId: "kael-ashward",
    relationship: "protects succession rights of",
  },
];

// ─────────────────────────────────────────────
// IRONLIGHT CAMPAIGN — CONNECTIONS
// ─────────────────────────────────────────────

export const ironlightConnections: Connection[] = [
  {
    id: "conn-il-city-guilds",
    sourceId: "ironlight-city",
    targetId: "artificer-guilds",
    relationship: "controlled by infrastructure of",
  },
  {
    id: "conn-il-city-union",
    sourceId: "ironlight-city",
    targetId: "conduit-workers-union",
    relationship: "site of organizing by",
  },
  {
    id: "conn-il-guilds-union",
    sourceId: "artificer-guilds",
    targetId: "conduit-workers-union",
    relationship: "in dispute with",
  },
  {
    id: "conn-il-veln-union",
    sourceId: "veln-the-unmeasured",
    targetId: "conduit-workers-union",
    relationship: "lead organizer of",
  },
  {
    id: "conn-il-veln-guilds",
    sourceId: "veln-the-unmeasured",
    targetId: "artificer-guilds",
    relationship: "former employee of",
  },
  {
    id: "conn-il-conduitlaw-guilds",
    sourceId: "aetheric-conduit-law",
    targetId: "artificer-guilds",
    relationship: "constrains operations of",
  },
  {
    id: "conn-il-conduitlaw-city",
    sourceId: "aetheric-conduit-law",
    targetId: "ironlight-city",
    relationship: "physical rules of",
  },
];

// ─────────────────────────────────────────────
// MERIDIAN SECTOR — CONNECTIONS
// ─────────────────────────────────────────────

export const meridianConnections: Connection[] = [
  {
    id: "conn-ms-gate-authority",
    sourceId: "meridian-gate",
    targetId: "gate-authority",
    relationship: "administered by",
  },
  {
    id: "conn-ms-gate-signal",
    sourceId: "meridian-gate",
    targetId: "alien-signal",
    relationship: "transmission medium for",
  },
  {
    id: "conn-ms-gate-kessel",
    sourceId: "meridian-gate",
    targetId: "kessel-station",
    relationship: "approached from",
  },
  {
    id: "conn-ms-authority-signal",
    sourceId: "gate-authority",
    targetId: "alien-signal",
    relationship: "monitoring and suppressing",
  },
  {
    id: "conn-ms-authority-kessel",
    sourceId: "gate-authority",
    targetId: "kessel-station",
    relationship: "headquartered at",
  },
  {
    id: "conn-ms-signal-kessel",
    sourceId: "alien-signal",
    targetId: "kessel-station",
    relationship: "classified information at",
  },
];

// ─────────────────────────────────────────────
// ALL CONNECTIONS COMBINED
// ─────────────────────────────────────────────

export const allConnections: Connection[] = [
  ...ashwardConnections,
  ...ironlightConnections,
  ...meridianConnections,
];
