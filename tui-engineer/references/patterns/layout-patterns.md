# TUI Layout Patterns

Reference guide for structuring terminal user interfaces. Each pattern includes an 80×24 ASCII mockup, usage guidance, and degradation notes.

---

## 1. Full-Screen App (Header / Body / Footer with Side Panel)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  MyApp v1.0          [Projects]  [Settings]  [Help]              q:Quit  ?  │
├─────────────────────────────┬──────────────────────────────────────────────┤
│ SIDEBAR                     │ MAIN CONTENT                                  │
│ ─────────────────────────   │ ───────────────────────────────────────────   │
│ > Project Alpha             │  Project Alpha                                │
│   Project Beta              │  ───────────────────────────────────────────  │
│   Project Gamma             │  Status:  Active                              │
│                             │  Owner:   alice                               │
│ ─────────────────────────   │  Created: 2026-01-12                          │
│ FILTERS                     │                                               │
│   [x] Active                │  Description:                                 │
│   [ ] Archived              │  Lorem ipsum dolor sit amet, consectetur      │
│   [x] Mine                  │  adipiscing elit. Sed do eiusmod tempor.      │
│                             │                                               │
│                             │                                               │
│                             │                                               │
│                             │                                               │
│                             │                                               │
│                             │                                               │
├─────────────────────────────┴──────────────────────────────────────────────┤
│  3 projects │ Last sync: 12:34:01 │ ↑↓ navigate │ Enter: open │ /: search  │
└──────────────────────────────────────────────────────────────────────────────┘
```

**When to use:** Primary application shell. Persistent navigation + context panel + detail area. Suits any CRUD-style app (file managers, project managers, config editors).

**Responsive degradation:**
- Below 80 cols: collapse sidebar to icons or hide with toggle (`[`/`]`)
- Below 24 rows: drop footer, merge status into header right-side
- Below 40 cols: single-column mode, sidebar becomes a pop-over

---

## 2. Split Pane

```
┌────────────────────────────────────┬─────────────────────────────────────┐
│ LEFT PANE                          │ RIGHT PANE                          │
│ ─────────────────────────────────  │ ─────────────────────────────────── │
│ src/                               │  1  fn main() {                     │
│ ├── main.rs                        │  2      let args = Args::parse();   │
│ ├── config.rs                      │  3      run(args)?;                 │
│ └── ui/                            │  4  }                               │
│     ├── app.rs          <──────────│  5                                  │
│     ├── layout.rs                  │  6  fn run(args: Args) -> Result<() │
│     └── widgets.rs                 │  7  {                               │
│                                    │  8      // ...                      │
│                                    │  9  }                               │
│                                    │ 10                                  │
│                                    │ 11                                  │
│                                    │ 12                                  │
│                                    │ 13                                  │
│                                    │ 14                                  │
│                                    │ 15                                  │
│                                    │ 16                                  │
│                                    │ 17                                  │
│                                    │ 18                                  │
├────────────────────────────────────┴─────────────────────────────────────┤
│  src/ui/app.rs  │  Rust  │  18 lines  │  Tab: switch pane  │  Ctrl+W: close │
└──────────────────────────────────────────────────────────────────────────┘
```

**When to use:** File explorer + preview, diff viewer, log browser + detail. Any master/detail relationship where both sides need equal screen real estate.

**Responsive degradation:**
- Below 80 cols: stack vertically (top/bottom split) or allow toggle
- Below 60 cols: single pane with `Tab` to switch, indicator in status bar

---

## 3. Wizard / Stepper

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        Setup Wizard — Step 2 of 4                           │
├──────────────────────────────────────────────────────────────────────────────┤
│   [1. Welcome] ── [2. Database] ── [ 3. Auth ] ── [ 4. Confirm ]            │
│        ✓               ●                ○                 ○                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Database Configuration                                                    │
│   ──────────────────────────────────────────────────────────                │
│                                                                              │
│   Host:      [ localhost__________________________ ]                         │
│   Port:      [ 5432____ ]                                                   │
│   Database:  [ myapp_db___________________________ ]                         │
│   Username:  [ postgres__________________________ ]                          │
│   Password:  [ ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●● ]                         │
│                                                                              │
│   [ Test Connection ]                                                        │
│                                                                              │
│   ✓ Connection successful                                                    │
│                                                                              │
│                                                                              │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│   [← Back]                                             [Next →]  [Cancel]   │
└──────────────────────────────────────────────────────────────────────────────┘
```

