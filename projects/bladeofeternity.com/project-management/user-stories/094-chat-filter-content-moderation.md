# US-094: Chat Filter and Content Moderation

**Persona:** Carol — Sighted parent of blind daughter (14) and sighted son (12)
**Priority:** P0
**Epic:** Content Moderation / Safety

## Story
As Carol, I want to configure content filters appropriate for my children's ages so that they can play in the same world without being exposed to adult language or themes in player chat.

## Acceptance Criteria
- [ ] Account-level content filter settings offer tiers: Family Safe, Teen (13+), Mature (18+, age-verified)
- [ ] Profanity filter is enabled by default for all accounts; can be disabled at Mature tier
- [ ] Player-generated text chat is screened against the active filter tier before display
- [ ] Filter violations are replaced with sanitized text, not silently dropped — announcement: "[message filtered]"
- [ ] Players cannot circumvent filters via character substitution (l33tspeak, zero-width spaces) — filter uses normalized comparison
- [ ] Children's accounts (under 13) require parental consent and are locked to Family Safe tier
- [ ] Parents can link child accounts to a family account for centralized filter management

## Notes
COPPA compliance is required for under-13 accounts — do not collect more data than necessary and require parental consent flow. The filter system must not break screen reader output — filtered text announcements must be ARIA-friendly. Carol's daughter is 14 (Teen tier appropriate); son is 12 (COPPA territory).
