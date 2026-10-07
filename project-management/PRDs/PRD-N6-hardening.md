# PRD-N6: Hardening, Docs & Live Verification

**Series**: NPL last-mile (N6 of 6) — see [INDEX-NPL.md](./INDEX-NPL.md)
**Repo**: `Portfolio/Apps/AI/NoizuPromptLingo` (anchors relative to `backend/`)
**Gates**: **N6a (SHORT SOAK)** runs BEFORE the hex publish — staging deployment of the integration branch against **lib `main` via the path dep** (Decision 5: the publish is irreversible; the soak is its gate). **N6b** runs after the N5 flip — staging → prod verification + permanent regression + docs.
**Branch**: `feat/n6-hardening` (post-flip, NPL `main`)
**Status**: Draft

---

## 1. Goal

1. **Permanent parity regression** — the R6 invariant ("manifest == served == catalog") guarded by CI forever, for scope AND set endpoints, via the lib `Toolset.catalog/3` path.
2. **Docs** — PROJ-SCHEMA (+summary) for `mcp_tool_sets`; PROJ-ARCH for the provider/resolver/gateway topology; CHANGELOG carrying BOTH wire deltas; verify the lib CHANGELOG 0.3.0 entry exists.
3. **Live checks 1-5** (staging → prod) closing the incident and proving every R2-R8 behavior on REAL traffic.
4. **Short-soak procedure (N6a)** — the repeatable pre-publish gate.
5. Known-hardening notes recorded (multi-node propagation, flag cleanup).

---

## 2. Decisions applied (INDEX-NPL §3)

- **Decision 5 (Q3 SHORT SOAK)**: live checks 1/3/5 run in STAGING against lib `main` via the path dep BEFORE the user-run `mix hex.publish` (2FA OTP — agents never publish).
- **Decision 3**: CHANGELOG documents both wire deltas (step-up envelope; dotted-alias retirement).
- **Decision 2**: zero-writes guard stays permanent (already CI since N2b; re-run in the regression suite here).
- Multi-node: `ToolsetCache.bump/0` is `:persistent_term` ⇒ node-local; cross-node refresh bounded by the 45s TTL (`toolset_cache.ex:82`); optional PubSub broadcast → bump on all nodes is RECORDED as optional hardening, not built in v1 (pubsub plane exists).

---

## 3. Permanent parity regression (N6b)

**FR-6-1** NEW `backend/test/noizu_prompt_lingua/mcp/parity_regression_test.exs` (supersedes the N1/N5 parity suites as the FOREVER test):

- For each fixture principal × {scope endpoint, set endpoint} × {session-domain server, `tobor_custom`}:
  `Session_Manifest.generate/2` `included: true` names == served `tools/list` names == `Toolset.catalog/3` entry names (via the resolver's toolset — D1's one-resolver proof) == `ToolSummary`/`ToolDefinition`/`Tools.Catalog` views (R6 triple).
- Includes ACL-denied and negotiation-gated tools: all four views agree (AP-14 continuous).
- Includes a rename + enum-prune set: all four views show the effective surface.
- Fails LOUDLY on drift; runs in the default CI lane (not tagged).

**FR-6-2** The regression suite asserts zero-writes (runs `zero_writes_guard_test.exs` logic or composes it) so the Decision-2 boundary stays audited in the same lane.

---

## 4. Docs (N6b)

**FR-6-3** `backend/docs/PROJ-SCHEMA.md` (+ `PROJ-SCHEMA.summary.md` if the summary file convention exists): `mcp_tool_sets` — columns, closed op vocabulary (with example jsonb from PRD-N2 §4.1), settings whitelist, org-wide slug namespace, FKs (`organizations`/`projects`/`groups`), expiry/active semantics, and the PERMANENT-disposition note (lib `noizu_mcp_toolset*` tables stay empty in NPL deployments).

**FR-6-4** `backend/docs/PROJ-ARCH.md`: the post-flip topology — every server through lib protocol defaults (`toolset:`/`principal:`/`providers:`/`toolset_cache:`), `ToolsetProvider`/`AclProvider` over NPL tables (grants weight 200 / ACL weight 300 / ToolGuard-as-policy-source), `PrincipalMapper` + `ToolsetResolver`, set gateway routes + `:tool_sets_enabled`, `Session_Manifest` over `permissions/3`, notify propagation (N1 context hooks as FINAL home).

