# US-086: Font Size and Contrast Settings

**Persona:** Sarah — Low-vision (retinitis pigmentosa), toggles between visual and VoiceOver
**Priority:** P0
**Epic:** Settings

## Story
As Sarah, I want to independently adjust font size, line spacing, and contrast mode so that during periods when I'm reading visually I can optimize the display for my remaining vision without affecting other players.

## Acceptance Criteria
- [ ] Font size control offers a range of at least 12px–32px in 2px increments, accessible as a spinbutton or segmented control
- [ ] Line height control offers options: Compact, Normal, Relaxed, Spacious
- [ ] Contrast mode options: Default Dark, High Contrast Dark, High Contrast Light, System Preference
- [ ] All contrast modes meet WCAG 2.1 AA (4.5:1 for normal text, 3:1 for large text) at minimum; AAA preferred
- [ ] Settings apply instantly as a live preview without page reload
- [ ] Settings persist per account across devices and sessions
- [ ] A "Reset to defaults" button is clearly labeled and reachable via keyboard
- [ ] Font family selection includes: Literata (narrative default), Inter (UI default), system fonts for performance

## Notes
Sarah's condition causes tunnel vision — large fonts help but so does increased letter-spacing. Consider a letter-spacing control as a P2 addition. High Contrast Light mode is essential for users who cannot use dark themes due to photophobia variants.
