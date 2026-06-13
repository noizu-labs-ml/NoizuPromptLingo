# US-025: Brush Opacity and Flow Control

**As a** watercolor illustrator building up tonal washes,
**I want to** independently control brush opacity and flow rate,
**So that** I can replicate the layered buildup behavior of wet-on-wet and wet-on-dry painting techniques.

## Personas
- **Primary:** P1 Maya Chen — watercolor workflow depends on granular opacity and flow control for wash behavior
- **Also relevant:** P3 Lena Vasquez, P5 Suki Tanaka

## Acceptance Criteria
- [ ] Opacity (0–100%) controls the maximum alpha of paint deposited in a single stroke, regardless of overlap within that stroke
- [ ] Flow (0–100%) controls the rate of paint deposition per dab; lower flow accumulates paint more slowly as the brush passes over the same area
- [ ] Opacity and flow are independently adjustable via number keys (1–0 map to 10%–100% for opacity; Shift+1–0 for flow)
- [ ] Both values are displayed and editable in the Tool Options bar
- [ ] Values respond to pressure mapping (US-021) if opacity or flow is assigned as a pressure target
- [ ] A stroke rendered at 50% opacity with 100% flow produces identical output to the same stroke rendered at 100% flow with 50% opacity only if no overlap occurs within the stroke

## Notes
The opacity/flow distinction mirrors Photoshop's model and will be familiar to P1 and P3. The Beer-Lambert absorption model in the VolumeLayer system must be consulted to ensure these parameters map correctly to the underlying pigment concentration math.
