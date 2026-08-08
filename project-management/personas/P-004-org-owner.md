---
id: P-004
name: "Marcus Chen"
slug: "org-owner"
archetype: "The Org Owner"
segment: "secondary"
tags: [org-admin, onboarding, governance, custom-scopes]
---

# Marcus Chen — The Org Owner

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 41 |
| **Role** | Founder / Head of Engineering, 15-person startup |
| **Technical Level** | Advanced |
| **Industry** | Developer tools |
| **Location** | Toronto, Canada |

## Bio

Marcus provisioned the organization, invited the team, and is the one person who has to answer for what agents are allowed to touch. He doesn't do day-to-day ticket work himself anymore, but he owns every governance decision: who's a member, what tools are exposed, and what happens if an agent misbehaves.

## Goals

1. Stand up a new organization and invite a team without needing platform-admin help.
2. Scope MCP tools per project so a marketing-only agent can't reach GitHub write access.
3. Understand, at a glance, who has owner/admin rights and revoke them quickly if someone leaves.

## Frustrations

1. Governance controls that are all-or-nothing instead of scoped per project.
2. Invite flows that don't expire or cap usage, becoming a slow security leak.
3. Not knowing which custom MCP scope is actually in effect for a given project until something breaks.

## Behaviors

- Sets up invite tokens with a use cap and expiry rather than sharing a permanent link.
- Reviews the membership list quarterly and prunes stale accounts.
- Delegates day-to-day scope tweaks to a lead but keeps final approval on anything touching GitHub or billing-adjacent settings.

## Job to Be Done

> "When I bring a new team or project onto the platform, I want to control exactly which tools and members can touch what, so I'm not exposed by a default-open configuration."

## Relationship to Product

The first fifteen minutes — org creation, invite send, first successful member login — decide whether Marcus trusts the platform with anything sensitive. He stays because custom MCP scopes let him say "yes to tickets, no to GitHub writes" per project instead of an all-or-nothing toggle. He'd churn immediately if an invite token turned out to have no expiry or use cap by default.

## Scenarios

1. **Org bootstrap** — Marcus creates the organization, sets the key prefix, and sends capped, expiring invite tokens to his first five hires.
2. **Scoped project rollout** — Marcus assigns a `core_variant` custom MCP scope to the marketing project that excludes GitHub and admin tool groups entirely.
3. **Offboarding** — Marcus revokes a departing contractor's membership and confirms their MCP API keys stop working immediately, not on next token refresh.
