# US-038: Custom Brush Parameter Presets (Save/Load)

**As a** technical artist who builds custom brush configurations for specific workflows,
**I want to** save and load named brush presets that capture all brush parameters,
**So that** I can reproduce exact brush behavior across sessions and share presets with collaborators.

## Personas
- **Primary:** P6 Alex Kirchner — builds bespoke brush configs for shader-driven effects; needs to save, version, and share them
- **Also relevant:** P4 James Whitfield, P3 Lena Vasquez

## Acceptance Criteria
- [ ] Any brush configuration (all parameters: shape, size, hardness, opacity, flow, texture, custom shader params) can be saved as a named preset
- [ ] Presets are saved to a human-readable JSON or YAML file format under `~/Library/Application Support/TheRobotPaints/Presets/`
- [ ] Presets can be imported and exported as single files for sharing
- [ ] The brush library panel displays all saved presets with thumbnail previews and allows organization into folders
- [ ] Saving a preset with an existing name prompts to overwrite or save as a new version
- [ ] Presets include a metadata block: author, creation date, app version, and an optional description
- [ ] Deleting a preset removes the file from disk after a confirmation dialog; it does not affect brushes currently in use

## Notes
The preset file format must be forward-compatible: future brush parameters not present in an older preset should load with their default values, not cause a load failure. A schema version field is required in the file format from day one.
