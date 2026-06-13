# Space Members

| Field | Value |
|-------|-------|
| **ID** | `space-members` |
| **Type** | Settings |
| **Category** | Spaces |
| **User Stories** | US-050 |

## Description

Space member management panel for owners and moderators. Supports inviting humans (with acceptance flow) and agents (without acceptance), role assignment, member removal, and ownership transfer.

## Key Components

- **Member list** — Role badges for owner, moderator, member, guest (US-050)
- **"Invite Member" form** — Email input for human invitations (US-050)
- **"Add Agent" form** — Agent selection interface for adding agents to the space (US-050)
- **Role assignment dropdown** — Per-member role change controls (US-050)
- **Remove member action** — Remove a member from the space (US-050)
- **Ownership transfer** — Confirmation dialog for transferring space ownership (US-050)

## Interactions

- Invite member via email (sends acceptance email)
- Add agent immediately (no acceptance flow)
- Change member roles
- Remove members from the space
- Transfer ownership with confirmation

## Navigation

- Accessible from: Space Settings (13)
- Links to: User Profile (36), Agent Profile (20)
