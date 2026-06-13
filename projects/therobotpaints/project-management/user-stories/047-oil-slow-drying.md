# US-047: Oil Slow Drying with Extended Wet-on-Wet Time

**As a** traditional oil painter,
**I want to** work wet-on-wet for an extended session without paint locking prematurely,
**So that** I can blend, lift, and rework oil paint with the same extended open time that real oil medium provides, which can range from hours to days depending on pigment and medium.

## Personas
- **Primary:** P2 David Okafor — extended open time is the defining advantage of oil he exploits for subtle blending and glazing
- **Also relevant:** P3 Lena Vasquez, P4 James Whitfield

## Acceptance Criteria
- [ ] Oil medium has a drying rate parameter orders of magnitude slower than watercolor; default open time spans the equivalent of a full painting session
- [ ] During the open-time window, all oil paint on canvas remains blendable, liftable, and responsive to new paint deposits
- [ ] A session clock or real-time drying simulation allows the artist to optionally enable time-lapse drying for long compositions
- [ ] The drying rate can be modified by medium additives (e.g., linseed vs. alkyd medium) exposed as per-layer or per-stroke parameters
- [ ] Partial drying states are visually distinguishable: tacky paint shows reduced gloss and slightly altered blending response before full cure

## Notes
Oil drying is oxidative polymerization, not evaporation — it is modeled as a slow monotonic decrease in an oxidation index rather than a moisture channel. The drying clock runs in simulation time, which may be decoupled from real time via a simulation speed multiplier.
