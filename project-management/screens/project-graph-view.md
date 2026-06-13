# Project Graph View — Visual Design Spec

> **Screen**: `ProjectGraphView`
> **Theme**: tobornalp (style-guide)
> **Status**: Design concept
> **Author**: Priya Mehta
> **Date**: 2026-05-27
> **Aesthetic**: Linear project views crossed with a circuit board — dense, functional, alive

---

## 1. Overview

A live, interactive directed graph that visualizes project work as a circuit: **user stories** are the source nodes, **roles** are the relay points (job slots that assignees fill into), and **subtasks** are the terminal outputs. Dependency edges wire stories to stories and subtasks to subtasks across role boundaries, creating the execution topology.

The graph is not a Gantt chart. Not a kanban board. It's a **circuit board** — when a subtask completes, its outgoing edges light up, the downstream node activates, and progress ripples through the graph like current through a circuit.

**Two scales of reading:**
- **Macro**: full project topology — which stories are blocked, where work is concentrated, what's shipped
- **Micro**: single-node detail — assignees, progress, priority, linked artifacts, activity log

---

## 2. Graph Topology

The primary data flow is a three-layer DAG:

```
[User Story] ──assignment──> [Role Slot] ──breakdown──> [Subtask]
     │                                                       │
     │ dependency                              cross-role    │
     v                                         dependency    v
[User Story]                                            [Subtask]
```

**Story nodes** decompose into **role nodes** — each role represents a job slot (e.g., "Frontend Dev", "PM Agent", "QA Engineer") that may be empty (unassigned) or filled (assignee avatar visible). Each role node further decomposes into **subtask nodes** — the concrete work items that role must complete.

Cross-cutting dependencies wire the graph laterally: a backend subtask may block a frontend subtask, or one story may block another entirely.

**Milestone/gate nodes** sit upstream of stories as synchronization points — downstream stories cannot start until the gate is satisfied.

---

## 3. Node Catalog

### 3.1 User Story Node

The largest node. Represents a deliverable capability from the user's perspective.

| Property | Value |
|----------|-------|
| **Shape** | Rounded rectangle, 260px wide, variable height |
| **Border** | 1px `var(--border)`, left accent bar 3px (epic/priority color) |
| **Background** | `var(--surface)` |
| **Corner radius** | `var(--radius-md)` (6px) |
| **Header row** | Story ID in `var(--font-mono)` `var(--font-size-xs)` `var(--text-muted)` + priority `.badge` right-aligned |
| **Title** | `var(--font-sans)` `var(--font-size-sm)` `var(--text)` weight 500, 2-line clamp |
| **Footer** | Progress bar (2px, full width) + completion percentage in mono xs + role avatar stack |
| **Epic color** | Left accent bar color — assigned per epic from the extended palette |

**Visual states:**

| State | Rendering |
|-------|-----------|
| Unstarted | `var(--gray-200)` border, dashed left accent, muted text (`var(--text-muted)`) |
| In progress | Solid border, colored left accent, normal text, progress bar animated |
| Completed | `var(--success)` left accent, muted background (`opacity: 0.6`), checkmark overlay on ID |
| Blocked | `var(--error)` left accent, `var(--error-tint)` background wash, warning icon beside ID |

**Collapsed form:** Pill shape — just ID + title (truncated to 30ch) + progress % + priority dot. Used at low zoom or when a story's subtask graph is hidden.

```
+--+----------------------------------------------+
|▐ | #US-014  Authentication flow          P1     |
|▐ | Users can sign in with OAuth providers        |
|▐ |                                               |
|▐ | ██████████░░░░░░  62%          ○ ○ ◇         |
+--+----------------------------------------------+
 ↑ left accent (priority/epic color)    ↑ role avatars (○=human ◇=agent)
```

### 3.2 Role Node

Medium-sized. Represents a **job slot** — a function needed by a story. Empty until an assignee fills it.

| Property | Value |
|----------|-------|
| **Shape** | Rounded rectangle, 180px wide |
| **Border** | 1px `var(--border)`, 2px top accent (role-type color) |
| **Background** | `var(--surface-alt)` |
| **Corner radius** | `var(--radius-md)` |
| **Avatar area** | 32px circle (human) or hexagon (agent) — centered. Empty state: dashed border + `+` glyph. Filled: avatar image or initial letter |
| **Label** | Role name below avatar, `var(--font-sans)` `var(--font-size-xs)` weight 500 |
| **Status badge** | Small `.badge` below label — shows subtask progress (e.g., "2/4 done") |
| **Agent accent** | Agent role slots: hexagon avatar, top accent in `var(--violet)`, `.badge.agent-working` when active |

**Visual states:**

| State | Rendering |
|-------|-----------|
| Unassigned | Dashed avatar placeholder, `var(--gray-300)` border, label in `var(--text-muted)` |
| Assigned, idle | Filled avatar, solid border, badge shows "0 active" in gray |
| Assigned, working | Filled avatar, `var(--blue)` top accent (human) or `var(--violet)` (agent), badge shows active count |
| All subtasks done | `var(--success)` top accent, checkmark overlay on avatar, muted opacity |
| Overloaded | `var(--warning)` top accent, amber badge count, tooltip "at capacity" |

**Assignee filling animation:** When a role slot gets assigned, the dashed placeholder morphs into the assignee avatar — scale from 0.5 → 1.0, opacity 0 → 1, 200ms ease-out. The top accent bar fills from left to right (150ms).

```
     Unassigned:          Assigned (human):      Assigned (agent):
    +-----------+         +-----------+          +-----------+
    |   ┌···┐   |         |   ┌───┐   |         |   ╱───╲   |
    |   ¦ + ¦   |         |   │KM │   |         |   │PM │   |
    |   └···┘   |         |   └───┘   |         |   ╲───╱   |
    | Frontend  |         | Frontend  |         | PM Agent   |
    | --- / --- |         | .badge 2/4|         | .badge 1/3 |
    +-----------+         +-----------+         +-----------+
```

### 3.3 Subtask Node

The smallest node. Atomic unit of execution — a concrete work item owned by a role.

