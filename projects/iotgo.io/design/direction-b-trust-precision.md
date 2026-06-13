---
project: IOTGO
domain: iotgo.io
direction: B
name: Trust + Precision
style_system: Minimal Tech 80% + Corporate Enterprise 20%
one_liner: Autonomous agents, enterprise trust
status: Design direction
created: 2026-03-13
---

# Direction B: Trust + Precision

**Style System:** Minimal Tech 80% + Corporate Enterprise 20%
**One-liner:** Autonomous agents, enterprise trust

---

## Scenario

IoTGo deploys autonomous AI agents that monitor IoT device telemetry, detect anomalies, execute remediation playbooks, and optimize configurations across device fleets ranging from 500 to 100K+ endpoints. The platform sits on top of existing IoT infrastructure — AWS IoT Core, Azure IoT Hub, ThingsBoard — and adds an intelligence layer that closes the detect-act loop without waiting for a human operator to read a dashboard at 3am.

Direction B targets enterprise buyers: CISOs evaluating security posture, VPs of Operations justifying IoT spend, procurement teams running vendor assessments against SOC 2 and ISO 27001 checklists. These buyers need the technical capability — the anomaly detection, the playbook execution, the fleet-wide canary rollouts — but they also need to *trust* the platform with critical infrastructure. A misfired firmware rollout bricks 10,000 sensors. A rogue agent action trips a safety system. The trust barrier is the #1 adoption gate, and the visual language must address it directly.

The 20% Corporate Enterprise influence serves this trust requirement without tipping the interface into legacy enterprise territory. Serif headings (Source Serif 4) at H1/H2 add institutional authority. Button radii tighten from 6px to 4px for a more conservative, reliable feel. Table headers get background fills for formal report scanability. Compliance badges and audit trails are first-class UI citizens, not afterthoughts. Transition timing slows from 150ms to 200ms — deliberate, not flashy. The result reads as "Datadog if it were selling to a CISO" rather than "SAP with a dark theme."

---

## Color Palette

### CSS Custom Properties

```css
:root {
  /* ── Surfaces ──────────────────────────────────── */
  --color-bg:             #09090B;
  --color-surface:        #111116;
  --color-elevated:       #1A1A22;
  --color-table-header:   #141420;

  /* ── Text ──────────────────────────────────────── */
  --color-text-primary:   #E4E4E8;
  --color-text-secondary: #8A8A98;
  --color-text-tertiary:  #52526A;

  /* ── Borders ───────────────────────────────────── */
  --color-border:         #252530;

  /* ── Accent: Teal ──────────────────────────────── */
  --color-accent:         #0D9488;
  --color-accent-hover:   #14B8A6;
  --color-accent-muted:   rgba(13, 148, 136, 0.10);

  /* ── CE Influence: Navy ────────────────────────── */
  --color-navy:           #1E3A5F;
  --color-navy-muted:     rgba(30, 58, 95, 0.15);

  /* ── Device Health ─────────────────────────────── */
  --color-healthy:        #22C55E;
  --color-warning:        #EAB308;
  --color-critical:       #EF4444;
  --color-offline:        #6B7280;
  --color-updating:       #A78BFA;

  /* ── Semantic ──────────────────────────────────── */
  --color-info:           #60A5FA;

  /* ── Typography ────────────────────────────────── */
  --font-serif:           'Source Serif 4', 'Georgia', serif;
  --font-sans:            'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-mono:            'JetBrains Mono', 'Fira Code', 'Consolas', monospace;

  /* ── Spacing (8px base) ────────────────────────── */
  --space-1:              4px;
  --space-2:              8px;
  --space-3:              12px;
  --space-4:              16px;
  --space-5:              20px;
  --space-6:              24px;
  --space-7:              28px;
  --space-8:              32px;
  --space-10:             40px;
  --space-12:             48px;
  --space-16:             64px;
  --space-20:             80px;   /* CE influence: section padding */

  /* ── Layout ────────────────────────────────────── */
  --grid-columns:         12;
  --grid-max-width:       1440px;
  --grid-gutter:          24px;

  /* ── Radii ─────────────────────────────────────── */
  --radius-sm:            2px;
  --radius-md:            4px;    /* CE influence: tighter than MT's 6px */
  --radius-lg:            8px;
  --radius-full:          9999px;

  /* ── Shadows ───────────────────────────────────── */
  --shadow-button:        0 1px 2px rgba(0, 0, 0, 0.2);
  --shadow-card:          0 1px 3px rgba(0, 0, 0, 0.15);
  --shadow-elevated:      0 4px 12px rgba(0, 0, 0, 0.25);

  /* ── Transitions ───────────────────────────────── */
  --duration-fast:        100ms;
  --duration-base:        200ms;  /* CE influence: more deliberate than MT's 150ms */
  --duration-slow:        300ms;
  --easing-default:       cubic-bezier(0.4, 0, 0.2, 1);
}
```

