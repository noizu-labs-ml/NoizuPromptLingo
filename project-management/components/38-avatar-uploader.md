# Avatar Uploader

| Field | Value |
|-------|-------|
| **ID** | `avatar-uploader` |
| **Category** | Forms / Media |
| **Used In** | S02 Profile Setup, S22 Account Settings |

## Description

Image upload component for setting a user profile photo. Provides a dropzone or click-to-browse trigger, an in-browser crop UI (circular mask), a preview of the cropped result, and a save/cancel flow. Falls back to an initials-based generated avatar (colored circle with 1–2 initial letters) when no image is uploaded. Handles image validation (type, max size) and upload progress.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Current avatar thumbnail + "Change photo" link; used in settings forms alongside other fields |
| **Expanded** | Full dropzone + crop canvas + preview; used in dedicated onboarding profile setup step |

## Props / Configuration

- `currentAvatarUrl` — String or null; URL of the existing avatar image
- `initials` — String; 1–2 characters used for the fallback avatar; derived from display name
- `initialsColor` — String; background color for the initials avatar; auto-assigned from user ID hash if omitted
- `maxSizeBytes` — Number; upload size limit in bytes; defaults to 5MB
- `acceptedTypes` — String array; MIME types; defaults to `['image/jpeg', 'image/png', 'image/webp']`
- `onUpload` — Async callback `(croppedBlob: Blob) => Promise<string>`; receives cropped image, returns new avatar URL
- `onRemove` — Callback invoked when user removes current avatar and reverts to initials
- `cropAspectRatio` — Number; defaults to `1` (square/circle crop)

## Interactions

- Dropzone accepts drag-and-drop or click-to-browse; highlights border on drag-over
- After file selection, crop modal opens with pan and zoom controls; Save applies the crop
- Upload progress renders as an arc overlay on the preview circle
- Validation errors (wrong type, too large) appear as inline error text below the dropzone
- "Remove photo" link appears when a custom avatar is set; triggers `onRemove` after confirmation
