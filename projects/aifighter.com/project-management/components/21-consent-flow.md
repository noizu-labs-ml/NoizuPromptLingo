# Consent Flow

| Field | Value |
|-------|-------|
| **ID** | `consent-flow` |
| **Category** | Modals & Overlays |
| **Used In** | 10-Education Portal |

## Description

COPPA-compliant multi-step consent flow for student accounts including age gate, parental/educator consent form, and activation confirmation email trigger.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full Page** | Multi-step wizard (age gate → consent form → confirmation) |

## Props / Configuration

- `accountType` — Account type being created (student | minor)
- `consentType` — Who is providing consent (parental | educator)
- `requiredFields` — List of required form fields for consent submission

## Interactions

- Complete age verification step
- Submit consent form with required fields
- Trigger activation confirmation email
- View restricted feature indicators after consent completion
