# Style Guide: IoTGo — Direction A: Dark Ops Console

> Your fleet is the interface.

**Style System:** Minimal Tech 100%
**Source Spec:** minimal-tech.md
**Scenario:** AI-powered autonomous IoT fleet management platform for device engineers and NOC operators

---

## Scenario

IoTGo is an **autonomous agent layer for IoT fleet management** — it sits on top of existing infrastructure (AWS IoT Core, Azure IoT Hub, ThingsBoard) and deploys persistent AI agents that monitor telemetry streams, detect anomalies, execute remediation playbooks, and optimize device configurations without human intervention. Its primary users are IoT platform engineers managing fleets of 500 to 100,000 devices. They're the people who get paged at 3am when a temperature sensor drifts or a gateway drops offline. IoTGo's promise: the detect-act loop, closed.

The interface lives on NOC monitors and control room displays. It needs to be readable at arm's length, usable for 12-hour shifts, and dense enough that a single screen tells you whether your fleet is healthy. The hero surface is a **fleet topology view** — devices as nodes on a map or network graph, color-coded by health status, with agent activity overlaid as a real-time feed. Device health colors ARE the visual system: green for healthy, amber for warning, red for critical, gray for offline, purple for in-progress updates. The rest of the UI steps back into near-black and lets the data speak.

Dark Ops Console is the natural expression for infrastructure that runs in the dark — server rooms, control centers, operations floors. Teal accent signals connectivity and uptime (not blue — every other monitoring tool uses blue). The product sits alongside Datadog, Grafana, and Linear in the operator's tool belt. One accent color, dark mode only, data visualization as the primary decorative element, information density over whitespace.

