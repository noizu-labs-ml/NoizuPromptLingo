# US-066: Currency Management and Wallet Accessibility

**Persona:** Sarah — Low-Vision, Toggles VoiceOver
**Priority:** P0
**Epic:** Player Economy

## Story
As Sarah, I want to check my currency balances and convert between currency tiers with a single command so that managing gold, crystals, and tokens is fast whether I'm in visual mode or using VoiceOver.

## Acceptance Criteria
- [ ] `WALLET` or `BAL` announces all three currency balances in a single line: "Wallet: 1,240 gold | 18 crystals | 3 tokens"
- [ ] Currency conversion (`CONVERT 100 gold TO crystals`) announces rate and result before confirming: "Rate: 50 gold = 1 crystal. You will receive 2 crystals. Confirm? (Y/N)"
- [ ] Currency amounts in all game text use consistent formatting — no ambiguous abbreviations (g/c/t vs gold/crystals/tokens must be configurable)
- [ ] In visual mode, wallet displays in a persistent HUD element with sufficient contrast (WCAG AA minimum)
- [ ] VoiceOver mode: wallet summary is available on-demand without navigating away from current context
- [ ] Automatic low-balance warning is configurable: "Alert when gold falls below [threshold]"

## Notes
Sarah toggles between modes depending on fatigue and lighting. Currency readout must be equally clean in both modes. Avoid displaying wallet only in a visual sidebar with no text-mode equivalent. Tokens (premium currency) need to be especially prominent to prevent accidental spending.
