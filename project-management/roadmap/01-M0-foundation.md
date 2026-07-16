---
id: M0
name: "Foundation: Identity, Auth & Session Scoping"
sequence: 0
depends_on: []
lanes: 5
stories: [US-001, US-002, US-003, US-004, US-005, US-037, US-038, US-039, US-040, US-041, US-042, US-043, US-044, US-045, US-046]
---

# M0 — Foundation: Identity, Auth & Session Scoping

This milestone stands up the identity substrate every other request depends on: an organization
a user can register, an OIDC/SSO login, self-minted MCP API keys that exchange for Guardian JWTs,
and the org/project-scoped **work session** that all subsequent artifacts, tickets, and chat
activity attribute to. It is sequenced first because nothing else in the platform is reachable
without an authenticated principal and a session to scope work under.

## Entry criteria

- None — this is the sequence's origin point.

## Exit criteria

- `mix compile --warnings-as-errors` exits 0 in `backend/` and `npm run build` exits 0 in
  `frontend/`.
- A principal can complete the full bootstrap end-to-end: register an org, log in via OIDC,
  self-mint an MCP API key, exchange it for a Guardian JWT, and create a work session scoped to
  an org/project — demonstrated by the integration spec in L0.E passing.
- The `Session.Create` / `Session.Get` / `Session.Update` / `Session.List` MCP tools resolve an
  org+project slug and return a session UUID; a call with an unknown org returns a structured
  "Organization not found" error rather than crashing.
- All 15 US-0XX / US-00X stories assigned to this milestone have their acceptance criteria
  checked off.
- `backend/test/` auth and session suites and `frontend/e2e/auth.spec.ts` pass (exit 0).

## Transition checklist

- [ ] `backend/` compiles with `--warnings-as-errors`; `frontend/` builds clean
- [ ] Bootstrap integration spec (register → login → mint key → mint JWT → create session) passes
- [ ] Session MCP tools resolve slugs and error cleanly on unknown org/project
- [ ] All 15 stories' acceptance criteria met
- [ ] M1's Entry criteria reviewed and satisfied

## Worker lanes

### L0.A — Auth Contracts & Data Model
- **Zone / exclusive paths:** `backend/priv/repo/migrations/` (auth/session tables),
  `frontend/src/types/auth.ts`, `frontend/src/config/selectors/auth.ts`, and this milestone's
  contract spec notes.
- **Mission:** Freeze the auth/session data model and the interfaces sibling lanes build against,
  before any implementation starts.
- **Tasks:**
  - T0.A.1 — [contract] Migrations + schema for organizations, users, `mcp_api_keys`, sessions,
    and the invite/registration token.
  - T0.A.2 — [contract] Guardian JWT claims contract (subject, org/project scope, expiry) and the
    MCP API-key → JWT exchange interface.
  - T0.A.3 — [contract] `data-cy` selector schema for the login, invite, SSO-callback, org-list,
    and session screens.
- **Stories delivered:** none — enablement only.
- **Contracts:** provides the session/org/project data model, JWT-claims contract, and selector
  schema. Consumed by L0.B, L0.C, L0.D, L0.E.

### L0.B — Identity & Access Backend
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/auth/`, `mcp_auth.ex`,
  `guardian.ex`, `token.ex`, `entities/{organizations,users,auth}/`, `entities/mcp_api_keys.ex`,
  `mcp/organizations/`, `mcp/projects/`, and web `auth_controller.ex`, `organization_controller.ex`,
  `project_controller.ex`.
- **Mission:** Implement org registration, OIDC/SSO login, and the MCP key/JWT lifecycle.
- **Tasks:**
  - T0.B.1 — `M` Register a new organization with a key prefix (US-037).
  - T0.B.2 — `M` Send an invite token with expiry and use cap (US-038).
  - T0.B.3 — `M` Accept an invite and complete OIDC login (US-039); first-time SSO callback (US-040).
  - T0.B.4 — `M` Self-mint an MCP API key (US-041); mint an MCP JWT from a raw key (US-043).
  - T0.B.5 — `S` Refresh an expiring Guardian JWT pair (US-044); revoke a lost/leaked key (US-045).
- **Stories delivered:** US-037, US-038, US-039, US-040, US-041, US-043, US-044, US-045.
- **Contracts:** provides the auth endpoints + key/JWT services. Consumes L0.A data model.

### L0.C — Sessions Backend & MCP
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/mcp/sessions/`,
  `entities/sessions/`, `schema/session*.ex`, and the session controller.
- **Mission:** Implement the org/project-scoped work session and its MCP tool surface.
- **Tasks:**
  - T0.C.1 — `M` Create a work session scoped to an org/project (US-001); resume a session and see
    its rooms/tickets/artifacts (US-002).
  - T0.C.2 — `S` Update a session's status/title/description (US-003); list a project's sessions
    filtered by status (US-004).
  - T0.C.3 — `C` Tailor a session's tool descriptions to the target model/runner (US-005).
- **Stories delivered:** US-001, US-002, US-003, US-004, US-005.
- **Contracts:** provides the Session MCP tools + session UUID that M1–M5 scope work under.
  Consumes L0.A data model, L0.B principal/JWT.

### L0.D — Onboarding & Session Frontend
- **Zone / exclusive paths:** `frontend/src/app/(auth)/`, `frontend/src/app/onboarding/`,
  `frontend/src/app/sessions/`, `frontend/src/context/auth*`, `frontend/src/components/auth/`.
- **Mission:** The login/invite/SSO screens, the post-login org list, and the copyable MCP setup
  command.
- **Tasks:**
  - T0.D.1 — `M` Copy a generated `claude mcp add` setup command (US-042).
  - T0.D.2 — `S` View my organizations after login (US-046).
  - T0.D.3 — `M` Render the login, invite-accept, and SSO-callback flows against the L0.B endpoints.
- **Stories delivered:** US-042, US-046.
- **Contracts:** consumes L0.A selector schema, L0.B auth endpoints, L0.C session tools. Supports
  US-037/US-039/US-040/US-001/US-002 (their UI).

### L0.E — Auth QA & Integration
- **Zone / exclusive paths:** `frontend/e2e/auth.spec.ts`, `frontend/e2e/session.spec.ts`,
  `backend/test/noizu_prompt_lingua/{auth,sessions}/`.
- **Mission:** Prove the whole bootstrap composes, keyed to the frozen selector schema.
- **Tasks:**
  - T0.E.1 — [contract] Write `auth.spec.ts` against the L0.A selector schema and the API stub,
    before L0.D ships.
  - T0.E.2 — Backend unit/integration tests for key/JWT lifecycle and session slug resolution.
- **Stories delivered:** none — enablement only.
- **Contracts:** consumes L0.A selector schema + all sibling outputs.

## Cross-lane integration tasks

- **T0.X.1** (owned by L0.E) — End-to-end: register an org (L0.B) → OIDC login (L0.B) → self-mint
  an MCP API key (L0.B) → exchange for a Guardian JWT (L0.B) → `Session.Create` scoped to that
  org/project (L0.C) returns a UUID, with the UI (L0.D) rendering each step. This spec exiting 0
  is the milestone's exit gate.
