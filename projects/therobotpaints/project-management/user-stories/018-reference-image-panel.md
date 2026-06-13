# US-018: Reference Image Panel Alongside Canvas

**As a** traditional oil painter working from photographic reference,
**I want to** load a reference image into a panel that stays visible alongside my canvas,
**So that** I can study color relationships, values, and composition without switching between applications.

## Personas
- **Primary:** David Okafor — plein air and studio oil painting always involves working from reference; an in-app panel eliminates the context switching that breaks observational focus
- **Also relevant:** Lena Vasquez, Maya Chen

## Acceptance Criteria
- [ ] File > Import Reference Image loads JPEG, PNG, HEIC, or TIFF files into a floating reference panel
- [ ] The reference panel can be positioned anywhere in the window, including undocked as a floating window
- [ ] Reference image can be zoomed and panned independently of the canvas
- [ ] Reference panel has a configurable opacity (20–100%) so it can be used as a semi-transparent overlay on the canvas when docked
- [ ] Multiple reference images can be loaded; each appears as a tab in the reference panel
- [ ] Reference image is not part of the paint volume and is never exported or saved into the document
- [ ] The reference panel can be quickly toggled visible/hidden via Cmd+Shift+R

## Notes
Reference images should be loaded into a standard `MTLTexture` for display but must not be included in the VolumeLayer compositor pipeline. If the user positions the reference panel as an overlay on the canvas (opacity < 100%), it must be composited in a final blit pass after the canvas compositor, not before, to avoid affecting paint color judgment.
