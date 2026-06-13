# US-081: Accessible Account Creation Flow

**Persona:** Elena — Blind teenager (16), VoiceOver on iPhone
**Priority:** P0
**Epic:** Onboarding

## Story
As Elena, I want to create an account using only VoiceOver on my iPhone so that I can start playing without needing sighted assistance.

## Acceptance Criteria
- [ ] All form fields have explicit, descriptive labels readable by VoiceOver
- [ ] Error messages are announced immediately via ARIA live regions when field validation fails
- [ ] Password strength indicator is communicated as text (e.g., "Weak", "Strong"), not color alone
- [ ] CAPTCHA has a fully functional audio alternative
- [ ] Form submission success/failure is announced before any page transition
- [ ] Tab/swipe order follows a logical top-to-bottom sequence with no focus traps
- [ ] "Show password" toggle announces its current state ("password hidden" / "password visible")

## Notes
CAPTCHA is a known accessibility blocker — prefer hCaptcha with audio option or a logic-based challenge. Age verification for under-18 users must also be screen-reader accessible. Consider a separate parental consent flow triggered by birthdate input.
