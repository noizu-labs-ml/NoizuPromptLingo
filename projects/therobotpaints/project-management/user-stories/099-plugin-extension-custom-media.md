# US-099: Plugin/Extension Point for Custom Media Types

**As a** technical artist who needs to simulate non-standard media,
**I want to** load a plugin that defines a custom paint media type with its own physics parameters and shader code,
**So that** I can extend the simulation with new materials (e.g., encaustic wax, screen-printing ink) without forking the app.

## Personas
- **Primary:** P6 Alex Kirchner — needs to prototype exotic media simulations; a plugin model avoids maintaining a fork and allows sharing media packs with collaborators
- **Also relevant:** P4 James Whitfield

## Acceptance Criteria
- [ ] Plugins are macOS bundles (`.trpmedia`) placed in `~/Library/Application Support/TheRobotPaints/Plugins/`
- [ ] Each plugin bundle declares a `MediaDefinition.json` manifest describing: media name, parameter schema (names, types, ranges, defaults), and references to included `.metal` shader files
- [ ] On launch and on Preferences > Extensions > Reload, the app discovers and loads installed plugins
- [ ] Installed media types appear in the New Canvas dialog and the Media Selector alongside built-in types
- [ ] Plugin shaders are compiled via the same hot-reload pipeline as internal shaders; compilation errors surface in the Shader Log panel
- [ ] A sample plugin ("Encaustic Wax") is included in the app bundle as a reference implementation

## Notes
Plugin loading requires code-signing or a developer entitlement exemption for macOS sandbox compliance — this is a significant distribution constraint. For v1, plugins can be restricted to parameter overrides on existing shader templates (no arbitrary shader injection) to avoid sandboxing complexity; full shader extension is a v2 concern.
