---
id: P-001
name: "Jordan Vance"
slug: "harness-operator"
archetype: "The Harness Operator"
segment: "primary"
tags: [developer, mcp-client, daily-active, cli]
---

# Jordan Vance — The Harness Operator

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 29 |
| **Role** | Senior Software Engineer, mid-size product team |
| **Technical Level** | Advanced |
| **Industry** | B2B SaaS |
| **Location** | Remote, US Central |

## Bio

Jordan runs Claude Code and Codex CLI side by side for most of the working day, delegating whole features to agents while reviewing diffs and steering direction. They care most about not losing context between sessions — the number of times an agent has re-explained something already decided is Jordan's biggest source of friction with AI tooling in general.

## Goals

1. Give every agent session a durable home (tickets, chat, artifacts) instead of a throwaway terminal buffer.
2. Mint and rotate MCP API keys without leaving the terminal workflow.
3. See, at a glance, what an agent did while Jordan was away from the keyboard.

## Frustrations

1. Agent context resets on every new CLI session, so decisions get re-litigated.
2. No single place to see "what did the agent actually touch" across a multi-hour task.
3. Setting up a new MCP server by hand (config JSON, auth headers) is fiddly and easy to get wrong.

## Behaviors

- Keeps three or four Claude Code sessions running in parallel on different tickets.
- Checks the web dashboard once or twice a day, mostly to skim chat rooms and ticket status rather than to do primary work there.
- Rotates MCP API keys after any laptop change or suspected leak.

## Job to Be Done

> "When I hand a multi-step task to a coding agent, I want a persistent session that tracks tickets, chat, and artifacts across restarts, so I can pick up exactly where the agent left off without re-explaining anything."

## Relationship to Product

Discovers NPL through a teammate's `claude mcp add` command. Adopts it the moment a session survives a laptop reboot. The MCP key + setup-command generator at `/app/mcp-keys` is what turns a curious first use into a daily habit — if that flow breaks or feels untrustworthy, Jordan reverts to ad hoc terminal usage and churns.

## Scenarios

1. **Morning handoff** — Jordan opens the session from last night, reads what the agent logged in chat and which tickets moved, and gives the next instruction without re-reading the whole diff.
2. **New machine setup** — Jordan mints a fresh MCP API key, copies the generated `claude mcp add` command, and is back to full agent capability inside two minutes.
3. **Mid-task key rotation** — Jordan revokes a possibly-leaked key from `/app/mcp-keys` and confirms the running agent session fails closed rather than continuing on a stale credential.
