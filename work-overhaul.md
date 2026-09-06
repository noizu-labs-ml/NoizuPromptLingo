# Work Overhaul — NPL User-Story Implementation Review

**Date**: 2026-09-06
**Scope**: All 265 user stories in `project-management/user-stories/` (US-001–120, US-201–232, plus newly generated US-301–307 VFS and US-401–407 Database Access Services).
**Method**: 25+ parallel review agents, each verifying stories against actual code — Python MCP fleet (`src/npl_mcp/`) **and** the Elixir backend (`backend/` in the projects checkout) — reading implementation bodies, SQL, and tests rather than trusting grep hits. One review file per story under `project-management/reviews/` (matched by basename), each with: implementation assessment, per-acceptance-criterion check with file:line evidence, gaps/risks, and a BDD (Gherkin) scenario.
**Reusable template**: `sub-agent-prompts/story-review.md`.

> ⚠️ Naming note: this repo's stories span TWO codebases. Stories marked **[Elixir]** are implemented in `backend/lib/noizu_prompt_lingua/` (the projects checkout); stories marked **[Python]** target `src/npl_mcp/`. Several story IDs have one file in each cohort.

---

## 1. Executive Summary

| Status | Share (approx.) | Reading |
|---|---|---|
| Implemented | ~15% | Solid, tested, and matching story intent |
| Partially Implemented | ~45% | Core mechanism exists; scoping/authz/edge cases/lifecycle missing |
| Not Implemented | ~40% | Greenfield epics + stories written against a codebase that no longer exists |

The dominant pattern is **"engine ahead of surface, surface ahead of enforcement"**: real capability sits in modules (browser interact, pm_tools, tasker lifecycle) that are either unregistered on the MCP surface or registered only as stubs, while the tools that ARE exposed frequently lack authorization, validation, or any writer for the tables their companion "feed/notification" tools read. A second systematic problem is **story drift**: a large cohort of stories cites `worktrees/main/mcp-server`, `unified.py`, and SQLite — none of which exist; storage is Postgres/asyncpg (Python) and Ecto/Liquibase (Elixir).

---

## 2. What Works (Implemented)

