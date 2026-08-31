# 17: Message Block

| Field | Value |
|-------|-------|
| ID | CMP-17 |
| Category | AI-Specific |
| Surfaces | web, cli-ink |
| Used In | SCR-04, SCR-05, SCR-08, SCR-19, SCR-21, SCR-33 |

## Description
The atomic rendering unit for one turn in a conversation — avatar/role label plus rendered content blocks (markdown text, code, thinking, tool-use, tool-result). User and Assistant variants share this shell; content-block sub-rendering is delegated to CMP-18 (Thinking Block) and CMP-19 (Tool Use/Result Block). Mirrored directly on CLI-ink as `MessageBlock.tsx` + `ContentBlockView.tsx`.

## Size Variants

| Variant | Use Case |
|---------|---------|
| User | User-authored message — JetBrains Mono 13px, `--text-primary` |
| Assistant | Assistant message — JetBrains Mono 13px, `--text-secondary`, may contain multiple content blocks |
| Compact (cli-ink/cli-command) | Role + content only, no avatar |

## Props / Configuration
- `role` — `"user" \| "assistant" \| "tool"`
- `contentBlocks` — array of typed blocks (text, thinking, tool_use, tool_result, image)
- `selected` — multi-select state (Thread Editor context)

## Interactions
- Individual content blocks (thinking, tool-use/result) collapse/expand independently within the message
- Selectable (checkbox / `Space`) in Thread Editor and Merge contexts
