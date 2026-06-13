# Graph Editor

| Field | Value |
|-------|-------|
| **ID** | `graph-editor` |
| **Type** | Primary |
| **Category** | Script Authoring |
| **User Stories** | US-001, US-002, US-003, US-004, US-005, US-006, US-008, US-011, US-015, US-041, US-042, US-043, US-044, US-045, US-048, US-074, US-075, US-111, US-112, US-113 |

## Description

The core visual canvas for building and editing conversation test scripts. Displays nodes and edges as a directed graph. Supports creating/editing nodes of all types (user_turn, system, terminal, freeball_anchor), attaching prompts and expectations, connecting edges with match conditions, and publishing versions.

## Key Components

- **Graph canvas** — Visual DAG rendering with draggable nodes and directed edges (US-002, US-005)
- **Node palette** — Toolbar for adding node types: user_turn, system, terminal, freeball_anchor (US-002, US-041, US-042, US-043)
- **Node detail pane** — Side panel showing selected node's prompt, expectations, freeball_policy, comments (US-003, US-004, US-074, US-075, US-112)
- **Edge inspector** — Panel for configuring match_method, match_config, label, priority (US-005)
- **Prompt picker** — Typeahead selector for published prompts with version pinning (US-003, US-011)
- **Expectation list** — Inline list of expectations with label, weight, direction, scoring_method (US-004)
- **Publish button** — Validates and publishes the current draft as an immutable version (US-006)
- **Run button** — Triggers a run against a published version (US-015)
- **Version selector** — Dropdown to switch between published versions and current draft (US-044)
- **Export YAML** — Downloads current published version as YAML (US-008)
- **Auto-layout button** — Rearranges graph topology automatically (US-113)
- **Bulk selection tools** — Multi-select for bulk operations (US-111)
- **Template variable bindings** — Per-node variable binding UI for prompt templates (US-048)

## Interactions

- Drag from node palette to canvas to create nodes
- Click + drag between nodes to create edges
- Click a node to open detail pane
- Click an edge to open edge inspector
- Set freeball_policy per node (allow/strict/required)
- Publish validates graph (root node, expectations, edge references)
- "Run" opens the Run Trigger Modal

## Navigation

- Accessible from: Script List (click a script)
- Links to: Run Detail (after triggering), Prompt Library (from prompt picker), Script Version Diff (from version selector)
