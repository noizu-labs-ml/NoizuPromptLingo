# File Upload / Attachment Dropzone

| Field | Value |
|-------|-------|
| **ID** | `file-upload` |
| **Category** | Input & Forms |
| **Used In** | 01-Task Creation Form, 22-Dispute Resolution Page, 28-Account Settings |

## Description

Drag-and-drop file upload area with MIME type and size validation, upload progress tracking, image preview, and management of existing uploaded files.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact attachment row with add button and file list |
| **Compact** | Single-file button trigger with minimal UI |
| **Expanded** | Full dropzone with dashed border, drop instructions, preview grid, and progress bars |

## Props / Configuration

- `accept` — Accepted MIME types or file extensions (e.g., `"image/*,.pdf"`)
- `maxSize` — Maximum file size in bytes per file
- `maxFiles` — Maximum number of files allowed
- `multiple` — Whether multiple file selection is permitted
- `onUpload` — Callback with file(s) once upload completes
- `showPreview` — Whether image files are rendered as thumbnails
- `existingFiles[]` — Array of already-uploaded file objects to display in the list

## Interactions

- Drag files onto the dropzone to initiate upload
- Click the zone or button to open the OS file picker
- Remove individual files from the list via a delete control
- Image files render as thumbnail previews when `showPreview` is enabled
- Progress bar tracks upload completion per file
