# Planning & Workflow Summary

| Tool | Purpose | Required Params |
|------|---------|-----------------|
| **EnterPlanMode** | Transition into planning mode | none |
| **ExitPlanMode** | Signal plan completion, request approval | optional: `allowedPrompts` |

**Key rules:**
- Use EnterPlanMode for non-trivial features (3+ files, architectural decisions)
- Use AskUserQuestion BEFORE ExitPlanMode for clarifications
- Plan must be written to plan file before calling ExitPlanMode
- ExitPlanMode is ONLY for code implementation tasks, not research
- Integrate with TDD workflow: plan → tasks → tests → code

---

**For expanded view:** [planning.md](planning.md) — Full documentation with when to use/not use, workflow examples, and parameter descriptions. Load for unfamiliar tools or edge cases.