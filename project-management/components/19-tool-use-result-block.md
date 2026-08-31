# 19: Tool Use / Tool Result Block

| Field | Value |
|-------|-------|
| ID | CMP-19 |
| Category | AI-Specific |
| Surfaces | web, cli-ink |
| Used In | SCR-04, SCR-19, SCR-33 |

## Description
Collapsible block rendering a tool invocation (tool name, glow-accented per style guide, plus input preview) and its paired result (stdout/stderr with truncation for very large outputs). The two are visually paired even though they may originate as separate message entries in the source JSONL.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Collapsed (default) | Tool name + one-line input/output summary |
| Expanded | Full input JSON + full stdout/stderr, with a "show more" affordance if still truncated |

## Props / Configuration
- `toolName` — string, rendered in `--glow` per style guide
- `input` — object/string preview
- `output` — stdout/stderr text, `--text-muted`, JetBrains Mono 12px
- `truncated` — boolean + `fullLength` for a "show N more lines" control

## Interactions
- Independent expand/collapse per block
- Truncated output has an explicit "show full output" action rather than silently capping
