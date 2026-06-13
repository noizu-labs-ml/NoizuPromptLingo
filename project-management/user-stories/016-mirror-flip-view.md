# US-016: Mirror / Flip View for Checking Composition

**As a** concept artist,
**I want to** flip the canvas view horizontally to see a mirrored version of my work,
**So that** I can catch compositional imbalances and proportion errors that become invisible when you stare at a painting too long.

## Personas
- **Primary:** Lena Vasquez — mirroring is a standard compositional check used by concept artists and illustrators; catching proportion errors early saves rework time
- **Also relevant:** David Okafor, Maya Chen

## Acceptance Criteria
- [ ] View > Flip Horizontal (or keyboard shortcut Cmd+Shift+H) mirrors the canvas view left-to-right
- [ ] View > Flip Vertical (Cmd+Shift+V) mirrors the canvas view top-to-bottom
- [ ] Mirror state is indicated by a persistent visual badge (e.g., "MIRRORED" label) in the viewport so the user always knows they are in a flipped view
- [ ] Mirror is a view transform only — canvas pixel data is not modified
- [ ] Brush input coordinates are inverse-transformed through the mirror matrix so strokes still land on the correct canvas pixels
- [ ] Mirrored state is not saved with the document; it resets on document open
- [ ] Mirror can be combined with canvas rotation (US-015) and the combined transform remains correct

## Notes
Horizontal flip is a scale of −1 on the X axis in the viewport transform. Combined with rotation, the order of transforms in the matrix must be: scale × rotation × mirror × translation to avoid unexpected behavior. The "MIRRORED" badge prevents the user from accidentally saving a work-in-progress while flipped.