**Reference energy:** Datadog dark mode (density + real-time), Grafana (chart systems), Linear (sidebar + transitions), Vercel (typographic restraint)

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #09090B;
  --bg-surface: #111116;
  --bg-elevated: #1A1A22;

  /* Text */
  --text-primary: #E4E4E8;
  --text-secondary: #8A8A98;
  --text-tertiary: #52526A;

  /* Borders */
  --border-default: #252530;
  --border-subtle: #1A1A22;

  /* Accent — Teal (signals connectivity, uptime, "online") */
  --accent: #14B8A6;
  --accent-hover: #2DD4BF;
  --accent-muted: rgba(20, 184, 166, 0.12);

  /* Device Health — THE color system */
  --health-healthy: #22C55E;
  --health-healthy-muted: rgba(34, 197, 94, 0.12);
  --health-warning: #EAB308;
  --health-warning-muted: rgba(234, 179, 8, 0.12);
  --health-critical: #EF4444;
  --health-critical-muted: rgba(239, 68, 68, 0.12);
  --health-offline: #6B7280;
  --health-offline-muted: rgba(107, 114, 128, 0.12);
  --health-updating: #A78BFA;
  --health-updating-muted: rgba(167, 139, 250, 0.12);

  /* Semantic */
  --info: #60A5FA;
}
```

```
+------------------------------------------+
|  IOTGO PALETTE — Direction A: Dark Ops   |
+------------------------------------------+
|                                           |
|  ██████  #09090B  Background              |
|  ██████  #111116  Surface                 |
|  ██████  #1A1A22  Elevated                |
|                                           |
|  ██████  #E4E4E8  Text Primary            |
|  ██████  #8A8A98  Text Secondary          |
|  ██████  #52526A  Text Tertiary           |
|                                           |
|  ██████  #252530  Border                  |
|  ██████  #1A1A22  Border Subtle           |
|                                           |
|  ██████  #14B8A6  Accent (Teal)           |
|  ██████  #2DD4BF  Accent Hover            |
|                                           |
|  ██████  #22C55E  Healthy                 |
|  ██████  #EAB308  Warning                 |
|  ██████  #EF4444  Critical                |
|  ██████  #6B7280  Offline                 |
|  ██████  #A78BFA  Updating                |
|                                           |
|  ██████  #60A5FA  Info                    |
|                                           |
+------------------------------------------+
```

**Usage rules:**
- Dark mode is the default and only mode — optimized for NOC/control room environments
- Accent (teal) appears ONLY on: primary CTA buttons, active sidebar items, focus rings, fleet connectivity indicators, and the "Deploy Agent" action
- Device health colors (healthy/warning/critical/offline/updating) are the primary visual system — they appear on topology nodes, status dots, sparkline thresholds, table row indicators, and fleet health score breakdowns
- Health-muted variants are used for node backgrounds, row highlights, and badge backgrounds in tables and cards
- Background should occupy 80%+ of visual field
- No gradients anywhere in the interface
- Teal is NOT used for health states — it is reserved exclusively for accent/interactive elements
- Purple (updating) signals active agent operations: firmware rollouts, config pushes, playbook execution in progress

---

## Typography

**Font stack:**
```css
--font-sans: 'Geist', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'Geist Mono', 'JetBrains Mono', 'Fira Code', Consolas, monospace;
```

| Level | Size | Weight | Line Height | Letter Spacing | Use |
|-------|------|--------|-------------|----------------|-----|
| Display | 48–72px | 600 | 1.1 | -0.02em | Fleet health score hero metric |
| H1 | 36px | 600 | 1.15 | -0.02em | Page titles ("Fleet Overview", "Agents", "Playbooks") |
| H2 | 24px | 600 | 1.2 | -0.01em | Panel titles, fleet segment names |
| H3 | 20px | 600 | 1.25 | 0 | Card headers, agent names, topology labels |
| H4 | 16px | 600 | 1.3 | 0 | Sub-sections, table group headers |
| Body | 16px | 400 | 1.6 | 0 | Default prose text |
| Body Small | 14px | 400 | 1.5 | 0 | Table cells, metadata, descriptions — primary reading size for data-dense views |
| Caption | 12px | 400 | 1.4 | 0 | Timestamps, device counts, sparkline labels, status bar text |
| Code | 14px | 400 | 1.5 | 0 | Device IDs, telemetry values, playbook YAML, agent reasoning logs, API responses |

**Typography notes:**
- Mono font is used extensively: device IDs (`dev_0a3f...`), telemetry readings (`23.4°C`), timestamps (`2026-03-13T08:42:11Z`), playbook code, agent reasoning chains, MQTT topics. In data tables, nearly every cell is monospace.
- Two weights only: 400 and 600. Never bold (700).
- Body Small (14px) is the effective base size for dashboard views — Body (16px) is reserved for overview prose and empty states.
- Display size scales responsively: 72px on wide/desktop, 56px on tablet, 48px on mobile.
- Letter-spacing tightens on Display and H1 only (-0.02em) — all other levels use 0.

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Geist | Vercel | Free / OFL | [GitHub](https://github.com/vercel/geist-font) |
| Geist Mono | Vercel | Free / OFL | [GitHub](https://github.com/vercel/geist-font) |
| Inter (fallback) | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Inter) |
| JetBrains Mono (fallback) | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) |

---

## Spacing & Layout

**Base unit:** 8px

**Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96px

```css
--space-1: 4px;    /* Inline icon gap, status dot margin */
--space-2: 8px;    /* Compact table cell padding, button icon gap */
--space-3: 12px;   /* Table cell padding, compact card padding */
--space-4: 16px;   /* Card padding, section gap, nav item padding */
--space-6: 24px;   /* Card gap, panel padding */
--space-8: 32px;   /* Section spacing, panel margins */
--space-12: 48px;  /* Major section breaks */
--space-16: 64px;  /* Page-level margins (desktop) */
--space-24: 96px;  /* Hero spacing, topology view padding */
```

**Grid:**

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 16px | 16px | 100% |
| Tablet (768–1024px) | 8 | 24px | 32px | 100% |
| Desktop (1024–1440px) | 12 | 24px | 64px | 100% |
| Wide (>1440px) | 12 | 32px | auto | 1440px |

**Note:** Max-width is 1440px, wider than typical Minimal Tech (1280px), because fleet management dashboards are data-dense and benefit from horizontal space. The topology view and tables both demand it.

**Layout pattern:** Collapsible sidebar (240–280px expanded, 64px icon rail collapsed) + main workspace.

```
+------------------------------------------------------------------+
|  iotgo.io                                                         |
+----------+-------------------------------------------------------+
|          |                                                        |
| SIDEBAR  |  MAIN WORKSPACE                                       |
| 240-280  |                                                        |
|          |  ┌──────────────────────────────────────────────────┐  |
| iotgo    |  │  BENTO GRID OVERVIEW                             │  |
| logo     |  │                                                  │  |
|          |  │  ┌─ Fleet Health ──┐ ┌─ Active Agents ──────────┐│  |
| Fleet    |  │  │  98.4%  ●●●●●○ │ │  12 agents  3 executing  ││  |
| selector |  │  └────────────────┘ └───────────────────────────┘│  |
| ▼        |  │                                                  │  |
|          |  │  ┌─ Recent Actions ────────────────────────────┐ │  |
| Overview |  │  │  ● Restarted gw-042 (anomaly:spike)         │ │  |
| Fleets   |  │  │  ● Recalibrated temp-119 (anomaly:drift)    │ │  |
| Agents   |  │  │  ● Staged fw 2.4.1 to canary group          │ │  |
| Playbooks|  │  └─────────────────────────────────────────────┘ │  |
| Actions  |  │                                                  │  |
| Insights |  │  ┌─ Anomaly Feed ──┐ ┌─ Device Status ─────────┐│  |
|          |  │  │  3 new today     │ │  ● 8,412 healthy        ││  |
| ──────── |  │  │  1 unresolved    │ │  ● 23 warning           ││  |
| Settings |  │  │                  │ │  ● 2 critical           ││  |
|          |  │  │                  │ │  ● 8 offline             ││  |
|          |  │  │                  │ │  ● 41 updating           ││  |
|          |  │  └─────────────────┘ └──────────────────────────┘│  |
|          |  │                                                  │  |
|          |  └──────────────────────────────────────────────────┘  |
|          |                                                        |
|          |  ┌─ FLEET TOPOLOGY VIEW ──────────────────────────────┐|
|          |  │                                                     │|
|          |  │    ●  ●  ● ●    ●  ●     ●  ●  ●  ●  ●           │|
|          |  │   ● ●  ●  ●  ●  ● ●  ●   ●  ●  ●  ●  ●          │|
|          |  │  ●  ●  ●  ●  ● ●  ● ●  ●  ●  ●  ●               │|
|          |  │   (devices as dots, color = health status)          │|
|          |  │                                                     │|
|          |  └─────────────────────────────────────────────────────┘|
+----------+-------------------------------------------------------+
```

---

## Component Styling

### Buttons

```css
/* Primary — Deploy Agent, Execute Playbook */
.btn-primary {
  background: var(--accent);
  color: #FFFFFF;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  font-family: var(--font-sans);
  border: none;
  transition: opacity 150ms ease;
}
.btn-primary:hover { opacity: 0.9; }
.btn-primary:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
.btn-primary:disabled { opacity: 0.4; cursor: not-allowed; }

