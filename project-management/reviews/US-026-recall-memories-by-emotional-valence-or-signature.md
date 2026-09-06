# Review: Recall Memories by Emotional Valence or Signature

- **Story**: `project-management/user-stories/US-026-recall-memories-by-emotional-valence-or-signature.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The emotional-memory substrate is fully built in the Elixir backend: memories carry a **7-dimensional emotional vector** (VAD + hormone channels) written via `remember`/`emotion.ex` (VAD with `vad_weight 0.6`, hormone channels; `backend/lib/noizu_prompt_lingua/domains/memory/emotion.ex`), and `recall_by_emotion` (`backend/lib/noizu_prompt_lingua/domains/memory/recall.ex:44`) runs a Weaviate `nearVector` search on that emotional vector with Sentinel authorization. Multi-vector recall also blends the emotional vector (`recall.ex:69`). However, the **agent-facing tool** narrows the surface: `recall_by_emotion` tool (`backend/lib/noizu_prompt_lingua/domains/memory/tools/recall_by_emotion.ex`) accepts only `valence`/`arousal`/`dominance` inputs — no hormone-channel query inputs and no emotion+keyword combined query — so a "full emotional signature" (all 7 dims) cannot be queried, and the story's combined-text+emotion recall exists only in the internal `active` path, not as a tool parameter. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent can recall by valence/arousal/dominance | Met | tool inputs (`tools/recall_by_emotion.ex`) → nearVector on emotional vector (`recall.ex:44`) |
| Agent can recall by full emotional signature (incl. hormones) | Not Met | tool exposes VAD only; hormone dims stored (`emotion.ex`) but not queryable |
| Combined keyword + emotion query | Not Met | tool has no keyword input; fusion exists only internally (`recall.ex:69`) |
| Results authorized/scoped to the caller | Met | Sentinel authorization in `recall.ex:44` |

## Gaps / Risks

- Extend the tool schema to accept the 7-d vector (or named emotion presets) and an optional keyword field that routes to the fused path — the backend already supports both.
- Document hormone-dim semantics before exposing them; raw hormone inputs may be unintuitive for agents.

## BDD Scenario

```gherkin
Feature: Emotionally-salient memory recall
  Scenario: Agent recalls memories matching an emotional tone
    Given memories embedded with 7-d emotional vectors
    When the agent queries recall_by_emotion with valence/arousal/dominance
    Then Weaviate nearVector returns emotionally-similar, Sentinel-scoped memories
  Scenario: Agent requests recall by full signature + keyword
    When the agent supplies hormone channels or a keyword alongside emotion
    Then the tool rejects/ignores those inputs today
    And only the internal active path can perform such fusion
```
