# US-036: Accessibility and Settings

**As a** player with accessibility needs
**I want to** configure visual, audio, and interaction settings to accommodate my needs
**So that** I can enjoy the full game experience regardless of ability

## Acceptance Criteria
- [ ] Color-blind modes for all rarity-coded and faction-coded UI elements
- [ ] Scalable UI text and icon sizes
- [ ] Screen reader compatibility for marketplace listings and notifications
- [ ] Configurable keybindings for all actions
- [ ] Audio volume controls: music, ambient, SFX, notifications (independent sliders)
- [ ] Notification frequency controls (reduce notification spam for overwhelm-sensitive players)
- [ ] Session timer option: gentle reminder after X minutes of play
- [ ] Reduced-motion option for weather effects and animations

## Category
Platform

## Priority
Should

## Notes
- Browser-based client (Phoenix LiveView + canvas) has inherent accessibility advantages over native engines.
- The warm, cozy aesthetic should not exclude players with sensory sensitivities.
- Notification frequency is especially important given the persistent-world design (lots of overnight activity to review).