/* Secondary */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  border: 1px solid var(--border-default);
  transition: background 150ms ease;
}
.btn-secondary:hover { background: var(--bg-elevated); }

/* Ghost */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 400;
  border: none;
  transition: color 150ms ease;
}
.btn-ghost:hover { color: var(--text-primary); }

/* Danger — Critical fleet actions (force restart, rollback) */
.btn-danger {
  background: transparent;
  color: var(--health-critical);
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  border: 1px solid var(--health-critical);
  transition: background 150ms ease;
}
.btn-danger:hover {
  background: var(--health-critical-muted);
}
```

### Form Inputs

```css
.input {
  background: var(--bg-surface);
  color: var(--text-primary);
  padding: 8px 12px;
  border: 1px solid var(--border-default);
  border-radius: 6px;
  font-size: 14px;
  font-family: var(--font-sans);
  transition: border-color 150ms ease;
}
.input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted);
  outline: none;
}
.input::placeholder {
  color: var(--text-tertiary);
}
.input--error {
  border-color: var(--health-critical);
  box-shadow: 0 0 0 3px var(--health-critical-muted);
}

/* Device ID, MQTT topic, YAML inputs use mono */
.input--code {
  font-family: var(--font-mono);
  font-size: 14px;
}

/* Search — fleet search, device filter */
.input--search {
  padding-left: 36px; /* icon space */
  background-image: url('search-icon.svg');
  background-repeat: no-repeat;
  background-position: 12px center;
  background-size: 16px;
}
```

### Cards

```css
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  padding: 16px;
}
.card:hover {
  border-color: var(--text-tertiary);
  transition: border-color 150ms ease;
}

