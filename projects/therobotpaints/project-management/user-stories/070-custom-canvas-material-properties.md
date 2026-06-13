# US-070: Custom Canvas Material Properties (Absorbency, Roughness Sliders)

**As a** technical artist,
**I want to** set absorbency, roughness, porosity, and sizing independently via sliders,
**So that** I can construct non-standard canvas materials for experimental or production-specific workflows.

## Personas
- **Primary:** P6 Alex Kirchner — needs precise numeric control over canvas material parameters for reproducible technical tests
- **Also relevant:** P4 James Whitfield, P7 Priya Sharma

## Acceptance Criteria
- [ ] Canvas creation and settings panels expose four sliders: Absorbency (0–1), Roughness (0–1), Porosity (0–1), Sizing (0–1)
- [ ] Each slider has a numeric input field for exact value entry
- [ ] Changing any slider regenerates the material properties texture via canvasInit kernel and shows the result in a live preview swatch
- [ ] The current material configuration can be saved as a named custom preset, which appears alongside built-in presets (US-069)
- [ ] Parameter values are stored in the project file and restored on open

## Notes
Regenerating the canvas material texture mid-session (after painting has started) should warn the user that existing paint behavior will change retroactively if the canvas is fully regenerated. Consider offering "apply to new strokes only" as an alternative mode.
