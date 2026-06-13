# US-073: Crimes System — Risk and Reward

**Persona:** Dave — Sighted MUD Veteran
**Priority:** P1
**Epic:** Crimes System

## Story
As Dave, I want to commit crimes (theft, smuggling, assassination contracts) with escalating risk and proportional reward so that playing a criminal character is a deep, strategically rich path rather than a side curiosity.

## Acceptance Criteria
- [ ] Crime actions are gated by skill rank: pickpocketing requires Thievery I, assassination requires Thievery IV+
- [ ] Each crime attempt announces risk factors before committing: "Pickpocket attempt on merchant: Detection chance 34% (base 40%, -6% for Shadowy Fingers skill). Proceed? (Y/N)"
- [ ] Successful crimes yield gold, items, or contraband with quality variance
- [ ] Failed crimes trigger a witness check — detection escalates a Notoriety rating announced to the player: "Your notoriety in Ironhaven rises to Wanted."
- [ ] Notoriety levels (Unknown → Suspected → Wanted → Infamous) affect NPC interactions, guard aggression, and shop prices — all changes announced contextually
- [ ] `CRIMES STATUS` announces current notoriety by zone, active warrants, and bounty on head
- [ ] Notoriety decays over time with configurable rate; players can clear warrants via bribe, quest, or jail time

## Notes
Dave wants the crimes system to reward deep knowledge of the game world — knowing guard patrol patterns, NPC schedules, faction relationships. All crime outcomes must be announced in text. The notoriety system should create roleplaying opportunities (playing a reformed criminal) as well as strategic ones (managing which zones are safe).
