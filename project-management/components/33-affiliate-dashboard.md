# Affiliate Dashboard

| Field | Value |
|-------|-------|
| **ID** | `affiliate-dashboard` |
| **Category** | Data Display |
| **Used In** | 17-Creator Dashboard |

## Description

Creator affiliate program management panel showing application form, referral code, and conversion metrics (installs, conversions, pending rewards).

## Size Variants

| Variant | Description |
|---------|-------------|
| Compact | Referral code + summary stats |
| Expanded | Full dashboard with metrics charts |

## Props / Configuration

- `applicationStatus` — `pending` | `approved` | `rejected`
- `referralCode` — Unique referral code string
- `metrics` — Installs, conversions, and rewards data object

## Interactions

- Submit affiliate program application
- Copy referral code to clipboard
- View conversion metrics breakdown
- Track pending rewards status
