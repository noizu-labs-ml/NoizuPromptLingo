# Node Detail Pane

| Field | Value |
|-------|-------|
| **ID** | `node-detail-pane` |
| **Category** | Domain-Specific |
| **Used In** | 02-Graph Editor |

## Description

Side panel that opens when a graph node is selected. Shows and edits the node's configuration including type, attached prompt, expectations, freeball policy, template variable bindings, and comments. Content varies by node type (user_turn, system, terminal, freeball_anchor).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Right-side panel occupying ~30-40% width alongside the graph canvas |

## Props / Configuration

- `node` — The selected node object with all metadata
- `nodeType` — user_turn | system | terminal | freeball_anchor
- `onUpdate` — Callback when node properties are modified
- `promptPicker` — Embedded typeahead for attaching prompts
- `expectations` — List of expectations with inline editing
- `freeballPolicy` — allow | strict | required toggle
- `templateBindings` — Variable binding UI for prompt templates
- `comments` — Thread of node-level comments

## Interactions

- Edit node label and metadata
- Attach/change prompt via embedded prompt picker
- Add/edit/remove expectations (label, weight, direction, scoring_method)
- Set freeball policy
- Configure template variable bindings
- Add comments to the node
