# Review: React to a Wiki Page or Comment

- **Story**: `project-management/user-stories/US-076-react-to-a-wiki-page-or-comment.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Reaction infrastructure is solid on the Elixir backend: a polymorphic reaction table over `page | comment` with per-(target, emoji, actor) uniqueness (`backend/lib/noizu_prompt_lingua/schema/wiki/reaction.ex:8-29`, index `idx_wiki_reactions_unique`) and MCP tools `Wiki.ReactionAdd` (validates target exists; idempotent per actor — `tools/reaction_add.ex:22-46`, `wiki.ex:184-232` including race-safe ON CONFLICT handling), `Wiki.ReactionRemove`, and `Wiki.ReactionList` (returns per-reaction id/emoji/actor plus total count). Distinct emoji coexist without overwriting (uniqueness includes emoji). The one criterion miss: re-adding the same reaction is **idempotent, not toggling** — the story requires a repeat to *remove* the reaction; instead `ReactionAdd` returns the existing row and removal requires the separate `ReactionRemove` tool. Also `actor` is a caller-supplied label (default `"mcp"`), not a server-resolved identity, so per-user accounting is soft. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Reaction appears with count, reacting user recorded, visible to members | Met | `reaction_list.ex:25-35` returns emoji + actor per row and total count; rows persist in `wiki_reactions` |
| Re-triggering the same reaction toggles it off rather than double-counting | Partially Met | no double-count occurs — `add_reaction` is idempotent (`wiki.ex:184-207` pre-check + `on_conflict: :nothing` on `[:target_type, :target_id, :emoji, :actor]`) — but it does **not toggle off**; removal is a separate explicit `Wiki.ReactionRemove` call (`wiki.ex:246-257`) |
| Distinct emoji each keep their own count, none overwrite others | Met | uniqueness key includes emoji (`reaction.ex:26-28`); `ReactionList` returns every emoji's rows independently |

## Gaps / Risks

- Toggle-off semantics absent: clients wanting the story's behavior must call `ReactionAdd` then `ReactionRemove` (two calls with a check in between = race window).
- `actor` label is spoofable (caller-supplied, default `"mcp"`) — reaction counts cannot be attributed to real users; contrast with `ToolGuard`'s server-side identity rule.
- Reactions are not permission-gated (any caller can add/remove any actor's reaction since `ReactionRemove` takes actor as an argument).

## BDD Scenario

```gherkin
Feature: React to a wiki page or comment

  Scenario: Acknowledge a page
    When the agent calls Wiki.ReactionAdd with target_type="page", target=<id>, emoji="👍", actor="jordan"
    Then Wiki.ReactionList returns one "👍" from "jordan" with count 1

  Scenario: Reacting twice
    When "jordan" calls Wiki.ReactionAdd again with the same target and emoji
    Then the same reaction row is returned (count stays 1 — no double-count)
    And the reaction is NOT removed; toggling off requires Wiki.ReactionRemove (story deviation)

  Scenario: Mixed emoji
    When "priya" adds "🎉" to the same page
    Then ReactionList shows "👍" count 1 and "🎉" count 1 independently
```