- **Tool discovery suite** [Elixir + Python mirror]: list/search tools, semantic search, full definitions, help (US-065–068, US-070-codex). Semantic search is Postgres/pgvector on the backend — story says Weaviate (documented divergence).
- **Auth foundations** [Elixir]: first-time SSO callback (US-040), self-minted MCP API keys (US-041), API-key→JWT mint (US-043, TTL 7d vs story's "short-lived"), `claude mcp add` copy command (US-042), rate-limited token mint (US-087, 3/4), token-budget-free room notification prefs (US-051).
- **Sessions & orgs** [Elixir]: org registration with owner bootstrap (US-037), my-orgs view (US-046), REST session access (US-097, different paths than story), session dashboard basics (US-005 partial), config/scope presets (US-058).
- **NPL tooling** [Python]: NPLLoad/NPLSpec conventions loading (US-001, partial), markdown filter/collapse pipeline (US-209–213), conversion cache (US-207, 6/6), Fabric pattern analysis (US-095), ephemeral tasker tools (US-094/113 — registered and working), project-structure exploration (US-025), memory recall (US-025-recall, 5/5 [Elixir Weaviate]).
- **Platform services** [Elixir]: VFS consumer over VFSWS (US-301, 4/4), remote-access tunnel (US-102, 4/4), mock-MCP-from-prose generator (US-103, 4/4), creative-asset pipeline (US-036, 2.5/3), GitHub PR list/comment (US-079/080), wiki create/comment/react (US-073/074/076), chat room messaging (US-006, 8/8), executor/fabric CLI + MCP exposure (US-112/113/114/117).

---

## 3. Partially Supported — dominant gaps per epic

**Work Sessions / Tasks / Tickets [Python]** — Session/Task/Ticket CRUD works; org & project scoping does not exist on the Python schema (`npl_generic_sessions` has no org/project columns); `session_get_contents` is unscoped (see §5-S1); status filtering never coexists with project filtering on one endpoint; complexity scale contradicts between story (1–5) and code (1–13); task assignment is frozen after creation; no pick/claim atomicity.

**Tickets & Boards [Elixir]** — Type/custom fields persist but aren't validated or filterable (US-072: 0/4); `Ticket.Update` lacks stage/iteration params that HTTP and VFS accept (split-brain); activity feeds are stubs; no self-link or cross-board stage guards; TicketLink has no FK to TRP-backed tickets.

**Chat & Collaboration** — Messaging solid [Elixir]; no threading, pins, scheduling, mute-mentions, or notification *producers* on Python (see §5-S6); no room RBAC checks on send (sender is caller-asserted); reaction removal is a separate tool, not a toggle; todo stories at 4/11 with no complete/remove paths.

**Agent Personas & Memory** — register-persona, journal, private KB, valence-recall are 0–25% met; the KB has a **privacy hole** (UUID lookup bypasses persona scoping, `personas.ex:128-137` [Elixir]); no compartments/ACL anywhere; semantic recall works (Weaviate) but emotional-dimension recall exposes VAD only.

**Creative Assets & Campaigns [Elixir]** — ad-groups, ad-copy variants, keyword→campaign linkage, landing-page drafts: fully greenfield (0/3 across the board); creative-asset generate/publish pipeline itself is real.

**Onboarding & Auth** — invite tokens are **schema-only**: entity exists (with expiry+cap), zero consumers end-to-end (US-039/085: 0/3, 0/4); suspended-user status defined but never enforced per-request (see §5-S3); custom-role tables exist but the Authz engine never reads them (US-048/049 — "decoy feature").

**Search & Discovery / Wiki** — wiki creation/comments/reactions solid; body search & ranking missing (US-071: 1/3); attachments are metadata-only records with no upload (US-075: 0/3).

**Security cluster** — essentially greenfield: artifact secret-leak scanning (0/6), review/artifact ACLs (0/6), KB encryption (0/6 — zero cipher code in either codebase), security dashboard (0/6 — no violation data source). Root blocker: ToolGuard ships in `:shadow` mode and **no domain tool declares `authz:` metadata**, so nothing is enforced anywhere; identity on many writes is caller-supplied labels, not server-resolved principal.

**Scale epic** — board pagination and chat virtualization unimplemented; both surfaces fetch-and-render unbounded lists; backend cursor paging exists but no client uses it (US-096/097: 0/4).

**Validation/test-suite stories (US-104–110, US-119–120)** — partially re-baselined: tools + tests exist for core CRUD, but coverage claims are stale snapshots, no coverage gate exists in pyproject/CI, executor/fabric have zero tests, and the skill validator/evaluator cover a single file — the SKILL-GUIDELINE directory conventions (EVAL/, FINE-TUNE/, MULTI-SHOT/, Phoenix) are 0%.

**Accessibility & i18n** — greenfield in the frontend: no theme switching (US-094: 0/4), no focus management/keyboard board nav (US-091kb: 0/4), no dashboard live-region strategy (US-092sr), no RTL/i18n search handling (US-093ne).

**Performance & Edge** — memory-recall latency bounding has real ANN + fanout caps but no benchmark/p95 gate (US-098: 2/4); browser timeout/retry has timeouts but zero retry/backoff (US-052); queue rate-limit/bulk generation unimplemented (US-099: 0/4 — Oban present but unused).

**New: VFS (US-301–307)** — consumer works; token lifecycle, scope enforcement, wire-level write testing, mount conformance registry, and docs (US-307: 0/5) are partial. Premise corrections needed (see §7).

**New: Database Access Services (US-401–407)** — greenfield by design, reviewed with precise groundwork evidence: no RLS anywhere (US-403), metering decorator stores literal arguments so naive reuse leaks SQL into telemetry and fails open (US-407), no pgvector store exists (US-406 — see open decision §8).

---

## 4. Not Implemented (major greenfield cohorts)

| Cohort | Stories | Note |
|---|---|---|
| Creative/Campaigns epic | US-029–031 ad/landing, US-030/031 variants | zero code |
| Personas & Memory epic | US-022-register, US-023-journal, US-024-KB, US-025/026-valence | no agent-identity primitive |
| Coordination epic | US-051-worklog, US-053-alerting, US-054-capture, US-057-replay, US-058-consensus, US-060-cross-validate, US-061-negotiate, US-062-trees, US-064-handoff | no worklog/DAG/replay infra in either codebase |
| Security cluster | US-071-secrets, US-074-encrypt, US-075-review-ACL, US-076-dashboard, US-070-audit | no cross-cutting audit system exists |
| Governance/PM admin | US-048/049 custom roles, US-054-suspend, US-088-archived | data model exists, enforcement absent |
| Sprint/quality metrics | US-033-sprint (0/32), US-037-quality (0/16–17) | no agent/human attribution anywhere to build on |
| DB access services | US-401–405, US-407 | greenfield by design (this review cycle) |
| Test-executor suites | US-100-executor (0/7) | highest-risk untested surface |

---

## 5. Cross-Cutting Gaps

### Security (ticket-worthy)
- **S1 — Unscoped session contents** 🐛🔒: `session_get_contents` (`src/npl_mcp/sessions/sessions.py:231-245`) returns ALL rooms/artifacts db-wide; no session filter, no authz. Cross-session data leak.
- **S2 — VFS token lifecycle** 🔒 [Elixir]: claims bind once at `vfs/auth`, never re-verified — expiry/revocation don't affect open sockets; re-auth is rejected while old claims continue.
- **S3 — Suspension not enforced** 🔒 [Elixir]: `:suspended` enum + SSO active-gate exist, but Guardian/MCP-key/OAuth request paths never check status — suspended users' existing keys keep working.
- **S4 — Invite cap race** 🔒 [Elixir]: `increment_invite_uses` has no in-transaction cap recheck.
- **S5 — Persona KB privacy hole** 🔒 [Elixir]: UUID lookup bypasses persona scoping (`personas.ex:128-137`).
- **S6 — Write-orphaned tables** 🐛: nothing INSERTs into `npl_task_events` or `npl_chat_notifications` (Python) — Notifications and Feed tools are readers over permanently-empty tables.
- **S7 — Plaintext persona API-key vault** [Elixir]: no encryption, no get_secret tool, no rotation/admin surface (US-077-vault: 2/7).
- **S8 — Spoofable rate-limit key** [Elixir]: plug trusts first `x-forwarded-for` hop.
- **S9 — Metering leaks arguments** 🔒: `npl_tool_calls` stores literal args (truncated 4096) and swallows DB errors — fail-open where DB-access stories demand fail-closed.
- **S10 — Authz enforcement absent** ⚠️: ToolGuard `:shadow` default; no tool declares `authz:`; several tools (DefinitionCreate, QueueFeed, TicketLinkEntity, chat sends) run zero role checks; identity is caller-asserted on wiki/chat/review writes.

### Architecture / correctness
- **A1 — Stub-vs-real collision** 🚀: `stub_catalog.py` advertises ~15 tools (browser scroll/text/evaluate/cookies, add_task_message, notifications, pm_tools, screenshot tools) that are either implemented-but-unexposed (`browser/interact.py`) or pure stubs — ToolSearch misleads agents.
- **A2 — pm_tools fully built, stub-registered** 🚀: all file-based PM tools implemented + tested in `src/npl_mcp/pm_tools/` but return `{"status":"stub"}` via ToolCall (`launcher.py:434-438`). Wiring them flips US-226–232 for free.
- **A3 — Dead lifecycle code** 🐛: `start_lifecycle_monitor()` never called — tasker nag/timeout logic inert (US-111).
- **A4 — Split-brain surfaces** ⚠️: core `Ticket.Update` lacks stage/iteration params that HTTP/VFS accept; Python chat/artifacts unscoped vs Elixir scoped/threaded; two disconnected review systems.
- **A5 — Resolver schema mismatch** ⚠️: components keyed on `slug:` but 5 of 8 `conventions/*.yaml` have `name:` only — **CLAUDE.md's own NPLLoad examples raise NPLResolveError**.
- **A6 — Error-code collapse** [Elixir]: all auth failures collapse to generic `:invalid_token` (expired/revoked indistinguishable; `dual_token_verifier.ex:93`); chat/task invalid IDs surface as raw FK exceptions.
- **A7 — Silent failure modes**: Jina conversion failures return `success:true` with empty content; `Review.Compile`-style re-completion overwrites verdicts with no status guard; profile PATCH uses `Repo.update_all` bypassing changeset validation; `web_to_md` timeout param discarded.
- **A8 — No coverage tooling**: no pytest-cov/vitest/coverage gate anywhere; all story coverage targets unmeasurable.
- **A9 — No attribution**: no agent/human identity on task events, artifact revisions, sprint metrics — blocks the entire metrics epic.

### Story drift (re-baseline before implementing)
- **D1**: stories cite `worktrees/main/mcp-server/`, `unified.py`, SQLite, `.npl/logs/*.jsonl` — all gone; storage is Postgres/asyncpg + Ecto/Liquibase. Affects US-038-migrations, US-045/046 db/storage, US-055-migration, US-073-RLS (SQLite premise), US-104–110 cohorts.
- **D2**: some "✅ Implemented" self-claims in story files are wrong (stub tools); some "not exposed" claims are wrong (tools are registered — e.g. US-094-taskers, US-095-fabric).
- **D3**: duplicate IDs across cohorts (US-001–048 two files each; US-063–070 pairs; US-071–076 wiki+security pairs) — traceability tooling will collide.
- **D4**: `index.yaml` covers 118 entries (incl. the new epics) vs 265 story files on disk — stale beyond the new additions.
- **D5**: CLAUDE.md says yq v3.4.3; installed is v4.53.3 (temp-file pattern still valid).
- **D6**: `npl-tdd-coder`/`npl-tdd-debugger` reference `mise run test-failures`, undefined in `.mise.toml`.

---

## 6. Todos — recommended remediation order

**Wave 1 — cheap, high-yield (days)**
1. Fix `session_get_contents` scoping (S1) + add authz to Sessions tools.
2. Wire `pm_tools` out of the stub catalog (A2); register real browser interact tools; prune or implement stub-catalog entries (A1).
3. Call `start_lifecycle_monitor()` (A3); wire task-event/notification producers into existing mutations (S6).
4. Resolver slug/name fallback (A5); document in CLAUDE.md; fix yq version note (D5); add `mise run test-failures` or update agent docs (D6).
5. Distinct auth error codes (`token_expired`, `key_revoked`) in the transport plug (A6) — fixes US-083/084 in one stroke.

**Wave 2 — enforcement & lifecycle (1–2 weeks)**
6. ToolGuard rollout: flip shadow→enforce per domain, add `authz:` metadata to all tools, server-resolve principal on writes (S10).
7. Token lifecycle: re-verify VFS claims per-op or on interval; scoped `vfs/subscribe`; wire-level write conformance test (US-302–305).
8. Invite redemption flow end-to-end + in-transaction cap recheck (US-039/085, S4); per-request suspension check (S3); KB persona scoping fix (S5).
9. Producers for feeds/notifications; task pick/claim with atomicity; assignment updates.
10. Intro coverage tooling + CI gate; re-baseline the test-suite stories (US-104–110) against real inventories.

**Wave 3 — structural (planned work)**
11. Org/project scoping on Python sessions schema (US-003/004 cohort) or consolidate on Elixir surface.
12. Security cluster build-out (secret scanning, artifact ACLs, KB encryption, audit system) — sequence after ToolGuard enforcement.
13. Attribution model (agent/human identity on events) → unblocks sprint/quality metrics epics.
14. Scale: adopt backend cursor paging in board/chat clients.
15. Story re-baseline sweep (D1/D2): rewrite stale-premise stories before any implementation sprint; reindex `index.yaml` to all 265 files (D4).

**Open product decisions (see §8)** before US-406 and US-303–305 revisions.

---

## 7. New stories added this cycle

- **US-301–307 Virtual File System** [Elixir] — consumer (4/4, implemented), auth lifecycle, scope enforcement, write-path activation, pubsub notifications, mount conformance, docs. Reviews found the write-path premise stale (mounts already have gated writes — only wire-level testing is missing) and two security gaps (§5-S2, unscoped subscribe).
- **US-401–407 Database Access Services** — read-only SQL tool, schema introspection, tenant scoping (no RLS groundwork exists), Infisical least-privilege creds, approval-gated writes, pgvector search (⚠️ premise conflict — §8), audit/observability (⚠️ metering hazard — §5-S9). Greenfield; reviews carry the BDD groundwork.

## 8. Open decisions

1. **US-406 pgvector vs Weaviate**: memory vectors are Weaviate-backed with an explicit "no pgvector fallback" (`domains/memory/vector_store.ex`). Recommend re-scoping US-406 to formalize the existing Weaviate-backed recall tools; building pgvector creates a second store to keep in sync.
2. **US-303 scope model**: authorization is a group-gate cascade (EffectiveToolset), not literal `vfs/read|vfs/write` scope strings (zero hits in code), and denials deliberately don't name the missing scope (existence-leak protection) — story AC2 needs a rewrite either way.
3. **US-047 key-prefix case**: story demands lowercase-friendly prefixes; schema mandates `^[A-Z0-9]{2,16}$`. Pick one.

---

## Appendix — full per-story status table

Auto-extracted from all 265 review files in `project-management/reviews/` (story id, slug, status, criteria met; "P partial" = partially-met criteria count).
| Story | Title/Slug | Status | Criteria Met |
|-------|-----------|--------|--------------|
| US-001 | Create a new work session scoped to an org/project | Partially Implemented | 0/4 met (1 partial) |
| US-001 | Load NPL Core Components | Partially Implemented | 3/6 met (2 partial) |
| US-002 | Load Project-Specific Context | Not Implemented | 0/8 met |
| US-002 | Resume an existing session and see its rooms/tickets/artifacts | Partially Implemented | 0/4 met (1 partial) |
| US-003 | Fetch Web Content as Markdown | Partially Implemented | 5/6 met (1 partial) |
| US-003 | Update a session's status/title/description as work evolves | Partially Implemented | 3/4 met |
| US-004 | List all sessions for a project, filtered by status | Partially Implemented | 2/4 met (1 partial) |
| US-004 | Share Artifact in Chat Room | Partially Implemented | 3/7 met (2 partial) |
| US-005 | Tailor a session's tool descriptions to the target model/runner | Not Implemented | 0/4 met |
| US-005 | View Session Dashboard | Partially Implemented | 3/11 met (2 partial) |
| US-006 | Create a ticket with a custom type and custom fields | Partially Implemented | 1/4 met (1 partial) |
| US-006 | Send Message to Chat Room | Implemented | 8/8 met |
| US-007 | Create Chat Room for Collaboration | Partially Implemented | 8/10 met (1 partial) |
| US-007 | Move a ticket across kanban board stages | Partially Implemented | 0/4 met (2 partial) |
| US-008 | Assign a sprint/iteration to a ticket | Partially Implemented | 2/4 met |
| US-008 | Create Versioned Artifact | Partially Implemented | 10/16 met (2 partial) |
| US-009 | Link two tickets together (blocks/relates-to) | Partially Implemented | 1/4 met (2 partial) |
| US-009 | Review Artifact Revision History | Partially Implemented | 9/13 met (2 partial) |
| US-010 | Add Inline Review Comment | Partially Implemented | 8/14 met (1 partial) |
| US-010 | Link a ticket to a non-ticket entity (polymorphic link) | Partially Implemented | 1/4 met (3 partial) |
| US-011 | Annotate Screenshot with Overlay | Partially Implemented | 6/8 met |
| US-011 | Define a custom ticket field scoped to a project | Partially Implemented | 2/4 met |
| US-012 | Capture Screenshot of Current Work | Partially Implemented | 5/9 met (3 partial) |
| US-012 | Define a custom ticket type scoped to an org | Partially Implemented | 2/4 met |
| US-013 | Compare Screenshots for Visual Regression | Partially Implemented | 2/9 met (4 partial) |
| US-013 | View a ticket queue's feed of recent activity | Not Implemented | 0/4 met |
| US-014 | Create a PRD ticket and link multiple user_story tickets to it | Partially Implemented | 1/4 met (2 partial) |
| US-014 | Pick Up Task from Queue | Partially Implemented | 4/7 met (2 partial) |
| US-015 | Create a chat room scoped to a session or project | Partially Implemented | 2/4 met (2 partial) |
| US-015 | View Task Queue Progress | Partially Implemented | 5/10 met (1 partial) |
| US-016 | Create Task in Queue | Partially Implemented | 5/11 met (3 partial) |
| US-016 | Send a message with a threaded reply | Partially Implemented | 1/4 met (1 partial) |
| US-017 | Link Artifact to Task | Partially Implemented | 9/16 met (3 partial) |
| US-017 | Pin an important message in a room | Not Implemented | 0/4 met |
| US-018 | Schedule a message to send later | Not Implemented | 0/4 met |
| US-018 | Update Task Status | Partially Implemented | 0/10 met (3 partial) |
| US-019 | Automate Form Submission | Partially Implemented | 2/10 met (2 partial) |
| US-019 | Mute a room or mute unless mentioned | Not Implemented | 0/4 met |
| US-020 | Quick Form Fill for Developers | Partially Implemented | 1/11 met (4 partial) |
| US-020 | React to and highlight a message | Partially Implemented | 2/4 met (1 partial) |
| US-021 | Browser Navigation | Partially Implemented | 2/5 met (2 partial) |
| US-021 | Receive Room Notification and Clear It | Implemented | 5/5 met |
| US-022 | Receive Notifications (Kinds, Filters, Aggregation) | Implemented | 4/5 met |
| US-022 | Register New Agent Persona with Bio | Partially Implemented | 3/4 met |
| US-023 | Add Journal Entry Documenting Completed Work | Partially Implemented | 2/4 met |
| US-023 | Complete Review | Partially Implemented | 2/5 met |
| US-024 | Add Knowledge Base Entry to Private KB | Partially Implemented | 4/5 met (1 partial) |
| US-024 | Manage Browser State | Partially Implemented | 1/2 met (1 partial) |
| US-025 | Explore Project Structure | Implemented | 4/4 met |
| US-025 | Recall Memory by Semantic Similarity | Implemented | 5/5 met |
| US-026 | Ask a Question on a Task | Not Implemented | 0/4 met |
| US-026 | Recall Memories by Emotional Valence or Signature | Partially Implemented | 2/4 met |
| US-027 | React to Chat Messages | Partially Implemented | 7/10 met |
| US-027 | Reinforce or de-emphasize a memory association | Not Implemented | 0/4 met |
| US-028 | Create Todo from Chat | Partially Implemented | 4/11 met (4 partial) |
| US-028 | Register an agent call sign and track agent state | Not Implemented | 0/4 met |
| US-029 | Create a Campaign with an Ad Group | Not Implemented | 0/3 met |
| US-029 | Inject Scripts and Styles | Not Implemented | 0/16 met |
| US-030 | Assign Task Complexity | Partially Implemented | 3/9 met (1 partial) |
| US-030 | Generate Ad Copy Variants for an Ad Group | Not Implemented | 0/3 met |
| US-031 | Approve or Reject a Generated Ad Copy Variant | Not Implemented | 0/3 met |
| US-031 | View Agent Work Logs | Not Implemented | 0/11 met |
| US-032 | Assign Tasks to Specific Agents | Partially Implemented | 0/10 met (3 partial) |
| US-032 | Generate a Landing Page Draft | Not Implemented | 0/3 met |
| US-033 | Monitor Sprint Progress with Agent Metrics | Partially Implemented | 0/32 met (2 partial) |
| US-033 | Track a Domain Name Against a Campaign | Implemented | 1/3 met (1 partial) |
| US-034 | Research Competitors for a Market Segment | Partially Implemented | 0/3 met (2 partial) |
| US-034 | Review Agent-Generated Code | Partially Implemented | 4/15 met (4 partial) |
| US-035 | Research and Track Keywords | Partially Implemented | 1/3 met (2 partial) |
| US-035 | Share Architectural Context with Agents | Partially Implemented | 3/13 met (2 partial) |
| US-036 | Generate a Creative Asset and Publish Its Active Output | Implemented | 2/3 met (1 partial) |
| US-036 | Pair Program via Chat Room | Partially Implemented | 4/10 met (3 partial) |
| US-037 | Register a New Organization | Implemented | 3/3 met |
| US-037 | Track Code Quality Metrics for Agent Output | Not Implemented | 0/17 met |
| US-038 | Apply Database Schema Migration | Not Implemented | 0/5 met (2 partial) |
| US-038 | Send an Invite Token with Expiry and Use Cap | Partially Implemented | 0/3 met (3 partial) |
| US-039 | Accept an Invite and Complete OIDC Login | Not Implemented | 0/3 met (1 partial) |
| US-039 | Backup and Restore Database | Not Implemented | 0/5 met |
| US-040 | Complete First-Time SSO Callback | Implemented | 4/4 met |
| US-040 | Monitor Database Health and Performance | Not Implemented | 0/5 met |
| US-041 | Prevent Concurrent Write Conflicts | Not Implemented | 0/4 met |
| US-041 | Self-Mint MCP API Key | Implemented | 5/5 met |
| US-042 | Audit Schema Version Compatibility | Not Implemented | 0/4 met |
| US-042 | Copy Claude `mcp add` Setup Command | Implemented | 4/4 met |
| US-043 | Export and Import Data Between Databases | Not Implemented | 0/4 met |
| US-043 | Mint MCP JWT from API Key | Implemented | 4/4 met |
| US-044 | Refresh Expiring Guardian JWT Pair | Partially Implemented | 3/5 met (1 partial) |
| US-044 | Validate Database Integrity | Not Implemented | 0/4 met |
| US-045 | Manage Multiple Database Instances | Not Implemented | 0/6 met (1 partial) |
| US-045 | Revoke a Lost or Leaked MCP API Key | Implemented | 2/3 met (1 partial) |
| US-046 | Optimize Database Storage | Not Implemented | 0/6 met |
| US-046 | View My Organizations After Login | Implemented | 3/3 met |
| US-047 | Update Organization Name and Key Prefix | Partially Implemented | 1/4 met (2 partial) |
| US-047 | View Database Schema Documentation | Partially Implemented | 2/6 met (3 partial) |
| US-048 | Define a Custom Role with Named Permissions | Partially Implemented | 1/4 met |
| US-048 | Real-Time Agent Workflow Failure Diagnostics | Not Implemented | 0/5 met |
| US-049 | Assign a Custom Role to a Member | Not Implemented | 0/3 met |
| US-049 | Structured Error Logging for MCP Tools | Partially Implemented | 0/6 met (5 partial) |
| US-050 | Agent Performance Metrics Dashboard | Partially Implemented | 0/6 met (2 partial) |
| US-050 | Apply an MCP Custom Scope to a Project | Partially Implemented | 3/4 met (1 partial) |
| US-051 | Configure Notification Preferences for a Room | Implemented | 3/3 met |
| US-051 | Worklog Error Propagation Protocol | Not Implemented | 0/6 met |
| US-052 | Browser Automation Timeout & Retry Handling | Partially Implemented | 0/6 met (3 partial) |
| US-052 | Update User Profile Details | Partially Implemented | 0/3 met (1 partial) |
| US-053 | Configure a Media-Provider API Key for an Org | Partially Implemented | 3/4 met |
| US-053 | Exception Alerting for Long-Running Processes | Not Implemented | 0/6 met |
| US-054 | Suspend a User Account | Partially Implemented | 0/4 met (2 partial) |
| US-054 | Test Execution Error Detail Capture | Not Implemented | 0/6 met |
| US-055 | Change a User's Global Role with Self-Lockout Guard | Partially Implemented | 1/4 met (1 partial) |
| US-055 | Database Migration Error Recovery | Not Implemented | 0/6 met |
| US-056 | List and Search All Organizations | Partially Implemented | 2/3 met |
| US-056 | Token Usage Tracking and Budget Alerts | Not Implemented | 0/6 met |
| US-057 | Add and Live-Test an LLM Model Provider | Partially Implemented | 0/4 met (2 partial) |
| US-057 | Cross-Agent Debugging Session Replay | Not Implemented | 0/6 met |
| US-058 | Create and Curate a Global MCP Custom-Scope Preset | Implemented | 3/4 met (1 partial) |
| US-058 | Facilitate Multi-Persona Consensus | Not Implemented | 0/6 met (1 partial) |
| US-059 | Chain Multi-Agent Workflows with Dependencies | Partially Implemented | 1/6 met (2 partial) |
| US-059 | Review an MCP Overview Queue Item | Partially Implemented | 1/4 met (3 partial) |
| US-060 | Cross-Validate Agent Outputs | Not Implemented | 0/6 met |
| US-060 | Grant GitHub Token/Repo Access at the Org Level | Partially Implemented | 2/4 met (1 partial) |
| US-061 | Configure an Org-Level Media-Provider Config as Admin | Partially Implemented | 2/3 met |
| US-061 | Negotiate Resource Access Priority | Not Implemented | 0/6 met |
| US-062 | Check a PBAC Policy Decision with the Simulator | Partially Implemented | 0/3 met (2 partial) |
| US-062 | Visualize Multi-Agent Decision Trees | Not Implemented | 0/6 met |
| US-063 | Explain a PBAC Policy Denial | Partially Implemented | 2/3 met (1 partial) |
| US-063 | Multi-Perspective Artifact Review | Partially Implemented | 0/6 met (2 partial) |
| US-064 | Agent Handoff Protocol | Not Implemented | 0/6 met |
| US-064 | Audit MCP API Key Usage Across Organizations | Partially Implemented | 0/3 met (1 partial) |
| US-065 | List All Tools on an MCP Server | Implemented | 3/3 met |
| US-065 | Parallel Agent Synthesis | Not Implemented | 0/6 met |
| US-066 | Agent Quality Gates | Partially Implemented | 2/6 met (3 partial) |
| US-066 | Search Tools by Keyword | Implemented | 3/3 met |
| US-067 | Agent Reasoning Path Export | Not Implemented | 0/6 met |
| US-067 | Search Tools by Semantic Intent | Implemented | 3/3 met |
| US-068 | Define Artifact Access Control Policies | Partially Implemented | 0/5 met (2 partial) |
| US-068 | Get a Tool's Full Definition | Implemented | 2/3 met (1 partial) |
| US-069 | Get Contextual Help for a Tool | Partially Implemented | 0/3 met (1 partial) |
| US-069 | Implement Chat Room Role-Based Access | Partially Implemented | 0/6 met (3 partial) |
| US-070 | Generate Audit Logs for Sensitive Operations | Not Implemented | 0/6 met |
| US-070 | Search the NPL Glyph Codex | Implemented | 3/3 met |
| US-071 | Detect and Prevent Secret Leakage in Artifacts | Not Implemented | 0/6 met |
| US-071 | Search the Wiki by Keyword | Partially Implemented | 1/3 met (2 partial) |
| US-072 | Filter Tickets by Custom Field Values | Not Implemented | 0/4 met |
| US-072 | Implement Persona Permission Scopes | Partially Implemented | 0/7 met (5 partial) |
| US-073 | Create a Wiki Space and Page | Implemented | 3/3 met |
| US-073 | Enable Multi-User SQLite Access with Row-Level Security | Not Implemented | 0/6 met |
| US-074 | Comment on a Wiki Page | Partially Implemented | 2/3 met (1 partial) |
| US-074 | Encrypt Sensitive Persona Knowledge Bases | Not Implemented | 0/6 met |
| US-075 | Attach a File to a Wiki Page | Partially Implemented | 0/3 met (1 partial) |
| US-075 | Implement Review Access Control for Sensitive Artifacts | Not Implemented | 0/6 met |
| US-076 | Create Security Dashboard for Access Violations | Not Implemented | 0/6 met |
| US-076 | React to a Wiki Page or Comment | Partially Implemented | 2/3 met (1 partial) |
| US-077 | Create a Code Review with Overlay Comments | Partially Implemented | 2/4 met (1 partial) |
| US-077 | Manage API Key Vault for Personas | Partially Implemented | 1/7 met (1 partial) |
| US-078 | Compile a Review into a Final Verdict | Partially Implemented | 0/3 met (2 partial) |
| US-078 | Implement MCP Artifact Creation Tool | Implemented | 5/6 met (1 partial) |
| US-079 | Define Multi-Agent Orchestration Patterns | Partially Implemented | 0/7 met (5 partial) |
| US-079 | List GitHub Pull Requests for a Linked Repo | Implemented | 3/3 met |
| US-080 | Build NPL Syntax Parser | Partially Implemented | 1/7 met (2 partial) |
| US-080 | Comment on a GitHub Pull Request | Implemented | 3/3 met |
| US-081 | Follow a Pub/Sub Channel for Updates | Partially Implemented | 2/3 met (1 partial) |
| US-081 | Implement MCP Chat Room Management Tools | Partially Implemented | 0/7 met (4 partial) |
| US-082 | Implement MCP Task Queue System | Partially Implemented | 1/7 met (3 partial) |
| US-082 | Watch an Entity for Change Notifications | Partially Implemented | 2/4 met (2 partial) |
| US-083 | Implement Browser Automation Tools | Partially Implemented | 1/7 met (6 partial) |
| US-083 | Reject MCP Calls with an Expired JWT | Partially Implemented | 0/4 met (1 partial) |
| US-084 | Create Agent Definition System | Partially Implemented | 0/7 met (3 partial) |
| US-084 | Reject MCP Calls Using a Revoked API Key | Partially Implemented | 1/4 met (1 partial) |
| US-085 | Implement CLI Utilities (npl-load, npl-persona, npl-session) | Partially Implemented | 0/7 met (5 partial) |
| US-085 | Block Registration on Expired or Exhausted Invite Tokens | Not Implemented | 0/4 met |
| US-086 | Extract and Load 45 Agent Specifications | Partially Implemented | 0/7 met (3 partial) |
| US-086 | Log tool_guard Identity Mismatches in Shadow Mode | Partially Implemented | 1/4 met (2 partial) |
| US-087 | Build NPL Syntax Pattern Library (155 elements) | Partially Implemented | 0/7 met (2 partial) |
| US-087 | Rate-Limit the Unauthenticated Token-Mint Endpoint | Partially Implemented | 3/4 met |
| US-088 | Fall Back to Read-Only When Operating on an Archived Project | Not Implemented | 0/4 met |
| US-088 | Implement Session Management with Worklogs | Partially Implemented | 0/7 met (2 partial) |
| US-089 | Build Multi-Perspective Artifact Review System | Partially Implemented | 0/7 met (4 partial) |
| US-089 | Handle Orphaned Polymorphic Ticket Links Gracefully | Not Implemented | 0/4 met (1 partial) |
| US-090 | Create Agent Handoff Protocol | Not Implemented | 0/7 met |
| US-090 | Quarantine Flagged Content at Memory Ingest | Partially Implemented | 2/4 met |
| US-091 | Extract Web Content Programmatically | Partially Implemented | 0/7 met (7 partial) |
| US-091 | Full Keyboard Navigation of the Ticket Board | Not Implemented | 0/4 met |
| US-092 | Manage Browser Cookies and Storage | Partially Implemented | 0/7 met (7 partial) |
| US-092 | Announce Dashboard State Changes to Screen Readers | Partially Implemented | 0/4 met (1 partial) |
| US-093 | Inject Scripts and Styles Into Pages | Partially Implemented | 0/6 met (6 partial) |
| US-093 | Render Non-English Content Correctly in Wiki and Tickets | Partially Implemented | 0/4 met (2 partial) |
| US-094 | Switch to the High-Contrast Nocturne Theme | Not Implemented | 0/4 met |
| US-094 | Spawn Ephemeral Tasker Agents | Implemented | 7/8 met (1 partial) |
| US-095 | Analyze Output with Fabric Patterns | Implemented | 7/7 met |
| US-095 | Respect prefers-reduced-motion in Chat and Board Animations | Partially Implemented | 1/4 met (2 partial) |
| US-096 | Convert Web Pages to Markdown | Partially Implemented | 5/7 met (2 partial) |
| US-096 | Paginate Large Ticket Boards Without a Full Reload | Not Implemented | 0/4 met |
| US-097 | Access Session Data via REST API | Implemented | 4/7 met (3 partial) |
| US-097 | Virtualize Chat Rooms with Thousands of Messages | Not Implemented | 0/4 met |
| US-098 | Add Browser Automation Test Suite | Partially Implemented | 0/8 met (2 partial) |
| US-098 | Bound Memory-Recall Latency as a Persona's Memory Store Grows | Partially Implemented | 1/4 met (3 partial) |
| US-099 | Add Web Interface Test Suite | Partially Implemented | 1/7 met (5 partial) |
| US-099 | Queue and Rate-Limit Bulk Creative-Asset Generation | Not Implemented | 0/4 met |
| US-100 | Add Executor System Test Suite | Not Implemented | 0/7 met |
| US-100 | Connect a GitHub Repository and Set Its Default ACL | Partially Implemented | 2/4 met (1 partial) |
| US-101 | Create a Pull Request from Within the Platform | Partially Implemented | 1/4 met (2 partial) |
| US-101 | Expose Executor Spawn Tool | Partially Implemented | 2/6 met (2 partial) |
| US-102 | Expose Executor Lifecycle Tools | Partially Implemented | 4/6 met (1 partial) |
| US-102 | Open a Remote-Access Tunnel to a Local Dev Server | Implemented | 4/4 met |
| US-103 | Expose Fabric Pattern Tools | Partially Implemented | 0/4 met (2 partial) |
| US-103 | Build a Mock MCP Server from a Prose Description | Implemented | 4/4 met |
| US-104 | Receive an Outbound Webhook on Ticket State Change | Partially Implemented | 1/4 met (1 partial) |
| US-104 | Validate Artifact Management Implementation | Partially Implemented | 1/7 met (4 partial) |
| US-105 | Validate Chat System Implementation | Partially Implemented | 0/7 met (5 partial) |
| US-106 | Validate Task Queue Implementation | Partially Implemented | 1/7 met (6 partial) |
| US-107 | Validate Browser Automation Implementation | Partially Implemented | 1/7 met (4 partial) |
| US-108 | Validate Web Interface Implementation | Partially Implemented | 2/7 met (2 partial) |
| US-109 | Add Session Management Test Suite (0% → 80%) | Partially Implemented | 1/7 met (3 partial) |
| US-110 | Add Task Queue Test Suite (0% → 80%) | Partially Implemented | 0/7 met (2 partial) |
| US-111 | Ephemeral Tasker Lifecycle Management | Partially Implemented | 4/6 met (2 partial) |
| US-112 | Fabric CLI Integration | Implemented | 5/5 met |
| US-113 | MCP Tool Exposure for Taskers | Implemented | 5/6 met (1 partial) |
| US-114 | MCP Artifact Management Tools | Implemented | 5/6 met (1 partial) |
| US-115 | MCP Chat Collaboration Tools | Partially Implemented | 2/7 met (5 partial) |
| US-116 | MCP Task Queue Tools | Partially Implemented | 3/6 met (2 partial) |
| US-117 | MCP Browser Automation Tools | Implemented | 5/6 met (1 partial) |
| US-118 | MCP Cross-Domain Integration Tools | Partially Implemented | 1/4 met (2 partial) |
| US-119 | Skill Structure Validator | Partially Implemented | 1/10 met (3 partial) |
| US-120 | Skill Quality Evaluator with Arize Phoenix | Partially Implemented | 2/10 met (2 partial) |
| US-201 | Load Directives Section with Priority Filtering | Partially Implemented | 0/5 met (3 partial) |
| US-202 | Load Fences Section with All Layout Strategies | Partially Implemented | 5/6 met |
| US-203 | Load Pumps Section with Complex Expressions | Partially Implemented | 3/6 met (2 partial) |
| US-204 | Cross-Section Loading with Additions and Subtractions | Partially Implemented | 3/6 met (3 partial) |
| US-205 | Generate Coverage Reports for All Loaded Components | Partially Implemented | 3/5 met (1 partial) |
| US-206 | Convert Documentation Sources to Markdown | Partially Implemented | 4/5 met (1 partial) |
| US-207 | Cache Converted Files with Hybrid Strategy | Implemented | 6/6 met |
| US-208 | Configure Cache Expiry for URL Caches | Partially Implemented | 2/6 met (3 partial) |
| US-209 | Filter Markdown by Heading Path | Partially Implemented | 6/7 met (1 partial) |
| US-210 | Filter Markdown by Heading Level Selectors | Partially Implemented | 3/6 met (1 partial) |
| US-211 | MCP Tools for Markdown Conversion and Viewing | Partially Implemented | 1/6 met (3 partial) |
| US-212 | Collapse Markdown Sections Below Depth Level | Partially Implemented | 3/7 met (4 partial) |
| US-213 | Combine Filtering and Collapsing in Pipeline | Partially Implemented | 3/7 met (1 partial) |
| US-214 | Markdown Output Format Options | Not Implemented | 0/7 met (3 partial) |
| US-220 | NPL Syntax Validation via CLI with Error Reporting | Not Implemented | 0/7 met |
| US-221 | Extract Metadata from Agent Definition Files | Partially Implemented | 1/7 met (3 partial) |
| US-222 | IDE Integration for NPL Syntax Highlighting | Partially Implemented | 2/7 met (4 partial) |
| US-223 | List All NPL Syntax Elements in Document | Not Implemented | 0/7 met (1 partial) |
| US-224 | Skip Already-Loaded Resources Using Flags | Partially Implemented | 1/7 met (1 partial) |
| US-225 | Cross-Agent Communication Through Shared Worklogs | Partially Implemented | 0/7 met (5 partial) |
| US-226 | Read User Story by ID | Partially Implemented | 7/7 met |
| US-227 | List and Filter User Stories | Partially Implemented | 9/9 met |
| US-228 | Read PRD Content by ID | Partially Implemented | 5/9 met (2 partial) |
| US-229 | Access PRD Functional Requirements | Partially Implemented | 6/8 met |
| US-230 | Access PRD Acceptance Tests | Partially Implemented | 7/9 met (2 partial) |
| US-231 | Update User Story Metadata | Partially Implemented | 10/11 met (1 partial) |
| US-232 | List and Access Personas | Partially Implemented | 9/9 met |
| US-301 | Operate platform data through the VFS file tree over the VFSWS transport | Implemented | 4/4 met |
| US-302 | Complete the vfs/auth handshake and token lifecycle including re-auth and revocation | Partially Implemented | 2/5 met (1 partial) |
| US-303 | Enforce per-operation vfs/read and vfs/write scope on every VFS operation | Partially Implemented | 2/5 met (2 partial) |
| US-304 | Activate the VFS write path for writable mounts | Partially Implemented | 1/5 met (2 partial) |
| US-305 | Receive VFS pubsub change notifications on an open VFSWS connection | Partially Implemented | 2/5 met (1 partial) |
| US-306 | Activate and conformance-test all per-domain VFS mounts | Partially Implemented | 0/5 met (3 partial) |
| US-307 | Document the VFS substrate in PROJ-ARCH, PROJ-LAYOUT, and PROJ-SCHEMA | Not Implemented | 0/5 met |
| US-401 | Query the platform database read-only through an MCP tool | Not Implemented | 0/5 met |
| US-402 | Introspect the Liquibase-managed schema from an MCP tool | Not Implemented | 0/4 met |
| US-403 | Scope DB tool results to the caller's org/project tenant | Not Implemented | 0/5 met |
| US-404 | Provision least-privilege scoped DB credentials via Infisical for DB-access services | Not Implemented | 0/5 met |
| US-405 | Gate database writes behind explicit approval | Not Implemented | 0/5 met |
| US-406 | Search knowledge and memory via pgvector similarity from MCP | Not Implemented | 0/5 met (3 partial) |
| US-407 | Audit DB tool queries and expose connection-pool observability | Partially Implemented | 0/5 met (1 partial) |
