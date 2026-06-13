# Danger Zone

| Field | Value |
|-------|-------|
| **ID** | `danger-zone` |
| **Category** | Settings |
| **Used In** | S-29 Universe Settings, S-23 Account Settings (Delete Section) |

## Description

Visually distinct section for destructive and irreversible actions. Rendered with a red border, a warning header, and individual action rows each requiring explicit user confirmation before execution. Placed at the bottom of settings screens to reduce accidental activation.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full section with red-bordered card, "Danger Zone" heading, warning description, and one or more action rows — standard usage |

## Props / Configuration

- `actions` — Array of danger action descriptors:
  - `id` — Unique action identifier
  - `label` — Action button label (e.g., "Delete Universe", "Delete Account")
  - `description` — One-sentence explanation of the irreversible consequence
  - `confirmationText` — Exact string the user must type to confirm (e.g., the universe name or `"delete my account"`)
  - `onConfirm` — Callback invoked after successful confirmation
- `sectionTitle` — Override for the section heading (default: "Danger Zone")

## Interactions

- Each action row shows a description text on the left and a red-outlined button on the right
- Clicking an action button opens a modal confirmation dialog specific to that action
- Confirmation modal requires the user to type the exact `confirmationText` string into an input field before the confirm button becomes active; prevents accidental one-click destruction
- Confirm button in the modal remains disabled until the typed value matches `confirmationText` exactly (case-sensitive)
- On confirm, a loading spinner replaces the button while the destructive operation executes
- Success redirects to an appropriate screen (e.g., universe list after universe deletion, login after account deletion)
- Failure shows an inline error message in the modal with the reason; the action can be retried
- The section is visually separated from the rest of the settings page by extra vertical margin and the red border treatment
- Screen readers announce the section as a "Danger Zone" landmark to alert assistive technology users
