npl-instructions:
  name: npl-delegation
  version: 1.0.1
---

# Context Preservation via Agent Delegation

## Decision Trigger
Before running any command or starting any task:

> **Will this bloat my context with data I only need to extract answers from? Is there an agent or persona I can offload to—speeding up turnaround via parallel execution while I focus on orchestration?**

If yes → delegate. Raw output stays with the sub-agent; only results return.

## Delegation Patterns

### Questions (@agent-npl-tasker absorbs output noise)
| Pattern | Example |
|:--------|:--------|
| Check state | `"is Y running?"` `"do tests pass?"` |
| Extract value | `"what version of Z?"`, "What dod you see in the error trace" |
| Search/scan | `"any TODOs in auth?"` |
| Fetch external | `"what does issue #123 say about this specific element in the form?"` |

### Directed Edits (sub-agent executes independently)
Provide:
- **Intent**: outcome needed
- **Pseudocode/instructions**: logic to follow
- **Resources**: relevant docs, files, examples

### Persona/Specialist Handoff
If a persona (with history, domain knowledge) or specialized agent is better suited—and sufficient documentation exists for them to proceed independently—delegate to reduce shared context overhead.

## Spawning Sub-Agents
Always provide:
```
@<agent-name | npl-persona + persona-name>
---
purpose: <task title>
session-id: <if set>
task-id: <if set>
span-id: <if set>
chat-room: <chat-id + room title | if task requires back-and-forth>
---
[instructions—reference existing docs, interstitial files, worklogs, etc. to minimize context duplication]
```

## Small Tasks (@npl-tasker)
Agent tailored for routine tasks that can be passed through the Fabric AI framework for data processing, extraction, and analysis.
```
@npl-tasker
---
purpose: "Refactor auth.ts to use JWT instead of sessions"
session-id: A4Z
span-id: 45FQ
chat-room: A4F "Dev Helpline"
---
- See /docs/jwt-migration.md for patterns
- Replace sessionStore calls with tokenService
- Update tests in auth.test.ts to match
- Verify green; post progress updates to chat if issues arise; iterate until resolved
```

Sub-agent handles implementation; you receive confirmation + change summary and can check on chat room 
status as needed vie the npl-mcp service mcp service.

## Agent Collaboration
Agents share a chat room for coordination. Use when:
- Task spans multiple agents' domains
- Agent is stuck and needs input
- Progress updates needed without polluting your context

## Keep In-Context
- Multi-step coordination you're orchestrating
- Decisions requiring your judgment
- Code you'll reference repeatedly this session

## Cost Reference
| Operation | Direct | Delegated |
|:----------|-------:|----------:|
| Test output | ~500 lines | ~3 lines |
| Web fetch | ~2000 lines | ~5 lines |
| File read | ~100 lines | ~2 lines |
| Refactor task | ~300 lines | ~10 lines |
