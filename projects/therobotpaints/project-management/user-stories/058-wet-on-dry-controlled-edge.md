# US-058: Wet-on-Dry Controlled Edge Application

**As a** watercolor illustrator,
**I want to** paint a wet stroke onto a fully dry surface and get a crisp, hard edge rather than diffusion-blurred edges,
**So that** I can alternate between wet-on-wet softness and wet-on-dry precision within the same painting, controlling edge quality through technique rather than post-processing.

## Personas
- **Primary:** P1 Maya Chen — edge control is a foundational watercolor technique; she needs hard and soft edges to coexist naturally in the same simulation
- **Also relevant:** P5 Suki Tanaka, P7 Priya Sharma

## Acceptance Criteria
- [ ] A stroke deposited onto a fully dry canvas region (moisture = 0) produces edges with no lateral diffusion spread beyond the brush footprint
- [ ] The edge sharpness of a wet-on-dry stroke is determined solely by the brush shape profile and stylus pressure, not by moisture diffusion
- [ ] Transition zones between wet-on-dry hard edges and wet-on-wet soft edges are handled correctly when a stroke crosses a wet/dry boundary mid-stroke
- [ ] Wet-on-dry strokes absorb into the canvas according to the absorbency parameter, producing the immediate color commitment real wet-on-dry technique requires
- [ ] No backrun (US-043) is triggered when painting wet-on-dry; backrun only fires when painting into a partially dry zone

## Notes
Wet-on-dry edge crispness is a direct consequence of the diffusion coefficient becoming zero (or near-zero) when the local moisture level is zero. The same moisture-driven diffusion model used for wet-on-wet naturally produces this behavior if moisture gating is correctly implemented — no separate edge mode is needed.
