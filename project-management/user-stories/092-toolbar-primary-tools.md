# US-092: Toolbar with Primary Tools (Brush, Eraser, Eyedropper, Pan, Zoom)

**As a** hobbyist painter learning digital art,
**I want to** access the most common tools from a visible toolbar,
**So that** I can switch between painting actions without memorizing keyboard shortcuts.

## Personas
- **Primary:** P5 Suki Tanaka — discoverability matters; icon-based toolbar reduces the learning curve for non-power users
- **Also relevant:** P7 Priya Sharma, P2 David Okafor

## Acceptance Criteria
- [ ] A toolbar is present at the top or side of the canvas with icons for: Brush, Eraser, Eyedropper, Pan, and Zoom
- [ ] The active tool is visually indicated (filled/highlighted icon state)
- [ ] Each toolbar button has a tooltip showing the tool name and keyboard shortcut
- [ ] Tools are also accessible via keyboard shortcuts (B=Brush, E=Eraser, I=Eyedropper, H=Pan, Z=Zoom)
- [ ] Toolbar respects Simple/Advanced mode: advanced-only tools (e.g., physics probe) are hidden in Simple Mode
- [ ] Toolbar position (top / left side) is configurable in Preferences

## Notes
The toolbar should use `NSToolbar` integration with SwiftUI for native macOS title-bar toolbar support, allowing the hidden title bar window to still expose toolbar items. Eyedropper must sample from the composited Metal texture, not the SwiftUI layer.
