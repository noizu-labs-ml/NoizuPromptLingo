# Shell Direction Mockups

Four candidate app-shell/layout directions for NoizuPromptLingo, rendered in
the locked **Nocturne** palette (dark-native, single phosphor-green signal —
see `design/theme/treatise-npl-nocturne.md` and
`design/theme/theme-npl-nocturne/style-guide.vars.yaml`). Referenced against
`UX-PLAN.md` §2 (shell + rail), §3.2 (new screens), §8 D4 (shell decision
pending).

All renders were generated with `service: gemini` forced to
`gemini-2.5-flash-image` ("nano banana") via an attached palette reference
image (`_nocturne-palette.png`, generated locally from
`style-guide.color-modes.yaml` dark values), so every render is anchored to
the same eight swatches: bg `#010409`, surface `#0d1117`, border `#21262d`,
text `#e6edf3`, muted `#6e7681`, accent `#3fb950`, info/link `#58a6ff`,
warning `#d29922`.

## The four directions

**D1 — Icon-rail + command palette.** A 56px collapsible icon-only rail
(org switcher pinned above 8 destination icons) plus a `⌘K` palette overlay
and top breadcrumbs. This is `UX-PLAN.md`'s current recommendation.
*Trade-off:* maximizes canvas width for wide surfaces (editor, SQL console,
board) and scales past 9 destinations via the palette/search, but hides
destination labels — new users must learn icon meanings or rely on hover,
and the org switcher competing for the same 56px column with 8 icons is
tight at small sizes.

**D2 — Persistent three-pane triage.** A labeled, always-expanded left nav
(~180px) plus a list pane and a detail pane, explicitly built for fast
list-then-inspect workflows (`j`/`k` traversal, selected-row highlight) —
an email/ticket-triage shape. *Trade-off:* excellent for the list-heavy
majority of screens (sessions, tickets, chat rooms) and never hides nav
labels, but the fixed three-column split eats width from screens that want
one dominant wide canvas (SQL console, kanban, editor) and the nav column's
labels don't scale as gracefully past 8-9 destinations without a palette.

**D3 — Dual sidebar + wide canvas.** A 240px labeled left nav and a 320px
right inspector flank a wide central canvas — built for data/board-shaped
work needing both structural navigation (schema tree, board picker) and
persistent contextual detail (column/card inspector) around a dominant
canvas. *Trade-off:* best width-to-canvas ratio of the two-sidebar options
and keeps an always-visible inspector (useful for Data and Files screens
per `UX-PLAN.md` §2.2), but burns real estate on screens that don't need a
right inspector (chat, most dashboards) and two persistent sidebars is the
heaviest chrome footprint of the four.

**D4 — Top bar only + bento home.** No sidebar at all; navigation lives in
a persistent top bar (org switcher, horizontal destination links, search,
notifications), with home and section landings as bento tile grids.
*Trade-off:* maximizes vertical space for every screen and reads as the
lightest, most modern chrome, but a horizontal link row is the tightest fit
for 8 primary destinations before it wraps or truncates, and it has no
natural home for expanding into the ~30 secondary destinations `UX-PLAN.md`
§2.1 says the rail/palette combo is meant to absorb — D4 would need to lean
even harder on search/palette to compensate.

## Prompt → render

| Prompt | Render |
|---|---|
| `d1-icon-rail-palette--home-inbox.media.prompt` | `d1-icon-rail-palette--home-inbox.png` |
| `d1-icon-rail-palette--files-editor.media.prompt` | `d1-icon-rail-palette--files-editor.png` |
| `d2-three-pane-triage--work-sessions.media.prompt` | `d2-three-pane-triage--work-sessions.png` |
| `d2-three-pane-triage--chat-thread.media.prompt` | `d2-three-pane-triage--chat-thread.png` |
| `d3-dual-sidebar-canvas--data-console.media.prompt` | `d3-dual-sidebar-canvas--data-console.png` |
| `d3-dual-sidebar-canvas--board-kanban.media.prompt` | `d3-dual-sidebar-canvas--board-kanban.png` |
| `d4-topbar-bento--home-bento.media.prompt` | `d4-topbar-bento--home-bento.png` |
| `d4-topbar-bento--settings-keys.media.prompt` | `d4-topbar-bento--settings-keys.png` |

`_nocturne-palette.png` is the shared reference attachment (not a screen
mockup) — regenerate it with the script in the media-generator scratchpad
if the Nocturne hexes ever change, then re-run the prompts below so new
renders stay anchored to the current palette.

## Regenerating

```bash
# Validate the plan (provider, model, attachments, output paths) with no API calls
generate-media-prompt --dry-run design/ux-overhaul/directions/

# Generate for real (requires GEMINI_API_KEY; --no-eval skips the LAN eval grader)
generate-media-prompt --no-eval --verbose design/ux-overhaul/directions/

# Regenerate a single direction/screen
generate-media-prompt --no-eval design/ux-overhaul/directions/d1-icon-rail-palette--home-inbox.media.prompt
```

Each `.media.prompt` also creates a `.genai.<name>.png/` sidecar directory
holding the generation's metadata YAML (prompt sent, model, timestamp) plus
a hard-linked copy of the output — kept as generation history, not deleted.

## Critique

Per-render honest read: what the model got right, what it got wrong, and
whether it fairly represents the intended direction. No winner is picked
here.

### D1 — `home-inbox.png`
- **Right:** 56px icon-only rail with org switcher pinned above the icon
  stack, green active-item edge on Home, and a centered `⌘K` palette
  overlay with grouped "Recent / Files / Commands" results and a
  highlighted row — the core mechanic of the direction reads clearly.
