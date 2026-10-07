# Review: Render Non-English Content Correctly in Wiki and Tickets

- **Story**: `project-management/user-stories/US-093-non-english-content-rendering-wiki-tickets.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Storage round-tripping rides on the stack: Ecto/Postgres `:string`/`:text` columns are UTF-8 byte-safe by default (e.g., `backend/lib/noizu_prompt_lingua/schema/...` schemas throughout), so multi-byte content saved and reloaded is expected to round-trip, but there is no explicit handling or test proving it. Search exists only for wiki: `maybe_search` does case-insensitive substring `ilike` over name/slug and title/slug (`backend/lib/noizu_prompt_lingua/domains/wiki/wiki.ex:277-282`), which matches non-Latin terms as substrings; the tickets domain has no search at all (no `ilike`/search function in `backend/lib/noizu_prompt_lingua/domains/tickets/tickets.ex`). Presentation has no RTL or overflow handling: `frontend/src/app/layout.tsx:49` hardcodes `lang="en"` with no `dir` attribute logic, and no `dir="rtl"`/logical-property CSS exists in `frontend/src`. Confidence: medium-high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Multi-byte UTF-8 (CJK/Cyrillic/Arabic/emoji) round-trips with no mojibake | Partially Met | Postgres/Ecto text columns are UTF-8 by construction; no explicit handling or round-trip test found |
| RTL script renders with correct direction/alignment | Not Met | no evidence found — `layout.tsx:49` sets no `dir`; no RTL CSS in `frontend/src` |
| Long non-Latin titles wrap/truncate gracefully in fixed-width elements | Not Met | no evidence found — no overflow/truncation handling tied to this concern |
| Search returns matches for non-Latin terms (token/substring) | Partially Met | wiki substring `ilike` search (`wiki.ex:277-282`) works for non-Latin input; tickets domain has no search path |

## Gaps / Risks

- `lang="en"` fixed at the root means assistive tech and font selection get the wrong language hint for non-English content even when rendering is correct.
- ilike search is case-fold only; it does nothing for Unicode normalization differences (NFC/NFD) or caseless scripts — acceptable for "basic substring matching" per the story, but worth noting.
- No fixtures or tests anywhere assert non-Latin round-tripping; the "Met by the stack" position is unverified.

## BDD Scenario

```gherkin
Feature: Render non-English content in wiki and tickets

  Scenario: Write and search CJK/Arabic content (today)
    Given Tomás saves a wiki page titled "日本語テスト — مرحبا" and a ticket with emoji
    When the content is saved via the Elixir API and reloaded in the new frontend
    Then Postgres/Ecto text storage preserves the bytes and no mojibake appears
    But the page still declares lang="en" with no dir switching for Arabic
    And wiki search finds his title via ilike substring match (wiki.ex:281-282)
    And ticket search returns nothing because no search exists
    And a very long non-Latin title has no guaranteed wrap/truncate behavior
```
