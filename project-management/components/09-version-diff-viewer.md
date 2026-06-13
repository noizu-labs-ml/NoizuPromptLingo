# Version Diff Viewer

| Field | Value |
|-------|-------|
| **ID** | `version-diff-viewer` |
| **Category** | Data Display |
| **Used In** | 18-Backlog Grooming, 39-Wiki Editor, 61-Prompt Version Timeline, 62-Prompt Comparison, 67-Prompt Audit Trail |

## Description

Side-by-side or inline diff display showing additions/deletions between two versions of text content

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Inline diff with colored additions/deletions |
| **Compact** | Collapsed diff summary with expand |
| **Expanded** | Side-by-side full diff panel |
| **Full_Page** | Full-page comparison view with metrics |

## Props / Configuration

- `versionA` — text content
- `versionB` — text content
- `mode` — side-by-side|inline
- `highlights` — semantic change annotations
- `metadata` — version info for each side

## Interactions

- toggle between side-by-side and inline
- click change to see context
- navigate between changes
- copy from either side