- **Wrong:** the palette overlay is opaque and fully occludes the bento
  grid and inbox pane behind it rather than dimming through a scrim, so
  the "overlay above dimmed content" framing is lost; a couple of card
  labels ("First-run chmematmor", "Check-runt checklist") are garbled
  micro-text, a known image-model text-rendering limit, not a shell flaw.
- **Fair representation:** yes for the rail + palette mechanic; the
  dashboard-behind-overlay composition undersells how much content stays
  visible during a real palette session.

### D1 — `files-editor.png`
- **Right:** clean three-column tree | editor | inspector split, a
  pulsing "LIVE" badge on the editor tab, mono SQL with theme-only syntax
  coloring, and a populated inspector (path, size, revision history) —
  this is the strongest render of the batch.
- **Wrong:** the icon rail collapsed to a thinner sliver than D1's other
  shot and swapped the org-switcher square avatar for a generic user
  circle, so it reads slightly inconsistent with `home-inbox.png` as "the
  same rail."
- **Fair representation:** yes — a faithful, high-fidelity read of the
  VFS dual-sidebar-plus-canvas screen inside the icon-rail shell.

### D2 — `work-sessions.png`
- **Right:** labeled persistent nav with Work expanded into its
  sub-items, a visibly highlighted selected list row, the `j/k to
  navigate` hint rendered verbatim, and a right detail pane with tabs and
  a live streaming event timeline — the triage mechanic is unmistakable.
- **Wrong:** several list rows repeat near-duplicate titles/ids ("VFS
  mount smoke test" appears many times) and the event-log right column
  trails off into truncated/garbled words ("short goes", "run_tests on
  pto_…") — content realism breaks down under repetition and small text.
- **Fair representation:** yes for the pane mechanics and proportions;
  the repeated/garbled copy is a content-generation artifact, not a
  layout problem.

### D2 — `chat-thread.png`
- **Right:** rooms list with unread badges, a flat hairline-separated
  message stream including a distinct "Scheduled · sends in 2h14m" chip,
  and a right thread panel with a genuine pinned section above a threaded
  reply chain plus a mute toggle — all the called-for chat mechanics are
  present and legible.
- **Wrong:** message avatars/hairlines feel slightly card-like (faint
  separation) rather than the pure flat hairline rule the theme calls
  for; minor drift, not a violation.
- **Fair representation:** yes — probably the cleanest, most legible
  render of the whole set.

### D3 — `data-console.png`
- **Right:** tenant-scope chip and write-approval banner both sit exactly
  where specified, directly above the console; the schema tree, SQL
  editor, results grid, and inspector-with-audit are all present and the
  layout proportions read correctly.
- **Wrong:** the left-nav labels are garbled ("Peotmists" instead of
  "Settings", a nav item duplicating "Data"), and several result-grid UUID
  values contain non-hex characters (e.g. "BFFAae4739") — the model's
  text rendering degrades on dense small-size mono content.
- **Fair representation:** yes for the D3 mechanic (two sidebars + wide
  canvas, scope chip, approval banner); the garbled nav copy would need a
  regenerate/refine pass before use as a spec reference.

### D3 — `board-kanban.png`
- **Right:** four kanban columns with count chips, a per-column "Load 12
  more" affordance, a card highlighted for keyboard-move with the
  "← → to move columns · enter to drop" hint, a bottom toast
  ("Moved NPL-479 to In Review"), and a populated right card inspector —
  every called-for element is present.
- **Wrong:** several card titles are garbled ("VFS conwercommar badges",
  "meamons") and the toast overlaps/crops against the inspector edge
  rather than floating clear of it.
- **Fair representation:** yes for the D3 mechanic and the specific
  keyboard-move/toast/pagination requirements; text fidelity is the weak
  point again.

### D4 — `home-bento.png`
- **Right:** a genuinely sidebar-free top bar (org switcher, wordmark,
  horizontal destination links with Home underlined in green, search,
  notification badge, avatar) sitting above a true uneven bento mosaic —
  hero "continue session" tile, stat tiles, notifications, files, data,
  and a full-width checklist all present and well-proportioned.
- **Wrong:** the checklist row text is garbled ("Motion your first
  iegration", a stray "NoizuPromplingo" label used as a checklist item)
  and the Data tile's mini-sparkline is just a flat line rather than a
  legible trend.
- **Fair representation:** yes — the no-sidebar mechanic and bento
  composition are unambiguous and match the direction's intent well.

### D4 — `settings-keys.png`
- **Right:** the key-vault mechanics are all there — masked keys with
  rotate/revoke actions, a genuine "Reveal once" green button with the
  amber "will not be shown again" warning on a fresh key, and an
  invite-cap progress meter tile with the seats-used copy exactly as
  specified.
- **Wrong:** the top-bar destination links were hallucinated as
  "Organization switcher / Customers / Project / Contact" instead of the
  requested Home/Work/Chat/Knowledge/Files/Data/Integrations/Settings —
  the model invented a different nav taxonomy for this shot than it used
  in `home-bento.png`, breaking cross-screen shell consistency.
- **Fair representation:** partially — the settings/key-vault content is
  faithful and strong, but the wrong top-bar labels mean this render
  should not be trusted as evidence of D4's actual primary-nav wording;
  a regenerate with a more constrained nav-label instruction is advised
  before using this shot to argue the direction on its chrome alone.

**Decision pending: see UX-PLAN.md §8 D4.**
