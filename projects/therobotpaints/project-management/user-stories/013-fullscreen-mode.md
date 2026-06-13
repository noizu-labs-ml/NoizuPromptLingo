# US-013: Fullscreen Mode for Maximum Canvas Area

**As a** concept artist needing maximum screen real estate,
**I want to** enter a fullscreen mode that hides all chrome except a minimal floating HUD,
**So that** every pixel of my display is available for the canvas during intensive painting sessions.

## Personas
- **Primary:** Lena Vasquez — large displays and 4K canvases demand maximum viewport area; panel chrome wastes precious screen space during long sessions
- **Also relevant:** Priya Sharma, David Okafor

## Acceptance Criteria
- [ ] Cmd+Ctrl+F or View > Enter Full Screen toggles macOS native fullscreen
- [ ] In fullscreen, all SwiftUI panels (tool options, layer list) are hidden by default
- [ ] A minimal floating HUD (zoom level, brush size indicator, undo/redo) remains accessible in fullscreen via a semi-transparent overlay
- [ ] Floating HUD auto-hides after 3 seconds of inactivity and reappears on mouse movement
- [ ] Panels can be summoned temporarily by moving the cursor to the relevant screen edge (macOS standard behavior)
- [ ] Exiting fullscreen restores the exact panel layout that was active before entering fullscreen
- [ ] Canvas fit-canvas (US-003) is triggered automatically when entering fullscreen so the full canvas is visible

## Notes
macOS fullscreen is managed via `NSWindowStyleMask.fullScreen` and the `NSWindowDelegate` fullscreen transition callbacks. Panel auto-hide on edge hover should use macOS's standard `NSWindow` autohide behavior rather than a custom implementation.