| Property | Value |
|----------|-------|
| **Shape** | Rounded rectangle, 160px wide |
| **Border** | 1px `var(--border)` |
| **Background** | `var(--surface)` |
| **Corner radius** | `var(--radius-sm)` (4px) |
| **Status dot** | 6px circle, left of title — color from semantic class |
| **Title** | `var(--font-sans)` `var(--font-size-xs)`, 1-line clamp |
| **ID** | `var(--font-mono)` `var(--font-size-2xs)` `var(--text-muted)` right-aligned |

**Status → semantic class mapping:**

| Status | Semantic Class | Dot Color | Node Treatment |
|--------|---------------|-----------|----------------|
| Pending | `priority-low` | `var(--gray-400)` | Outline-only border (dashed) |
| In progress | `agent-working` | `var(--violet)` (agent) or `var(--blue)` (human) | Solid border, subtle pulse glow |
| In review | `info` | `var(--info)` | Solid, blue-tinted left edge |
| Blocked | `danger` | `var(--error)` | `var(--error-tint)` background, red dashed border |
| Done | `success` | `var(--success)` | Muted opacity (0.5), strikethrough on title, green dot |

**Circuit activation:** When a subtask completes, its outgoing edges illuminate (see Section 4.5) and the downstream node's status dot blinks once (300ms) before settling into its new state.

```
+-------------------------------+
| ● Implement OAuth callback  41|  ← dot=status, 41=task ID suffix
+-------------------------------+
```

### 3.4 Milestone / Gate Node

A synchronization point. Blocks downstream work until conditions are met.

| Property | Value |
|----------|-------|
| **Shape** | Diamond (rotated 45-degree square), 40px side |
| **Border** | 2px, color from state |
| **Background** | `var(--surface)`, partial fill for progress (liquid-gauge from bottom) |
| **Label** | Below diamond, `var(--font-mono)` `var(--font-size-xs)` |
| **Date** | Below label, `var(--font-mono)` `var(--font-size-2xs)` `var(--text-muted)` |

| State | Border | Fill |
|-------|--------|------|
| Not reached | `var(--gray-300)` | Empty |
| Approaching (>50% upstream done) | `var(--blue)` | Partial blue fill |
| Satisfied | `var(--success)` | Full emerald fill |
| Overdue | `var(--error)` | Pulsing red border |

```
    ◇          ◆         ◆
  v0.1      Sprint 4   Launch
 pending    75% done    overdue!
```

---

## 4. Edge Catalog

All edges are SVG paths. Straight segments preferred; cubic bezier curves when routing around nodes. Animation uses CSS `stroke-dashoffset` for the circuit-lighting effect.

### 4.1 Assignment Edge (Story → Role)

Connects a user story to its required role slots.

| Property | Value |
|----------|-------|
| **Style** | Solid, 1.5px |
| **Color** | `var(--gray-300)` (unstarted) → `var(--blue)` (active) → `var(--success)` at 50% (done) |
| **Arrow** | Small filled triangle (5px) at role end |
| **Label** | None |
| **Hover** | Brightens to full `var(--blue)`, 2px, shows "assigned" tooltip at midpoint |

### 4.2 Breakdown Edge (Role → Subtask)

Connects a role to its owned subtasks.

| Property | Value |
|----------|-------|
| **Style** | Solid, 1px |
| **Color** | `var(--gray-300)` default |
| **Arrow** | Thin chevron (4px) at subtask end |
| **Label** | None |
| **Circuit activation** | When subtask completes: edge flashes `var(--success)` traveling from subtask back to role node (200ms), role's progress badge increments |

### 4.3 Story Dependency Edge (Story → Story)

Directional blocking relationship. Target story cannot start until source completes.

| Property | Value |
|----------|-------|
| **Style** | Thick solid, 2.5px |
| **Color** | State-dependent (see below) |
| **Arrow** | Filled triangle (7px) at dependent end |
| **Label** | "blocks" in `var(--font-mono)` `var(--font-size-2xs)`, centered on edge midpoint |
| **Routing** | Curved bezier arc — always routes above/below the node layer, never through nodes |

| State | Edge Color | Edge Style |
|-------|-----------|------------|
| Source incomplete, target waiting | `var(--error)` at 40% | Dashed, slow pulse (2s period) |
| Source in progress, target queued | `var(--blue)` at 60% | Solid |
| Source complete, target unblocked | `var(--success)` at 40% | Solid, fade after 3s to `var(--gray-300)` at 20% |

**Circuit effect:** When the source story completes, the dependency edge lights up green from source → target (400ms travel time), then the target story's border flashes once to indicate it's unblocked.

### 4.4 Cross-Role Dependency Edge (Subtask → Subtask)

When one role's subtask blocks another role's subtask — the lateral wiring.

| Property | Value |
|----------|-------|
| **Style** | Solid, 1.5px |
| **Color** | `var(--blue)` at 50% (active) or `var(--error)` at 40% (blocking) |
| **Arrow** | Filled triangle (5px) |
| **Label** | Optional — relationship type in mono 2xs |
| **Routing** | Orthogonal with rounded corners (4px radius) — routes through the inter-layer gap |

These edges are the most visually important for identifying bottlenecks. They cross role boundaries horizontally and should be emphasized during "blocked" filter mode.

### 4.5 Circuit Activation Effect (All Edges)

The signature visual of this graph. When a node completes:

1. **Outgoing edges illuminate**: A bright dot (4px, `var(--success)`) travels along the edge path from source to target (200-400ms depending on edge length)
2. **Edge color transitions**: `var(--gray-300)` → brief `var(--success)` flash → settles to completed state color
3. **Downstream node reacts**: Target node's border pulses once (300ms), status dot updates
4. **Cascade**: If the target node was the last blocker, it auto-transitions to "ready" state, and its own outgoing edges may activate (domino effect)

Implementation: CSS `@keyframes` on `stroke-dashoffset` with a gradient mask that creates the traveling-dot illusion. A small `<circle>` element is animated along the `<path>` using `offset-path`.

```css
@keyframes circuit-pulse {
  0%   { stroke-dashoffset: 100%; opacity: 0.3; }
  50%  { opacity: 1; }
  100% { stroke-dashoffset: 0%; opacity: 0.3; }
}
```

`prefers-reduced-motion`: replaces animation with instant color transition.

---

## 5. Color System

All color encoding reuses the existing tobornalp semantic classes and design tokens. Zero new colors.