### ASCII Palette Diagram

```
 SURFACES                          TEXT
 ┌──────────┐ ┌──────────┐ ┌──────────┐   ┌──────────┐ ┌──────────┐ ┌──────────┐
 │          │ │          │ │          │   │ ████████ │ │ ████████ │ │ ████████ │
 │ #09090B  │ │ #111116  │ │ #1A1A22  │   │ #E4E4E8  │ │ #8A8A98  │ │ #52526A  │
 │ bg       │ │ surface  │ │ elevated │   │ primary  │ │ secondary│ │ tertiary │
 └──────────┘ └──────────┘ └──────────┘   └──────────┘ └──────────┘ └──────────┘

 ACCENT                            CE INFLUENCE
 ┌──────────┐ ┌──────────┐ ┌──────────┐   ┌──────────┐
 │ ████████ │ │ ████████ │ │ ░░░░░░░░ │   │ ████████ │
 │ #0D9488  │ │ #14B8A6  │ │ 10% teal │   │ #1E3A5F  │
 │ accent   │ │ hover    │ │ muted    │   │ navy     │
 └──────────┘ └──────────┘ └──────────┘   └──────────┘

 DEVICE HEALTH                     SEMANTIC
 ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   ┌──────────┐
 │ ████████ │ │ ████████ │ │ ████████ │ │ ████████ │ │ ████████ │   │ ████████ │
 │ #22C55E  │ │ #EAB308  │ │ #EF4444  │ │ #6B7280  │ │ #A78BFA  │   │ #60A5FA  │
 │ healthy  │ │ warning  │ │ critical │ │ offline  │ │ updating │   │ info     │
 └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘   └──────────┘

 BORDER
 ┌──────────┐ ┌──────────┐
 │ ──────── │ │ ──────── │
 │ #252530  │ │ #141420  │
 │ border   │ │ tbl-head │
 └──────────┘ └──────────┘
```

---

## Typography

### Font Sources

| Font | Source | URL |
|------|--------|-----|
| Source Serif 4 | Google Fonts | `https://fonts.google.com/specimen/Source+Serif+4` |
| Inter | Google Fonts | `https://fonts.google.com/specimen/Inter` |
| JetBrains Mono | JetBrains / Google Fonts | `https://fonts.google.com/specimen/JetBrains+Mono` |

**Load string:**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&family=Source+Serif+4:wght@700&display=swap" rel="stylesheet">
```

### Type Scale

| Level | Font | Size | Weight | Line Height | Letter Spacing | Use |
|-------|------|------|--------|-------------|----------------|-----|
| H1 | Source Serif 4 | 38px / 2.375rem | 700 | 1.25 | -0.01em | Page titles |
| H2 | Source Serif 4 | 26px / 1.625rem | 700 | 1.3 | -0.005em | Section headers |
| H3 | Inter | 20px / 1.25rem | 600 | 1.4 | 0 | Subsections |
| H4 | Inter | 16px / 1rem | 600 | 1.5 | 0 | Card titles |
| Body | Inter | 16px / 1rem | 400 | 1.7 | 0 | Primary content |
| Body Small | Inter | 14px / 0.875rem | 400 | 1.6 | 0 | Secondary content |
| Caption | Inter | 12px / 0.75rem | 500 | 1.5 | 0.01em | Labels, metadata |
| Data | JetBrains Mono | 13px / 0.8125rem | 400 | 1.4 | 0 | Telemetry, IDs, timestamps |
| Overline | Inter | 11px / 0.6875rem | 600 | 1.4 | 0.08em | Category labels (uppercase) |

**CE influence note:** Body line height is 1.7 (vs MT standard 1.6). This creates slightly more generous vertical rhythm in content blocks, reading as more polished and less compressed. Serif at H1/H2 only — below that, Inter takes over to maintain density and readability at smaller sizes.

### Typography CSS

```css
h1 {
  font-family: var(--font-serif);
  font-size: 2.375rem;
  font-weight: 700;
  line-height: 1.25;
  letter-spacing: -0.01em;
  color: var(--color-text-primary);
}

