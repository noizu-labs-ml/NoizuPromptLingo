---
id: M5
name: "Hardening & Reach: Resilience, Access, Scale & Integrations"
sequence: 5
depends_on: [M4]
lanes: 5
stories: [US-083, US-084, US-085, US-086, US-087, US-088, US-089, US-090, US-091, US-092, US-093, US-094, US-095, US-096, US-097, US-098, US-099, US-100, US-101, US-102, US-103, US-104]
---

# M5 — Hardening & Reach: Resilience, Access, Scale & Integrations

This final milestone applies cross-cutting quality over everything already built: **security and
error edge cases** (expired/revoked credentials, exhausted invites, `tool_guard` shadow mode,
rate-limited token minting, archived-project read-only fallback, orphaned links, memory-ingest
quarantine); **accessibility and i18n** (keyboard navigation, screen-reader announcements,
non-English rendering, high-contrast Nocturne theme, reduced motion); **performance and scale**
(board pagination, chat virtualization, bounded memory-recall latency, bulk-generation queueing);
and **external integrations** (GitHub repo connect + PR creation, remote-access tunnels, prose-to-
mock-MCP, outbound webhooks). It is sequenced last because you harden the features that exist — its
lanes cut by concern rather than by domain, editing narrow slices across the prior milestones' code.

## Entry criteria

- M4's exit criteria are met — the full feature set (auth, tickets, rooms, memory, wiki, review,
  governance, studio, discovery) exists to be hardened.
- All prior milestones' e2e specs pass, so the M5 QA lane can extend them rather than repair them.

## Exit criteria

- `mix compile --warnings-as-errors` and `npm run build` both exit 0.
- Security edge cases hold: MCP calls with an expired JWT or revoked API key are rejected,
  registration on an exhausted invite is blocked, and the unauthenticated token-mint endpoint is
  rate-limited — demonstrated by the L5.A security test suite passing (exit 0).
- An automated accessibility pass (axe via Playwright) reports zero critical violations across the
  primary screens, and keyboard-only navigation of the ticket board and screen-reader dashboard
  announcements are demonstrated by `frontend/e2e/a11y.spec.ts` passing (exit 0).
- Large boards paginate and chat rooms virtualize without a full reload, and memory-recall latency
  stays bounded as the store grows (performance test exits 0).
- A GitHub repo can be connected and a PR created from the platform, a remote-access tunnel opens,
  a mock MCP server is built from prose, and a ticket state change fires an outbound webhook —
  demonstrated by `frontend/e2e/integration.spec.ts` passing (exit 0).
- All 22 stories assigned to this milestone have their acceptance criteria checked off.

## Transition checklist

- [ ] `backend/` compiles clean; `frontend/` builds clean
- [ ] L5.A security suite, `a11y.spec.ts`, performance test, and `integration.spec.ts` pass (exit 0)
- [ ] axe accessibility pass reports zero critical violations on primary screens
- [ ] Full regression: every prior milestone's e2e spec still passes
- [ ] All 22 stories' acceptance criteria met

## Worker lanes

