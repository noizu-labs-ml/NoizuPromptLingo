# Model Selector

| Field | Value |
|-------|-------|
| **ID** | `model-selector` |
| **Category** | Generation |
| **Used In** | S-12 Generation Studio, S-27 AI Settings |

## Description

Selector for choosing the AI model used for generation. Displays each available model with its name, a brief capability description, estimated cost per 1,000 tokens, and a tier availability badge indicating which subscription plans can access it.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact dropdown showing only the selected model name with a chevron — used in the generation studio toolbar |
| **Expanded** | Card grid or list with full model details; used in the AI Settings screen for persistent model preference |

## Props / Configuration

- `models` — Array of model descriptors: `{ id, name, description, costPer1kTokens, availableTiers[], contextWindow }`
- `selectedModelId` — Currently selected model ID
- `userTier` — Current user's subscription tier; used to disable unavailable models
- `variant` — `"inline"` | `"expanded"` (default: `"inline"`)
- `showCostEstimate` — Boolean; renders cost-per-1k-tokens when true (default: true in expanded)
- `onSelect` — Callback receiving selected model ID

## Interactions

- Inline dropdown opens a popover list of models on click; selected model shown with a checkmark
- Unavailable models (above user's tier) are rendered greyed-out with a lock icon and "Upgrade to access" tooltip
- Expanded card variant highlights the selected model with a border; clicking any card selects it
- Cost estimate is shown per model in the expanded view; in inline mode it appears as a tooltip on the selected model
- Context window size is shown as a secondary metadata line (e.g., "128k context") in the expanded card
- Selecting a model in Generation Studio applies only to the current generation session, not globally
- Selecting a model in AI Settings updates the user's default model preference, persisted across sessions
- A "Recommended" badge is shown on the model that best matches the user's tier and use case
