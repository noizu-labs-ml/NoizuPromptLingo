# US-194: Mount System

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Tyler, I want rideable mounts that increase travel speed across the world with different types carrying different prestige and mechanical benefits so that traversal feels rewarding and my mount choice reflects my character identity.

## Acceptance Criteria
- [ ] Three mount tiers at launch: Common (horse, mule — 30% travel speed increase, widely available at stables), Rare (warhorse, direwolf — 50% speed, requires faction standing or achievement), Exotic (griffin, spectral wolf — 70% speed, prestige mounts from endgame content or rare events)
- [ ] Mount summoning via quick command ("Mount up") when in non-combat zones; unsummoning automatic on combat initiation with narration: "You dismount as the enemy closes in."
- [ ] Travel with mount narrated by LLM: brief descriptions of landscape passage generated at region transitions ("Your horse carries you swiftly across the Thornmead Plains. Wind pulls at your cloak as the city lights of Ashveil appear on the horizon.")
- [ ] Mount management accessible via character menu: keyboard-navigable list of owned mounts with name, tier, speed bonus, and any special abilities; SR reads each entry completely on focus
- [ ] Mount speed bonus applied server-side to region traversal time calculation; travel time announced before departure: "Travel to Ashveil: approximately 3 minutes on horseback (2 minutes on griffin)."
- [ ] Mount combat dismount narrated distinctly from voluntary dismount; forced dismount in PvP or environmental hazard triggers: "You are knocked from your saddle!"
- [ ] Mount stabling available in all major cities at gold cost; stabled mounts accessible across all city stables (no per-city retrieval requirement); mount registry accessible everywhere
- [ ] Exotic mount unlock triggers assertive ARIA announcement when first obtained; mount names player-assignable with SR-readable custom name reflected in all narration

## Notes
Tyler's MMO background includes mount grinding as a core prestige loop — rare mounts are visible identity signals. In a text-based game, mounts signal identity through narration ("Tyler the Warlord rides in on a spectral wolf") and through the travel speed advantage in competitive or time-sensitive content. The LLM travel narration is what elevates mount travel from a mechanical time reduction to a game experience — it should feel like riding across the world, not fast-forwarding through it. The speed announcement before departure (a feature unusual in visual MMOs) is essential for SR users planning session time — Lena especially will appreciate knowing travel time before committing. Named mounts are a strong personalization hook for Elena and Tyler alike.