### L5.A — Security, Guards & Resilience
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex`,
  `backend/lib/noizu_prompt_lingua_web/plugs/` (rate-limit + auth guards), the memory-ingest
  quarantine hook in `domains/memory/`, and archived-project + orphaned-link guards in
  `domains/{tickets,links}/`.
- **Mission:** Make the credential, authorization, and data-integrity edges fail safely.
- **Tasks:**
  - T5.A.1 — `M` Reject MCP calls with an expired JWT (US-083) or a revoked API key (US-084); block
    registration on expired/exhausted invite tokens (US-085).
  - T5.A.2 — `S` Log `tool_guard` identity mismatches in shadow mode (US-086); rate-limit the
    unauthenticated token-mint endpoint (US-087); fall back to read-only on archived projects
    (US-088); quarantine flagged content at memory ingest (US-090).
  - T5.A.3 — `C` Handle orphaned polymorphic ticket links gracefully (US-089).
- **Stories delivered:** US-083, US-084, US-085, US-086, US-087, US-088, US-089, US-090.
- **Contracts:** consumes M0 auth (US-083/084/085), M2 memory (US-090 hooks the L2.B store), M1
  tickets/links (US-088/089).

### L5.B — Accessibility & Internationalization
- **Zone / exclusive paths:** `frontend/src/i18n/`, and accessibility-only edits (ARIA, focus
  order, live regions, theme tokens) across `frontend/src/app/**` markup and
  `frontend/src/context/theme*` — markup and i18n only, no business logic.
- **Mission:** Make every primary screen usable by keyboard, screen reader, and reduced-motion
  users, and render correctly in non-English locales and the high-contrast theme.
- **Tasks:**
  - T5.B.1 — `M` Full keyboard navigation of the ticket board (US-091); announce dashboard state
    changes to screen readers (US-092).
  - T5.B.2 — `S` Render non-English content correctly in wiki and tickets (US-093); switch to the
    high-contrast Nocturne theme (US-094).
  - T5.B.3 — `C` Respect `prefers-reduced-motion` in chat and board animations (US-095).
- **Stories delivered:** US-091, US-092, US-093, US-094, US-095.
- **Contracts:** markup-only lane — files change-requests against sibling lanes for any non-markup
  change. Consumes M1 board/chat and M2 wiki screens.

### L5.C — Performance & Scale
- **Zone / exclusive paths:** pagination/virtualization paths in
  `frontend/src/components/{board,chat}/`, memory-recall index tuning in `workers/memory/` +
  pgvector index config, and the bulk-generation queue in `workers/` (Oban).
- **Mission:** Keep the platform responsive as boards, chat rooms, and memory stores grow.
- **Tasks:**
  - T5.C.1 — `M` Paginate large ticket boards without a full reload (US-096).
  - T5.C.2 — `S` Virtualize chat rooms with thousands of messages (US-097); bound memory-recall
    latency as a persona's store grows (US-098).
  - T5.C.3 — `C` Queue and rate-limit bulk creative-asset generation (US-099).
- **Stories delivered:** US-096, US-097, US-098, US-099.
- **Contracts:** consumes M1 board/chat (US-096/097), M2 memory (US-098), M4 asset generation
  (US-099).

### L5.D — External Integrations
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/domains/{mock_mcp,remote_access}/`,
  the PR-create path in `domains/github/` + `github/client.ex`, outbound webhooks in
  `domains/notifications/`, web `mock_mcp_controller.ex` + `github_controller.ex` (PR-create),
  `remote-access-client/`, and `frontend/src/app/integrations/`.
- **Mission:** Reach outward — GitHub write, tunnels, prose-to-mock-MCP, and outbound webhooks.
- **Tasks:**
  - T5.D.1 — `M` Connect a GitHub repository and set its default ACL (US-100).
  - T5.D.2 — `S` Create a pull request from within the platform (US-101); open a remote-access
    tunnel to a local dev server (US-102).
  - T5.D.3 — `C` Build a mock MCP server from a prose description (US-103); receive an outbound
    webhook on ticket state change (US-104).
- **Stories delivered:** US-100, US-101, US-102, US-103, US-104.
- **Contracts:** consumes M2 GitHub links (US-100/101), M1 tickets (US-104 fires on ticket state
  change).

### L5.E — Hardening QA & Integration
- **Zone / exclusive paths:** `frontend/e2e/{a11y,perf,integration}.spec.ts`,
  `backend/test/noizu_prompt_lingua/{tool_guard,plugs,mock_mcp,remote_access}/`, and the axe/load
  harness config.
- **Mission:** Prove resilience, accessibility, performance, and integration together, and run the
  full regression.
- **Tasks:**
  - T5.E.1 — [contract] Write `a11y.spec.ts` (axe pass), `perf.spec.ts`, and `integration.spec.ts`.
  - T5.E.2 — Run the full e2e suite from M0–M4 green as a regression gate.
- **Stories delivered:** none — enablement only.
- **Contracts:** consumes every prior milestone's selectors + specs.

## Cross-lane integration tasks

- **T5.X.1** (owned by L5.E) — Run the complete regression: every M0–M4 e2e spec plus the L5.A
  security suite, `a11y.spec.ts` (zero critical axe violations), `perf.spec.ts`, and
  `integration.spec.ts` all pass in one run — the platform's release gate.
