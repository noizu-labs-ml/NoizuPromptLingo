# State Matrix — NPL App UX Overhaul

How to read this: one table per screen, one row per applicable state. **Matrix before layout** — no screen in §1 or §2 gets a layout until every row below has a decision or an explicit n/a. "Announce" is the `aria-live` (or `role="alert"`) text a screen-reader user gets; `—` means no announcement is warranted for that state. Rows that don't apply to a screen are omitted from its table and the reason is given in one word directly under the table heading. Shared rendering rules (skeleton shape, empty-state anatomy, permission copy) live in `UX-PLAN.md` §5 — this file is the per-screen application of that contract, not a restatement of it.

---

## 1. New screens (48–74)

### 48 · Notification inbox
*n/a: long-running (list, not a job)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter, no cache | `SkeletonTable` (avatar + 2-line rows × 8) | — | — |
| refresh | background poll / channel push | existing rows stay, 2px progress bar under `PageHeader` | — | — |
| empty-first-run | 0 notifications ever | "Nothing here yet" + explainer of what triggers a notification | none (system-generated only) | — |
| empty-filtered | filter=unread/mentions returns 0 | "No unread notifications" + active filter chip | Clear filter | "0 results" |
| error-recoverable | fetch 5xx/timeout | inline `role="alert"` card in list region, chrome (filters, bell) stays live | Retry | (assertive) "Couldn't load notifications" |
| error-fatal | n/a | — | — | n/a: list fetch is never app-fatal |
| permission-role | n/a | — | — | n/a: every member has an inbox |
| permission-scope | n/a | — | — | n/a: no scoped sub-actions |
| offline/stale | S6 producers absent (feature-flagged) or connection lost | banner: "Notifications are in preview — some events aren't wired up yet" (flag) / offline banner (real) | Dismiss (flag) / Retry (offline) | — |
| live-update | new notification arrives via channel | new row inserts at top, unread dot, bell badge increments | Show / mark read | (polite) "1 new notification" |

