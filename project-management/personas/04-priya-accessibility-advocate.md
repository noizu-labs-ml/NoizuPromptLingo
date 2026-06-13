# Persona 04: Priya — The Accessibility Advocate

## Demographics
- **Age:** 31
- **Location:** Toronto, Canada
- **Occupation:** Accessibility engineer at a major tech company
- **Vision:** Fully sighted
- **Side work:** Runs an accessibility review blog; speaks at conferences (CSUN, Axe-con)

## Technology Profile
- **Tools:** axe DevTools, NVDA, JAWS, VoiceOver — uses all three daily for testing
- **Browser:** Tests across Chrome, Firefox, Safari, Edge
- **Setup:** Multiple VMs for cross-platform screen reader testing

## Goals
- Find exemplary accessible products to write about and recommend
- Evaluate whether "blind-first" is genuinely implemented or just marketing
- Use Blade of Eternity as a case study for her conference talk on accessible gaming
- Contribute accessibility feedback that actually gets implemented

## Frustrations
- Companies that claim "accessible" without testing with real assistive technology users
- Games that pass automated checks (Lighthouse 100) but fail manual screen reader testing
- "We'll add accessibility later" as a recurring industry excuse
- Products that treat WCAG compliance as the ceiling, not the floor

## Behaviors
- Opens DevTools before playing — inspects ARIA roles, live regions, heading hierarchy
- Tests with screen reader first, then visually, to verify the "blind-first" claim
- Documents every interaction pattern with screenshots and screen reader transcripts
- Files structured bug reports with WCAG criterion references
- Will write a 3,000-word teardown — positive or negative — and it will get read

## Relationship to Blade of Eternity
Priya is a force multiplier. She won't play 20 hours/week, but her review reaches 15,000 accessibility professionals. If the ARIA architecture holds up under her scrutiny, she becomes the game's most valuable evangelist. If it doesn't, her critique will be precise and public.

## Key Scenario
Priya runs the full testing matrix: NVDA+Firefox, JAWS+Chrome, VoiceOver+Safari. She tests combat (rapid live region updates), choice menus (focus management), and connection loss (assertive alerts). She's specifically looking for announcement collisions, orphaned focus, and any state where a blind user would be "stuck."

## Success Metric
Priya publishes a positive case study citing Blade of Eternity as a reference implementation for accessible real-time web applications.