### 5.1 Priority (Story Left Accent Bar)

| Priority | Token | Semantic Class |
|----------|-------|---------------|
| P0 Critical | `var(--error)` | `priority-critical` |
| P1 High | `var(--warning)` | `priority-high` |
| P2 Medium | `var(--blue)` | `priority-medium` |
| P3 Low | `var(--gray-400)` | `priority-low` |

### 5.2 Epic Color Coding

Epics/themes get colors from the extended palette, auto-assigned in declaration order:

| Slot | Color | Token |
|------|-------|-------|
| Epic 1 | Blue | `var(--blue)` |
| Epic 2 | Violet | `var(--violet)` |
| Epic 3 | Cyan | `var(--cyan)` |
| Epic 4 | Teal | `var(--teal)` |
| Epic 5 | Indigo | `var(--indigo)` |
| Epic 6 | Rose | `var(--rose)` |
| Epic 7 | Orange | `var(--orange)` |
| Epic 8 | Sky | `var(--sky)` |
| Epic 9+ | Rotate | Wraps from slot 1 |

Epic color appears as the story node's left accent bar (when not overridden by priority) and as a subtle background tint (`{epic-color}-light` token) on the story node.

### 5.3 Status (Subtask Status Dot)

| Status | Token | Class |
|--------|-------|-------|
| Pending | `var(--gray-400)` | `priority-low` |
| In progress (human) | `var(--blue)` | `info` |
| In progress (agent) | `var(--violet)` | `agent-working` |
| In review | `var(--info)` | `info` |
| Blocked | `var(--error)` | `danger` |
| Done | `var(--success)` | `success` |

### 5.4 Agent vs. Human

| Entity | Visual Marker | Color Token |
|--------|--------------|-------------|
| Human assignee | Circle avatar | `var(--blue)` accent when active |
| AI agent | Hexagon avatar | `var(--violet)` accent always |

Agents are peer team members, not features. Same node structure, same status indicators, different shape and color accent.

### 5.5 Node Badge Usage

The graph reuses the unified Badge component (from `css-snippets.yaml`) for:
- **Priority badges** on story nodes: `<span class="badge priority-high">P1</span>`
- **Role progress**: `<span class="badge badge-sm info">2/4</span>`
- **Status pills** in detail panel: `<span class="badge badge-dot success">done</span>`
- **Agent badges**: `<span class="badge badge-agent agent-working">PM Agent</span>`
- **Filter chips** in the filter bar: `<span class="badge badge-pill">In progress</span>`

---

## 6. Layout Options

### 6.1 Left-to-Right Flow (Default)

The primary layout. Reads like a circuit schematic — input left, processing center, output right.

```
Layer 0 (left):     [Milestones] ◇ ◇
Layer 1:            [User Stories] □ □ □
Layer 2:            [Role Slots]  ○ ◇ ○ ○
Layer 3 (right):    [Subtasks]    ■ ■ ■ ■ ■ ■

← blocked/upstream                     downstream/output →
```

- **Layout engine**: Dagre with `rankdir: LR`
- **Rank separation**: 100px between layers
- **Node separation**: 20px vertical (`var(--space-2) + var(--space-half)`)
- **Story → role edges**: short horizontal connectors
- **Cross-role dependency edges**: route vertically through inter-layer gaps, orthogonal with rounded corners
- **Group containment**: Stories and their connected roles/subtasks cluster into visual bands (dashed boundary, `var(--border)` dashed 1px)

### 6.2 Radial Layout

Stories at center, roles as first ring, subtasks as outer ring. Best for small projects (< 30 nodes) where you want to see the full topology at a glance.

```
                    ■ ■
                  ■       ■
              ○       □       ○
            ■   ○   □   □   ○   ■
              ○       □       ○
                  ■       ■
                    ■ ■
```

- **Center**: Milestone or project root node
- **Ring 1** (radius 120px): User stories, evenly spaced
- **Ring 2** (radius 240px): Roles, positioned near their parent stories
- **Ring 3** (radius 360px): Subtasks, fanned from their roles
- **Dependency edges**: Curved arcs between rings, drawn behind nodes

### 6.3 Hierarchical Top-Down

Classic DAG. Best for deep dependency chains where "what blocks what" is the primary question.

- `rankdir: TB` — milestones at top, subtasks at bottom
- Same engine as LTR but rotated
- Better for tall/narrow graphs with many serial dependencies

### 6.4 Force-Directed (Exploration Mode)

For when the user wants to discover structure rather than read a known layout.

- Spring constant: repulsion 300, link distance 100
- Nodes with more connections migrate to center
- Manual pinning: drag a node to pin it; pinned nodes show a small tack icon
- Double-click canvas background to un-pin all
- Useful for large graphs (100+ nodes) where hierarchical layout becomes unwieldy

### 6.5 Layout Switching

Keyboard shortcuts: `1` = LTR, `2` = Radial, `3` = Top-down, `4` = Force-directed

Transition: nodes animate to new positions over 400ms (ease-in-out). Edges redraw with the nodes. `prefers-reduced-motion`: instant snap.

---

## 7. Interaction Patterns

### 7.1 Node Interactions

| Interaction | Behavior |
|-------------|----------|
| **Hover** | Elevate: `box-shadow: var(--graph-node-shadow-hover)`. Highlight all connected edges (brighten to full opacity, +0.5px). Dim unconnected nodes to 30% opacity. Show tooltip: title + status + assignee + priority. |
| **Click** | Select node. Open detail panel (right sidebar, 340px). Blue selection ring (2px `var(--blue)`). All other nodes dim to 60%. |
| **Double-click story** | Toggle expand/collapse: expands to show role + subtask subgraph, or collapses to pill form. |
| **Double-click role** | Toggle show/hide subtasks for this role only. |
| **Drag** | Reposition node. Edges follow. Node becomes "pinned" (shows tack icon). Connected group drags if Shift held. |
| **Right-click** | Context menu: "Expand/Collapse", "Assign to...", "Set priority", "Add dependency", "Mark complete", "Copy link" |
| **Shift+click** | Add to multi-selection. |
| **Lasso (Shift+drag on canvas)** | Select all enclosed nodes. |

### 7.2 Edge Interactions