/* Bento grid card — overview dashboard */
.card--bento {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  padding: 24px;
}

/* Metric card — fleet health score, agent count */
.card--metric {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  padding: 24px;
}
.card--metric .metric-value {
  font-size: 48px;
  font-weight: 600;
  font-family: var(--font-mono);
  line-height: 1.1;
  letter-spacing: -0.02em;
}
.card--metric .metric-label {
  font-size: 12px;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-top: 8px;
}

/* No background color variations — differentiate cards by content, not fill */
```

### Navigation

```css
.sidebar {
  width: 260px;
  min-width: 260px;
  background: var(--bg-primary);
  border-right: 1px solid var(--border-default);
  padding: 16px 0;
  display: flex;
  flex-direction: column;
  height: 100vh;
  position: sticky;
  top: 0;
  transition: width 200ms ease-out, min-width 200ms ease-out;
}
.sidebar--collapsed {
  width: 64px;
  min-width: 64px;
}

/* Logo — top of sidebar */
.sidebar-logo {
  padding: 8px 16px 16px;
  font-size: 18px;
  font-weight: 600;
  font-family: var(--font-sans);
  color: var(--text-primary);
}

/* Fleet selector — below logo */
.fleet-selector {
  margin: 0 12px 16px;
  padding: 8px 12px;
  background: var(--bg-elevated);
  border: 1px solid var(--border-default);
  border-radius: 6px;
  font-size: 13px;
  color: var(--text-primary);
  cursor: pointer;
}
.fleet-selector:hover {
  border-color: var(--text-tertiary);
}

/* Nav items */
.nav-item {
  padding: 8px 16px;
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 400;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: color 150ms ease, background 150ms ease;
}
.nav-item:hover {
  color: var(--text-primary);
  background: var(--bg-surface);
}
.nav-item--active {
  color: var(--accent);
  background: var(--accent-muted);
  font-weight: 600;
}
.nav-group-label {
  padding: 24px 16px 8px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-tertiary);
}

/* Settings — pinned to bottom */
.sidebar-footer {
  margin-top: auto;
  border-top: 1px solid var(--border-subtle);
  padding-top: 8px;
}
```

### Tables

```css
/* Fleet management is a table-heavy interface */
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}
.table th {
  text-align: left;
  padding: 8px 12px;
  font-size: 12px;
  font-weight: 600;
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid var(--border-default);
  position: sticky;
  top: 0;
  background: var(--bg-primary);
  z-index: 1;
}
.table td {
  padding: 12px;
  border-bottom: 1px solid var(--border-subtle);
  color: var(--text-primary);
  vertical-align: middle;
}
.table tr:hover td {
  background: var(--bg-surface);
}

/* Compact variant — for high-density device lists */
.table--compact td {
  padding: 8px 12px;
  font-size: 13px;
}

/* Monospace cells — device IDs, telemetry, timestamps */
.table .cell-mono {
  font-family: var(--font-mono);
  font-size: 13px;
  color: var(--text-secondary);
}

/* Sortable column header */
.table th[data-sortable] {
  cursor: pointer;
  user-select: none;
}
.table th[data-sortable]:hover {
  color: var(--text-secondary);
}
.table th[data-sort-active] {
  color: var(--text-primary);
}

/* Inline sparkline cell */
.table .cell-sparkline {
  width: 120px;
  padding: 8px 12px;
}
.cell-sparkline svg {
  display: block;
}
```

### Status Indicators

```css
/* Small status dot — used inline in tables, nav, device lists */
.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
.status-dot--healthy { background: var(--health-healthy); }
.status-dot--warning { background: var(--health-warning); }
.status-dot--critical {
  background: var(--health-critical);
  animation: pulse-critical 2s ease-in-out infinite;
}
.status-dot--offline { background: var(--health-offline); }
.status-dot--updating {
  background: var(--health-updating);
  animation: pulse-updating 1.5s ease-in-out infinite;
}

