# How to: pull a reusable skill/agent/runbook out of a conversation

**Goal:** turn a conversation where you solved something well into a checked-in artifact (agent definition, skill, slash command, code snippet, or runbook) instead of re-explaining it next time.
**Prereqs:** API running; the conversation already indexed (`GET /api/conversations` or Browse page to find its id).

1. Open the conversation's Convert page:
   - Web UI: `/thread/:id/convert`
   - TUI: Explore/Thread page → Convert action
   - Or directly: `GET /api/conversations/:id/candidates` to see AI-suggested extraction points first.
2. Pick an artifact type and the message range to source it from.
3. Generate — `range` is a `[startIndex, endIndex]` tuple over that conversation's messages, not an object:
   ```bash
   curl -X POST localhost:3100/api/conversations/<id>/convert \
     -H 'content-type: application/json' \
     -d '{"type": "skill", "range": [4, 22], "name": "auth-middleware-setup", "description": "Wiring JWT middleware into Hono"}'
   ```
4. Review the generated output — it's a draft based on pattern detection (`packages/api/src/services/converter.ts`), not guaranteed-correct; edit before committing it into your skills/agents directory.

**Verify:** the response includes the generated artifact content (markdown/YAML depending on type); save it to the appropriate project location yourself (Convert does not write files outside the conversation database).
**Gotchas:**
- Convert quality depends on the LLM provider configured in Settings — if none is configured it falls back to weaker heuristic pattern-matching. See [configure-llm-provider.md](configure-llm-provider.md) if output looks thin.
- `/api/conversations/:id/candidates` suggests ranges but doesn't validate they contain a complete, self-consistent solution — skim the source messages before trusting a candidate range.