### 49 · Activity feed (project/board/ticket scope)
*n/a: permission-scope (feed inherits parent object's ACL, no sub-scope actions)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route/scope enter | `SkeletonList` (timeline dots + 2-line rows × 6) | — | — |
| refresh | poll/channel | existing entries stay, "Updated Xs ago" + manual Refresh | Refresh | — |
| empty-first-run | scope has zero activity ever | "No activity yet in {scope}" + explainer | none | — |
| empty-filtered | `?scope=` narrows to 0 | "No activity for this scope" + clear-scope link | Clear scope | "0 results" |
| error-recoverable | fetch failure | inline error card replacing feed region, header/scope-picker stay live | Retry | (assertive) "Couldn't load activity" |
| error-fatal | n/a | — | — | n/a |
| permission-role | viewer role, scope not visible to them | `PermissionState` inline (whole feed hidden, not per-row) | Request access / Back | — |
| offline/stale | S6 producers absent (flag) | same preview banner as 48 | Dismiss | — |
| long-running | n/a | — | — | n/a: reads only |
| live-update | new event lands in scope | day-grouped timeline gets new row, subtle highlight fades after 3s | — | (polite) "New activity: {actor} {verb} {object}" |

### 50 · Command palette
*n/a: refresh, empty-filtered-vs-first-run distinction (single query box), offline/stale, error-fatal, long-running (client-only, instant)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | `⌘K` opens, no query yet | recent actions + navigation shortlist (client cache) | — | focus moves to input |
| empty-filtered | query matches 0 actions/destinations | "No matches for \"{query}\"" + link to full search (screen 51) | Open in Search | (polite) "0 results" |
| error-recoverable | a provider registry entry throws while contributing actions | that provider's section silently drops (never blocks the palette) | — | — |
| permission-role | query matches an action the user's role can't run | entry omitted from results entirely (never shown-then-denied) | — | — |
| live-update | new items typed | result list re-ranks | — | debounced 500ms: "{N} results" |

### 51 · Global search results
*n/a: long-running*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | `/` submit or palette hand-off | `SkeletonList` grouped by result type (4 groups × 2 rows) | — | — |
| refresh | user edits query | previous results stay dimmed 0%(full opacity kept), new results replace on completion | — | — |
| empty-first-run | n/a | — | — | n/a: search always has a query |
| empty-filtered | query returns 0 across all federated sources | "No results for \"{query}\"" + per-source note (e.g. "wiki body search not yet indexed") | Try a different term | "0 results for {query}" |
| error-recoverable | one federated source fails (e.g. wiki index down), others succeed | that group shows a scoped inline error, other groups render normally | Retry that source | (assertive) "Couldn't search wiki" |
| error-fatal | all sources fail | full-region error, search box stays live | Retry | (assertive) "Search is unavailable" |
| permission-role | result belongs to an object outside the user's org/role | omitted from results, not shown-then-403 | — | — |
| offline/stale | connection lost mid-search | banner + last-good results marked stale | Retry | — |
| live-update | n/a | — | — | n/a: point-in-time query |

### 52 · VFS mount picker + auth state
| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonGrid` of mount cards (icon + 2 lines × 4) | — | — |
| refresh | n/a | mounts rarely change mid-session | — | n/a |
| empty-first-run | org has 0 mounts configured | "No VFS mounts yet" + explainer of what a mount is | Add mount (admin) / Ask an admin (member) | — |
| empty-filtered | n/a | — | — | n/a: no filter UI |
| error-recoverable | mount list fetch fails | inline error, retry | Retry | (assertive) "Couldn't load mounts" |
| permission-role | member with no group-gate on any mount | `PermissionState`: "No mounts are shared with your groups" | Request access | — |
| permission-scope | token expired for a specific mount | that mount card shows "Re-authenticate" badge instead of "Open"; other cards stay openable | Re-authenticate | — |
| offline/stale | n/a | — | — | n/a: static list, no staleness concept |
| live-update | admin adds a mount while picker is open | new card fades in | — | (polite) "New mount available: {name}" |

### 53 · VFS file tree browser
*n/a: empty-filtered (tree filter narrows visually, doesn't blank the panel)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | mount opened | `SkeletonTree` (indented bars, 3 levels) in tree pane; inspector empty | — | — |
| refresh | directory re-fetched (stale cache) | tree stays, changed node gets a subtle pulse | — | — |
| empty-first-run | mount root has 0 files | "This mount is empty" in tree pane, inspector shows mount docs link | Open mount docs (56) | — |
| error-recoverable | directory listing fails for one node | that node shows an inline retry icon, rest of tree unaffected | Retry node | (assertive) "Couldn't load {folder}" |
| permission-scope | node exists but group-gate denies read | node renders greyed with a lock icon, tooltip "Not shared with your groups" (never names the missing group) | — (no click target) | — |
| offline/stale | channel disconnects | banner: "Live updates paused — reconnecting" over tree pane | — | — |
| long-running | large directory (>2000 nodes) still paginating | "Loading more files…" row at tree bottom, load-more fallback | Load more | — |
| live-update | see 55 (badges) | — | — | see 55 |

### 54 · VFS editor (create/edit/delete)
*n/a: empty-first-run/empty-filtered (editor always has a target file)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | file opened | skeleton lines matching editor chrome, Monaco mounts async | — | — |
| refresh | file changed on disk by another writer while open | conflict banner: "This file was updated by {actor}. Reload / Keep mine" | Reload / Keep mine | (assertive) "File changed on disk" |
| error-recoverable | save fails (network) | inline banner above editor, content preserved, dirty flag stays set | Retry save | (assertive) "Couldn't save {file}" |
| error-fatal | file deleted server-side while open | full-pane "This file no longer exists" | Back to tree / Recreate | (assertive) |
| permission-scope | group-gate denies write on this path | editor opens read-only, toolbar write actions disabled with generic tooltip "You can't edit here" | — | — |
| saving | explicit save (⌘S) | Save button loading state, editor stays interactive | Cancel if abortable | — |
| long-running | large file diff/save > 5s | progress bar in editor toolbar | Cancel | — |
| live-update | n/a (own edit session) | — | — | n/a |

### 55 · VFS live-update badges
*n/a: first-load/refresh/error-fatal (badge layer, not a route — it decorates 53)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| error-recoverable | Phoenix channel drops | badge layer freezes, tree pane shows "Live updates paused" banner (same as 53 offline) | — | — |
| permission-scope | update event for a node the viewer can't read | event dropped client-side, no badge rendered | — | — |
| live-update | another writer creates/edits/deletes a node in view | badge on the row ("edited 2s ago" / new-file dot), auto-clears after 10s or on focus | — | (polite, only if tree pane focused) "{file} updated by {actor}" |

### 56 · VFS mount docs panel
*n/a: refresh, permission-scope (docs are mount-level, not path-gated), offline/stale, long-running, live-update*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | drawer opens from mount picker | skeleton paragraph blocks | — | drawer opens, focus moves to heading |
| empty-first-run | mount has no docs authored (M: backend missing) | "No documentation for this mount yet" + "Ask an admin to add usage notes" | Close | — |
| error-recoverable | docs fetch fails | inline error inside drawer, drawer chrome stays | Retry | (assertive) |
| permission-role | n/a — docs are readable by anyone who can see the mount | — | — | n/a |

### 57 · DB services index + tenant-scope chip
| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonTable` (service name + scope chip + 3 cols × 5 rows) | — | — |
| refresh | poll | rows stay, "Updated Xm ago" + Refresh | Refresh | — |
| empty-first-run | org has 0 DB services provisioned | "No database services yet" + explainer of what a service is | Add service (admin) / Ask an admin (member) | — |
| empty-filtered | search/filter narrows to 0 | "No services match these filters" | Clear filters | "0 results" |
| error-recoverable | list fetch fails | inline error, retry | Retry | (assertive) |
| permission-role | member with no DB scope at all | `PermissionState`: "No database services are shared with you" | Request access | — |
| permission-scope | service exists but this user's tenant scope excludes some tables | scope chip on the row reads "Restricted" with tooltip; row still openable into schema browser (57→58) filtered | — | — |
| live-update | admin provisions a new service | row fades in | — | (polite) "New service available: {name}" |

### 58 · DB schema browser
*n/a: empty-filtered (search narrows tree visually like 53)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | service opened | `SkeletonTree` (tables) + skeleton column grid | — | — |
| empty-first-run | service has 0 tables visible to this scope | "No tables visible in this scope" | Back to services | — |
| error-recoverable | schema introspection fails | inline error replacing column grid, table tree stays | Retry | (assertive) "Couldn't load schema for {table}" |
| permission-scope | table exists but tenant scope excludes it | table greyed with lock icon in tree, same generic-denial tooltip as 53 | — | — |
| offline/stale | schema cache older than TTL (e.g. 10 min, DDL may have changed) | "Schema last refreshed Xm ago" note + Refresh | Refresh | — |
| long-running | large schema (500+ tables) still loading | "Loading more tables…" at tree bottom | Load more | — |

### 59 · SQL query console
*n/a: empty-first-run/empty-filtered (console, not a list — see empty result set below is folded into error-recoverable's sibling "0 rows" which is populated-with-zero-rows, not an empty state)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | console opened | Monaco skeleton + empty results pane placeholder "Run a query to see results" | — | — |
| saving/running | Run clicked | Run button loading state, editor read-only during run, results pane shows spinner (< 5s expected) | Cancel | — |
| long-running | query still running past 5s | results pane: "query running 12s · Cancel", elapsed timer updates | Cancel | (polite, once at 10s) "Query still running" |
| error-recoverable | query errors (syntax, timeout, permission) | results pane shows the DB error message verbatim in a code block (not paraphrased — this is a technical audience) + line/col if available | Edit query | (assertive) "Query failed" |
| permission-scope | statement is a write (INSERT/UPDATE/DELETE/DDL) | Run button relabels "Submit for approval", results pane explains it routes to the approval queue (60) instead of executing | Submit for approval | — |
| offline/stale | connection to DB service lost mid-session | banner: "Lost connection to {service}. Reconnecting…" | Retry connection | — |
| live-update | n/a | — | — | n/a: single-user session |

### 60 · Write-approval queue
| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonList` master pane (2-line rows × 6) + empty detail pane | — | — |
| refresh | poll/channel | list stays, new items insert with highlight | — | — |
| empty-first-run | org has never had a write request | "No write requests yet" + explainer | none | — |
| empty-filtered | status filter (pending/approved/rejected) returns 0 | "No {status} requests" + clear filter | Clear filter | "0 results" |
| error-recoverable | approve/reject action fails | inline banner on the `ApprovalCard`, decision not applied, retry offered | Retry | (assertive) "Couldn't submit decision" |
| permission-role | member (not admin/owner) views queue | `PermissionState`: approvals require admin | Request access | — |
| long-running | diff preview still computing for a large statement | skeleton diff block in detail pane | — | — |
| live-update | new request submitted from console (59) while queue open | row inserts at top of pending list, badge on Data rail icon | Show | (polite) "1 new request · Show" |

### 61 · Vector search
*n/a: permission-scope (search is read-only across the whole recall index, no sub-scoping); gated entirely behind §8 D1 decision*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter, no query yet | search box + "Search your knowledge base" placeholder, no skeleton (nothing to fetch until query) | — | — |
| loading | query submitted | `SkeletonList` result cards (score bar + 2 lines × 5) | — | — |
| empty-filtered | query returns 0 above relevance threshold | "No results above the similarity threshold" + "Lower threshold" control | Lower threshold | "0 results" |
| error-recoverable | recall backend (Weaviate) unreachable | inline error, retry | Retry | (assertive) "Couldn't search" |
| permission-role | member with no memory/recall scope | `PermissionState` | Request access | — |
| offline/stale | n/a | — | — | n/a: point-in-time query, same as 51 |
| long-running | n/a | — | — | n/a: sub-second by design; if it isn't, treat as error |

### 62 · Query audit / pool dashboard
*n/a: empty-first-run (audit trail starts populated the moment any query runs; a truly empty org gets first-run copy explaining the feature once)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonTable` (timestamp/actor/statement/duration × 8) + skeleton pool gauge widgets | — | — |
| refresh | poll (pool metrics are near-live) | table rows stay + append; gauges update in place without flash | — | — |
| empty-first-run | zero queries ever run against this service | "No query activity yet" + link to console (59) | Open SQL console | — |
| empty-filtered | date-range/actor filter returns 0 | "No queries match these filters" | Clear filters | "0 results" |
| error-recoverable | one widget fails (e.g. pool gauge) while table succeeds | that widget shows a scoped inline error card, table renders normally | Retry widget | (assertive) "Couldn't load pool status" |
| permission-role | member without audit-view scope | `PermissionState` | Request access | — |
| permission-scope | args redacted per S9 policy | statement column shows "[redacted: bind params]" inline, not blank — never implies a fetch failure | — | — |
| live-update | new query lands | row appends at top with brief highlight | — | (polite) "New query logged" |

### 63 · DB credential provisioning (settings)
*n/a: refresh, offline/stale, live-update (settings form, single-writer, not a live surface)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonTable` of existing `SecretRow`s (name + masked value + 3 cols × 3) | — | — |
| empty-first-run | 0 credentials provisioned for this service | "No credentials yet" + explainer of reveal-once pattern | Provision credential | — |
| error-recoverable | list fetch fails | inline error, retry | Retry | (assertive) |
| error-fatal | provisioning succeeds server-side but the one-time reveal payload is lost (network drop mid-response) | full-region error: "Credential was created but couldn't be displayed. Rotate it to get a new value." | Rotate | (assertive) |
| permission-role | member (not admin/owner) | `PermissionState`: credential provisioning requires admin | Request access | — |
| saving | Provision clicked | button loading, form locked | — | — |
| long-running | n/a | — | — | n/a: provisioning is sub-second |

### 64 · Invite accept (OIDC + magic link)
*n/a: refresh, permission-scope, offline/stale, long-running, live-update (single-use, single-screen flow)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | `/invite/[token]` opened | skeleton card while token is validated | — | — |
| error-recoverable | token valid but the org is at seat cap (S4) | "This organization has reached its member limit" surfaced **before** the user picks a sign-in method, not after OIDC round-trip | Contact the org owner | (assertive) "This invite can't be completed right now" |
| error-fatal | token expired/already used/revoked | "This invite is no longer valid" + no retry (dead end by design) | Request a new invite | (assertive) |
| permission-role | n/a | — | — | n/a: pre-auth screen, no role yet | 
| saving | accept submitted (OIDC redirect or magic-link confirm) | button loading state | — | — |

### 65 · Suspended state page
*n/a: first-load skeleton (this page is a wall, not a fetch — it renders immediately from the suspended flag already known at redirect time), refresh, empty-*, error-recoverable, permission-role/scope, long-running, live-update — this screen has exactly one state*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| suspended (only state) | any authenticated request where membership.suspended = true | full-page block: "Your access to {org} is suspended" + contact path, no nav chrome, sign-out still available | Contact admin / Sign out | page title announces on load (standard route-change behavior, no live region needed) |

### 66 · Permission-denied inline state
*Component, not a route — every screen composes it. n/a: first-load/refresh/empty-*/offline (it IS the terminal state that pre-empts those, per precedence order in the states reference: permission → not-found → offline → error → empty → loading → populated)*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| permission-role | whole page denied by role | `PermissionState`: names the object, states the required role, shows current identity + switch-account link, per states.md §6.2 | Request access / Back | focus moves to the state heading on render |
| permission-scope | one action denied by group-gate/scope, rest of page usable | control rendered `aria-disabled` with tooltip; copy is generic ("You don't have access to this") and **never names the missing scope**, per UX-PLAN §8 D2 | — (tooltip only) | — |
| error-fatal | object genuinely doesn't exist (distinct from denied — never conflate 403 with 404) | separate `NotFoundState`, not this component | Back to list | focus moves to heading |

### 67 · Key vault (org settings)
*n/a: empty-filtered, offline/stale, long-running, live-update*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonTable` of `SecretRow`s (name, masked value, last-used, actions × 4) | — | — |
| refresh | last-used timestamps poll | rows stay, timestamps update silently (no flash, per rule: silent for unchanged data) | — | — |
| empty-first-run | 0 keys created | "No keys yet" + explainer of reveal-once pattern | Create key | — |
| error-recoverable | rotate/revoke fails | inline banner on that row, action not applied | Retry | (assertive) "Couldn't rotate {key name}" |
| permission-role | member (not admin/owner) | `PermissionState` | Request access | — |
| saving | rotate/revoke/create in flight | row shows inline spinner, action buttons disabled for that row only | — | — |
| destructive-confirm | revoke clicked | typed-confirm dialog (irreversible, external side effects — per undo-window rule this is the exception that needs a real confirm, not an undo toast) | Revoke / Cancel | — |

### 68 · Chat thread + pins + scheduled send + mute
*extends screen 23; only the additive states are listed — base send/receive states already exist in 23*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | thread panel opens | skeleton message bubbles in thread pane, parent message pinned at top | — | — |
| empty-first-run | thread has 0 replies yet | "No replies yet" + compose box focused | none (compose is the action) | — |
| error-recoverable | scheduled send fails to queue | inline banner in the schedule popover, draft preserved | Retry | (assertive) "Couldn't schedule message" |
| permission-scope | mute toggled on a room the user doesn't own but can act on | n/a — mute is always self-scoped, no denial case | — | — |
| saving | pin/unpin, mute toggle | optimistic (per optimistic-update rules: reversible, low-risk) — pin state flips immediately, rolls back with inline explanation on failure | Retry (only on rollback) | (assertive, on rollback only) "Couldn't pin message" |
| long-running | n/a | — | — | n/a: chat ops are sub-second |
| live-update | new reply in thread while open | bubble appends, auto-scroll if user was at bottom | — | (polite, only if thread panel focused) "New reply from {actor}" |

### 69 · Persona reinforcement + call-sign tracker
| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonTable`/timeline for reinforcement history + skeleton call-sign badge row | — | — |
| empty-first-run | persona has never been reinforced | "No reinforcement history yet" + explainer of what reinforcement does | Add reinforcement | — |
| empty-filtered | date-range filter on history returns 0 | "No reinforcement events in this range" | Clear range | "0 results" |
| error-recoverable | fetch fails | inline error, retry | Retry | (assertive) |
| permission-role | member without persona-edit scope | reinforcement history read-only visible; "Add reinforcement" hidden, not disabled (permanent-for-role → hide per states.md §6.1) | — | — |
| saving | reinforcement submitted | form locked, submit button loading | — | — |
| live-update | call-sign auto-updates from a triggering event elsewhere in the app | badge pulses once | — | (polite) "Call-sign updated: {sign}" |

### 70 · Campaign / ad-group builder + variant review + approve
| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | builder opened | wizard step skeleton (step rail + form skeleton) | — | — |
| empty-first-run | org has 0 campaigns | "No campaigns yet" on the landing list before entering the wizard | New campaign | — |
| error-recoverable | a wizard step's save-and-continue fails | inline banner at top of that step, entered data preserved, user stays on step | Retry | (assertive) "Couldn't save this step" |
| permission-role | member without campaign-create scope | `PermissionState` on the list; wizard route itself 403s if deep-linked | Request access | — |
| permission-scope | approve action on a variant, requester ≠ approver role | Approve button hidden for the requester's own submissions (self-approval blocked), shown for reviewers | — | — |
| saving | variant generation submitted | variant card shows generating state, rest of grid stays interactive | — | — |
| long-running | variant generation > 15s (media/creative gen) | moves to background per Long-Running rules: ack "Generating 4 variants…", status in a task tray, notification (48) on completion | — | (polite, on completion) "4 variants ready for review" |
| live-update | a co-reviewer approves/rejects a variant while this user has the review panel open | variant card badge updates, prevents duplicate approval attempts | — | (polite) "{actor} approved Variant B" |

### 71 · Bulk generation queue
| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | `SkeletonList` of job rows (status chip + progress + 2 lines × 6) | — | — |
| refresh | poll for in-flight jobs | rows stay, progress values update in place | — | — |
| empty-first-run | no jobs ever queued | "No generation jobs yet" + explainer | Start a bulk job | — |
| empty-filtered | status filter returns 0 | "No {status} jobs" | Clear filter | "0 results" |
| error-recoverable | a single job fails mid-batch (partial success) | that row shows "1,180 succeeded · 20 failed · Download error report", batch continues, other rows unaffected (per partial-failure rule, never take down siblings) | Download error report | (assertive, on completion) "Job finished with 20 failures" |
| permission-role | member without bulk-generation scope | `PermissionState` | Request access | — |
| long-running | job running > 15s | row shows determinate progress in domain units ("340 of 1,200 assets"), Cancel available, user can navigate away | Cancel | (polite, at 10s if still running) "Still generating" |
| live-update | job completes while queue open elsewhere | row status flips to terminal state with result summary | Open results | (polite) "Bulk job complete: {name}" |

### 72 · Accessibility & theme preferences
*n/a: empty-*, error-fatal, permission-scope, offline/stale, long-running, live-update — client-only settings form, single user*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | route enter | form renders immediately from persisted local prefs (no server round-trip needed for defaults) | — | — |
| error-recoverable | preference save to server fails (sync across devices) | inline banner: local change kept, "Couldn't sync to your account" | Retry | (assertive) |
| permission-role | n/a | — | — | n/a: every authenticated user owns their own prefs |
| saving | toggle changed | optimistic (per optimistic-update rule: reversible, near-zero failure) — applies instantly across the app | — | (polite) "Reduced motion enabled" |

### 73 · First-run checklist (org home empty state)
*n/a: empty-filtered, error-fatal, permission-scope, long-running — this IS the empty-first-run state of screen 17, broken out because it's structured (multi-step), not a generic EmptyState*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | org has 0 keys AND 0 MCP connections AND 0 sessions | 3-step checklist card: "Add a key" → "Connect MCP" → "Start your first session", each step's completion state checked live | Do the next incomplete step | — |
| empty-first-run | (same as first-load — this table's only populated state, the checklist itself is the empty-state content for screen 17) | see above | see above | — |
| error-recoverable | one step's completion check fails to fetch | that step shows "Couldn't check this step" inline, others unaffected | Retry | (assertive) |
| permission-role | member on a fresh org where they can't complete admin-only steps (e.g. key provisioning is admin-only) | that step shows "Ask an admin" instead of an action button | — | — |
| live-update | a step is completed (e.g. teammate connects MCP) while checklist is visible | that step flips to checked with a brief highlight; checklist auto-dismisses to normal dashboard once all steps complete | — | (polite) "Step complete: Connect MCP" |

### 74 · PBAC denial explainer (admin)
*n/a: empty-filtered, offline/stale, long-running, live-update*

| State | Trigger | What renders | Primary action | Announce |
|---|---|---|---|---|
| first-load | admin opens explainer for a specific denial | `SkeletonTree`/list of the evaluated policy chain | — | — |
| empty-first-run | n/a — always entered with a specific denial event to explain | — | — | n/a |
| error-recoverable | policy evaluation trace fetch fails | inline error, retry | Retry | (assertive) |
| error-fatal | the denial event referenced no longer exists (log rotated) | "This denial record is no longer available" | Back to AuthZ log | — |
| permission-role | non-platform-admin somehow reaches the route | full 403, not the inline `PermissionState` (this is a platform-admin-only surface, deep-link denial) | Back | — |

---

## 2. Existing screens — coverage gaps only

Verified by grepping each page for `loading`, `error`, `empty`, `403`/`effective_role`, `aria-live`, `Skeleton`. Listed below is only what's **absent**; anything not listed is already present in some form (may still need restyling onto the shared kit, but the state itself exists).

| # | Screen | File | Missing |
|---|---|---|---|
| 17 | Org dashboard | `frontend/src/app/app/[orgId]/page.tsx` (813 ln) | 403/permission-role, effective_role gating, `aria-live`, skeleton (loading is present but as text, not shape-matched) |
| 20 | Sessions list | `frontend/src/app/app/[orgId]/sessions/page.tsx` (225 ln) | 403/permission-role, effective_role, `aria-live`, skeleton |
| 21 | Session detail | `frontend/src/app/app/[orgId]/sessions/[id]/page.tsx` (64 ln) | **error state entirely**, **empty state entirely**, 403/permission-role, effective_role, `aria-live`, skeleton — only `loading` exists |
| 23 | Chat room | `frontend/src/app/app/[orgId]/chat/[roomId]/page.tsx` (524 ln) | 403/permission-role, effective_role, `aria-live`, skeleton |
| 24 | Board | `frontend/src/app/app/[orgId]/boards/[boardId]/page.tsx` (359 ln) | 403/permission-role, effective_role, `aria-live`, skeleton |
| 25 | Tickets list | `frontend/src/app/app/[orgId]/tickets/page.tsx` (246 ln) | **empty state entirely**, 403/permission-role, effective_role, `aria-live`, skeleton |
| 26 | Ticket detail | `frontend/src/app/app/[orgId]/tickets/[id]/page.tsx` (71 ln) | **error state entirely**, **empty state entirely**, 403/permission-role, effective_role, `aria-live`, skeleton — only `loading` exists |
| 28 | Wiki | `frontend/src/app/app/[orgId]/wiki/page.tsx` (611 ln) | 403/permission-role, effective_role, `aria-live`, skeleton |
| 44 | Members | `frontend/src/app/app/[orgId]/members/page.tsx` (187 ln) | **empty state entirely**, 403/permission-role, effective_role, `aria-live`, skeleton |
| 45 | Org settings | `frontend/src/app/app/[orgId]/settings/page.tsx` (135 ln) | **empty state entirely**, 403/permission-role, effective_role, `aria-live`, skeleton |

**Pattern across all 10**: zero screens have `effective_role` gating, zero have `aria-live`, zero use shape-matched `Skeleton` (loading exists everywhere but as bare "Loading…" text or a spinner). None render a 403/`PermissionState` — every page currently either fails silently or shows the generic error state on a permission denial, which is the wrong precedence per the states reference (permission should pre-empt error, not collapse into it). This confirms UX-PLAN §0's framing: it's a state-kit adoption problem, not a per-screen redesign.

Five deepest gaps (error/empty entirely absent, not just missing chrome): **21 session detail, 26 ticket detail** (both missing error AND empty), then **25 tickets list, 44 members, 45 org settings** (each missing empty entirely, tied at 5 total absent states).

---

## 3. Cross-cutting

- **Suspended handling**: checked at the layout/middleware level before any page component renders — a suspended membership redirects to `/suspended` (screen 65) before route data fetches, not after a failed fetch. No individual screen should implement its own suspended check; it is shell-level, once.
- **Permission copy rule**: denial copy names the object and the required role, never the specific scope/group that would grant it (UX-PLAN §8 D2). "You need admin access to this" is correct; "You need the `db:write:tenant-42` scope" is not, even in the SQL console (59) or VFS editor (54) where the underlying gate is a named scope.
- **Skeleton shapes catalog**: six shapes, matched to the region they replace, never a generic centered spinner for anything wider than a button —
  - **table**: header row live, N body rows of `.skeleton--text` bars matching column widths (screens 17, 20, 25, 44, 57, 60, 62, 63, 67, 71)
  - **board**: column headers live, 2–3 skeleton cards per column (screen 24)
  - **chat**: alternating-side skeleton bubbles, avatar circles (screens 23, 68)
  - **tree**: indented skeleton bars at 3 nesting levels (screens 53, 58, 74)
  - **bento**: mixed-size skeleton tiles matching the dashboard grid (screen 17, 73)
  - **form**: label + input skeleton pairs stacked, matching field count (screens 54, 63, 67, 69, 70's step forms)

