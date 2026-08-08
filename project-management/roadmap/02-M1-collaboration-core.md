---
id: M1
name: "Collaboration Core: Tickets & Rooms"
sequence: 1
depends_on: [M0]
lanes: 4
stories: [US-006, US-007, US-008, US-009, US-010, US-011, US-012, US-013, US-014, US-015, US-016, US-017, US-018, US-019, US-020, US-021]
---

# M1 — Collaboration Core: Tickets & Rooms

This milestone delivers the two daily-driver workspace primitives that a session contains:
kanban **tickets/boards** (custom types and fields, sprints, cross-entity links, activity feeds)
and **chat rooms** (threaded replies, pins, scheduling, mute rules, reactions, and realtime
notifications). It is sequenced here because every later domain — reviews, campaigns, admin
queues — links to tickets or posts to rooms, so these primitives must exist first.

## Entry criteria

- M0's exit criteria are met — an authenticated principal can create an org/project-scoped
  session, and the Session MCP tools resolve slugs.
- The org/project/session data model from `M0/L0.A` is merged (tickets and rooms scope to it).

## Exit criteria

- `mix compile --warnings-as-errors` and `npm run build` both exit 0.
- A ticket can be created with a custom type and custom fields, moved across board stages, and
  linked to another ticket and to a non-ticket entity — demonstrated by `frontend/e2e/board.spec.ts`
  passing (exit 0).
- A message can be sent with a threaded reply, pinned, and delivered as a realtime notification
  that a recipient can clear — demonstrated by `frontend/e2e/chat.spec.ts` passing (exit 0).
- The cross-lane integration task (a ticket state change surfaces in a room activity feed) passes.
- All 16 stories assigned to this milestone have their acceptance criteria checked off.

## Transition checklist

- [ ] `backend/` compiles clean; `frontend/` builds clean
- [ ] `board.spec.ts` and `chat.spec.ts` pass (exit 0)
- [ ] Ticket-state-change → room-feed integration task passes
- [ ] All 16 stories' acceptance criteria met
- [ ] M2's Entry criteria reviewed and satisfied

## Worker lanes

### L1.A — Collaboration Contracts & Data Model
- **Zone / exclusive paths:** `backend/priv/repo/migrations/` (ticket/board/chat tables),
  `frontend/src/types/{tickets,chat}.ts`, `frontend/src/config/selectors/{board,chat}.ts`.
- **Mission:** Freeze the ticket/board and chat schemas plus the realtime channel envelope before
  the feature lanes start.
- **Tasks:**
  - T1.A.1 — [contract] Migrations + schema for tickets, board stages/iterations, custom
    field/type definitions, and polymorphic ticket links.
  - T1.A.2 — [contract] Migrations + schema for chat rooms, messages, members, events, and
    notifications; the `org_channel` realtime message envelope.
  - T1.A.3 — [contract] `data-cy` selector schema for the board and chat screens.
- **Stories delivered:** none — enablement only.
- **Contracts:** provides ticket/chat data model + channel envelope + selectors. Consumed by
  L1.B, L1.C, L1.D.

### L1.B — Tickets & Boards
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/domains/{tickets,links}/`,
  `schema/{ticket,board_stage,board_iteration}*.ex`, web `board_controller.ex`,
  `field_definition_controller.ex`, and `frontend/src/app/board/`, `frontend/src/components/board/`.
- **Mission:** The full-stack ticket/board vertical.
- **Tasks:**
  - T1.B.1 — `M` Create a ticket with a custom type and custom fields (US-006); create a PRD ticket
    linking user_story tickets (US-014).
  - T1.B.2 — `M` Move a ticket across board stages (US-007); assign a sprint/iteration (US-008).
  - T1.B.3 — `S` Link two tickets blocks/relates-to (US-009); link a ticket to a non-ticket entity
    (US-010); define a project-scoped custom field (US-011); view a ticket queue activity feed (US-013).
  - T1.B.4 — `C` Define an org-scoped custom ticket type (US-012).
- **Stories delivered:** US-006, US-007, US-008, US-009, US-010, US-011, US-012, US-013, US-014.
- **Contracts:** provides ticket entities that later milestones link against. Consumes L1.A.

### L1.C — Chat & Rooms
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/domains/{chat,notifications}/`,
  `schema/chat_*.ex`, web `chat_controller.ex`,
  `backend/lib/noizu_prompt_lingua_web/channels/org_channel.ex`, and `frontend/src/app/chat/`,
  `frontend/src/components/chat/`.
- **Mission:** The full-stack chat-room vertical with realtime delivery.
- **Tasks:**
  - T1.C.1 — `M` Create a room scoped to a session or project (US-015); send a message with a
    threaded reply (US-016); receive a room notification and clear it (US-021).
  - T1.C.2 — `S` Pin a message (US-017); mute a room or mute-unless-mentioned (US-019).
  - T1.C.3 — `C` Schedule a message to send later (US-018); react to and highlight a message (US-020).
- **Stories delivered:** US-015, US-016, US-017, US-018, US-019, US-020, US-021.
- **Contracts:** provides the room/notification surface later milestones post to. Consumes L1.A.

### L1.D — Collaboration QA & Integration
- **Zone / exclusive paths:** `frontend/e2e/{board,chat}.spec.ts`,
  `backend/test/noizu_prompt_lingua/{tickets,chat}/`.
- **Mission:** Prove both verticals and their integration seam, keyed to the frozen selectors.
- **Tasks:**
  - T1.D.1 — [contract] Write `board.spec.ts` and `chat.spec.ts` against L1.A selectors + API stub.
  - T1.D.2 — Backend tests for custom-field validation, board-stage transitions, and notification
    fan-out.
- **Stories delivered:** none — enablement only.
- **Contracts:** consumes L1.A selectors + sibling outputs.

## Cross-lane integration tasks

- **T1.X.1** (owned by L1.D) — A ticket moved across a board stage (L1.B) emits an activity event
  that surfaces in the ticket queue's feed and, when the queue is linked to a room, posts a
  notification into that room (L1.C). Proves the tickets↔chat seam composes.
