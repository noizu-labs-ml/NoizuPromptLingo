# Screens Inventory

47 screens extracted from the NPL product surface, covering the public marketing/auth funnel, the authenticated app shell, platform administration, and every core-work, collaboration, agent-infrastructure, creative-suite, integration, reference-data, and governance domain in the backlog. Each screen file follows the standard schema (ID, Type, Category, User Stories, Description, Key Components, Interactions, Navigation) and lives at `project-management/screens/{NN}-{screen-slug}.md`.

## Screens by Category

### Public & Onboarding (5)

| # | Screen | ID |
|---|--------|-----|
| 01 | Landing / Marketing Page | `landing-page` |
| 02 | Login | `login` |
| 03 | SSO Callback | `sso-callback` |
| 04 | Registration (Invite) | `registration-invite` |
| 05 | Email/Account Verify | `email-account-verify` |

### Core Shell (3)

| # | Screen | ID |
|---|--------|-----|
| 06 | Organization Picker | `organization-picker` |
| 07 | User Profile | `user-profile` |
| 08 | MCP API Keys & Setup | `mcp-api-keys-setup` |

### Platform Admin (8)

| # | Screen | ID |
|---|--------|-----|
| 09 | Admin Home | `admin-home` |
| 10 | Admin: Users | `admin-users` |
| 11 | Admin: Organizations | `admin-organizations` |
| 12 | Admin: Authz (MCP Keys + PBAC) | `admin-authz` |
| 13 | Admin: GitHub Integration | `admin-github-integration` |
| 14 | Admin: LLM Model Catalog | `admin-llm-model-catalog` |
| 15 | Admin: MCP Custom Scopes | `admin-mcp-custom-scopes` |
| 16 | Admin: Media Providers | `admin-media-providers` |

### Core Work (11)

| # | Screen | ID |
|---|--------|-----|
| 17 | Org Dashboard | `org-dashboard` |
| 18 | Projects List | `projects-list` |
| 19 | Project Detail | `project-detail` |
| 20 | Sessions List | `sessions-list` |
| 21 | Session Detail | `session-detail` |
| 24 | Ticket Board | `ticket-board` |
| 25 | Tickets List | `tickets-list` |
| 26 | Ticket Detail | `ticket-detail` |
| 27 | Ticket Field/Type Admin | `ticket-field-type-admin` |
| 31 | Artifacts List | `artifacts-list` |
| 32 | Artifact Detail | `artifact-detail` |

### Collaboration (5)

| # | Screen | ID |
|---|--------|-----|
| 22 | Chat Room List | `chat-room-list` |
| 23 | Chat Room View | `chat-room-view` |
| 28 | Wiki Browser | `wiki-browser` |
| 29 | Reviews List | `reviews-list` |
| 30 | Review Detail (overlay annotation) | `review-detail` |

### Agent Infrastructure (6)

| # | Screen | ID |
|---|--------|-----|
| 33 | Agent Personas Management | `agent-personas-management` |
| 35 | Instructions (Prompt Templates) | `instructions-prompt-templates` |
| 36 | Agent Memory Browser | `agent-memory-browser` |
| 39 | Browser Relay Gallery | `browser-relay-gallery` |
| 40 | Mock MCP Builder | `mock-mcp-builder` |
| 41 | Mock MCP LLM Pool | `mock-mcp-llm-pool` |

### Creative Suite (3)

| # | Screen | ID |
|---|--------|-----|
| 34 | Creative Assets Pipeline | `creative-assets-pipeline` |
| 46 | Campaigns & Ad Groups | `campaigns-ad-groups` |
| 47 | Market & Competitor Research | `market-competitor-research` |

### Integrations (2)

| # | Screen | ID |
|---|--------|-----|
| 37 | GitHub Repos List | `github-repos-list` |
| 38 | GitHub Repo Detail / PRs | `github-repo-detail-prs` |

### Reference Data (2)

| # | Screen | ID |
|---|--------|-----|
| 42 | Unicode/NPL Glyph Codex | `unicode-npl-glyph-codex` |
| 43 | NPL Conventions Browser | `npl-conventions-browser` |

### Governance (2)

| # | Screen | ID |
|---|--------|-----|
| 44 | Org Members | `org-members` |
| 45 | Org Settings | `org-settings` |

**Total: 47 screens across 10 categories.**

## Type Legend

| Type | When to use |
|------|-------------|
| **Primary** | A main content screen a user navigates to and works within directly — lists, detail views, boards, browsers. The majority of the app's routed surface. |
| **Dashboard** | A landing/summary screen that aggregates cross-entity data and quick links rather than managing a single entity type (org/admin home pages, the read-only memory browser). |
| **Settings** | A configuration screen whose primary purpose is viewing/editing persistent config — profile, keys, roles, provider credentials, custom fields/types. |
| **Modal** | A transient overlay scoped inside another screen rather than its own route (e.g., the New Session Modal on Sessions List, the Grant Access Modal on Admin: GitHub Integration). None of the 47 top-level screens in this pass are Modal-typed; the type is reserved for overlay components identified during the upcoming component-extraction phase. |
| **Storyboard** | A brief, largely non-interactive transitional state a user passes through rather than lingers on — auth handoffs and blocked/verification states (SSO Callback, Registration, Email/Account Verify). |

## User Story Coverage

**All 104 user stories (US-001 through US-104) are mapped to at least one screen. Coverage confirmed: 104/104.**

Coverage notes:

- Several stories are genuinely relevant to more than one screen and are listed on each (e.g., US-002 appears on both Session Detail (21) and Artifacts List (31); US-093 appears on both Ticket Detail (26) and Wiki Browser (28); US-095 appears on both Chat Room View (23) and Ticket Board (24); US-040 appears on both Login (02) and SSO Callback (03)).
- Cross-cutting accessibility/performance/edge-case stories (US-083–US-104) were mapped by scenario fit per the inventory brief — e.g., US-091 (keyboard nav) and US-096 (board pagination) to Ticket Board (24); US-092 (screen-reader announcements) to Org Dashboard (17); US-083/US-084 (expired-JWT/revoked-key rejection) to MCP API Keys & Setup (08); US-102 (remote-access tunnel) attached to MCP API Keys & Setup (08) as the closest-fit "connect my local tooling" screen, since no dedicated tunnel screen exists in this inventory.
- Eight screens carry no direct story reference: Landing (01), Email/Account Verify (05), Projects List (18), Artifact Detail (32), Instructions (35), Browser Relay Gallery (39), Mock MCP LLM Pool (41), and NPL Conventions Browser (43). Each is a structural/navigational screen, a companion/detail screen to a story-bearing sibling, or a newer Agent Infrastructure surface not yet backed by an authored backlog story — the coverage requirement runs story → screen, not screen → story, so this is expected rather than a gap.
