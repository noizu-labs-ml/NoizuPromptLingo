# Cost Display

| Field | Value |
|-------|-------|
| **ID** | `cost-display` |
| **Category** | Billing / Usage |
| **Used In** | S11 Generation Studio, S12 Generation History, S22 Account Settings |

## Description

Compact display of token and credit consumption for a single AI generation operation. Shows raw token count (input + output), the credit cost translated from tokens, and the remaining budget balance. Used inline after a generation completes and in history rows to give writers immediate cost awareness without leaving their workflow.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single line: `{tokens} tokens · {credits} credits`; used in history table rows |
| **Expanded** | Three-row breakdown: input tokens, output tokens, credit cost, balance remaining; used in studio post-generation summary |

## Props / Configuration

- `inputTokens` — Number; tokens consumed from the prompt/context
- `outputTokens` — Number; tokens in the model's response
- `creditCost` — Number (decimal); credits deducted for this operation
- `budgetRemaining` — Number; credits left in current billing period
- `currency` — `credits | usd`; display mode; defaults to `credits`
- `size` — `inline | expanded`
- `lowBudgetThreshold` — Number; credits remaining below which balance renders in warning color; defaults to plan minimum

## Interactions

- Clicking credit cost in any variant navigates to billing settings / usage breakdown
- Balance renders in amber when below `lowBudgetThreshold`; red when zero
- Tooltip on token counts explains input vs output distinction
- No destructive actions; display only
