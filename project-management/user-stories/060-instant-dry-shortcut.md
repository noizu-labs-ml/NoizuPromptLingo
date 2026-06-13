# US-060: Instant-Dry Shortcut to Skip Drying Simulation

**As a** hobbyist painter,
**I want to** instantly dry all wet paint on the canvas with a single action,
**So that** I can quickly move to the next layer of my painting without waiting through drying simulation cycles, keeping my creative momentum without getting bogged down in physics timescales.

## Personas
- **Primary:** P5 Suki Tanaka — she wants satisfying physics when painting but needs an escape hatch to skip drying waits that break her creative flow
- **Also relevant:** P1 Maya Chen, P7 Priya Sharma, P3 Lena Vasquez

## Acceptance Criteria
- [ ] A keyboard shortcut and toolbar button trigger an instant-dry action that snaps all wet and drying paint to its fully-dried final state
- [ ] Instant-dry resolves all in-progress drying effects (edge darkening, granulation settling, backrun migration) to their final configurations before locking
- [ ] Drying effects that are still mid-process are resolved to a physically plausible final state, not abandoned mid-effect (e.g., partial edge darkening is not frozen mid-ring)
- [ ] Instant-dry applies to the entire canvas by default; an optional selection-scoped variant dries only the selected region
- [ ] After instant-dry, the canvas is fully reworkable with new wet paint as if natural drying had completed; no simulation state is left in an inconsistent intermediate form

## Notes
Instant-dry is implemented as a forced simulation flush: run Drying stage to convergence in a single off-screen compute pass rather than over real time. The key constraint is resolving mid-effect states correctly; this requires that each drying effect define a "fast-forward to final state" code path in addition to its per-tick update path. This is distinct from the per-layer dry shortcut; US-060 is a global canvas operation.
