---
id: P-005
name: "Daniel Okonkwo"
slug: daniel-okonkwo
archetype: "Engineering lead auditing AI usage"
segment: secondary
tags: [audit, oversight, browse, tags, safety-watch]
---

# P-005: Daniel Okonkwo

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 45 |
| Occupation | Engineering Manager, 12-person product team |
| Location | London, UK |
| Tech comfort | medium-high (was hands-on, now mostly reviews) |
| Claude Code usage | Occasional personally; mostly reviews team usage |
| Primary interface | Web UI (Browse, Dashboard, Settings) |

## Bio
Daniel doesn't write much code day to day anymore, but he's accountable for how his team uses AI coding agents — what gets touched, whether anything sensitive leaked into a prompt, and whether the team is actually getting value from the Claude Code spend. He checks in on usage patterns the way he used to check in on PR review turnaround.

## Goals
- Get a quick project-level view of how much Claude Code activity is happening and where, without reading every transcript
- Spot-check conversations for accidental exposure of secrets, credentials, or sensitive data pasted into prompts
- Understand which conversations are producing reusable value (converted into skills/runbooks) versus one-off dead ends

## Frustrations
- No single place to see "how much AI-assisted work happened this week across the team" before Claude Assist existed — it was all buried in individual engineers' local machines
- Spot-checking for sensitive data leakage is manual and slow; he wants a lightweight first pass, not a full compliance system
- Stats on the dashboard (conversation count, project count) are useful but don't yet tell him *which* conversations are worth his limited review time

## Behaviors
- Opens `/browse` grouped by project weekly to scan conversation counts and message volumes per repo
- Uses the dashboard's stat row (total conversations, projects indexed, dataset entries, last indexed) as a standing health check
- Spot-opens threads flagged with unusual patterns (very long sessions, odd tags) rather than reading everything
- Keeps an eye on the Safety Watch area as it matures, since it's the closest thing to the governance view he actually wants

## Job to Be Done
> "When I do my Monday review, I want a project-grouped overview of what the team's AI sessions actually touched last week, so I can catch anything concerning before it becomes a real problem."

## Relationship to Product
Claude Assist is his lightweight oversight dashboard — he's not editing or converting anything himself, just using Browse and the stats views as a periodic audit surface, with growing interest in the Safety Watch feature as it develops beyond a stub.

## Scenarios
- **Scenario 1: Weekly scan** — Opens `/browse`, groups by project, and sorts by message count to see which repos had unusually heavy AI-assisted activity in the past week.
- **Scenario 2: Spot check** — Notices an oddly long conversation in a client-facing repo, opens `/thread/:id`, and skims the collapsed tool-call blocks for anything that looks like a pasted credential or sensitive config.
- **Scenario 3: Value tracking** — Cross-references which threads were tagged or later show up as source conversations in datasets/skills to gauge whether the team's AI usage is converting into durable assets or staying one-off.
