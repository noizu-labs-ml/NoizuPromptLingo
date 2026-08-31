# npl-queue-board

Self-contained Lit 3 web component that renders NPL ticket queues (boards) as
stage columns with ticket cards. Ships as a single ES module bundle with styles
inlined — no CDN, no framework dependency for the host. Designed to be embedded
in any host page (Next.js, plain HTML) and themed entirely through CSS custom
properties.

- Tag: `<npl-queue-board>`
- Bundle: `dist/npl-queue-board.js` (ES2021 module, `lit` bundled, styles inlined)
- Data: pluggable `dataProvider` async function — default implementations for
  the tobor.locker REST API and for mocks/fixtures

## Embed in a Next.js host

Web components must run client-side; load the module with `next/script` (or a
dynamic import) and render the element inside a client component.

```tsx
// app/queues/page.tsx (client component)
'use client';

import Script from 'next/script';

export default function QueuesPage() {
  return (
    <>
      <Script
        src="/vendor/npl-queue-board.js"
        type="module"
        strategy="afterInteractive"
      />
      <npl-queue-board heading="Delivery boards" theme="auto" />
    </>
  );
}
```

To pass a `dataProvider` (functions cannot cross attributes), grab the element
from a ref after mount:

```tsx
'use client';

import {useEffect, useRef} from 'react';
import {createLockerProvider} from 'npl-queue-board';

export function QueueBoard({orgId, token}: {orgId: string; token: string}) {
  const ref = useRef<HTMLElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    (el as any).dataProvider = createLockerProvider({
      baseUrl: 'https://tobor.locker.noizu.com',
      orgId,
      token,
    });
  }, [orgId, token]);

  return <npl-queue-board ref={ref} heading="Queues" />;
}
```

For plain HTML hosts:

```html
<script type="module" src="/vendor/npl-queue-board.js"></script>
<npl-queue-board heading="Queues"></npl-queue-board>
```

Note: if you install the package from npm instead of script-tag embedding, do
not also import `lit` separately — the bundle is self-contained on purpose.

## Component API

### Attributes / properties

| Property | Attribute | Type | Default | Notes |
| --- | --- | --- | --- | --- |
| `dataProvider` | — | `(query?) => Promise<QueueBoardData>` | `null` | Async data source. Property only (cannot be an attribute). |
| `boardId` | `board-id` | `string` | `''` | Render only this board; empty renders all boards. |
| `heading` | `heading` | `string` | `''` | Optional heading rendered above the boards. |
| `theme` | `theme` | `'auto' \| 'light' \| 'dark'` | `'auto'` | `auto` follows `prefers-color-scheme`. |
| `hideEmptyStages` | `hide-empty-stages` | `boolean` | `false` | Drop columns with zero tickets. |

### Methods

| Method | Returns | Notes |
| --- | --- | --- |
| `refresh()` | `Promise<void>` | Re-invokes the provider; aborts any in-flight load. |

### Events

| Event | `detail` | Fired when |
| --- | --- | --- |
| `card-activate` | `{ticket: QueueTicket}` | A card is clicked or keyboard-activated. |
| `queue-load-error` | `{error: string}` | The provider rejects. |

### Render states

- **loading** — spinner region (`role="status"`, `aria-busy="true"` on the board region)
- **error** — `role="alert"` message with a Retry button
- **empty** — "No queues to display" (`role="status"`)
- **loaded** — board sections → stage columns (`role` groups with labelled
  headings) → card lists (`<ul>`) with focusable card `<button>`s

Cards show key (`PREFIX-NNN`), type, title, status dot, priority chip, tags
(from `tags` or `custom_fields.tags`), and assignee avatar + name.

## Data provider contract

The component never talks to a backend directly — it calls `dataProvider`:

```ts
type QueueDataProvider = (query?: {signal?: AbortSignal}) => Promise<{
  queues: QueueBoard[];   // boards with their stages
  items: QueueTicket[];   // tickets across those boards
}>;
```

```ts
interface QueueBoard {
  id: string;
  name: string;
  slug?: string | null;
  description?: string | null;
  methodology?: string | null;   // kanban | scrum | waterfall | spiral
  scope?: string;                // global | org | project
  stages?: QueueStage[];         // columns; sorted by `position`
}

interface QueueStage {
  id: string;
  slug?: string;
  name: string;
  kind?: string;                 // todo | in_progress | in_review | done | phase ...
  position?: number;
  wip_limit?: number | null;
}

interface QueueTicket {
  id: string;
  key?: string | null;           // PREFIX-NNN
  number?: number | null;
  title: string;
  status?: string | null;
  priority?: string | null;
  assignee?: string | null;
  tags?: string[];               // falls back to custom_fields.tags
  ticket_type?: string | null;
  queue_id?: string | null;      // must match a board id or the ticket is not shown
  stage_id?: string | null;      // null/unknown stage → "Unstaged" column
  updated_at?: string | null;
  custom_fields?: Record<string, unknown> | null;
}
```

