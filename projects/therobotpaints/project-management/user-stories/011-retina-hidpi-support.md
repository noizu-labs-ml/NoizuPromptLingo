# US-011: Retina / HiDPI Display Support

**As a** digital illustrator,
**I want to** see the canvas rendered at the full native resolution of my Retina display,
**So that** fine details, thin strokes, and antialiased edges appear sharp rather than blurry.

## Personas
- **Primary:** Maya Chen — pixel-level precision is meaningless if the display output is upscaled from a lower-resolution framebuffer; she needs 1:1 physical pixel mapping at 100% zoom on Retina
- **Also relevant:** Lena Vasquez, Alex Kirchner

## Acceptance Criteria
- [ ] MTKView is configured with `contentScaleFactor` equal to the backing scale factor of the display (2.0 on Retina, 1.0 on standard)
- [ ] The drawable size is set to `view.bounds.size × contentScaleFactor` so the Metal framebuffer matches physical pixels
- [ ] At 100% zoom on a 2x Retina display, one canvas pixel maps to one physical screen pixel
- [ ] UI chrome (SwiftUI panels, overlays) renders via SwiftUI's native HiDPI pipeline and does not need special handling
- [ ] Moving the window between a Retina and a standard display triggers a drawable resize and scale factor update within one frame
- [ ] No canvas content blurring is visible when switching between displays with different backing scale factors

## Notes
`MTKView.autoResizeDrawable` should be set to `false`; drawable size must be managed manually to account for both window resizes and display changes via `NSWindowDelegate.windowDidChangeBackingProperties`. Failure to do this is the most common cause of blurry Metal views on Retina.
