# US-094: Screen Recording Integration for Teaching Demos

**As a** traditional oil painter creating instructional content,
**I want to** start and stop a screen recording of my canvas directly within the app,
**So that** I can capture painting demos for students without juggling a separate recording app.

## Personas
- **Primary:** P2 David Okafor — records painting demonstrations for online classes; needs seamless single-app recording workflow
- **Also relevant:** P4 James Whitfield

## Acceptance Criteria
- [ ] File > Record Demo (or toolbar button) starts a screen capture of the canvas area using `ScreenCaptureKit`
- [ ] A visible recording indicator (red dot + timer) appears in the status bar or toolbar while recording is active
- [ ] Stopping recording presents a save panel to choose output location and format (MOV or MP4)
- [ ] Recording captures the canvas at the display's native resolution; UI chrome can be optionally included/excluded via a Preferences setting
- [ ] App requests screen recording permission on first use via `SCShareableContent` and guides the user through System Settings if permission is denied
- [ ] Recorded file is playable in QuickTime immediately after save completes

## Notes
`ScreenCaptureKit` (macOS 12.3+) should be preferred over deprecated `AVCaptureScreenInput`. The canvas-only capture mode should capture just the `MTKView` frame, not the full window, requiring a `SCContentFilter` scoped to the window or a specific display region.