**When to use:** Multi-step setup flows, install wizards, onboarding, multi-page forms where steps have dependencies. Linear or branching workflows.

**Responsive degradation:**
- Below 80 cols: abbreviate step labels, use numbers only (`1 > ●2 > 3 > 4`)
- Below 24 rows: compress whitespace, drop decorative lines

---

## 4. Tabbed Interface

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                       │
│  │ Overview │ │  Metrics │ │   Logs   │ │  Config  │      [+] New Tab       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Service: api-gateway                                                        │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│  Status:    ● Running          Uptime:   14d 3h 22m                         │
│  Replicas:  3/3 healthy        CPU:      12%                                 │
│  Version:   v2.4.1             Memory:   234MB / 512MB                       │
│                                                                              │
│  Recent Deployments:                                                         │
│  ─────────────────────────────────────────────────────────────────────────  │
│  2026-05-12 09:14  v2.4.1  alice    ✓ Success                               │
│  2026-05-11 16:32  v2.4.0  bob      ✓ Success                               │
│  2026-05-10 11:05  v2.3.9  alice    ✗ Rolled back                           │
│                                                                              │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│  Tab/S-Tab: switch  │  1-4: jump to tab  │  Enter: select  │  q: quit       │
└──────────────────────────────────────────────────────────────────────────────┘
```

**When to use:** Multi-context views of the same entity, settings panels, multi-document interfaces. Tabs when content is too large for a single view.

**Responsive degradation:**
- Below 60 cols: truncate tab labels, use number keys only
- Below 40 cols: replace tab bar with a select dropdown/menu

---

## 5. Modal Overlay

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  App Header                                                  [background]    │
├─────────────────────┬────────────────────────────────────────────────────── │
│ [dimmed sidebar]    │ [dimmed main content]                                 ▒│
│                     │                                                        ▒│
│    ╔══════════════════════════════════════╗                                  ▒│
│    ║  Delete Project                      ║                                  ▒│
│    ║  ────────────────────────────────    ║                                  ▒│
│    ║                                      ║                                  ▒│
│    ║  Are you sure you want to delete     ║                                  ▒│
│    ║  "Project Alpha"? This action        ║                                  ▒│
│    ║  cannot be undone.                   ║                                  ▒│
│    ║                                      ║                                  ▒│
│    ║  Type the project name to confirm:   ║                                  ▒│
│    ║  [ Project Alpha______________ ]     ║                                  ▒│
│    ║                                      ║                                  ▒│
│    ║  [ Cancel ]          [ Delete ] ←   ║                                  ▒│
│    ╚══════════════════════════════════════╝                                  ▒│
│                     │                                                        ▒│
├─────────────────────┴────────────────────────────────────────────────────── │
│  [status bar dimmed]                                                          │
└──────────────────────────────────────────────────────────────────────────────┘
```

**When to use:** Confirmations, quick-edit dialogs, context actions, alert messages. Keep modals single-purpose. Dim the background to maintain spatial context.

**Responsive degradation:**
- Below 60 cols: modal takes full width, reduce padding
- Always: Escape cancels, Tab cycles buttons, Enter confirms focused button

---

