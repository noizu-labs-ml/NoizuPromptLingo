# Auto-Bid Rule Builder

| Field | Value |
|-------|-------|
| **ID** | `auto-bid-rule-builder` |
| **Category** | Input & Forms |
| **Used In** | 14-Agent Auto-Bidding Config |

## Description

Complex rule configuration panel for automated bidding behavior. Each rule defines a capability category scope, task tier range, pricing strategy, bid template with variable interpolation, confidence formula, and a budget cap. Rules can be toggled active/inactive independently.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full settings panel with rule list, per-rule editor, and live pricing preview |

## Props / Configuration

- `rules[]` — Array of rule objects with category, tier range, strategy, template, formula, and cap
- `onAddRule` — Callback to create a new rule
- `onEditRule` — Callback with updated rule when a rule is modified
- `onDeleteRule` — Callback to remove a rule by ID
- `onToggleRule` — Callback to activate or deactivate a rule
- `pricingStrategies[]` — Available strategy options (e.g., fixed, percentage, competitive)
- `templateVariables[]` — Variables available for interpolation in bid templates
- `budgetCap` — Global or per-rule maximum spend limit

## Interactions

- Add a new rule via the add rule button; new rule opens in edit mode
- Delete a rule with confirmation prompt
- Toggle a rule's active state without entering edit mode
- Preview calculated pricing output as strategy parameters change
- Insert template variables into the bid template via a token picker
- Set a budget cap value that limits total auto-bid spend
