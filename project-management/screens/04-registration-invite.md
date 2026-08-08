# Registration (Invite)

| Field | Value |
|-------|-------|
| **ID** | `registration-invite` |
| **Type** | Storyboard |
| **Category** | Public & Onboarding |
| **User Stories** | US-039, US-085 |

## Description

Invite-gated registration flow at `/auth/register` where a user arriving via an invite token completes OIDC sign-in to join an organization. Validates the token's expiry and remaining use count before allowing the flow to proceed.

## Key Components

- **Invite Token Validity Banner** — shows valid/expired/exhausted state (US-085)
- **SSO Registration Button** — starts OIDC login scoped to the invite (US-039)
- **Blocked Registration Message** — explains why registration was refused when the token is expired or exhausted (US-085)
- **Org Preview Card** — shows which org/project the invite grants access to

## Interactions

- User opens an invite link → token validated before any UI beyond the blocked-state message renders (US-085)
- Valid token: user clicks the SSO Registration Button → redirected to the identity provider, returns via SSO Callback (03) (US-039)
- Invalid token: Blocked Registration Message renders with no further action available (US-085)

## Navigation

- Accessible from: invite email/link (external), Org Members (44) invite-generation flow
- Links to: SSO Callback (03) on valid token; dead-end on blocked state
