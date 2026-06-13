# US-069: Canvas Paper Type Presets (Cold Press, Hot Press, Rough, Smooth)

**As a** art educator,
**I want to** choose from named paper-type presets when creating a canvas,
**So that** students can start with physically meaningful surface properties without understanding the underlying parameters.

## Personas
- **Primary:** P4 James Whitfield — teaches watercolor fundamentals; paper type is a core concept he introduces before custom properties
- **Also relevant:** P5 Suki Tanaka, P1 Maya Chen

## Acceptance Criteria
- [ ] Canvas creation dialog offers at minimum four named presets: Cold Press, Hot Press, Rough, Smooth
- [ ] Each preset maps to a defined combination of absorbency, roughness, porosity, and sizing values passed to canvasInit kernel
- [ ] Preset selection shows a small visual preview of the surface texture pattern
- [ ] Selecting a preset populates the custom sliders (US-070) with its parameter values, allowing further adjustment
- [ ] Presets are defined in a user-editable config file so educators can add institution-specific presets

## Notes
Preset parameter values should be grounded in real watercolor paper measurements where possible (e.g., cold press: moderate roughness ~0.45, high absorbency ~0.7). The canvasInit kernel procedurally generates the material properties texture from these scalars.
