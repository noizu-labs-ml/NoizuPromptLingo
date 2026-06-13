# Artifact List

| Field | Value |
|-------|-------|
| **ID** | `artifact-list` |
| **Category** | Tables & Lists |
| **Used In** | 02-Task Detail Page, 09-Execution Progress Panel |

## Description

List of output files produced by a task execution. Each entry displays the filename, file size, MIME type, and a signed download URL. Handles expired URLs with a visual expired state.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Panel-embedded list with icon, filename, size, and download button per row |
| **Compact** | Single-line attachment row with filename and download icon; minimal metadata |

## Props / Configuration

- `artifacts` — array of artifact objects (`id`, `filename`, `size`, `mimeType`, `downloadUrl`, `expiresAt`)
- `onDownload` — callback invoked with the artifact object when a download is initiated
- `showMimeType` — boolean controlling visibility of the MIME type label
- `showSize` — boolean controlling visibility of the file size label

## Interactions

- Clicking a download button or filename initiates download via the signed `downloadUrl` and calls `onDownload`
- Artifacts with an expired `downloadUrl` render in a disabled state with an "Expired" label instead of the download control
