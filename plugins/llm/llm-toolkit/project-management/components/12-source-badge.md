# 12: Source Badge

| Field | Value |
|-------|-------|
| ID | CMP-12 |
| Category | Data Display |
| Surfaces | web, cli-ink |
| Used In | SCR-10, SCR-11, SCR-24, SCR-25 |

## Description
Small badge linking a derived artifact (dataset entry, saved prompt) back to its source conversation — title plus a click-through link.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Dataset entry / saved prompt provenance |

## Props / Configuration
- `sourceConversationId` — string, optional (prompts can be created without a source)
- `sourceTitle` — display text

## Interactions
- Click navigates to Thread Viewer (SCR-04 / SCR-19) at the source conversation