| Interaction | Behavior |
|-------------|----------|
| **Hover** | Edge brightens, thickens +0.5px. Source and target nodes get 2px highlight ring (`var(--blue)` at 30%). Tooltip shows edge type. |
| **Click** | Select edge. Sidebar shows relationship details + option to remove. |
| **Drag from port** | Connection ports (6px circles, `var(--blue)`) appear on node edges when hovering near borders. Drag from port to target creates a dependency edge. Drop on empty canvas to cancel. |

### 7.3 Canvas Interactions

| Interaction | Behavior |
|-------------|----------|
| **Scroll** | Pan canvas. |
| **Ctrl/Cmd+scroll** | Zoom (smooth, 20% min → 300% max). |
| **Click empty** | Deselect all, close sidebar. |
| **Minimap** | Bottom-right, 160x100px, semi-transparent `var(--surface-alt)`. Blue viewport rectangle. Click to navigate. |
| **`F` key** | Fit entire graph to viewport with 32px padding. |
| **`Escape`** | Deselect all. Close sidebar. Close context menu. |
| **`Tab`** | Cycle focus through nodes (follows layout order). |
| **`Enter`** | Select focused node, open sidebar. |
| **`1/2/3/4`** | Switch layout mode. |
| **`Cmd+K`** | Open command palette (graph-scoped search). |

### 7.4 Drag-to-Assign Interaction

The primary way to fill role slots:

1. User drags an **assignee chip** from the team roster panel (left sidebar or top bar)
2. Unassigned role nodes highlight with a blue dashed border ("drop target" state)
3. Drop on a role node → fills the avatar, creates assignment, animates fill
4. Drop on a story node → opens role picker ("which role?") then assigns

Alternative: right-click role → "Assign to..." → combobox with team member search (fuzzy, Cmd+K style).

### 7.5 Progress Animation (Circuit Completion)

When the user marks a subtask as done (via sidebar toggle, context menu, or keyboard shortcut):

1. **Subtask dot** transitions: current color → `var(--success)` (150ms)
2. **Title** gets strikethrough, opacity drops to 0.5
3. **Outgoing edges illuminate**: green dot travels from this node to all downstream targets (200-400ms)
4. **Breakdown edge** (subtask → role) flashes green, role badge count increments
5. **If all subtasks under a role are done**: role node's top accent transitions to `var(--success)`, checkmark appears on avatar
6. **If all roles under a story are done**: story progress bar fills to 100%, left accent turns green, edges from story light up downstream
7. **If story completion unblocks a dependency**: dependency edge fires the circuit pulse to the downstream story, which transitions from "blocked" to "ready"

The cascade is the payoff. Complete a subtask → role fills up → story fills up → downstream story unblocks → the graph visually "lights up" in a chain reaction.

---

## 8. Detail Panel (Right Sidebar)

Opens on node click. 340px wide, slides in from right. `var(--surface)` background, 1px `var(--border)` left edge.

### 8.1 Story Detail

```
+------------------------------------------+
| ← Back              #US-014   .badge P1  |
|------------------------------------------|
| Authentication Flow                      |
| "Users can sign in via OAuth providers"  |
|                                          |
| ── Progress ──────────────────────────── |
| ██████████░░░░░  62%  (5/8 subtasks)     |
|                                          |
| ── Roles ─────────────────────────────── |
| ○ Frontend Dev — Keith M.    3/4 done    |
| ◇ PM Agent — @pm-agent       1/2 done    |
| ○ QA Engineer — [unassigned]  0/2 done   |
|                                          |
| ── Dependencies ──────────────────────── |
| Blocks: US-018 (Dashboard)              |
| Blocked by: none                         |
|                                          |
| ── Acceptance Criteria ───────────────── |
| ☑ OAuth redirect works                  |
| ☐ Session persists across tabs          |
| ☐ Error states handled                  |
|                                          |
| ── Activity ──────────────────────────── |
| 2h ago  T-041 completed by Keith M.     |
| 5h ago  PM Agent assigned to PM role     |
| 1d ago  Story created                    |
+------------------------------------------+
```

### 8.2 Role Detail

```
+------------------------------------------+
| ← Back         Frontend Dev              |
|------------------------------------------|
|        ┌───┐                             |
|        │KM │  Keith Mercer               |
|        └───┘  .badge.agent-active online  |
|                                          |
| ── Subtasks ──────────────────────────── |
| ● T-041  Implement OAuth callback  done  |
| ● T-042  Session management      prog   |
| ● T-043  Error handling          block   |
| ○ T-044  E2E test suite         pending  |
|                                          |
| ── Workload ──────────────────────────── |
| 3 active across 2 stories               |
| Capacity: ██████░░░░ 60%                |
+------------------------------------------+
```

### 8.3 Subtask Detail

```
+------------------------------------------+
| ← Back       T-042  Session management   |
|------------------------------------------|
| Status: .badge.badge-dot info In review  |
| Assignee: ○ Keith M. (via Frontend Dev)  |
| Story: US-014 Authentication Flow        |
|                                          |
| ── Description ───────────────────────── |
| Implement session persistence using      |
| httpOnly cookies with 7-day expiry.      |
|                                          |
| ── Dependencies ──────────────────────── |
| Depends on: T-041 (done ✓)              |
| Blocks: T-051 (Dashboard layout)         |
|                                          |
| ── Activity ──────────────────────────── |
| 1h ago  Moved to "In review"            |
| 6h ago  PR #147 linked                   |
+------------------------------------------+
```

---

## 9. Filter & Search

### 9.1 Filter Bar

Horizontal bar above the graph canvas. Uses tobornalp badge-pill chips as toggles.

| Filter | Type | Chip Options |
|--------|------|-------------|
| **Status** | Multi-toggle | `Pending` `In Progress` `In Review` `Blocked` `Done` |
| **Priority** | Multi-toggle | `P0` `P1` `P2` `P3` |
| **Assignee** | Combobox dropdown | All team members + agents |
| **Epic** | Multi-toggle | Epic names (color-coded chips) |
| **Node type** | Multi-toggle | `Stories` `Roles` `Subtasks` `Milestones` |

Active filters dim non-matching nodes to 15% opacity and desaturate their edges. Matching nodes + their direct neighbors stay at full opacity (neighbors at 70%). This preserves local context around filtered results.

### 9.2 Preset Views

