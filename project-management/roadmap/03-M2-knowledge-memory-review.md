---
id: M2
name: "Knowledge, Memory & Review"
sequence: 2
depends_on: [M1]
lanes: 4
stories: [US-022, US-023, US-024, US-025, US-026, US-027, US-028, US-073, US-074, US-075, US-076, US-077, US-078, US-079, US-080, US-081, US-082]
---

# M2 — Knowledge, Memory & Review

This milestone builds the durable-content layer: **agent personas** with bios, journals, private
knowledge bases, and semantic/emotional **memory recall**, alongside the human-facing knowledge
and review surfaces — **wiki** spaces/pages/comments/attachments, **code review** with overlay
comments and verdicts, **GitHub** PR listing/commenting, and **pub/sub** follow + entity-watch.
It is sequenced after M1 because reviews and watches attach to tickets and rooms, and after M0
because personas and memory scope to the org/session principal. Its vector-recall substrate
(pgvector) is the interface the M4 discovery lane later reuses.

## Entry criteria

- M1's exit criteria are met — tickets and rooms exist for reviews, comments, and watches to
  attach to.
- The org/project/session principal from M0 is available to scope personas and memory.

## Exit criteria

- `mix compile --warnings-as-errors` and `npm run build` both exit 0.
- An agent persona can be registered, add a journal entry, add a private KB entry, and recall a
  memory by semantic similarity — demonstrated by `frontend/e2e/memory.spec.ts` and the backend
  recall test passing (exit 0).
- A wiki space/page can be created and commented on, and a code review can be created with overlay
  comments and compiled into a verdict — demonstrated by `frontend/e2e/wiki.spec.ts` and
  `frontend/e2e/review.spec.ts` passing (exit 0).
- The semantic-recall interface (`domains/memory` over pgvector) is documented and frozen for M4
  to consume — file exists at the contract path named in L2.A.
- All 17 stories assigned to this milestone have their acceptance criteria checked off.

## Transition checklist

- [ ] `backend/` compiles clean; `frontend/` builds clean
- [ ] `memory.spec.ts`, `wiki.spec.ts`, `review.spec.ts` pass (exit 0)
- [ ] Semantic-recall interface frozen and documented for M4
- [ ] All 17 stories' acceptance criteria met
- [ ] M3's Entry criteria reviewed and satisfied

## Worker lanes

### L2.A — Knowledge Contracts & Vector Substrate
- **Zone / exclusive paths:** `backend/priv/repo/migrations/` (persona/memory/wiki/review tables +
  pgvector indexes), `frontend/src/types/{personas,memory,wiki,review}.ts`,
  `frontend/src/config/selectors/{personas,memory,wiki,review}.ts`, and the semantic-recall
  interface spec.
- **Mission:** Freeze the persona/memory/wiki/review schemas and the semantic-recall interface
  before the feature lanes start.
- **Tasks:**
  - T2.A.1 — [contract] Migrations + schema for personas, memory records, journals, KB entries, and
    the pgvector embedding index.
  - T2.A.2 — [contract] Migrations + schema for wiki spaces/pages/comments/attachments/reactions,
    reviews/overlay-comments/verdicts, GitHub links, and pub/sub subscriptions + entity watches.
  - T2.A.3 — [contract] The semantic-recall interface (embed + similarity + valence filter) that
    M4 Search reuses, plus `data-cy` selectors for this milestone's screens.
- **Stories delivered:** none — enablement only.
- **Contracts:** provides the recall interface (consumed by L4.C in M4), data model, and selectors.

### L2.B — Agent Personas & Memory
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/domains/{personas,memory}/`,
  `workers/memory/`, `schema/{persona,memory}*.ex`, web `persona_controller.ex`,
  `memory_controller.ex`, and `frontend/src/app/{personas,memory}/`.
- **Mission:** The full-stack persona + memory vertical over the pgvector substrate.
- **Tasks:**
  - T2.B.1 — `M` Register an Agent Persona with a bio (US-022); add a journal entry (US-023);
    recall a memory by semantic similarity (US-025).
  - T2.B.2 — `S` Add a KB entry to a private KB (US-024); reinforce/de-emphasize a memory
    association (US-027); register an agent call sign and track agent state (US-028).
  - T2.B.3 — `C` Recall memories by emotional valence or signature (US-026).
- **Stories delivered:** US-022, US-023, US-024, US-025, US-026, US-027, US-028.
- **Contracts:** provides the memory store M5's quarantine guard (supports US-090) hooks into.
  Consumes L2.A recall interface.

### L2.C — Wiki, Reviews & Social
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/domains/{wiki,review,github,pubsub}/`,
  `services/{attach,comment,watch}.ex`, `github/client.ex`, web wiki/review/github controllers, and
  `frontend/src/app/{wiki,review,github}/`.
- **Mission:** The full-stack wiki + review + GitHub + pub/sub vertical.
- **Tasks:**
  - T2.C.1 — `M` Create a wiki space and page (US-073); create a code review with overlay comments
    (US-077); compile a review into a final verdict (US-078).
  - T2.C.2 — `S` Comment on a wiki page (US-074); list GitHub PRs for a linked repo (US-079);
    comment on a GitHub PR (US-080); watch an entity for change notifications (US-082).
  - T2.C.3 — `C` Attach a file to a wiki page (US-075); react to a wiki page/comment (US-076);
    follow a pub/sub channel (US-081).
- **Stories delivered:** US-073, US-074, US-075, US-076, US-077, US-078, US-079, US-080, US-081, US-082.
- **Contracts:** provides wiki content that M4's wiki search (supports US-071) indexes. Consumes L2.A.

### L2.D — Knowledge QA & Integration
- **Zone / exclusive paths:** `frontend/e2e/{personas,memory,wiki,review}.spec.ts`,
  `backend/test/noizu_prompt_lingua/{personas,memory,wiki,review,github,pubsub}/`.
- **Mission:** Prove both verticals and the cross-domain event flow, keyed to frozen selectors.
- **Tasks:**
  - T2.D.1 — [contract] Write the persona/memory/wiki/review e2e specs against L2.A selectors + stub.
  - T2.D.2 — Backend recall test asserting semantic similarity returns seeded memories in rank order.
- **Stories delivered:** none — enablement only.
- **Contracts:** consumes L2.A selectors + sibling outputs.

## Cross-lane integration tasks

- **T2.X.1** (owned by L2.D) — A comment on a wiki page (L2.C) fires a pub/sub watch notification
  (L2.C) into a room from M1, and an agent (L2.B) records a journal entry referencing that page —
  proving the memory↔social↔chat event flow composes.
- **T2.X.2** (owned by L2.D) — Semantic recall (L2.B) returns seeded memories ranked by similarity
  against the L2.A pgvector index, validating the interface M4 Search will reuse.
