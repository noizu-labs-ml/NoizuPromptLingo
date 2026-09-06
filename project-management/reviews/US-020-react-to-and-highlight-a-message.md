# Review: React to and highlight a message

- **Story**: `project-management/user-stories/US-020-react-to-and-highlight-a-message.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Reactions are fully modeled in the Elixir backend: the polymorphic `npl_reactions` table with a unique constraint on `(entity_type, entity_id, persona, emoji)`, an idempotent `add_reaction` using `on_conflict: :nothing` plus re-fetch so duplicate reactions merge (`lib/noizu_prompt_lingua/domains/chat/chat.ex:453-479`), `remove_reaction` (`chat.ex:483-497`), `reaction_counts` grouped by emoji (`chat.ex:507`), and batched `message_reaction_summaries` returning `%{emoji, count, me}` for list rendering. The `Chat.React` MCP tool adds reactions (`lib/noizu_prompt_lingua/domains/chat/tools/chat_react.ex:20-28`). However, no chat tool exposes removal/toggle-off (only the wiki domain ships `reaction_remove`), and "highlight" was implemented as a whole-message boolean flag rendered as a gold border (`lib/noizu_prompt_lingua/domains/chat/tools/highlight_message.ex`), not the story's substring/span highlight.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Emoji reaction attaches; aggregated count/avatar summary visible to all members | Met | `lib/noizu_prompt_lingua/domains/chat/tools/chat_react.ex:20-28`; `message_reaction_summaries/2` feeds rendering, `lib/noizu_prompt_lingua/domains/chat/chat.ex:517+` |
| Same emoji from another user merges into existing group count (no duplicate entry) | Met | unique index + `on_conflict: :nothing` with re-fetch, `lib/noizu_prompt_lingua/domains/chat/chat.ex:462-479`; counts grouped by emoji at `chat.ex:507-513` |
| Selected text substring highlight visible to other members | Not Met | highlight is message-level boolean flag only, `lib/noizu_prompt_lingua/domains/chat/tools/highlight_message.ex:3-5` ("highlighted flag ... gold border"); no span/offset model exists |
| Clicking own reaction again toggles it off | Partially Met | `remove_reaction/4` exists (`chat.ex:483-497`) but no Chat tool exposes it; no toggle path found for chat messages |

## Gaps / Risks

- Text-span highlight is a design divergence, not a partial: current model cannot express "highlight lines 3-7 of this code block".
- Reaction removal is unreachable from the tool surface — reactions are write-only for chat agents today.
- AC4's toggle UX is UI-side; only the backend data layer was verified (no frontend check in this review).

## BDD Scenario

```gherkin
Feature: Lightweight message feedback via reactions and highlights

  Scenario: Reviewer reacts to a message
    Given Sofia views a message in a chat room
    When she calls Chat.React with the event id, her persona, and an emoji
    Then the reaction is stored idempotently and the aggregated emoji count includes her

  Scenario: Reviewer highlights a text span
    Given Sofia selects a substring of the message
    When she applies a highlight to that span
    Then no span-level highlight exists today; only the whole message can be flagged (Chat.HighlightMessage)
```
