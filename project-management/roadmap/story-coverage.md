# Story Coverage & Traceability Matrix

Every one of the 104 user stories (`../user-stories/US-###-*.md`) is assigned to exactly one
primary milestone and lane, per the roadmap's decomposition (see [`00-overview.md`](00-overview.md)).
Rows are grouped by milestone, then by lane in the order the lane appears in that milestone's doc.
A story appears in the **Notes** column when a second lane materially supports its delivery — the
only kind of duplication this matrix records; every story still has exactly one primary owner.

No stories are deliberately excluded: coverage is 104/104 = 100%. The `LK.A` contracts and `LK.*`
QA lanes deliver no stories (pure enablement), so every story lands in a feature lane.

Count check: M0=15, M1=16, M2=17, M3=18, M4=16, M5=22 → 104.

## M0 — Foundation: Identity, Auth & Session Scoping

| US-ID | Title | Priority | Epic | Lane | Notes |
|---|---|---|---|---|---|
| US-037 | Register a New Organization | must-have | Onboarding & Auth | L0.B Identity & Access Backend | |
| US-038 | Send an Invite Token with Expiry and Use Cap | must-have | Onboarding & Auth | L0.B Identity & Access Backend | |
| US-039 | Accept an Invite and Complete OIDC Login | must-have | Onboarding & Auth | L0.B Identity & Access Backend | UI supported by L0.D |
| US-040 | Complete a First-Time SSO Callback Flow | must-have | Onboarding & Auth | L0.B Identity & Access Backend | UI supported by L0.D |
| US-041 | Self-Mint an MCP API Key | must-have | Onboarding & Auth | L0.B Identity & Access Backend | |
| US-043 | Mint an MCP JWT from a Raw API Key | must-have | Onboarding & Auth | L0.B Identity & Access Backend | |
| US-044 | Refresh an Expiring Guardian JWT Pair | should-have | Onboarding & Auth | L0.B Identity & Access Backend | |
| US-045 | Revoke a Lost or Leaked MCP API Key | must-have | Onboarding & Auth | L0.B Identity & Access Backend | |
| US-001 | Create a new work session scoped to an org/project | must-have | Work Sessions | L0.C Sessions Backend & MCP | |
| US-002 | Resume an existing session and see its rooms/tickets/artifacts | must-have | Work Sessions | L0.C Sessions Backend & MCP | |
| US-003 | Update a session's status/title/description as work evolves | should-have | Work Sessions | L0.C Sessions Backend & MCP | |
| US-004 | List all sessions for a project, filtered by status | should-have | Work Sessions | L0.C Sessions Backend & MCP | |
| US-005 | Tailor a session's tool descriptions to the target model/runner | could-have | Work Sessions | L0.C Sessions Backend & MCP | |
| US-042 | Copy a Generated `claude mcp add` Setup Command | must-have | Onboarding & Auth | L0.D Onboarding & Session Frontend | Token supplied by L0.B |
| US-046 | View My Organizations After Login | should-have | Onboarding & Auth | L0.D Onboarding & Session Frontend | Org list from L0.B |

## M1 — Collaboration Core: Tickets & Rooms

| US-ID | Title | Priority | Epic | Lane | Notes |
|---|---|---|---|---|---|
| US-006 | Create a ticket with a custom type and custom fields | must-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-007 | Move a ticket across kanban board stages | must-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-008 | Assign a sprint/iteration to a ticket | must-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-009 | Link two tickets together (blocks/relates-to) | should-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-010 | Link a ticket to a non-ticket entity (polymorphic link) | should-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-011 | Define a custom ticket field scoped to a project | should-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-012 | Define a custom ticket type scoped to an org | could-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-013 | View a ticket queue's feed of recent activity | should-have | Tickets & Boards | L1.B Tickets & Boards | Feed events consumed by L1.C |
| US-014 | Create a PRD ticket and link multiple user_story tickets to it | must-have | Tickets & Boards | L1.B Tickets & Boards | |
| US-015 | Create a chat room scoped to a session or project | must-have | Chat & Collaboration Rooms | L1.C Chat & Rooms | |
| US-016 | Send a message with a threaded reply | must-have | Chat & Collaboration Rooms | L1.C Chat & Rooms | |
| US-017 | Pin an important message in a room | should-have | Chat & Collaboration Rooms | L1.C Chat & Rooms | |
| US-018 | Schedule a message to send later | could-have | Chat & Collaboration Rooms | L1.C Chat & Rooms | |
| US-019 | Mute a room or mute unless mentioned | should-have | Chat & Collaboration Rooms | L1.C Chat & Rooms | |
| US-020 | React to and highlight a message | could-have | Chat & Collaboration Rooms | L1.C Chat & Rooms | |
| US-021 | Receive a room notification and clear it | must-have | Chat & Collaboration Rooms | L1.C Chat & Rooms | |

## M2 — Knowledge, Memory & Review

