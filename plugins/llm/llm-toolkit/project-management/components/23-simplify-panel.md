# 23: Simplify Panel

| Field | Value |
|-------|-------|
| ID | CMP-23 |
| Category | AI-Specific |
| Surfaces | web, cli-ink |
| Used In | SCR-05, SCR-21 |

## Description
Slide-out panel showing an LLM-assisted rewrite of a selected message range, with per-suggestion accept/reject. The only editor surface that makes a live LLM call (`POST /api/llm/simplify`), so it carries its own loading/error states independent of the rest of the editor.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Slide-out (web) | Right-edge panel |
| Overlay (cli-ink) | Bulk-simplify (`L`) applies the same rewrite pipeline without a dedicated visible panel — result is written directly into the draft with an inline status line |

## Props / Configuration
- `selection` — message range being simplified
- `rewrite` — proposed rewritten content, streamed or returned whole
- `status` — `"idle" \| "loading" \| "error" \| "ready"`

## Interactions
- Accept applies the rewrite to EditedPane; Reject discards and leaves the original selection untouched
- LLM failure surfaces inline without discarding any manual edits already made elsewhere in the draft