h2 {
  font-family: var(--font-serif);
  font-size: 1.625rem;
  font-weight: 700;
  line-height: 1.3;
  letter-spacing: -0.005em;
  color: var(--color-text-primary);
}

h3 {
  font-family: var(--font-sans);
  font-size: 1.25rem;
  font-weight: 600;
  line-height: 1.4;
  color: var(--color-text-primary);
}

h4 {
  font-family: var(--font-sans);
  font-size: 1rem;
  font-weight: 600;
  line-height: 1.5;
  color: var(--color-text-primary);
}

body {
  font-family: var(--font-sans);
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.7;
  color: var(--color-text-primary);
  background-color: var(--color-bg);
}

.text-small {
  font-size: 0.875rem;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

.text-caption {
  font-size: 0.75rem;
  font-weight: 500;
  line-height: 1.5;
  letter-spacing: 0.01em;
  color: var(--color-text-secondary);
}

.text-data {
  font-family: var(--font-mono);
  font-size: 0.8125rem;
  font-weight: 400;
  line-height: 1.4;
  color: var(--color-text-primary);
}

.text-overline {
  font-family: var(--font-sans);
  font-size: 0.6875rem;
  font-weight: 600;
  line-height: 1.4;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--color-text-tertiary);
}
```

---

## Spacing Scale

Base unit: **8px**

| Token | Value | Use |
|-------|-------|-----|
| `--space-1` | 4px | Inline icon gaps, tight padding |
| `--space-2` | 8px | Compact element spacing |
| `--space-3` | 12px | Input padding, small gaps |
| `--space-4` | 16px | Standard component padding |
| `--space-5` | 20px | Card internal margins |
| `--space-6` | 24px | Grid gutters, group spacing |
| `--space-7` | 28px | Card padding (CE influence: slightly more generous) |
| `--space-8` | 32px | Section internal padding |
| `--space-10` | 40px | Major component gaps |
| `--space-12` | 48px | Section breaks (within page) |
| `--space-16` | 64px | Large section dividers |
| `--space-20` | 80px | Page section padding (CE influence) |

**CE influence note:** Section padding bumps from MT's typical 48-64px to 80px. This creates more vertical breathing room between major page sections (Overview, Fleets, Agents). At data-dense component level, spacing remains compact (8-16px) to preserve information density. The extra whitespace lives between sections, not within them.

---

## Grid

```
┌─────────────────────────────────────── 1440px max-width ──────────────────────────────────────┐
│  24px  │ col │ 24px │ col │ 24px │ col │ 24px │ col │ 24px │ col │ 24px │ col │  24px  │
│ gutter │     │      │     │      │     │      │     │      │     │      │     │ gutter │
│        │  1  │      │  2  │      │  3  │      │  4  │      │  5  │      │  6  │        │
│        │     │      │     │      │     │      │     │      │     │      │     │        │
│        │  7  │      │  8  │      │  9  │      │ 10  │      │ 11  │      │ 12  │        │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Columns:** 12
- **Max width:** 1440px (optimized for data density on wide monitors)
- **Gutter:** 24px
- **Sidebar:** Fixed 260px (not part of grid), content area fills remainder
- **Breakpoints:** 768px (tablet collapse), 1024px (sidebar overlay), 1440px+ (centered)

---

## Components

### Buttons