Saved filter+layout combos, shown as tabs above the filter bar:

| Preset | Filter | Layout |
|--------|--------|--------|
| "All work" | None | LTR (default) |
| "Blocked" | status=blocked | LTR, blocked edges emphasized |
| "My tasks" | assignee=current user | LTR |
| "Unassigned" | roles with no assignee | LTR, role nodes highlighted |
| "Sprint N" | stories in current milestone | LTR |

### 9.3 Command Palette Search

`Cmd+K` opens the existing tobornalp command palette, filtered to graph entities:
- Type to search by node ID, title, or assignee name
- Results show: type icon + ID + title + status badge
- Select → viewport pans and zooms to center on the node, selects it, opens sidebar

---

## 10. Responsive Behavior

### 10.1 Zoom-Dependent Detail Levels

| Zoom Range | Node Rendering | Edge Rendering |
|------------|---------------|----------------|
| < 30% | **Dot mode**: 8px colored dots at node positions. Stories=squares, roles=circles, subtasks=dots | 1px straight lines, no arrows |
| 30-60% | **Compact**: ID + status dot only. No title text. Roles show avatar only. | 1.5px, small arrows |
| 60-120% | **Standard**: Full rendering as spec'd above | Full rendering |
| > 120% | **Expanded**: Additional metadata visible — dates, tags, full description text | Edge labels visible |

### 10.2 Edge Bundling

At > 50 visible edges, enable edge bundling: parallel edges between the same node clusters merge into a single weighted line. Width = `1.5px * sqrt(count)`. Individual edges fan out near endpoints (last 20px).

### 10.3 Cluster Collapsing

At > 100 visible nodes, offer auto-clustering:
- Each story + its roles + subtasks collapse into a single "super node"
- Super node shows: story title + role count + subtask completion + priority
- Expand any super node to drill into its subgraph
- Dependency edges between stories remain visible between super nodes

---

## 11. Dark Mode

All tokens flip automatically via `color-modes.yaml`. Graph-specific adjustments:

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Canvas | `var(--white)` #F8FAFC | `var(--black)` #0F172A |
| Node shadow (hover) | `rgba(0,0,0,0.12)` | `rgba(0,0,0,0.4)` |
| Edge default color | `var(--gray-300)` | `var(--gray-600)` |
| Circuit pulse glow | `var(--success)` at 60% | `var(--success)` at 80% (brighter against dark) |
| Dimmed node opacity | 30% | 20% (darker canvas = less opacity needed to dim) |
| Minimap background | `rgba(255,255,255,0.9)` | `rgba(15,23,42,0.9)` |
| Selection ring | `var(--blue)` 2px | `var(--blue)` 2px (same — already high contrast) |

The circuit effect is more dramatic in dark mode — green pulses against dark slate are highly visible. This is intentional. Dark mode is primary.

---

## 12. Proposed CSS Tokens

New graph-specific tokens to add to `style-guide.vars.yaml`:

```yaml
- name: "Graph"
  vars:
    graph-canvas-bg: "var(--bg)"
    graph-node-bg: "var(--surface)"
    graph-node-border: "var(--border)"
    graph-node-shadow: "0 1px 3px rgba(0,0,0,0.08)"
    graph-node-shadow-hover: "0 4px 16px rgba(0,0,0,0.12)"
    graph-node-radius: "var(--radius-md)"
    graph-subtask-radius: "var(--radius-sm)"
    graph-edge-color: "var(--gray-300)"
    graph-edge-width: "1.5px"
    graph-edge-dep-width: "2.5px"
    graph-edge-assign-width: "1px"
    graph-port-size: "6px"
    graph-port-color: "var(--blue)"
    graph-selection-ring-color: "var(--blue)"
    graph-selection-ring-width: "2px"
    graph-circuit-color: "var(--success)"
    graph-circuit-speed: "300ms"
    graph-minimap-bg: "var(--surface-alt)"
    graph-minimap-border: "var(--border)"
    graph-minimap-viewport: "var(--blue)"
    graph-rank-gap: "100px"
    graph-node-gap: "20px"
```

---

## 13. Technical Recommendations

| Concern | Library | Rationale |
|---------|---------|-----------|
| Graph rendering | **React Flow** v12+ | Mature React integration, custom node/edge types, built-in minimap, pan/zoom, keyboard nav |
| Layout: hierarchical | **Dagre** | Fast, supports `rankdir: LR/TB`, cluster grouping |
| Layout: orthogonal routing | **elkjs** | Superior edge routing for dense graphs |
| Layout: force-directed | **D3-force** | Standard, well-documented, integrates with React Flow |
| Animation | CSS + **Framer Motion** | CSS for edge animations (`stroke-dashoffset`), Framer for node transitions |
| State | **Zustand** (React Flow default) | Lightweight, built into React Flow's internals |

### Data Model

```typescript
interface ProjectGraph {
  nodes: GraphNode[];
  edges: GraphEdge[];
  milestones: Milestone[];
  epics: Epic[];
}

interface GraphNode {
  id: string;
  type: 'story' | 'role' | 'subtask' | 'milestone';
  data: StoryData | RoleData | SubtaskData | MilestoneData;
  position?: { x: number; y: number };  // null = auto-layout
  pinned?: boolean;
}

interface StoryData {
  title: string;
  description: string;
  priority: 'p0' | 'p1' | 'p2' | 'p3';
  epicId: string;
  status: NodeStatus;
  acceptanceCriteria: { text: string; done: boolean }[];
}

interface RoleData {
  roleName: string;          // "Frontend Dev", "PM Agent"
  assignee?: Assignee;       // null = unassigned slot
  isAgent: boolean;
  subtaskProgress: { done: number; total: number };
}

interface SubtaskData {
  title: string;
  description?: string;
  status: NodeStatus;
  assignedVia: string;       // role node ID
}

interface MilestoneData {
  title: string;
  dueDate?: string;
  progress: number;          // 0-100
}

type NodeStatus = 'pending' | 'in-progress' | 'in-review' | 'blocked' | 'done';

interface Assignee {
  id: string;
  name: string;
  avatar?: string;
  isAgent: boolean;
}

interface GraphEdge {
  id: string;
  source: string;
  target: string;
  type: 'assignment' | 'breakdown' | 'story-dep' | 'cross-role-dep';
  animated?: boolean;        // circuit pulse active
  health?: 'active' | 'blocked' | 'resolved';
}

interface Epic {
  id: string;
  name: string;
  colorSlot: number;         // 1-9, maps to extended palette
}
```