**FR-6-5** NPL CHANGELOG: BOTH wire deltas verbatim (PRD-N5 §9) + flip summary + `:tool_sets_enabled` flag documentation.

**FR-6-6** Verify the lib CHANGELOG 0.3.0 entry exists and covers the public-surface summary (lib PRD-4 FR-4.12) — a checklist item, not an NPL file change (agents do NOT edit the lib in this phase without a separate approved task).

---

## 5. Live checks 1-5 (normative procedure — N6a subset, N6b full)

Each check: procedure, pass criteria, evidence recorded in the tobor session (e5532107-a380-4557-a05a-434b7b334361) + PR. Staging first, prod after flip. Agents use existing tooling (API calls via `req`/curl through the staging host, DC creds per repo rules); NO credential values printed.

**Check 1 — tobor-ce closure (R6).** For client `tobor-ce56171f6764`: initialize a session, run `Session_Manifest`; count == served `tools/list` count == `ToolSummary` view count; spot-check that client-narrowed tools (the 14) are exactly the served set. PASS: three counts equal; no over-report.
*(N6a: runs against the integration-branch staging build — closes the incident BEFORE publish.)*

**Check 2 — enum-prune e2e (R2).** Create a set (staging admin API) pruning an enum on a tickets tool (e.g. priority minus one value) + renaming one arg. `tools/list` shows the pruned enum; `tools/call` with the pruned value ⇒ invalid-args (identical to unknown-tool); with an allowed value ⇒ ok; renamed arg accepted only under its wire name. PASS: listing == enforcement.
*(N6b: prod re-run.)*

**Check 3 — live-edit rotation (R6).** Edit the set's config (toggle a tool). The NEXT `tools/list` on the live connection reflects the change — no reconnect; `notifications/tools/list_changed` observed (client-side or via a probe session). Multi-node note: allow ≤45s cross-node (TTL backstop). PASS: rotation without reconnect, bounded latency.
*(N6a: runs in staging — this is the provider-version rotation proof.)*

**Check 4 — group 404 no-leak (R3).** Group-scoped set: caller WITHOUT membership (and one with EXPIRED membership) ⇒ 404 identical to unknown-slug; member ⇒ serves. PASS: byte-identical 404 bodies.
*(N6b: staging + prod.)*

**Check 5 — legacy smoke (R7).** One of each: `/custom/:slug/mcp` scope serves; `/user/:slug/mcp` serves; bare `/mcp` aggregator serves; one existing API key lists+calls; one OAuth client lists+calls. PASS: all five, byte-compatible responses (R7 zero-delta), API-key step-up (if triggered) now speaking the NEW `forbidden`+elevation envelope — recorded as the accepted delta, not a failure.
*(N6a: runs in staging against the path-dep build — proves the legacy surface survives the new stack BEFORE the publish.)*

---

## 6. N6a — short-soak procedure (gate for the publish)