```css
.btn {
  font-family: var(--font-sans);
  font-size: 0.875rem;
  font-weight: 600;
  line-height: 1;
  padding: 10px 20px;
  border-radius: var(--radius-md);          /* 4px — CE influence */
  border: 1px solid transparent;
  cursor: pointer;
  transition: all var(--duration-base) var(--easing-default);
}

.btn-primary {
  background-color: var(--color-accent);
  color: #FFFFFF;
  box-shadow: var(--shadow-button);          /* CE influence */
}

.btn-primary:hover {
  background-color: var(--color-accent-hover);
}

.btn-secondary {
  background-color: transparent;
  color: var(--color-text-primary);
  border-color: var(--color-border);
}

.btn-secondary:hover {
  background-color: var(--color-elevated);
  border-color: var(--color-text-tertiary);
}

.btn-ghost {
  background-color: transparent;
  color: var(--color-text-secondary);
  padding: 8px 12px;
}

.btn-ghost:hover {
  color: var(--color-text-primary);
  background-color: var(--color-accent-muted);
}

.btn-danger {
  background-color: transparent;
  color: var(--color-critical);
  border-color: var(--color-critical);
}

.btn-danger:hover {
  background-color: rgba(239, 68, 68, 0.10);
}

/* Sizes */
.btn-sm { padding: 6px 12px; font-size: 0.75rem; }
.btn-lg { padding: 14px 28px; font-size: 1rem; }
```

### Form Inputs

```css
.input {
  font-family: var(--font-sans);
  font-size: 0.875rem;
  line-height: 1.5;
  padding: 10px 12px;
  background-color: var(--color-surface);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);           /* 4px */
  transition: border-color var(--duration-base) var(--easing-default);
  width: 100%;
}

.input:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 2px var(--color-accent-muted);
}

.input-label {
  display: block;
  font-family: var(--font-sans);
  font-size: 0.875rem;
  font-weight: 600;                          /* CE influence: always visible, strong weight */
  color: var(--color-text-primary);
  margin-bottom: var(--space-2);
}

.input-hint {
  font-size: 0.75rem;
  color: var(--color-text-tertiary);
  margin-top: var(--space-1);
}

.input-error {
  border-color: var(--color-critical);
}

.input-error-message {
  font-size: 0.75rem;
  color: var(--color-critical);
  margin-top: var(--space-1);
}
```

### Cards

```css
.card {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);           /* 8px */
  padding: var(--space-7);                   /* 28px — CE influence: slightly more generous */
  transition: border-color var(--duration-base) var(--easing-default);
}

.card:hover {
  border-color: var(--color-text-tertiary);
}

.card-header {
  padding-bottom: var(--space-4);
  margin-bottom: var(--space-4);
  border-bottom: 1px solid var(--color-border);  /* CE pattern: header separator */
}

.card-header h4 {
  margin: 0;
}

.card-header .card-subtitle {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  margin-top: var(--space-1);
}

.card-body {
  /* Content area — no additional padding, inherits from .card */
}

.card-footer {
  padding-top: var(--space-4);
  margin-top: var(--space-4);
  border-top: 1px solid var(--color-border);
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
}
```

### Tables

```css
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.table th {
  font-family: var(--font-sans);
  font-size: 0.75rem;
  font-weight: 600;
  text-align: left;
  padding: 10px 16px;
  color: var(--color-text-secondary);
  background-color: var(--color-table-header);  /* CE influence: background fill */
  border-bottom: 2px solid var(--color-border);  /* CE influence: stronger border */
  white-space: nowrap;
}

.table td {
  padding: 10px 16px;
  color: var(--color-text-primary);
  border-bottom: 1px solid var(--color-border);
  vertical-align: middle;
}

.table tr:hover td {
  background-color: var(--color-elevated);
}

.table .cell-mono {
  font-family: var(--font-mono);
  font-size: 0.8125rem;
}

.table .cell-status {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.table .cell-status::before {
  content: '';
  width: 8px;
  height: 8px;
  border-radius: var(--radius-full);
  flex-shrink: 0;
}

.table .cell-status.healthy::before  { background-color: var(--color-healthy); }
.table .cell-status.warning::before  { background-color: var(--color-warning); }
.table .cell-status.critical::before { background-color: var(--color-critical); }
.table .cell-status.offline::before  { background-color: var(--color-offline); }
.table .cell-status.updating::before { background-color: var(--color-updating); }
```

### Navigation — Sidebar

```css
.sidebar {
  width: 260px;
  height: 100vh;
  position: fixed;
  left: 0;
  top: 0;
  background-color: var(--color-surface);
  border-right: 1px solid var(--color-border);
  padding: var(--space-6) 0;
  display: flex;
  flex-direction: column;
  z-index: 100;
}

.sidebar-logo {
  padding: 0 var(--space-6);
  margin-bottom: var(--space-8);
  font-family: var(--font-sans);
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--color-text-primary);
  letter-spacing: -0.02em;
}

.sidebar-nav-item {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: 10px var(--space-6);
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: all var(--duration-base) var(--easing-default);
}

.sidebar-nav-item:hover {
  color: var(--color-text-primary);
  background-color: var(--color-elevated);
}

.sidebar-nav-item.active {
  color: var(--color-accent);
  background-color: var(--color-accent-muted);
}
```