## 6. Streaming Log Viewer

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Logs — api-gateway  [LIVE ●]    [INFO] [WARN] [ERROR] [ALL ✓]  / filter    │
├──────────────────────────────────────────────────────────────────────────────┤
│ 12:34:01.123 INFO  Request: GET /api/v1/users 200 45ms                      │
│ 12:34:01.456 INFO  Request: POST /api/v1/auth 200 123ms                     │
│ 12:34:02.001 WARN  Rate limit approaching: client 10.0.0.5 (450/500)        │
│ 12:34:02.234 INFO  Request: GET /api/v1/health 200 2ms                      │
│ 12:34:02.891 ERROR Request: DELETE /api/v1/users/99 404 8ms                 │
│ 12:34:03.012 INFO  Cache hit: user:42 (ttl: 284s)                           │
│ 12:34:03.234 INFO  Request: GET /api/v1/projects 200 67ms                   │
│ 12:34:03.456 INFO  Request: PUT /api/v1/projects/7 200 89ms                 │
│ 12:34:03.678 WARN  Slow query detected: 823ms  SELECT * FROM events WHERE…  │
│ 12:34:04.001 INFO  Request: GET /api/v1/users 200 43ms                      │
│ 12:34:04.234 INFO  Request: GET /api/v1/metrics 200 12ms                    │
│ 12:34:04.456 INFO  Background job: cleanup_sessions completed (14 removed)  │
│ 12:34:04.789 INFO  Request: GET /api/v1/users 200 41ms                      │
│ 12:34:05.001 ERROR DB connection pool exhausted (32/32 active)              │
│                                                                         ↓↓↓  │
│                                                                              │
│                                                                              │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│  Live │ 14 lines │ 2 warnings │ 2 errors │ Space: pause │ G: tail │ /: filter│
└──────────────────────────────────────────────────────────────────────────────┘
```

**When to use:** Live log tailing, build output, test runners, deployment progress. Auto-scroll to tail when at bottom; freeze on manual scroll.

**Responsive degradation:**
- Timestamps are first casualty: truncate to `HH:MM:SS` or drop date
- Below 60 cols: hide level filter bar, use single-key toggles

---

## 7. Form Layout

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  New User                                                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Personal Information                                                        │
│  ─────────────────────────────────────────────────────────────────────────  │
│  First Name *    [ Jane_____________________ ]                               │
│  Last Name  *    [ Doe______________________ ]                               │
│  Email      *    [ jane@example.com_________ ]  ✓ valid                     │
│                                                                              │
│  Account Settings                                                            │
│  ─────────────────────────────────────────────────────────────────────────  │
│  Username   *    [ jdoe_____________________ ]  ✓ available                  │
│  Role            ( ) Admin  (●) Editor  ( ) Viewer                          │
│  Team            [ ▼ Engineering___________ ]                                │
│                                                                              │
│  Permissions                                                                 │
│  ─────────────────────────────────────────────────────────────────────────  │
│  [x] Can create projects    [ ] Can delete projects                          │
│  [x] Can invite members     [x] Can view billing                             │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│  * required │ Tab: next field │ S-Tab: prev │ Space: toggle │ [Save] [Cancel]│
└──────────────────────────────────────────────────────────────────────────────┘
```

**When to use:** Configuration editors, user management, settings panels, any structured data entry.

**Responsive degradation:**
- Below 60 cols: labels stack above inputs (label on one line, input on next)
- Inline validation moves to a line below the input

---

## 8. Dashboard Grid

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Dashboard                                                 2026-05-12 12:34  │
├─────────────────────────┬──────────────────────────┬──────────────────────┤
│ REQUESTS / MIN          │ ERROR RATE                │ AVG LATENCY          │
│                         │                           │                      │
│        1,247            │        0.3%               │       47ms           │
│   ▲ 12% vs last hour    │   ▼ 0.1% vs last hour     │  ▲ 3ms vs last hour  │
│                         │                           │                      │
│ ▁▂▂▃▄▄▅▅▆▇▇█▇▆▅▄▃▂▂▁  │ ▁▁▁▁▂▁▁▁▁▁▂▁▁▁▁▁▁▁▁▁      │ ▂▃▃▄▄▃▃▄▅▄▃▃▄▄▃▃▄▄▃  │
├─────────────────────────┴──────────────────┬────────┴──────────────────────┤
│ TOP ENDPOINTS                              │ ACTIVE ALERTS                  │
│ ────────────────────────────────────────   │ ────────────────────────────── │
│ GET  /api/v1/users        432 req/m        │ ● WARN  Slow query (8m ago)    │
│ POST /api/v1/auth         287 req/m        │ ● WARN  Pool near limit (12m)  │
│ GET  /api/v1/projects     198 req/m        │ ✓ INFO  Deploy done (1h ago)   │
│ GET  /api/v1/health        89 req/m        │                                │
│ PUT  /api/v1/projects      65 req/m        │                                │
├────────────────────────────────────────────┴──────────────────────────────┤
│  r: refresh │ a: alerts │ e: endpoints │ l: logs │ q: quit                  │
└──────────────────────────────────────────────────────────────────────────────┘
```

**When to use:** Monitoring, observability, system health, analytics overview. Multiple independent metrics shown simultaneously.

**Responsive degradation:**
- Below 100 cols: 2-column grid instead of 3
- Below 60 cols: single column, stack all widgets vertically
- Sparklines degrade gracefully to single numeric value
