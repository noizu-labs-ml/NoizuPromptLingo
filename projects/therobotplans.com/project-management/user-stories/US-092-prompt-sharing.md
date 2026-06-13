---
id: US-092
title: "Share prompts across team members with permissions"
personas: [sarah-kim]
domain: prompt-archival
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to share prompts across team members with permission controls (view, clone, edit) so that effective prompt configurations propagate through my team while maintaining authorship and preventing unauthorized modifications.

## Acceptance Criteria

- [ ] A share action on any prompt version or template opens a permission dialog with options: view-only, clone (copy to own workspace), and edit (direct modification rights)
- [ ] Shared prompts appear in recipients' prompt libraries with a clear indicator of the source author and sharing permission level
- [ ] Clone creates an independent copy that the recipient owns — subsequent edits do not affect the original
- [ ] Edit permission grants direct write access with all changes attributed to the actual editor in the version history
- [ ] Sharing can be revoked at any time by the owner, immediately removing access (cloned copies remain with the recipient)

## Notes

Prompt sharing is how institutional knowledge about agent configuration spreads within a team. Sarah's use case is onboarding: when a new engineer joins, she shares her battle-tested code review agent prompt as view-only so they can learn, then upgrades to clone permission when they're ready to customize. The permission model should be simple — three levels are enough. Avoid enterprise-grade RBAC complexity at this phase. The key UX detail: when someone clones a shared prompt, they should see what the original author's notes say about why certain constraints exist, not just the raw prompt text.