1. Deploy the integration branch to STAGING (existing CI lane; image from the branch), with lib `main` resolved via the path dep **baked into the build** (the dep is compile-time — CI builds the image from the branch, carrying lib main's code).
2. Set `:noizu_prompt_lingua, :tool_sets_enabled` true in staging config.
3. Run live checks **1, 3, 5** (Decision 5 subset) + the scoped conformance suites (`effective_toolset_matrix_conformance`, `client_toolsets_conformance`, `tool_sets_conformance`) against staging.
4. Soak window: minimum ONE full live-edit rotation cycle + one cross-node TTL window (≥45s) with no errors in staging logs (`[:noizu_mcp, :persistence, :error]`, D5 degradation warnings, 5xx on MCP routes — Monitor/log-grep for the duration; "short" = hours, not days).
5. Record results in the tobor session; report GO/NO-GO to the lead. GO ⇒ lead schedules the USER's `mix hex.publish`. NO-GO ⇒ fixes on the integration branch, re-soak.

**FR-6-7**: the soak report (checks run, evidence links, GO/NO-GO) exists in the session log BEFORE the publish; the publish step cites it.

---

## 7. N6b — post-flip hardening (gate for prod)

1. Flip merged to NPL `main`; staging rebuilt from `main` on hex `~> 0.3.0` (never the path dep).
2. Full live checks 1-5 in staging → prod.
3. `parity_regression_test.exs` merged + CI-wired (FR-6-1/6-2).
4. Docs merged (FR-6-3..6-5); lib CHANGELOG verified (FR-6-6).
5. Optional hardening DECISION (not implementation): PubSub broadcast → `ToolsetCache.bump/0` on all nodes (multi-node propagation below TTL bound) — recorded as a follow-up ticket with the design note; built only if the lead approves.
6. Flag lifecycle: `:tool_sets_enabled` stays as a kill-switch in prod (documented in PROJ-ARCH); revisit removal post-stabilization.

---

## 8. Acceptance criteria

**AC-N6-1** `parity_regression_test.exs` green in CI and covers the FR-6-1 matrix (scope + set × manifest/list/catalog/Catalog-tool views; ACL + negotiation cases; rename/prune case).

**AC-N6-2** Zero-writes composition green in the same lane.

**AC-N6-3** PROJ-SCHEMA/PROJ-ARCH/CHANGELOG merged; both wire deltas documented verbatim; lib CHANGELOG 0.3.0 existence verified (FR-6-6).

**AC-N6-4** N6a soak report exists with checks 1/3/5 evidence + GO (it precedes and gates the publish — FR-6-7).

**AC-N6-5** Checks 1-5 executed in staging AND prod post-flip, all PASS, evidence recorded; check 1 closes the `tobor-ce56171f6764` incident (counts equal).

**AC-N6-6** Legacy smoke (check 5) shows R7 zero-delta on all five surfaces, with the step-up envelope delta recorded as accepted.

**AC-N6-7** Follow-up ticket exists for the optional PubSub multi-node hardening (or the lead's explicit decline recorded).

---

## 9. Test plan

- `backend/test/noizu_prompt_lingua/mcp/parity_regression_test.exs` (NEW) — FR-6-1/6-2.
- Live-check harness: ad-hoc scripts/API calls executed via the delegated-tasker lane (not committed as tests); each check's commands + outputs land in the tobor session log and the N6 PR description.
- No new fixture servers — the regression composes the conformance-suite fixtures.

Run scoped: `mix test test/noizu_prompt_lingua/mcp/parity_regression_test.exs` (+ composed zero-writes).

---

## 10. Compat & rollback

- N6a touches NO production code (staging deployment of an existing branch); rollback = redeploy prior staging image.
- N6b is post-flip: docs + a CI test + live procedures. Rollback of the flip itself is PRD-N5 §8; N6 artifacts are inert.
- Live checks are read-only except check 2/3's staging set CRUD (created via the admin API, deactivated after evidence capture).

---

## 11. Out of scope

- Any lib change (freeze); new product features; the PubSub broadcast implementation (ticketed, not built); prod set-seeding beyond the checks' fixtures.

---

## 12. Open questions

1. **Soak duration** — Decision 5 fixes "short soak"; this PRD operationalizes it as one rotation cycle + one TTL window with clean logs (hours). If the lead wants a fixed calendar window (e.g. 24h), amend FR-6-7 before the soak starts.
2. **Prod set fixtures** — check 2/3 create a THROWAWAY set in prod for evidence; confirm the lead is fine with a visible-but-inactive test set, or run 2/3 in staging only and record staging evidence as sufficient for the prod gate.
3. **Check-5 step-up capture** — observing the NEW envelope on the legacy API-key path requires a destructive scope-gated tool call in staging; confirm a safe candidate tool (one whose elevation flow is harmless in staging).

---

## 13. File change map

| File | Change |
|---|---|
| `backend/test/noizu_prompt_lingua/mcp/parity_regression_test.exs` | NEW (FR-6-1) |
| `backend/docs/PROJ-SCHEMA.md` (+summary) | mcp_tool_sets section (FR-6-3) |
| `backend/docs/PROJ-ARCH.md` | post-flip topology (FR-6-4) |
| NPL CHANGELOG | wire deltas + flip summary (FR-6-5) |
| tobor session log | soak + live-check evidence (FR-6-7, AC-N6-4/5) |