---

## 14. Accessibility

| Concern | Approach |
|---------|----------|
| **Color-blind safety** | Shape encodes type (rect/circle/hexagon/diamond). Status uses dot + color. Priority uses position (accent bar) + badge text + color. Never color alone. |
| **Keyboard** | Full `Tab`/`Enter`/`Escape` cycle. Arrow keys traverse graph edges (→ follows outgoing, ← follows incoming). `F` fits. `1-4` layouts. `Cmd+K` search. |
| **Screen reader** | Nodes: "User story US-014, Authentication flow, 62% complete, priority high, 2 of 3 roles assigned". Edges announced on focus: "blocks US-018 Dashboard". Role: "Frontend Developer, assigned to Keith Mercer, 3 of 4 subtasks done". |
| **Reduced motion** | `prefers-reduced-motion`: instant state transitions, no circuit pulse animation, no layout transition animation. Status changes are still visually distinct via color/opacity. |
| **High contrast** | `forced-colors`: nodes use `Canvas` fill, `CanvasText` borders. Edges use `LinkText`. Selection ring uses `Highlight`. |

---

## 15. Example: Full Sprint Graph

```
◇ Sprint 4 (Jun 15) ─────────────────────────────────────────────────┐
│                                                                      │
├── [US-014 Auth Flow] ── P1 ── 62% ──────────────────────────────┐   │
│   ├── ○ Frontend Dev (Keith M.) ── 3/4                           │   │
│   │   ├── ● T-041 OAuth callback .............. done ✓           │   │
│   │   ├── ● T-042 Session mgmt ................ in review        │   │
│   │   ├── ● T-043 Error handling .............. blocked ✗        │   │
│   │   └── ○ T-044 E2E tests ................... pending          │   │
│   ├── ◇ PM Agent (@pm) ── 1/2                                   │   │
│   │   ├── ● T-045 Spec review ................. done ✓           │   │
│   │   └── ● T-046 Acceptance sign-off ......... pending          │   │
│   └── ○ QA Engineer [unassigned] ── 0/2                          │   │
│       ├── ○ T-047 Integration tests ........... pending          │   │
│       └── ○ T-048 Security audit .............. pending          │   │
│                                                                   │   │
├── [US-015 Dashboard] ── P2 ── 35% ── blocked by US-014 ────────┐│   │
│   ├── ○ Frontend Dev (Keith M.) ── 1/3                          ││   │
│   │   ├── ● T-051 Layout ...................... in progress      ││   │
│   │   ├── ○ T-052 Widgets .................... pending           ││   │
│   │   └── ○ T-053 Data binding ............... pending           ││   │
│   └── ◇ QA Agent (@qa) ── 0/1                                  ││   │
│       └── ○ T-054 Dashboard smoke tests ...... pending           ││   │
│                                                                  ││   │
│ Cross-role deps: T-042 ──blocks──> T-051 (session needed for     ││   │
│                                    dashboard auth state)         ││   │
└──────────────────────────────────────────────────────────────────┘│   │
                                                                    │   │
Legend: ○=human ◇=agent ●=has status ✓=done ✗=blocked              │   │
```

---

## 16. Open Questions

| Question | Default Assumption | Impact |
|----------|-------------------|--------|
| Max nodes before clustering kicks in? | 100 nodes visible; auto-cluster beyond | Affects layout engine performance budget |
| Real-time multi-user collaboration? | Not v1 — single-user editing | Simplifies state management |
| Persist node positions per user? | Yes, stored in user preferences | Requires position storage layer |
| Integrate with Plane/Taiga or standalone? | Standalone model with import adapters | Affects data schema + sync |
| Team roster source? | Inline definition for v1; API integration later | Affects assignee picker |
| Animation budget (ms per frame)? | 16ms target (60fps), circuit animations are CSS-only (GPU-composited) | No JS layout cost during animation |

---

## 17. Agent Decision Forks

This is the core differentiator. Agents in tobornalp don't just execute tasks — they make **strategic decisions** about approach. When an agent encounters a blocker, ambiguity, or design choice, it can **fork** the graph: spawn N parallel exploration branches, evaluate results, and **merge** the winner back into the main line. The graph visualizes this as a fan-out / fan-in pattern — a visible decision process.

### 17.1 Fork Node

A decision point where an agent spawns parallel exploration branches.

| Property | Value |
|----------|-------|
| **Shape** | Rounded trapezoid (wider at bottom), 200px wide — the "fan-out" shape |
| **Border** | 2px `var(--violet)` (agent decision = violet accent) |
| **Background** | `var(--violet-light)` |
| **Corner radius** | `var(--radius-md)` |
| **Icon** | Fork glyph (⑂ or custom SVG: line splitting into 3) top-left, `var(--violet)` |
| **Header** | "FORK" label in `var(--font-mono)` `var(--font-size-2xs)` `var(--violet)` uppercase tracking 0.08em |
| **Title** | Decision question in `var(--font-sans)` `var(--font-size-sm)` weight 500 — e.g., "Auth strategy?" |
| **Agent badge** | `.badge.badge-agent.agent-working` showing which agent initiated the fork |
| **Branch count** | Small counter badge bottom-right: "3 branches" in mono xs |
| **Timestamp** | "forked 2m ago" in `var(--font-mono)` `var(--font-size-2xs)` `var(--text-muted)` |

**Visual states:**

| State | Rendering |
|-------|-----------|
| Evaluating | `var(--violet)` border pulses slowly (3s period, opacity 0.5 → 1.0). Agent badge shows `.agent-working`. Background subtly shimmers (radial gradient rotation, 8s period). |
| Decided | Pulse stops. Border transitions to `var(--success)`. Winner label appears: "→ Branch B selected". |
| Stale (>1h, no activity) | Border fades to `var(--gray-400)`. Warning icon. Tooltip: "Fork stale — no agent activity for 1h." |

```
    ╭─────────────────────────────────╮
    │ ⑂ FORK           ◇ PM Agent    │
    │   Auth strategy?                │
    │                                 │
    │   .agent-working  3 branches    │
    ╰──────┬──────┬──────┬────────────╯
           │      │      │
         ╱ A ╲  ╱ B ╲  ╱ C ╲    ← divergent branches
```

