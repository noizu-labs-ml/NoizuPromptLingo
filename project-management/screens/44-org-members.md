# Org Members

| Field | Value |
|-------|-------|
| **ID** | `org-members` |
| **Type** | Settings |
| **Category** | Governance |
| **User Stories** | US-038, US-049 |

## Description

Membership management at `/app/[orgId]/members` and `/app/[orgId]/members/[id]` for the org, covering invite-token generation (with expiry and use cap) and custom-role assignment.

## Key Components

- **Member Table** — all org members with role and status
- **Invite Token Generator** — creates a token with expiry and use-cap fields (US-038)
- **Invite Token List** — active/expired/exhausted tokens with a revoke action (US-038)
- **Role Assignment Selector** — assigns a custom role to a member (US-049)

## Interactions

- User sets expiry/use-cap in the Invite Token Generator and creates a token → appears in the Invite Token List, shareable as a link (US-038)
- User changes a member's Role Assignment Selector → role updates immediately (US-049)

## Navigation

- Accessible from: Org Settings (45), Org Dashboard (17)
- Links to: Registration (Invite) (04) (where generated tokens are redeemed)