Contract rules:

- The provider receives `{signal}`; honor `signal.aborted` / reject with an
  `AbortError` when cancelled. The component aborts in-flight loads when the
  provider or `boardId` changes or when `refresh()` is called.
- Tickets whose `queue_id` does not match a returned board are ignored.
- Tickets whose `stage_id` is null or unknown render in a trailing
  "Unstaged" column (only when non-empty).
- Malformed payloads resolve to an empty board rather than an error.

### Default provider — tobor.locker REST API

```ts
import {createLockerProvider} from 'npl-queue-board';

el.dataProvider = createLockerProvider({
  baseUrl: 'https://tobor.locker.noizu.com',   // NPL API host
  orgId: 'my-org-slug-or-uuid',
  projectId: 'optional-project-uuid',          // optional scope filter
  token: bearerToken,                          // Authorization: Bearer …
});
```

It calls, in parallel:

- `GET {baseUrl}/api/v1/organizations/{orgId}/boards[?project_id=…]` → `{boards: [...]}`
- `GET {baseUrl}/api/v1/organizations/{orgId}/tickets[?project_id=…]` → `{tickets: [...]}`

and maps them onto `{queues, items}`. Non-2xx responses reject with an
`Error` including the status, which surfaces in the component's error state.
Both endpoints are authenticated in the NPL backend (`:api, :authenticated`
pipelines); per-key auth wiring for served embeds is a separate integration
task — until then the host supplies a token.

### Mock provider (dev/test)

```ts
import {createMockProvider, defaultFixture} from 'npl-queue-board';

el.dataProvider = createMockProvider();                    // built-in fixture
el.dataProvider = createMockProvider({delayMs: 500});      // exercises loading state
el.dataProvider = createMockProvider({fixture: myData});   // your own data
```

## Theming

All visuals flow through `--nqb-*` custom properties on `:host` — override them
from the host page (on the element or any ancestor):

| Token | Light default | Purpose |
| --- | --- | --- |
| `--nqb-bg` | `#f5f6f8` | Region background |
| `--nqb-surface` | `#ffffff` | Columns and cards |
| `--nqb-surface-raised` | `#eef0f4` | Chips, tags, methodology badge |
| `--nqb-border` | `#d9dde5` | Borders |
| `--nqb-text` | `#1f2430` | Primary text |
| `--nqb-text-muted` | `#5b6472` | Secondary text |
| `--nqb-accent` | `#4f46e5` | Keys, focus, active status, avatar |
| `--nqb-accent-contrast` | `#ffffff` | Text on accent |
| `--nqb-danger` / `--nqb-warn` / `--nqb-ok` | `#b91c1c` / `#92400e` / `#047857` | Priority/status colors |
| `--nqb-chip-bg` | `#e8ebf1` | Neutral chip background |
| `--nqb-radius` / `--nqb-radius-sm` | `10px` / `6px` | Corner radii |
| `--nqb-font` / `--nqb-mono` | system stacks | Typography |
| `--nqb-column-width` | `280px` | Column width (clamped responsively) |
| `--nqb-gap` / `--nqb-pad` | `12px` / `16px` | Spacing |

Dark mode: `theme="auto"` (default) swaps to dark tokens under
`prefers-color-scheme: dark`; `theme="dark"` / `theme="light"` force one.

```css
/* re-skin example */
npl-queue-board {
  --nqb-accent: #0ea5e9;
  --nqb-radius: 14px;
  --nqb-surface: #f8fafc;
}
```

## Development

```bash
npm install
npm run dev      # vite demo at http://localhost:5180 (mock provider, theme toggle)
npm run lint     # tsc --noEmit over src + tests
npm run build    # vite lib bundle -> dist/npl-queue-board.js (+ .d.ts, sourcemaps)
npm test         # Web Test Runner (system Chrome) — component, grouping, provider suites
```

The bundle is built with `lit` bundled in and styles inlined; hosts embed it
without any dependency install.

## Source map of the data seam

- `src/types.ts` — provider contract types
- `src/grouping.ts` — pure grouping/classification logic (unit-tested)
- `src/providers/locker-provider.ts` — tobor.locker REST implementation
- `src/providers/mock-provider.ts` + `src/fixtures.ts` — mock data + fixtures
- `src/npl-queue-board.ts` — the element

Backend shapes mirrored here: `backend/lib/noizu_prompt_lingua_web/controllers/board_controller.ex`
(`board_detail`, `stage_json`) and `ticket_controller.ex` (`ticket_to_json`).
If those controllers change shape, update `types.ts` and the locker provider.
