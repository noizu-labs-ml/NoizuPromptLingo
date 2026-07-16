---
id: M3
name: "Platform Governance, Roles & Providers"
sequence: 3
depends_on: [M2]
lanes: 4
stories: [US-047, US-048, US-049, US-050, US-051, US-052, US-053, US-054, US-055, US-056, US-057, US-058, US-059, US-060, US-061, US-062, US-063, US-064]
---

# M3 — Platform Governance, Roles & Providers

This milestone configures and governs the platform: **settings** (org name/key prefix, custom
roles and permissions, MCP custom scopes, room notification preferences, user profile, media-
provider API keys) and **admin/platform operations** (user suspension, global role changes with a
self-lockout guard, org search, LLM provider add/live-test, global scope presets, the MCP-overview
review queue, org-level GitHub access, PBAC policy simulation/explanation, and MCP key auditing).
It is sequenced here — before the M4 growth studio — because provider configuration (LLM + media)
gates any generation feature, and the PBAC policy engine must exist before the surfaces it governs.

## Entry criteria

- M2's exit criteria are met — personas, memory, wiki, and reviews exist for policies to govern
  and for the MCP-overview queue to reference.
- The org/user/membership data model from M0 is merged (roles and scopes attach to it).

## Exit criteria

- `mix compile --warnings-as-errors` and `npm run build` both exit 0.
- A custom role with named permissions can be defined and assigned, and an MCP custom scope can be
  applied to a project — demonstrated by `frontend/e2e/settings.spec.ts` passing (exit 0).
- An LLM provider and a media provider can be configured and live-tested; the resulting
  provider-config contract is frozen and documented for M4 to consume (file exists at the L3.A
  contract path).
- The PBAC simulator returns the correct allow/deny for a defined role+scope, and a denial can be
  explained — demonstrated by `frontend/e2e/policy.spec.ts` passing (exit 0).
- A global-role change that would lock out the last admin is refused (self-lockout guard test
  exits 0).
- All 18 stories assigned to this milestone have their acceptance criteria checked off.

## Transition checklist

- [ ] `backend/` compiles clean; `frontend/` builds clean
- [ ] `settings.spec.ts` and `policy.spec.ts` pass (exit 0)
- [ ] LLM + media provider-config contract frozen and documented for M4
- [ ] Self-lockout guard refuses last-admin demotion
- [ ] All 18 stories' acceptance criteria met
- [ ] M4's Entry criteria reviewed and satisfied

## Worker lanes

### L3.A — Governance Contracts & Policy Model
- **Zone / exclusive paths:** `backend/priv/repo/migrations/` (role/permission/scope/provider/audit
  tables), `frontend/src/types/{settings,admin,policy}.ts`,
  `frontend/src/config/selectors/{settings,admin,policy}.ts`, and the PBAC + provider-config specs.
- **Mission:** Freeze the PBAC policy model, the provider-config contract, and the audit-event
  schema before the feature lanes start.
- **Tasks:**
  - T3.A.1 — [contract] Migrations + schema for custom roles, permissions, MCP custom scopes, and
    the audit-event log.
  - T3.A.2 — [contract] The provider-config contract for LLM and media providers (the interface M4
    generation consumes) and the PBAC policy-decision interface.
  - T3.A.3 — [contract] `data-cy` selectors for the settings, admin, and policy screens.
- **Stories delivered:** none — enablement only.
- **Contracts:** provides the provider-config contract (consumed by L4.B in M4) and the
  policy-decision interface. Consumed by L3.B, L3.C, L3.D.

### L3.B — Settings & Preferences
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/entities/authz/`,
  `mcp_custom_scopes.ex`, web `custom_role_controller.ex`, `authz_membership_controller.ex`,
  `config_controller.ex`, media-key config under `media/`, and `frontend/src/app/settings/`.
- **Mission:** The full-stack workspace-configuration vertical.
- **Tasks:**
  - T3.B.1 — `M` Apply an MCP custom scope to a project (US-050).
  - T3.B.2 — `S` Update org name and key prefix (US-047); define a custom role with permissions
    (US-048); assign a custom role to a member (US-049); configure a media-provider API key for an
    org (US-053).
  - T3.B.3 — `C` Configure room notification preferences (US-051); update user profile details (US-052).
- **Stories delivered:** US-047, US-048, US-049, US-050, US-051, US-052, US-053.
- **Contracts:** the media-provider key (US-053) supports M4's creative generation (supports US-036).
  Consumes L3.A policy/provider model.

### L3.C — Admin & Platform Operations
- **Zone / exclusive paths:** `backend/lib/noizu_prompt_lingua/authz/policy_evaluator.ex`,
  `domains/mcp_overview/`, provider-admin services, web `admin_controller.ex`, `policy_controller.ex`,
  `mcp_overview_controller.ex`, org-level `github` access, and `frontend/src/app/admin/`.
- **Mission:** The full-stack platform-administration vertical, including PBAC and auditing.
- **Tasks:**
  - T3.C.1 — `M` Suspend a user account (US-054); change a user's global role with a self-lockout
    guard (US-055); add and live-test an LLM model provider (US-057).
  - T3.C.2 — `S` Search/list all organizations (US-056); create a global MCP custom-scope preset
    (US-058); review an MCP-overview queue item (US-059); grant org-level GitHub access (US-060);
    run the PBAC policy simulator (US-062); explain a PBAC policy denial (US-063).
  - T3.C.3 — `C` Configure an org-level media-provider as admin (US-061); audit MCP API-key usage
    across orgs (US-064).
- **Stories delivered:** US-054, US-055, US-056, US-057, US-058, US-059, US-060, US-061, US-062, US-063, US-064.
- **Contracts:** the LLM provider config (US-057) supports M4 generation (supports US-030/US-036).
  Consumes L3.A.

### L3.D — Governance QA & Integration
- **Zone / exclusive paths:** `frontend/e2e/{settings,admin,policy}.spec.ts`,
  `backend/test/noizu_prompt_lingua/{authz,mcp_custom_scopes,admin}/`.
- **Mission:** Prove settings↔policy composition and the self-lockout guard, keyed to frozen
  selectors.
- **Tasks:**
  - T3.D.1 — [contract] Write the settings/admin/policy e2e specs against L3.A selectors + stub.
  - T3.D.2 — Backend test asserting the self-lockout guard refuses demoting the last admin.
- **Stories delivered:** none — enablement only.
- **Contracts:** consumes L3.A selectors + sibling outputs.

## Cross-lane integration tasks

- **T3.X.1** (owned by L3.D) — Define a custom role and apply an MCP scope to a project (L3.B), then
  the PBAC simulator (L3.C) returns the expected allow/deny for a principal holding that role, and
  the denial explainer names the deciding policy — proving the settings↔policy seam composes.