### 17.2 Branch (Divergent Path)

Each fork produces N branches — parallel exploration paths, each pursuing a different approach.

| Property | Value |
|----------|-------|
| **Container** | Vertical lane with dashed border, 1px `var(--violet)` at 30%, rounded corners |
| **Lane header** | Branch label ("Branch A: JWT tokens") in `var(--font-mono)` `var(--font-size-xs)` + confidence badge |
| **Content** | Standard subtask nodes inside the lane — the work being explored on this branch |
| **Confidence score** | `.badge` in lane header showing agent's confidence: "78%" — color-coded (see below) |
| **Lane background** | Transparent default; `var(--violet-light)` when agent is actively evaluating this branch |

**Confidence score color mapping:**

| Range | Badge Style | Token |
|-------|-------------|-------|
| 0-30% | `.badge.danger` | `var(--error)` — low confidence, likely to be pruned |
| 31-60% | `.badge.warning` | `var(--warning)` — uncertain |
| 61-80% | `.badge.info` | `var(--info)` — promising |
| 81-100% | `.badge.success` | `var(--success)` — strong candidate |

**Branch-internal edges:** Standard breakdown edges (Role → Subtask) apply inside each branch. Branch work items are real subtask nodes — they just exist inside a branch container.

```
    Branch A: JWT tokens        Branch B: OAuth proxy       Branch C: Session cookies
    .badge.info 72%             .badge.success 89%          .badge.warning 45%
    ┊                           ┊                           ┊
    ┊ ● T-061 JWT lib eval     ┊ ● T-064 Proxy setup      ┊ ● T-067 Cookie impl
    ┊ ● T-062 Token rotation   ┊ ● T-065 Provider config  ┊   ...stalled
    ┊ ● T-063 Refresh flow     ┊ ● T-066 Callback handler ┊
    ┊                           ┊                           ┊
```

### 17.3 Merge Node

The convergence point where the winning branch is selected and losers are pruned.

| Property | Value |
|----------|-------|
| **Shape** | Inverted trapezoid (wider at top), 200px wide — the "fan-in" shape |
| **Border** | 2px `var(--success)` (resolved) or `var(--violet)` (pending) |
| **Background** | `var(--success-tint)` (resolved) or `var(--surface-alt)` (pending) |
| **Corner radius** | `var(--radius-md)` |
| **Icon** | Merge glyph (⑃ or custom SVG: 3 lines converging) top-left |
| **Header** | "MERGE" in mono 2xs uppercase |
| **Result** | "Winner: Branch B — OAuth proxy" in sans sm weight 500 |
| **Agent badge** | Which agent made the decision |
| **Rationale** | 1-line summary: "Faster integration, better provider support" in sans xs `var(--text-secondary)` |

**Visual states:**

| State | Rendering |
|-------|-----------|
| Pending (branches still evaluating) | `var(--violet)` border, dashed. No result text. Shows "awaiting evaluation..." |
| Decided | `var(--success)` border, solid. Result text visible. Winning branch label highlighted. |

```
           │      │      │
         ╱ A ╲  ╱ B ╲  ╱ C ╲
           │      │      │
    ╭──────┴──────┴──────┴────────────╮
    │ ⑃ MERGE             ◇ PM Agent │
    │   Winner: Branch B              │
    │   "Faster integration"          │
    ╰─────────────────────────────────╯
           │
           ▼
      [next downstream node]
```

### 17.4 Fork-to-Merge Edge Flow

The edges that connect fork → branches → merge form a distinct visual pattern:

**Fork → Branch (fan-out edges):**

| Property | Value |
|----------|-------|
| **Style** | Solid, 1.5px |
| **Color** | `var(--violet)` at 50% |
| **Arrow** | Small filled triangle at branch entry |
| **Spacing** | Edges fan out evenly from the fork node's bottom edge |
| **Active branch** | The branch currently being evaluated by the agent: edge brightens to full `var(--violet)` |

**Branch → Merge (fan-in edges):**

| Property | Value |
|----------|-------|
| **Style** | Solid (winner) or dashed (losers), 1.5px |
| **Color** | Winner: `var(--success)`. Losers: `var(--gray-300)` at 30%. |
| **Arrow** | Filled triangle at merge node |

**Upstream → Fork edge:** Standard dependency or breakdown edge connecting the triggering subtask/story to the fork node. Color follows the parent edge type rules.

**Merge → Downstream edge:** Standard dependency edge from the merge node to whatever comes next. Activates via circuit pulse when the merge resolves.

### 17.5 Resolution Animation

When the agent selects a winner, a multi-step animation plays:

1. **Agent decision indicator** (200ms): Fork node's pulse stops. Merge node border transitions from dashed `var(--violet)` to solid `var(--success)`.

2. **Winner highlight** (300ms): Winning branch lane's dashed border solidifies. Background transitions to `var(--success-tint)` at 5% opacity. Confidence badge pulses once.

3. **Winner edge lights up** (400ms): A circuit pulse (green dot, `var(--success)`) travels from the fork node down the winning branch's fan-out edge, through the branch's subtask chain, and into the merge node.

4. **Loser fade** (600ms, parallel with step 3): Losing branches simultaneously:
   - Lane border fades to `var(--gray-300)` at 15%
   - Internal subtask nodes transition to ghost state: 20% opacity, desaturated, dashed borders
   - Fan-out edges to losing branches become dashed `var(--gray-300)` at 15%
   - Fan-in edges from losers become dashed `var(--gray-300)` at 15%

5. **Collapse option** (after animation): A small "collapse" button (chevron) appears on the fork node. Clicking it collapses the entire fork/branch/merge structure into a single compact node showing just "⑂ Auth strategy → OAuth proxy ✓" — hiding the pruned branches.

6. **Downstream activation** (200ms after merge resolves): The merge node fires the standard circuit pulse to its downstream edges — continuing the cascade.

`prefers-reduced-motion`: Steps 1-4 are instant (no animation). Winner is highlighted, losers are dimmed, merge shows result. No traveling dots.

### 17.6 Layout Behavior Per Mode

#### LTR (Left-to-Right)