| US-ID | Title | Priority | Epic | Lane | Notes |
|---|---|---|---|---|---|
| US-022 | Register a new Agent Persona with a bio | must-have | Agent Personas & Memory | L2.B Agent Personas & Memory | |
| US-023 | Add a journal entry documenting completed work | must-have | Agent Personas & Memory | L2.B Agent Personas & Memory | |
| US-024 | Add a knowledge-base entry to a persona's private KB | should-have | Agent Personas & Memory | L2.B Agent Personas & Memory | |
| US-025 | Recall a memory by semantic similarity | must-have | Agent Personas & Memory | L2.B Agent Personas & Memory | Recall interface reused by L4.C |
| US-026 | Recall memories by emotional valence or signature | could-have | Agent Personas & Memory | L2.B Agent Personas & Memory | |
| US-027 | Reinforce or de-emphasize a memory association | should-have | Agent Personas & Memory | L2.B Agent Personas & Memory | |
| US-028 | Register an agent call sign and track agent state | should-have | Agent Personas & Memory | L2.B Agent Personas & Memory | |
| US-073 | Create a Wiki Space and Page | must-have | Social & Collaboration | L2.C Wiki, Reviews & Social | Content indexed by L4.C (US-071) |
| US-074 | Comment on a Wiki Page | should-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-075 | Attach a File to a Wiki Page | could-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-076 | React to a Wiki Page or Comment | could-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-077 | Create a Code Review with Overlay Comments | must-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-078 | Compile a Review into a Final Verdict | must-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-079 | List GitHub Pull Requests for a Linked Repo | should-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-080 | Comment on a GitHub Pull Request | should-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-081 | Follow a Pub/Sub Channel for Updates | could-have | Social & Collaboration | L2.C Wiki, Reviews & Social | |
| US-082 | Watch an Entity for Change Notifications | should-have | Social & Collaboration | L2.C Wiki, Reviews & Social | Notifies into M1 rooms |

## M3 — Platform Governance, Roles & Providers

| US-ID | Title | Priority | Epic | Lane | Notes |
|---|---|---|---|---|---|
| US-047 | Update Organization Name and Key Prefix | should-have | Settings & Preferences | L3.B Settings & Preferences | |
| US-048 | Define a Custom Role with Named Permissions | should-have | Settings & Preferences | L3.B Settings & Preferences | Evaluated by L3.C PBAC |
| US-049 | Assign a Custom Role to a Member | should-have | Settings & Preferences | L3.B Settings & Preferences | |
| US-050 | Apply an MCP Custom Scope to a Project | must-have | Settings & Preferences | L3.B Settings & Preferences | |
| US-051 | Configure Notification Preferences for a Room | could-have | Settings & Preferences | L3.B Settings & Preferences | |
| US-052 | Update User Profile Details | could-have | Settings & Preferences | L3.B Settings & Preferences | |
| US-053 | Configure a Media-Provider API Key for an Org | should-have | Settings & Preferences | L3.B Settings & Preferences | Enables L4.B generation (US-036) |
| US-054 | Suspend a User Account | must-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-055 | Change a User's Global Role with Self-Lockout Guard | must-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-056 | List and Search All Organizations | should-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-057 | Add and Live-Test an LLM Model Provider | must-have | Admin & Platform Operations | L3.C Admin & Platform Operations | Enables L4.B generation (US-030/US-036) |
| US-058 | Create and Curate a Global MCP Custom-Scope Preset | should-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-059 | Review an MCP Overview Queue Item | should-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-060 | Grant GitHub Token/Repo Access at the Org Level | should-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-061 | Configure an Org-Level Media-Provider Config as Admin | could-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-062 | Check a PBAC Policy Decision with the Simulator | should-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-063 | Explain a PBAC Policy Denial | should-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |
| US-064 | Audit MCP API Key Usage Across Organizations | could-have | Admin & Platform Operations | L3.C Admin & Platform Operations | |

## M4 — Growth Studio & Discovery

| US-ID | Title | Priority | Epic | Lane | Notes |
|---|---|---|---|---|---|
| US-029 | Create a Campaign with an Ad Group | must-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | |
| US-030 | Generate Ad Copy Variants for an Ad Group | must-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | Uses M3 LLM provider (US-057) |
| US-031 | Approve or Reject a Generated Ad Copy Variant | must-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | |
| US-032 | Generate a Landing Page Draft | should-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | |
| US-033 | Track a Domain Name Against a Campaign | could-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | |
| US-034 | Research Competitors for a Market Segment | should-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | |
| US-035 | Research and Track Keywords | should-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | |
| US-036 | Generate a Creative Asset and Publish Its Active Output | must-have | Creative Assets & Campaigns | L4.B Growth & Creative Studio | Uses M3 media provider (US-053) |
| US-065 | List All Tools on an MCP Server | must-have | Search & Discovery | L4.C Search & Discovery | |
| US-066 | Search Tools by Keyword | must-have | Search & Discovery | L4.C Search & Discovery | |
| US-067 | Search Tools by Semantic Intent | must-have | Search & Discovery | L4.C Search & Discovery | Reuses M2 recall interface (US-025) |
| US-068 | Get a Tool's Full Definition | should-have | Search & Discovery | L4.C Search & Discovery | |
| US-069 | Get Contextual Help for a Tool | could-have | Search & Discovery | L4.C Search & Discovery | |
| US-070 | Search the NPL Glyph Codex | should-have | Search & Discovery | L4.C Search & Discovery | |
| US-071 | Search the Wiki by Keyword | should-have | Search & Discovery | L4.C Search & Discovery | Indexes M2 wiki content (US-073) |
| US-072 | Filter Tickets by Custom Field Values | should-have | Search & Discovery | L4.C Search & Discovery | Over M1 tickets (US-006/US-011) |

