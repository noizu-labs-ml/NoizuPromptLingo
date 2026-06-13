# Upgrade Modal

| Field | Value |
|-------|-------|
| **ID** | `upgrade-modal` |
| **Category** | Modals & Overlays |
| **Used In** | 05-Projects Dashboard, 29-Billing Settings |

## Description

Contextual in-app upgrade modal with Stripe payment integration. Shows current tier vs. target tier comparison, processes payment, and immediately unlocks features on success.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full modal with tier comparison + payment form |

## Props / Configuration

- `currentTier` — Current plan details
- `targetTier` — Plan being upgraded to
- `features` — Newly unlocked features list
- `stripePublicKey` — Payment integration

## Interactions

- Shows what you're gaining (feature comparison)
- Stripe Elements form for card input
- Processing state with spinner
- Success: confetti + immediate feature unlock
- Failure: error message with retry option