Branches stack **vertically** between the fork and merge columns:

```
                    ┌─ [Branch A subtasks] ─┐
[Story] → [Fork] ──┼─ [Branch B subtasks] ─┼── [Merge] → [downstream]
                    └─ [Branch C subtasks] ─┘
```

- Fork node occupies its own rank column
- Each branch gets a horizontal lane, stacked vertically with `var(--space-3)` gap
- Merge node aligns to the rightmost subtask column + 1 rank
- Branches are contained within a dashed group container
- If branches have different lengths, shorter branches pad with empty space to align the merge

#### Radial

Branches fan out as **angular sectors** from the fork node:

- Fork sits on Ring 2 (role layer)
- Each branch occupies an angular sector, subtasks distributed along the arc
- Merge sits directly opposite the fork on the next ring out
- Angular spread: `360° / N` per branch (capped at 120° per branch to avoid wraparound)

#### Top-Down

Branches spread **horizontally** below the fork:

```
        [Fork]
       /  |  \
    [A]  [B]  [C]     ← branches side by side
       \  |  /
        [Merge]
```

- Fork node at rank N, branches at rank N+1, merge at rank N+2
- Subtasks within each branch add ranks N+3, N+4, etc.
- Merge node at max-branch-depth + 1

#### Force-Directed

- Fork and merge are attracted to each other (short spring)
- Branch subtasks are attracted to their branch neighbors (medium spring)
- Cross-branch repulsion is slightly higher than normal to keep branches visually separated
- The fork/merge cluster tends to form a "diamond" or "eye" shape naturally

### 17.7 Nested Forks

An agent within a branch can fork again — creating a nested decision tree.

| Depth | Visual Treatment |
|-------|-----------------|
| Depth 1 | Standard fork/merge as described above |
| Depth 2 | Inset within branch lane, slightly smaller nodes (80% scale), `var(--violet)` at 40% border |
| Depth 3+ | Collapsed by default — shown as a single node "⑂ Nested fork (2 branches)" with expand-on-click |

Maximum visual depth: 2 levels expanded simultaneously. Beyond that, auto-collapse to prevent visual noise.

### 17.8 Interaction: Fork Nodes

| Interaction | Behavior |
|-------------|----------|
| **Hover fork** | All branches highlight. Confidence scores become prominent. Losing branches (if resolved) briefly un-ghost to 50% for comparison. |
| **Click fork** | Sidebar shows: decision question, agent rationale, branch list with confidence scores, timeline of evaluation, winner (if decided). |
| **Click branch header** | Sidebar shows: branch approach description, subtask list, confidence score history (sparkline), agent notes. |
| **Click merge** | Sidebar shows: winning branch, rationale, pruned branches (expandable), decision timestamp, downstream impact. |
| **Right-click fork** | Context menu: "Collapse fork", "Re-evaluate" (signals agent to re-run), "Override winner" (manual selection), "View all branches". |
| **Keyboard: `B`** | When fork is focused, cycle through branches. `Enter` on a branch selects it for detail view. |

### 17.9 Data Model Additions

```typescript
// Add to GraphNode.type union:
type NodeType = 'story' | 'role' | 'subtask' | 'milestone' | 'fork' | 'merge';

interface ForkData {
  question: string;              // "Auth strategy?"
  agentId: string;               // Which agent initiated
  branches: Branch[];
  status: 'evaluating' | 'decided' | 'stale';
  decidedAt?: string;            // ISO timestamp
  winnerId?: string;             // Branch ID of winner
}

interface Branch {
  id: string;
  label: string;                 // "Branch A: JWT tokens"
  approach: string;              // Longer description
  confidence: number;            // 0-100
  confidenceHistory: { time: string; value: number }[];  // sparkline data
  subtaskIds: string[];          // Subtask nodes in this branch
  status: 'exploring' | 'won' | 'pruned';
}

interface MergeData {
  forkId: string;                // Links back to the originating fork
  winnerId: string;              // Which branch won
  rationale: string;             // Agent's explanation
  decidedBy: string;             // Agent ID
  decidedAt: string;             // ISO timestamp
}

// Add to GraphEdge.type union:
type EdgeType = 'assignment' | 'breakdown' | 'story-dep' | 'cross-role-dep'
              | 'fork-branch' | 'branch-merge';

// Fork-branch edges carry the branch ID:
interface ForkBranchEdgeData {
  branchId: string;
  isWinner?: boolean;
}
```

### 17.10 CSS Tokens for Fork/Merge

Additions to the proposed `graph-*` token group:

```yaml
# ── Graph: Agent Decision Forks ──
graph-fork-border: "var(--violet)"
graph-fork-bg: "var(--violet-light)"
graph-fork-pulse-speed: "3s"
graph-fork-shimmer-speed: "8s"
graph-merge-border-pending: "var(--violet)"
graph-merge-border-resolved: "var(--success)"
graph-merge-bg-resolved: "var(--success-tint)"
graph-branch-border: "color-mix(in srgb, var(--violet) 30%, transparent)"
graph-branch-bg-active: "var(--violet-light)"
graph-branch-ghost-opacity: "0.2"
graph-branch-winner-highlight: "var(--success-tint)"
graph-resolution-speed: "600ms"
```

### 17.11 Accessibility: Fork/Merge

| Concern | Approach |
|---------|----------|
| **Screen reader** | Fork: "Decision fork by PM Agent: Auth strategy? 3 branches, evaluating." Branch: "Branch B, OAuth proxy, confidence 89%, 3 subtasks." Merge: "Decision resolved: Branch B selected. Rationale: faster integration." |
| **Keyboard** | `B` cycles branches when fork is focused. `Enter` on branch opens detail. `W` jumps to winning branch (if resolved). |
| **Reduced motion** | No pulse, no shimmer, no resolution cascade. Instant state change. Winner is solid, losers are dimmed. |
| **Shape encoding** | Fork = trapezoid (wider bottom). Merge = inverted trapezoid (wider top). Distinct from all other node shapes — identifiable without color. |

---

*All color decisions trace to `semantic-classes.yaml` and `vars.yaml`. The Badge component from Task 20 is reused for priority chips, status pills, role progress, and filter toggles. The circuit activation effect and agent decision forks are the two new visual concepts — everything else composes existing tobornalp patterns.*
