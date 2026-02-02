# User Interaction Summary

| Tool | Purpose | Required Params |
|------|---------|-----------------|
| **AskUserQuestion** | Ask clarification questions | `questions` (array of 1-4 questions) |
| **Skill** | Invoke custom skills/commands | `skill` |

**Key rules:**
- AskUserQuestion: max 4 questions, 2-4 options each, header ≤12 chars (UX rec)
- "Other" option always available for free-form input
- Use multiSelect for non-exclusive choices
- In plan mode: ask questions BEFORE exiting, not instead of exiting
- Skill: MUST invoke BEFORE responding about the task

---

**For expanded view:** [user-interaction.md](user-interaction.md) — Full documentation with JSON examples, multiSelect patterns, and complete skill list. Load for parameter details or when building complex question flows.