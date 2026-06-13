# US-014: Dark Chrome UI to Reduce Eye Strain

**As a** traditional oil painter working in long sessions,
**I want to** use a dark application chrome that does not compete with the canvas colors,
**So that** my eyes can accurately judge color and value on the canvas without being influenced by bright UI surroundings.

## Personas
- **Primary:** David Okafor — accurate color judgment is critical for oil painting; light-colored UI creates simultaneous contrast effects that distort perceived canvas hues
- **Also relevant:** Lena Vasquez, Priya Sharma

## Acceptance Criteria
- [ ] The application uses macOS Dark Mode appearance by default, regardless of the system appearance setting
- [ ] Panel backgrounds target L* ≤ 15 (near-black) to minimize surround luminance contrast with the canvas
- [ ] All text and icons in dark mode meet WCAG AA contrast ratio (4.5:1) against their backgrounds
- [ ] A "Follow System Appearance" option in Preferences allows the app to match the system light/dark setting
- [ ] The canvas viewport background (outside the canvas bounds) uses the user-defined background color (see US-019) and is independent of UI chrome color
- [ ] Color picker and swatch panels use neutral grey surrounds rather than white to preserve color judgment accuracy

## Notes
SwiftUI `.preferredColorScheme(.dark)` should be applied at the root scene level to enforce dark chrome while still allowing the canvas and background area to use custom colors. The color picker surround color is a known professional requirement from Photoshop and Procreate conventions.
