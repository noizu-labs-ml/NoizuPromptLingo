---
id: P-004
name: "Tobias Lindqvist"
slug: tobias-lindqvist
archetype: "Prompt / skill author packaging reusable agents"
segment: secondary
tags: [convert, skill-authoring, skill-manage, agents, commands]
---

# P-004: Tobias Lindqvist

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 37 |
| Occupation | Developer advocate / internal tooling author at a dev-tools company |
| Location | Stockholm, Sweden |
| Tech comfort | high |
| Claude Code usage | Daily; deliberately probes it to discover reusable patterns |
| Primary interface | Web UI (Convert wizard) + `skill-manage` CLI/TUI |

## Bio
Tobias's job is essentially "turn one good Claude Code session into a reusable capability everyone else can invoke." He notices when a conversation contains a pattern worth packaging — a slash command, a specialized agent, a skill — and treats the Convert wizard as his authoring tool, then uses `skill-manage` to actually wire the result into his and his teammates' environments.

## Goals
- Spot high-value patterns in a conversation (a repeated multi-step workflow, a well-tuned system prompt) and turn them into a named, reusable artifact
- Package the extracted artifact correctly for its target kind — skill (dir + `SKILL.md`), agent (`*.md` definition), or slash command — without hand-authoring frontmatter from scratch
- Get the new skill/agent/command symlinked and enabled across providers (Claude, Codex, Grok) without manual file shuffling

## Frustrations
- Manually authoring a `SKILL.md` from memory loses the specific tool sequence and phrasing that made the original conversation work well
- It's easy to extract an artifact that works for him but forget the parameters/config another person would need to reuse it
- Keeping skills enabled consistently across three provider install roots (`~/.claude/skills/`, Codex, Grok) without name clashes or stale symlinks is fiddly by hand

## Behaviors
- Reviews the Convert wizard's AI-suggested candidate panel first, then narrows to the exact message range that captures the reusable pattern
- Steps through the 5-step wizard deliberately: type → message range → configure (name, description, parameters, output path) → preview → export
- After export, switches to `skill-manage enable skills <name> --provider claude` (and repeats per provider) to make the new artifact live
- Periodically runs `skill-manage audit --strict` and `skill-manage context --provider all` to make sure his growing library of authored skills isn't bloating any provider's context budget

## Job to Be Done
> "When I notice a Claude Code session nailed a repeatable workflow — say, a specific way of scaffolding a new API route — I want to extract it as a named skill with the right parameters, so the whole team can invoke it instead of re-deriving the prompt each time."

## Relationship to Product
Claude Assist's Convert wizard is where he mines conversations for reusable capability; `skill-manage` (bundled in the same project) is where he installs and governs what he's extracted, treating the two as one authoring-to-deployment pipeline.

## Scenarios
- **Scenario 1: Pattern spotting** — Opens `/thread/:id/convert`, picks "Skill" as the type, and uses the candidate panel's confidence scores to find the exact turn where the reusable prompt pattern crystallized.
- **Scenario 2: Configure & preview** — In Step 3, names the artifact, writes its description and parameters, sets an output path under the team's skills source root, then reviews the syntax-highlighted preview in Step 4 before exporting.
- **Scenario 3: Cross-provider rollout** — After export, runs `skill-manage enable skills api-route-scaffold --provider claude` and `--provider codex`, then `skill-manage audit` to confirm no symlink conflicts.
