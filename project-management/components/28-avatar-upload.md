# Avatar Upload

| Field | Value |
|-------|-------|
| **ID** | `avatar-upload` |
| **Category** | Input & Forms |
| **Used In** | 03-Profile Creation, 37-Edit Profile |

## Description

Image upload control with crop/resize/preview. Validates file type (JPG, PNG, WebP) and size (max 2MB). Auto-resizes to 256x256.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Circular avatar with upload overlay |
| **Expanded** | Upload area + crop tool + preview |

## Props / Configuration

- `maxSize` — Maximum file size (default 2MB)
- `allowedTypes` — Accepted formats
- `outputSize` — Resize target (default 256x256)

## Interactions

- Click/drop to upload; crop tool; preview result; save
