# US-091: Preferences Window (Performance, Display, Defaults)

**As a** technical artist running the app on varied hardware,
**I want to** configure performance, display, and default behavior settings in a Preferences window,
**So that** I can tune the app to my machine's capabilities and my personal workflow expectations.

## Personas
- **Primary:** P6 Alex Kirchner — needs fine-grained control over GPU usage, texture resolution limits, and debug defaults
- **Also relevant:** P1 Maya Chen, P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] Cmd+, opens a Preferences window following macOS HIG tab conventions (General, Performance, Display, Shortcuts, Extensions)
- [ ] Performance tab: simulation tick rate (30/60/120 Hz), max texture resolution, Metal device selection (for multi-GPU Macs)
- [ ] Display tab: canvas checkerboard for transparency, UI scale override, color profile (sRGB / Display P3)
- [ ] General tab: default canvas size, default media, auto-save interval, unsaved-changes behavior (warn / auto-save / discard)
- [ ] All preferences are stored in `UserDefaults` with domain `com.therobotpaints.prefs`
- [ ] Preferences take effect immediately where possible; settings requiring restart are labeled as such

## Notes
Metal device selection requires enumerating `MTLCopyAllDevices()` — only relevant on Mac Pro or eGPU configurations. Preferences window should use SwiftUI's `Settings` scene on macOS 13+ for native tab chrome.
