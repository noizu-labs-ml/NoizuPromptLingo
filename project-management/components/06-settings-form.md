# Settings Form

| Field | Value |
|-------|-------|
| **ID** | `settings-form` |
| **Category** | Input & Forms |
| **Used In** | 07-user-profile, 14-admin-llm-model-catalog, 15-admin-mcp-custom-scopes, 16-admin-media-providers, 23-chat-room-view, 33-agent-personas-management, 35-instructions-prompt-templates, 44-org-members, 45-org-settings |

## Description

A labeled-field form for creating or editing a configuration entity — profile details, provider credentials, scope presets, notification preferences, persona bios, prompt templates, invite tokens, org identity. The generic shape underneath most "fill fields, save" screens in the product.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | A handful of fields inline (e.g. name + key prefix) |
| **Expanded** | Multi-section form with validation and a distinct save/cancel action |
| **Full Page** | The form is the entire screen content (e.g. a template or preset editor) |

## Props / Configuration

- `fields` — field definitions (label, type, validation)
- `initialValues` / `onSave`
- `testAction` — optional inline verification step before save is allowed (e.g. a live connectivity test)
- `primaryActionLabel` — overrides the default "Save" label for specialized submits (e.g. "Render & Spawn")

## Interactions

- User edits one or more fields and saves → values persist and a confirmation (inline or toast) appears
- If `testAction` is configured, the user can fire it before saving to get a pass/fail result inline
- Some instances autosave on blur (e.g. inline header edits) rather than requiring an explicit save click