@keyframes pulse-critical {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
@keyframes pulse-updating {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}

/* Status badge — larger, with label */
.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 2px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  font-family: var(--font-mono);
}
.status-badge--healthy { background: var(--health-healthy-muted); color: var(--health-healthy); }
.status-badge--warning { background: var(--health-warning-muted); color: var(--health-warning); }
.status-badge--critical { background: var(--health-critical-muted); color: var(--health-critical); }
.status-badge--offline { background: var(--health-offline-muted); color: var(--health-offline); }
.status-badge--updating { background: var(--health-updating-muted); color: var(--health-updating); }
```

### Agent Activity Feed

```css
/* Timeline of agent actions — right panel or embedded in overview */
.activity-feed {
  display: flex;
  flex-direction: column;
  gap: 0;
}
.activity-item {
  display: flex;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--border-subtle);
}
.activity-item:last-child {
  border-bottom: none;
}
.activity-timeline {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 20px;
  flex-shrink: 0;
}
.activity-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-top: 6px;
}
.activity-line {
  width: 1px;
  flex: 1;
  background: var(--border-subtle);
  margin-top: 4px;
}
.activity-content {
  flex: 1;
  min-width: 0;
}
.activity-action {
  font-size: 14px;
  color: var(--text-primary);
  line-height: 1.4;
}
.activity-meta {
  font-size: 12px;
  font-family: var(--font-mono);
  color: var(--text-tertiary);
  margin-top: 4px;
}
```

### Topology Node

```css
/* Device node in fleet topology view */
.topo-node {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  transition: transform 150ms ease, box-shadow 150ms ease;
  cursor: pointer;
}
.topo-node:hover {
  transform: scale(1.5);
  box-shadow: 0 0 0 4px var(--bg-elevated);
}
.topo-node--selected {
  transform: scale(2);
  box-shadow: 0 0 0 3px var(--accent-muted), 0 0 0 1px var(--accent);
}

/* Health states */
.topo-node--healthy { background: var(--health-healthy); }
.topo-node--warning { background: var(--health-warning); }
.topo-node--critical { background: var(--health-critical); }
.topo-node--offline { background: var(--health-offline); opacity: 0.5; }
.topo-node--updating { background: var(--health-updating); }

/* Agent overlay on topology — shows agent coverage area */
.topo-agent-zone {
  border: 1px dashed var(--accent);
  border-radius: 12px;
  background: var(--accent-muted);
  padding: 8px;
}
```

### Toast Notifications

```css
/* Agent action notifications — bottom-right */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 16px;
  background: var(--bg-elevated);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  max-width: 400px;
  animation: toast-in 200ms ease-out;
  z-index: 1000;
}
.toast--success { border-left: 3px solid var(--health-healthy); }
.toast--warning { border-left: 3px solid var(--health-warning); }
.toast--error { border-left: 3px solid var(--health-critical); }
.toast--info { border-left: 3px solid var(--accent); }

.toast-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
}
.toast-body {
  font-size: 13px;
  color: var(--text-secondary);
  margin-top: 4px;
}
.toast-timestamp {
  font-size: 11px;
  font-family: var(--font-mono);
  color: var(--text-tertiary);
  margin-top: 4px;
}

@keyframes toast-in {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
```

### Skeleton Loading

```css
/* No spinners — skeleton placeholders only */
.skeleton {
  background: var(--bg-surface);
  border-radius: 4px;
  position: relative;
  overflow: hidden;
}
.skeleton::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    90deg,
    transparent 0%,
    var(--bg-elevated) 50%,
    transparent 100%
  );
  animation: skeleton-shimmer 1.5s ease-in-out infinite;
}
@keyframes skeleton-shimmer {
  from { transform: translateX(-100%); }
  to { transform: translateX(100%); }
}