## M5 — Hardening & Reach: Resilience, Access, Scale & Integrations

| US-ID | Title | Priority | Epic | Lane | Notes |
|---|---|---|---|---|---|
| US-083 | Reject MCP Calls with an Expired JWT | must-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | Guards M0 auth |
| US-084 | Reject MCP Calls Using a Revoked API Key | must-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | Guards M0 auth |
| US-085 | Block Registration on Expired or Exhausted Invite Tokens | must-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | Guards M0 invites |
| US-086 | Log tool_guard Identity Mismatches in Shadow Mode | should-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | |
| US-087 | Rate-Limit the Unauthenticated Token-Mint Endpoint | should-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | |
| US-088 | Fall Back to Read-Only When Operating on an Archived Project | should-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | |
| US-089 | Handle Orphaned Polymorphic Ticket Links Gracefully | could-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | Guards M1 links (US-010) |
| US-090 | Quarantine Flagged Content at Memory Ingest | should-have | Edge Cases & Error States | L5.A Security, Guards & Resilience | Hooks M2 memory store (US-025) |
| US-091 | Full Keyboard Navigation of the Ticket Board | must-have | Accessibility & Internationalization | L5.B Accessibility & Internationalization | Over M1 board |
| US-092 | Announce Dashboard State Changes to Screen Readers | must-have | Accessibility & Internationalization | L5.B Accessibility & Internationalization | |
| US-093 | Render Non-English Content Correctly in Wiki and Tickets | should-have | Accessibility & Internationalization | L5.B Accessibility & Internationalization | Over M1/M2 screens |
| US-094 | Switch to the High-Contrast Nocturne Theme | should-have | Accessibility & Internationalization | L5.B Accessibility & Internationalization | |
| US-095 | Respect prefers-reduced-motion in Chat and Board Animations | could-have | Accessibility & Internationalization | L5.B Accessibility & Internationalization | |
| US-096 | Paginate Large Ticket Boards Without a Full Reload | must-have | Performance & Scale | L5.C Performance & Scale | Over M1 board |
| US-097 | Virtualize Chat Rooms with Thousands of Messages | should-have | Performance & Scale | L5.C Performance & Scale | Over M1 chat |
| US-098 | Bound Memory-Recall Latency as a Persona's Memory Store Grows | should-have | Performance & Scale | L5.C Performance & Scale | Over M2 recall (US-025) |
| US-099 | Queue and Rate-Limit Bulk Creative-Asset Generation | could-have | Performance & Scale | L5.C Performance & Scale | Over M4 generation (US-036) |
| US-100 | Connect a GitHub Repository and Set Its Default ACL | must-have | Integration & External APIs | L5.D External Integrations | Over M2 GitHub links |
| US-101 | Create a Pull Request from Within the Platform | should-have | Integration & External APIs | L5.D External Integrations | Over M2 GitHub links |
| US-102 | Open a Remote-Access Tunnel to a Local Dev Server | should-have | Integration & External APIs | L5.D External Integrations | |
| US-103 | Build a Mock MCP Server from a Prose Description | could-have | Integration & External APIs | L5.D External Integrations | |
| US-104 | Receive an Outbound Webhook on Ticket State Change | could-have | Integration & External APIs | L5.D External Integrations | Fires on M1 ticket events |

## Epic → milestone summary

Every epic maps cleanly to exactly one milestone — the decomposition keeps epics intact rather
than splitting them across the sequence, so cross-milestone dependencies are expressed as the
"supports" notes above rather than as split ownership.

| Epic | Milestone(s) |
|---|---|
| Work Sessions | M0 |
| Onboarding & Auth | M0 |
| Tickets & Boards | M1 |
| Chat & Collaboration Rooms | M1 |
| Agent Personas & Memory | M2 |
| Social & Collaboration | M2 |
| Settings & Preferences | M3 |
| Admin & Platform Operations | M3 |
| Creative Assets & Campaigns | M4 |
| Search & Discovery | M4 |
| Edge Cases & Error States | M5 |
| Accessibility & Internationalization | M5 |
| Performance & Scale | M5 |
| Integration & External APIs | M5 |
