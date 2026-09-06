# Render notes — wireframe route pass

Rendered at 1440x900, light theme, via headless Chrome (playwright not installed in this env).
Shots in `shots/`.

## /acme (default)
- Rail | main reads correctly. Stat tiles grid, first-run checklist below — structurally sound.
- `918,273,645,102` pending-approvals fixture is absurd but renders fine (no overflow).

## /acme?state=empty
- State variant switches correctly: dashboard replaced with "Welcome — let's get this org set up" + Start checklist CTA. Confirms `?state=` wiring works.

## /acme/work/boards/b1 (Backlog / In progress / Review / Done)
- Kanban columns read correctly, four-column layout intact.
- 200-char hostile ticket title wraps cleanly inside its card (no overflow) — good.
- **Bug (fixed):** RTL assignee chip ("أحمد المصري") sat glued directly against the adjacent `ticket #377` link with no gap, because the JSX had no whitespace node between the two elements. `components/Board.tsx` — added `{" "}` between the chip and link.
- **Bug (fixed):** `<Toast>` (renders a `<div>`) was wrapped in a `<p>` in `app/(app)/[org]/work/boards/[id]/page.tsx:46`, which is invalid HTML nesting and threw a React hydration error on every load (visible as the Next.js dev "N · Issues" badge). Changed wrapper to `<div>`.

## /acme/chat/general?thread=t1
- Three-pane layout (Rooms | Messages | Thread) reads correctly.
- 200-char hostile room name in the Rooms list wraps inside its column, no overflow.
- RTL message text renders but the bidi algorithm reorders the timestamp fragment (`14:05:00 06-09-2026` vs the LTR row's `2026-09-06 14:00:00`) — cosmetic bidi quirk from mixed-direction text, not a layout break. Left as-is (wireframe stage, needs `unicode-bidi: isolate` treatment later, not urgent).
- `thread=t1` query param does not appear to select/highlight a message or populate the Thread pane — it still shows the empty "Select a message to open its thread" prompt. Route param isn't wired to fixture state. Flagging as a fix-list item, not fixed here (requires wiring thread lookup logic, more than a trivial one-line change).

## /acme/files/wiki/docs/readme.md
- Three-pane layout (Tree | editor | Inspector) reads correctly. Long filename wraps in the tree without breaking layout.
- Breadcrumb shows `Files / wiki / docs / readme.md` but the page body renders the static `core-vfs` mount fixture (`src/`, `README.md`, `検索インデックス/`) regardless of the `wiki/docs/readme.md` path in the URL — `app/(app)/[org]/files/[mount]/[...path]/page.tsx` falls back to `mounts[0]` because no `wiki` mount exists in `lib/fixtures.ts`. Cosmetic mismatch between breadcrumb and body; not fixed (needs a fixture entry, out of scope for a wireframe-defect sweep).

## /acme/data/main/console
- Rail | main, SQL editor, results table all read correctly. No defects observed.

## /acme/settings/keys
- Table layout intact. 90-char hostile key label wraps inside its cell without breaking the table. No defects observed.

## /palette
- Static command-palette review page, dialog centered, list of actions readable.
- **Bug (fixed):** placeholder text "Type a command or search…" was clipped to "Type a command or sea" because the `<input>` had no width set. `components/CommandPalette.tsx` — added `style={{ width: "100%" }}`.

## /acme/work/sessions?state=denied
- State variant switches correctly: "Access restricted" copy replaces the sessions list.
- Minor: the "New session" primary action and the filter controls stay visible/enabled even though the page reports access denied — arguably fine for a wireframe stub since nothing is destructive, but worth a note for the real access-gate pass.

## Fix list (concrete wireframe defects)
1. **Fixed** — `components/Board.tsx`: no whitespace between assignee `.chip` and ticket link, causing RTL/CJK names to visually glue to the link text.
2. **Fixed** — `app/(app)/[org]/work/boards/[id]/page.tsx:46`: `<Toast>` (a `<div>`) nested inside a `<p>`, invalid HTML causing a React hydration error on every board page load.
3. **Fixed** — `components/CommandPalette.tsx:9`: command input had no explicit width, clipping its own placeholder text.
4. **Not fixed** — `app/(app)/[org]/chat/[room]/page.tsx`: `thread=<id>` query param isn't wired to select a message/populate the Thread pane.
5. **Not fixed** — `app/(app)/[org]/files/[mount]/[...path]/page.tsx` + `lib/fixtures.ts`: no `wiki` mount fixture, so any mount other than `core-vfs` silently falls back and shows the wrong tree/content relative to the breadcrumb.
6. **Not fixed (low priority)** — `/acme/chat/...` RTL timestamp bidi reordering; needs `unicode-bidi: isolate` on timestamp spans, deferred to a later pass.
7. **Not fixed (low priority)** — `/acme/work/sessions?state=denied`: primary/filter controls remain interactive under a denied state.