/* Skeleton variants */
.skeleton--text { height: 14px; width: 60%; }
.skeleton--metric { height: 48px; width: 120px; }
.skeleton--sparkline { height: 32px; width: 100%; }
.skeleton--row { height: 44px; width: 100%; margin-bottom: 1px; }
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Opacity fade | 150ms | ease |
| Input focus | Border + glow ring | 150ms | ease |
| Nav item hover | Background fade | 150ms | ease |
| Sidebar collapse | Width slide | 200ms | ease-out |
| Card hover | Border color shift | 150ms | ease |
| Topology node hover | Scale 1.5x | 150ms | ease |
| Toast notification | Slide up + fade in | 200ms | ease-out |
| Toast dismiss | Fade out + slide down | 150ms | ease-in |
| Skeleton shimmer | Translate X sweep | 1.5s | ease-in-out, infinite |
| Telemetry number update | Counter tick transition | 300ms | ease-out |
| Status dot (critical) | Pulse opacity | 2s | ease-in-out, infinite |
| Status dot (updating) | Pulse opacity | 1.5s | ease-in-out, infinite |
| Fleet health score load | Count-up from 0 | 800ms | ease-out |
| Table sort | Row reorder | 200ms | ease-out |
| Panel slide (device detail) | SlideX from right | 200ms | ease-out |

**Motion philosophy:** Functional only. No decorative animations. The two signature moments:

1. **Telemetry updates** — when real-time data arrives, numbers transition smoothly between values (counter tick, not page refresh). This creates the "live system" feel without visual noise.

2. **Fleet health score on load** — the hero metric counts up from 0 to its value (e.g., 98.4%) over 800ms. This is the one moment of drama in the interface — it communicates "we just checked everything."

All animations respect `prefers-reduced-motion` by collapsing to instant state changes:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Data Visualization

**Chart library recommendation:** Recharts or Tremor (React), or D3 for the topology view.

### General Principles

- Teal accent (`--accent`) for primary data series
- `--text-tertiary` for secondary/comparison data
- Device health colors for status-coded data only (never decorative)
- No grid lines — use subtle horizontal reference lines at most (`--border-subtle`)
- Minimal axis labels — bottom axis for time, left axis for value, both in Caption size (12px) and `--text-tertiary`
- Interactive tooltips on hover, styled as `--bg-elevated` with `--border-default` border
- No 3D effects, no drop shadows on chart elements

### Sparklines

```css
/* Inline sparklines in tables and cards */
.sparkline {
  height: 32px;
  width: 120px;
}
.sparkline-path {
  fill: none;
  stroke: var(--accent);
  stroke-width: 1.5px;
}
.sparkline-area {
  fill: var(--accent-muted);
}

/* Health-coded sparkline — changes color based on threshold */
.sparkline-path--healthy { stroke: var(--health-healthy); }
.sparkline-path--warning { stroke: var(--health-warning); }
.sparkline-path--critical { stroke: var(--health-critical); }
```

### Heatmaps

- Used for fleet health overview — devices as cells, color = health status
- Cell size: 8px minimum with 1px gap
- Color mapping: direct health color mapping (healthy/warning/critical/offline)
- On hover: tooltip with device ID (mono), current reading, last update timestamp

### Time-Series Charts

- Default time window: 24 hours
- Line weight: 1.5px
- Data point dots: hidden by default, appear on hover
- Current value: displayed as a number label at the end of the line, mono font
- Threshold lines: dashed, using health-warning or health-critical color at 0.5 opacity

### Fleet Health Score

- Donut or ring chart, single value
- Ring color: segmented by health status breakdown
- Center: large mono number (Display size) showing percentage
- Ring thickness: 8px
- Background ring: `--border-subtle`

---

## Asset Guidelines

**Photography:** None. This is a data interface. Zero decorative imagery.

**Iconography:** Lucide icons, 18px default, 1.5px stroke weight. Monochrome — uses `currentColor`. Always outlined, never filled. Key icons:
- `server` — devices
- `cpu` — agents
- `play` — playbooks
- `activity` — telemetry
- `alert-triangle` — anomalies
- `check-circle` — healthy
- `x-circle` — critical
- `wifi-off` — offline
- `refresh-cw` — updating
- `terminal` — agent reasoning log

**Illustrations:** None. Empty states use icon + text only:
- "No devices connected" — `server` icon at 48px, `--text-tertiary`, single CTA button
- "No agents deployed" — `cpu` icon at 48px
- Pattern: icon (48px, tertiary) + heading (H3) + description (Body Small, secondary) + primary CTA button

