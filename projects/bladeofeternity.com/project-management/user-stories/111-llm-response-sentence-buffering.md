# US-111: LLM Response Sentence Buffering

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP focus)
**Priority:** P0
**Epic:** LLM & AI Systems

## Story
As Marcus, I want the game to never push partial sentences or mid-word text to my screen reader so that NVDA doesn't stutter through half-formed words and I can process every description cleanly and quickly without having to re-read or ask for a repeat.

## Acceptance Criteria
- [ ] All LLM-generated text is buffered server-side at sentence boundaries (period, exclamation, question mark followed by whitespace or end of string) before delivery to the client via Phoenix Channel
- [ ] Streaming LLM responses (if used from provider) are consumed and buffered internally — the WebSocket protocol to the client delivers only complete sentences, never character streams
- [ ] Sentence boundary detection handles: ellipses ("He paused..."), abbreviations ("St. Aldric's"), decimal numbers ("3.5 seconds"), and dialogue-end quotes (`"Indeed." She turned away.`) without false splits
- [ ] Empty or whitespace-only buffers are not transmitted; minimum deliverable unit is one complete grammatical sentence
- [ ] Response delivery latency target: first complete sentence delivered within 1.5 seconds of LLM response start; full response within 3 seconds for standard-length descriptions
- [ ] Combat narration sentences delivered as atomic units with a minimum 150ms gap between sentences to prevent NVDA announcement overlap — gap configurable per domain in the template registry
- [ ] Screen reader testing matrix: NVDA+Firefox, JAWS+Chrome, VoiceOver+Safari, TalkBack+Chrome — all must handle multi-sentence delivery without word repetition or dropped content
- [ ] Diagnostic mode (admin flag per player) logs: sentence boundary detection decisions, buffer accumulation timeline, delivery timestamps — for debugging SR-specific announcement issues

## Notes
Sentence buffering implemented as `BladeOfEternity.AI.SentenceBuffer` — a pure functional module with `accumulate/2` (adds text chunk to buffer, returns `{complete_sentences, remaining_buffer}`) and `flush/1` (returns remaining buffer as complete unit). Used as streaming consumer in LLM client response handler.

Sentence boundary detection via regex (not naive period-splitting):
```elixir
@sentence_end ~r/(?<=[.!?…])(?=\s+[A-Z"]|$)/
@abbreviations ~r/\b(St|Dr|Mr|Mrs|Ms|Jr|Sr|etc|vs|Inc|Ltd)\./
```
Algorithm: find all period positions, exclude abbreviation matches, exclude decimal numbers (`\d\.\d`), exclude ellipses mid-sentence. Remaining periods followed by uppercase or end-of-string are sentence boundaries.

Delivery gap between sentences: configurable per generation domain in template registry as `inter_sentence_gap_ms`. Default: room descriptions 0ms (delivered together), combat narration 200ms (staggered for dramatic effect and SR clarity), ambient 0ms. Gap implemented via `Process.sleep/1` in delivery pipeline (acceptable since delivery is on a dedicated Task, not blocking game loop).

Phoenix Channel delivery: sentences pushed as individual `push/3` calls with event `"narrative"`. Client-side ARIA injector receives each sentence as an atomic event and appends to the narrative `aria-live` region. This is preferable to batching all sentences in one message — allows client to begin announcing the first sentence while server is still delivering later ones.

Streaming LLM provider handling: if using a streaming provider API (`genai` Elixir library with streaming option), the response stream is consumed in a Task that accumulates into `SentenceBuffer` and pushes complete sentences to the player channel as they form. The player never sees the streaming — they see only complete sentences appearing progressively.

NVDA-specific issue: NVDA can "skip" content if multiple `aria-live` updates arrive within ~100ms. The 150ms minimum gap for combat narration exists to prevent this. Longer content (room descriptions) is safe to deliver in a single push since it's one atomic announcement.