### Trust Bar (CE Influence)

A persistent bar at the top of the content area showing fleet-wide status and trust signals.

```css
.trust-bar {
  display: flex;
  align-items: center;
  gap: var(--space-6);
  padding: 10px var(--space-6);
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  font-size: 0.75rem;
  color: var(--color-text-secondary);
}

.trust-bar-item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.trust-bar-item .label {
  font-weight: 500;
  color: var(--color-text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-size: 0.6875rem;
}

.trust-bar-item .value {
  font-family: var(--font-mono);
  font-size: 0.8125rem;
  color: var(--color-text-primary);
}

.trust-bar-item .value.healthy { color: var(--color-healthy); }
.trust-bar-item .value.warning { color: var(--color-warning); }
```

**Trust bar contents:**
- Fleet Health Score (composite %, color-coded)
- Last Sync (timestamp, mono)
- Agent Status (X active / Y total)
- Account Tier (Pro / Team / Enterprise badge)

### Confirmation Dialogs (CE Influence)

Formal confirmation for Level 2+ agent actions.

```css
.dialog-overlay {
  position: fixed;
  inset: 0;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.dialog {
  background-color: var(--color-elevated);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--space-8);
  max-width: 480px;
  width: 100%;
}

.dialog-title {
  font-family: var(--font-sans);
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: var(--space-3);
}

.dialog-body {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  line-height: 1.6;
  margin-bottom: var(--space-6);
}

.dialog-action-summary {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--space-4);
  margin-bottom: var(--space-6);
  font-family: var(--font-mono);
  font-size: 0.8125rem;
  color: var(--color-text-primary);
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
}
```

### Toast Notifications

```css
.toast {
  position: fixed;
  bottom: var(--space-6);
  right: var(--space-6);
  display: flex;
  align-items: flex-start;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  background-color: var(--color-elevated);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-elevated);
  max-width: 420px;
  z-index: 2000;
  animation: toast-in var(--duration-slow) var(--easing-default);
}

.toast-success { border-left: 3px solid var(--color-healthy); }
.toast-warning { border-left: 3px solid var(--color-warning); }
.toast-error   { border-left: 3px solid var(--color-critical); }
.toast-info    { border-left: 3px solid var(--color-info); }

.toast-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-text-primary);
}

.toast-message {
  font-size: 0.8125rem;
  color: var(--color-text-secondary);
  line-height: 1.5;
  margin-top: var(--space-1);
}

@keyframes toast-in {
  from {
    opacity: 0;
    transform: translateY(12px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

**Toast language (CE influence):** Formal tone. "Agent restarted 3 devices in fleet:warehouse-east. All endpoints reporting healthy." Not "Done!" or "3 devices restarted."

### Skeleton Screens

```css
.skeleton {
  background: linear-gradient(
    90deg,
    var(--color-surface) 0%,
    var(--color-elevated) 50%,
    var(--color-surface) 100%
  );
  background-size: 200% 100%;
  animation: skeleton-pulse 1.8s ease-in-out infinite;
  border-radius: var(--radius-md);
}

.skeleton-text {
  height: 14px;
  margin-bottom: var(--space-2);
}

.skeleton-heading {
  height: 28px;
  width: 60%;
  margin-bottom: var(--space-4);
}

.skeleton-progress-text {
  font-size: 0.75rem;
  color: var(--color-text-tertiary);
  margin-top: var(--space-3);
  text-align: center;
}