**Logo direction:** Wordmark only. "iotgo" in Geist at 600 weight, all lowercase. The "go" can be styled in accent color (teal) as a subtle brand element: `iot`(primary) + `go`(accent). Alternatively, monochrome wordmark for sidebar.

**Favicon:** Minimal mark — a single teal dot, representing a healthy device node. 32x32 and 16x16 variants.

---

## Keyboard Shortcuts

IoT operators live in the keyboard. The interface should be navigable without a mouse.

| Shortcut | Action |
|----------|--------|
| `g` then `o` | Go to Overview |
| `g` then `f` | Go to Fleets |
| `g` then `a` | Go to Agents |
| `g` then `p` | Go to Playbooks |
| `/` | Focus search |
| `k` | Open command palette |
| `j` / `k` | Navigate list items (down/up) |
| `Enter` | Open selected item |
| `Esc` | Close panel / deselect |
| `[` | Collapse sidebar |
| `]` | Expand sidebar |
| `?` | Show shortcut help |

Command palette: opens center-screen, `--bg-elevated` background, search input at top, fuzzy-matched results below. Styled like Linear's command menu.

---

## Implementation Checklist

### Typography & Color
- [ ] Single typeface family (Geist) with mono variant (Geist Mono)
- [ ] Two font weights maximum (400, 600) — never bold (700)
- [ ] Accent (teal) used only for CTAs, active states, focus rings, connectivity indicators
- [ ] Device health colors (healthy/warning/critical/offline/updating) are the primary visual system
- [ ] Health-muted variants for backgrounds and row highlights, never full-opacity fills on large areas
- [ ] Background is 80%+ of visual field
- [ ] No gradients anywhere in the interface
- [ ] Dark mode only — no light mode toggle

### Layout
- [ ] Sidebar collapses from 240–280px to 64px icon rail
- [ ] Sidebar structure: logo, fleet selector, main nav, settings (bottom)
- [ ] Bento grid overview with: fleet health score, active agents, recent actions, anomaly feed, device status breakdown
- [ ] Fleet topology view as hero surface
- [ ] Max-width 1440px on wide viewports

### Components
- [ ] All buttons: 6px radius, no shadows
- [ ] All inputs: 6px radius, 1px border, teal focus ring
- [ ] All cards: 8px radius, 1px border, no background color variation between cards
- [ ] Tables: compact rows (12px padding), monospace for device IDs / telemetry / timestamps
- [ ] Tables: sortable columns, filterable, sticky headers
- [ ] Status dots: 8px, rounded-full, health-colored
- [ ] No border-radius greater than 12px anywhere
- [ ] No decorative elements or illustrations

### Data & Telemetry
- [ ] Sparklines inline in table cells for telemetry trends
- [ ] Telemetry values update via number transition, not page refresh
- [ ] Heatmap for fleet-wide health overview
- [ ] Charts: teal primary series, gray secondary, minimal chrome
- [ ] All data values rendered in monospace

### Interaction
- [ ] 150ms micro-interactions, 300ms max for content transitions
- [ ] Skeleton loading — no spinners
- [ ] Toast notifications bottom-right for agent actions
- [ ] All animations respect `prefers-reduced-motion`
- [ ] Keyboard shortcuts implemented (g-then-key navigation, `/` for search, `k` for command palette)

### Accessibility
- [ ] Color contrast meets WCAG AA (text-primary #E4E4E8 on bg-primary #09090B)
- [ ] Touch targets >= 44px on mobile
- [ ] Status communicated through shape/label in addition to color (not color-only)
- [ ] Focus states visible on all interactive elements
- [ ] Topology nodes keyboard-navigable
- [ ] Screen reader labels for all status indicators

### Do Not
- [ ] No decorative elements, illustrations, or stock photography
- [ ] No multiple accent colors — teal only
- [ ] No border-radius > 12px
- [ ] No gradients
- [ ] No spinners (skeletons only)
- [ ] No light mode

---

*Derived from: minimal-tech.md*
*Product: iotgo.io*
*Direction: Dark Ops Console*
