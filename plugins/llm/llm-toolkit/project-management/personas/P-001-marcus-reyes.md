---
id: P-001
name: "Marcus Reyes"
slug: marcus-reyes
archetype: "Solo power-user developer"
segment: primary
tags: [core-user, daily-active, search, thread-viewer, cli]
---

# P-001: Marcus Reyes

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | 34 |
| Occupation | Independent contractor / freelance full-stack developer |
| Location | Austin, TX (remote) |
| Tech comfort | high |
| Claude Code usage | 3-6 sessions/day across 4-8 active client projects |
| Primary interface | CLI (`llm-toolkit recent`, `search`) + Web UI for deep dives |

## Bio
Marcus juggles four to six client codebases at once, often switching projects mid-morning. He lives inside Claude Code and treats every session as disposable unless he can find it again later — which is exactly the problem. He's comfortable in a terminal and would rather type `llm-toolkit recent 2h` than open a browser tab.

## Goals
- Instantly recall "what was I doing in this repo yesterday" without re-reading JSONL by hand
- Resume a half-finished session (via the resume command) instead of re-explaining context to a fresh Claude Code instance
- Keep a mental map of which project a stray terminal session actually belongs to

## Frustrations
- Claude Code conversations vanish into `~/.claude/projects/{encoded-path}/` and become unsearchable the moment the terminal closes
- Directory-name encoding (`/Users/foo/bar` → `-Users-foo-bar`) makes it hard to eyeball which JSONL belongs to which client repo
- Grepping raw JSONL for a remembered phrase is slow and returns unreadable raw tool_use/tool_result blobs

## Behaviors
- Starts most mornings with `llm-toolkit recent 1d` before opening the web UI
- Uses full-text search (FTS5) for exact error strings, semantic search when he only remembers "the gist"
- Filters `/browse` by project constantly since he context-switches between client repos all day
- Tags conversations by client name right after finishing so future-Marcus can filter fast

## Job to Be Done
> "When I sit down after lunch and can't remember which of six client sessions had the fix for a flaky test, I want to search by meaning, not just exact keywords, so I can jump straight back into the right thread and resume."

## Relationship to Product
Claude Assist is his daily-driver recall layer on top of Claude Code — the dashboard and search bar are the first things he opens each session, and the CLI's `recent`/`show` commands are muscle memory for quick lookups without leaving the terminal.

## Scenarios
- **Scenario 1: Morning triage** — Runs `llm-toolkit recent 2h --json` to see what he left mid-thread the night before, then resumes the top session directly from the CLI.
- **Scenario 2: Cross-project recall** — Uses `/search` in semantic mode with a vague query ("that auth middleware thing") because he can't remember the exact function name, filters by role=assistant to skip his own prompts.
- **Scenario 3: Client hygiene** — After finishing a task, opens `/thread/:id` and tags the conversation with the client's project name and a one-line summary via the metadata panel.