@keyframes skeleton-pulse {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

**Progress text examples:** "Connecting to fleet...", "Loading telemetry for 2,847 devices...", "Syncing agent configurations..."

### Status Badges

```css
.badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 8px;
  font-size: 0.6875rem;
  font-weight: 600;
  border-radius: var(--radius-full);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.badge-healthy  { background-color: rgba(34, 197, 94, 0.12);  color: var(--color-healthy); }
.badge-warning  { background-color: rgba(234, 179, 8, 0.12);  color: var(--color-warning); }
.badge-critical { background-color: rgba(239, 68, 68, 0.12);  color: var(--color-critical); }
.badge-offline  { background-color: rgba(107, 114, 128, 0.12); color: var(--color-offline); }
.badge-updating { background-color: rgba(167, 139, 250, 0.12); color: var(--color-updating); }
.badge-info     { background-color: rgba(96, 165, 250, 0.12);  color: var(--color-info); }
```

### Autonomy Level Indicator

```css
.autonomy-level {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: 0.75rem;
  color: var(--color-text-secondary);
}

.autonomy-level-dots {
  display: flex;
  gap: 3px;
}

.autonomy-level-dot {
  width: 6px;
  height: 6px;
  border-radius: var(--radius-full);
  background-color: var(--color-border);
}

.autonomy-level-dot.filled {
  background-color: var(--color-accent);
}

/* Level 0: 0 filled, Level 4: 4 filled (out of 4 dots) */
```

---

## Interaction Patterns

| Pattern | Timing | Easing | Notes |
|---------|--------|--------|-------|
| Button hover | 200ms | ease-out | Background + border color shift |
| Button press | 100ms | ease-in | Scale 0.98 transform |
| Card hover | 200ms | ease-out | Border color lightens |
| Sidebar nav item | 200ms | ease-out | Background + text color |
| Input focus | 200ms | ease-out | Border color + box-shadow ring |
| Toast enter | 300ms | ease-out | Slide up 12px + fade in |
| Toast exit | 200ms | ease-in | Fade out |
| Dialog enter | 200ms | ease-out | Scale 0.96 -> 1.0 + fade in |
| Dialog exit | 150ms | ease-in | Fade out |
| Skeleton pulse | 1800ms | ease-in-out | Infinite shimmer |
| Dropdown open | 200ms | ease-out | Scale Y from 0.95 + fade in |
| Tooltip appear | 150ms | ease-out | Fade in, 500ms delay |
| Page transition | 200ms | ease-out | Content opacity + translateY(4px) |
| Status dot pulse | 2000ms | ease-in-out | Opacity 1 -> 0.4 -> 1 (critical only) |

**CE influence:** 200ms base timing is 33% slower than MT's typical 150ms. This creates a more measured, deliberate feel — the UI doesn't snap, it moves with intention. Critical for trust perception: a platform managing 50K devices shouldn't feel twitchy.

---

## Trust Elements

The 20% Corporate Enterprise influence manifests primarily as trust signals. These are not decorative — they address the specific objection pattern of enterprise buyers evaluating autonomous systems for critical infrastructure.

### Compliance Panel

Located in the sidebar footer or a dedicated Settings > Compliance page.

```
┌─────────────────────────────────────┐
│  COMPLIANCE                         │
│                                     │
│  ┌─────┐  ┌─────┐  ┌─────┐        │
│  │SOC 2│  │ ISO │  │GDPR │        │
│  │ II  │  │27001│  │     │        │
│  └─────┘  └─────┘  └─────┘        │
│                                     │
│  Last audit: 2026-01-15             │
│  View certificates →                │
└─────────────────────────────────────┘
```

- Badges rendered in muted tones (navy on dark surface, low contrast)
- Not animated, not flashy — their presence is the signal
- Links to downloadable compliance documentation

### Agent Audit Trail

First-class UI element, not buried in logs.

```
┌─────────────────────────────────────────────────────────────┐
│  AUDIT TRAIL — agent:warehouse-east-temp                    │
├─────────────────────────────────────────────────────────────┤
│  2026-03-13 14:23:07  ANOMALY DETECTED                     │
│  Score: 0.87 | Type: temperature_spike                      │
│  Sensors: T-4401, T-4402, T-4403                            │
│                                                             │
│  2026-03-13 14:23:08  PLAYBOOK MATCHED                     │
│  Playbook: anomaly-spike-v3.2                               │
│  Action: throttle_sampling_rate → 50%                       │
│  Constraint check: PASSED (within max_concurrent_actions)   │
│                                                             │
│  2026-03-13 14:23:08  ACTION EXECUTED                      │
│  Target: 3 devices | Duration: 340ms                        │
│  Approval: AUTO (Level 2 — supervised)                      │
│                                                             │
│  2026-03-13 14:25:12  OUTCOME VERIFIED                     │
│  Temperature readings normalized within 2m04s               │
│  Baseline deviation: 0.12 (within tolerance)                │
│  Result: SUCCESS                                            │
│                                                             │
│  ↓ Load earlier entries                                     │
└─────────────────────────────────────────────────────────────┘
```

- Timestamps in mono
- Every entry includes: what happened, why, what constraint checks passed, what the outcome was
- Exportable as CSV/PDF for compliance reporting
- Filterable by agent, action type, autonomy level, outcome

### Controlled Autonomy Messaging

Visible throughout the UI wherever agents act:

1. **Autonomy level indicator** on every agent card (dot visualization, 0-4)
2. **Approval queue** as a primary nav item — not hidden in settings
3. **Constraint visibility** — on agent detail pages, constraints are listed prominently, not collapsed
4. **"Why did the agent do this?"** link on every action in the action history, expanding the reasoning chain

### Printable Status Reports

Monthly/weekly fleet status report, exportable as PDF. Uses navy (#1E3A5F) as a header color in light-panel print context:

```css
@media print {
  body {
    background: #FFFFFF;
    color: #1A1A22;
  }

  .report-header {
    background-color: var(--color-navy);
    color: #FFFFFF;
    padding: var(--space-6);
  }

  .report-section-title {
    font-family: var(--font-serif);
    color: var(--color-navy);
    border-bottom: 2px solid var(--color-navy);
    padding-bottom: var(--space-2);
  }
}
```

---

## Mixing Notes

### The 5 Corporate Enterprise Elements

| # | Element | MT Default | CE Modification | Rationale |
|---|---------|-----------|-----------------|-----------|
| 1 | **Serif headings (H1/H2)** | Sans-serif throughout | Source Serif 4 at H1/H2 | Adds institutional gravitas. "This is a platform, not a toy." Serif at heading level only preserves data-density readability below H2. |
| 2 | **Button radius + shadow** | 6px radius, no shadow | 4px radius, `0 1px 2px rgba(0,0,0,0.2)` | More conservative geometry signals reliability. The subtle shadow adds physical weight — buttons feel like controls, not decoration. |
| 3 | **Table header treatment** | Transparent headers, 1px border | Background fill (#141420), 2px border-bottom | Tables become formal reports. Enterprise buyers print and screenshot dashboards for steering committees. Scannable header rows matter. |
| 4 | **Trust badges + compliance panel** | Absent | SOC 2/ISO badges, formal audit trail, printable status reports, approval queue as primary nav | Directly addresses the enterprise procurement objection: "How do I know this is safe?" The audit trail is not a log viewer — it's a trust artifact. |
| 5 | **200ms transition timing** | 150ms | 200ms | More deliberate pacing. The UI moves with intention, not urgency. A platform governing 50K devices should feel steady. |

### What Was Considered and Rejected

| Considered | Reason for Rejection |
|-----------|----------------------|
| **Light mode** | Conflicts with the primary use case. IoTGo is watched in NOCs, control rooms, and operations centers. Light mode causes eye strain in low-light monitoring environments. Dark mode is the operational standard for dashboards (Datadog, Grafana, PagerDuty all default dark). |
| **Navy primary replacing teal** | Would make IoTGo indistinguishable from every enterprise dashboard (Salesforce, ServiceNow, Jira). Teal maintains the "modern infrastructure" signal while navy serves as a secondary structural accent. Two teal shades (#0D9488 base, #14B8A6 hover) provide enough range without introducing navy as a competing primary. |
| **Mega menu navigation** | IoTGo's information architecture is too flat — 7 top-level sections, minimal nesting. A mega menu solves a problem that doesn't exist here and adds visual complexity that undermines the "precision" positioning. Sidebar with single-level nav items is the correct pattern. |
| **Serif body text** | Readability collapses at data-dense sizes. Body text at 16px in a serif face competes with mono telemetry data and small-caption labels. Serif at H1/H2 is enough to establish authority without sabotaging scanability. |
| **Gold accent** | Gold signals finance, premium tiers, or rewards. Wrong connotation for operations software managing critical infrastructure. Teal signals uptime, connectivity, and systems health — semantically aligned with IoTGo's domain. |
| **Animation-heavy onboarding** | Enterprise buyers evaluate with procurement teams in the room. Lottie animations and particle effects feel frivolous in a vendor assessment context. Skeleton screens with progress text ("Connecting to fleet...") are the correct loading pattern. |

---

## Reference Energy

| Product | What to take | What to leave |
|---------|-------------|---------------|
| **Datadog (enterprise tier)** | Information density, sidebar nav structure, dark mode palette depth, monitoring dashboard patterns | Over-complexity of their settings/config pages, logo-heavy integrations grid |
| **PagerDuty** | Incident timeline design, escalation visibility, status page patterns | Dated component styling, inconsistent spacing |
| **AWS Console** | Table density, breadcrumb patterns, service-level navigation | Visual heaviness, blue-orange palette, cluttered header chrome |
| **Cloudflare Dashboard** | Clean dark surfaces, teal accent system, card-based layout, trust through simplicity | Some pages feel too sparse for IoTGo's data density requirements |

**The synthesis:** Datadog's density + Cloudflare's surface treatment + PagerDuty's incident patterns + institutional gravitas from serif headings and formal table styling. The result should feel like a monitoring tool built by people who've been through a SOC 2 audit.

---

## Implementation Checklist

### Phase 1: Foundation

- [ ] Set up CSS custom properties (copy `:root` block from this doc)
- [ ] Import fonts: Source Serif 4 (700), Inter (400, 500, 600, 700), JetBrains Mono (400, 500)
- [ ] Implement base reset and body styles
- [ ] Build spacing utility classes from token scale
- [ ] Define color utility classes for device health states
- [ ] Set up 12-column grid with 1440px max-width

### Phase 2: Typography

- [ ] Implement heading styles (H1/H2 serif, H3/H4 sans)
- [ ] Implement body, small, caption, data, and overline text styles
- [ ] Verify line-height rendering at each scale level
- [ ] Test serif/sans pairing at different viewport widths

### Phase 3: Core Components

- [ ] Buttons: primary, secondary, ghost, danger (all sizes)
- [ ] Form inputs: text, select, textarea, checkbox, radio
- [ ] Cards: standard, with header/footer, interactive
- [ ] Tables: standard, with status cells, with mono data cells
- [ ] Badges: all 6 status variants
- [ ] Autonomy level dot indicator

### Phase 4: Navigation + Layout

- [ ] Sidebar: logo, nav items, active states, compliance footer
- [ ] Trust bar: health score, last sync, agent status, account tier
- [ ] Content area: proper offset for fixed sidebar
- [ ] Responsive: tablet collapse (sidebar -> overlay at 1024px)

### Phase 5: Interaction + Feedback

- [ ] Toast notification system (4 variants, formal language)
- [ ] Confirmation dialog (standard + agent action variant)
- [ ] Skeleton screens with progress text
- [ ] Tooltip component (150ms delay, 500ms appear)
- [ ] All hover/focus/active states per interaction table

### Phase 6: Trust Elements (CE Contribution)

- [ ] Compliance badge panel in sidebar footer
- [ ] Agent audit trail component (timeline format)
- [ ] Approval queue as primary navigation item
- [ ] Constraint visibility panel on agent detail pages
- [ ] "Why did the agent do this?" expansion on action items
- [ ] Printable status report styles (@media print)

### Phase 7: Validation

- [ ] Side-by-side comparison with Direction A
- [ ] Enterprise buyer gut-check: does it feel trustworthy without feeling legacy?
- [ ] Data density test: populate with realistic fleet data (5K+ devices)
- [ ] Accessibility: contrast ratios meet WCAG AA on all text/background combos
- [ ] Performance: font loading strategy (preconnect + display=swap)

---

## Accessibility Notes

| Element | Foreground | Background | Contrast Ratio | WCAG AA |
|---------|-----------|------------|----------------|---------|
| Body text | #E4E4E8 | #09090B | 16.2:1 | Pass |
| Secondary text | #8A8A98 | #09090B | 5.8:1 | Pass |
| Tertiary text | #52526A | #09090B | 3.2:1 | Fail (decorative only) |
| Accent on bg | #0D9488 | #09090B | 5.1:1 | Pass |
| Accent on surface | #0D9488 | #111116 | 4.6:1 | Pass (large text) |
| Table header text | #8A8A98 | #141420 | 4.9:1 | Pass (large text/bold) |

**Tertiary text (#52526A):** Use only for decorative labels, disabled states, or supplementary metadata that has a non-text equivalent. Never use for actionable or informational content.
