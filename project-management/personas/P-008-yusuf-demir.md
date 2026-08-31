---
id: P-008
name: "Yusuf Demir"
slug: yusuf-demir
archetype: "Multi-provider agent tinkerer"
segment: tertiary
tags: [skill-manage, multi-provider, harness, context-budget, tui]
---

# P-008: Yusuf Demir

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 27 |
| Occupation | AI tooling hobbyist / indie developer |
| Location | Istanbul, Turkey |
| Tech comfort | very high |
| Claude Code usage | Runs Claude, Codex, and Grok CLIs side by side, switching by task |
| Primary interface | `skill-manage` TUI + CLI; web UI mainly for Settings/LLM config |

## Bio
Yusuf refuses to commit to a single coding-agent provider. He runs Claude Code, Codex, and Grok depending on the task and cost, and treats provider parity — same skills, same agents, same commands available everywhere — as a personal project. He's the kind of user who reads the `context` budget report for fun and gets annoyed when one provider's symlinks drift from another's.

## Goals
- Keep the same set of skills, agents, and commands enabled consistently across Claude, Codex, and Grok install roots
- Understand exactly how much context-window budget his enabled skills/agents are consuming per provider before hitting a runner's limit
- Take advantage of Claude Assist's multi-harness session continuity as Codex import support matures, and eventually Gemini/OpenCode/Aider as those land
- Configure alternate LLM providers (OpenAI-compatible endpoints, Groq, Cerebras, DeepSeek) for the simplify/summarize features rather than relying on a single default

## Frustrations
- Providers have different install root conventions and per-description caps (e.g., Codex's 1,024-character description limit), so what fits cleanly on Claude can silently overflow Codex's budget
- Some providers only stub-support agent definitions, so "enable everywhere" isn't always literally possible and he has to track exceptions manually
- Cross-harness conversation continuity (Claude ↔ Codex) is still early — Gemini/OpenCode/Aider importers are stubbed, not live — so he has to plan around gaps rather than assume full parity
- Manually diffing symlink state across three provider roots before this tool existed was tedious and error-prone

## Behaviors
- Runs `skill-manage tui` regularly, cycling providers with `p` to compare enabled state side by side
- Uses `skill-manage context --provider all --json` before adding any new skill, to check it won't blow a provider's context budget
- Applies `enable-set --work-type` bundles rather than enabling skills one at a time, then runs `audit --strict` to catch drift
- In Claude Assist's Settings page, configures the LLM provider used for simplify/summarize to a cheaper OpenAI-compatible endpoint (via LiteLLM/inference.noizu.com) rather than the default, and keeps an eye on which harness importers (Claude, Codex) are live versus stubbed

## Job to Be Done
> "When I add a new skill to my toolbox, I want to know immediately whether it fits inside every provider's context budget and get it symlinked consistently everywhere, so I don't end up with Claude and Codex silently running different capability sets."

## Relationship to Product
Claude Assist's conversation tooling is secondary for Yusuf — his center of gravity is `skill-manage`, the embedded Rust CLI/TUI bundled in the same project, which he uses to govern parity, context budgets, and provider-specific quirks across his multi-agent setup, plus the Settings page's LLM provider configuration for cost control.

## Scenarios
- **Scenario 1: Budget check before enabling** — Runs `skill-manage context skills --provider codex --context-window 200000` before enabling a large new skill, to see it stays under Codex's 2% metadata budget.
- **Scenario 2: Cross-provider audit** — After a batch `enable-set --work-type feature-dev --provider claude`, repeats for `--provider codex`, then runs `skill-manage audit --strict --json` to catch any symlink that didn't resolve to the shared source root.
- **Scenario 3: Cost-conscious LLM config** — In `/settings`, switches the LLM provider used for thread-simplify operations from the default Anthropic model to a Groq-backed OpenAI-compatible endpoint to cut per-operation cost during heavy experimentation.
