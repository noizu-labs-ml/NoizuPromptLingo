# Artifact Domain

Artifacts are versioned, typed content objects. Each artifact has a `kind` (code, document, image, wiki, etc.) and a chain of revisions. Artifacts are the shared content substrate — wiki pages, review targets, and chat attachments all reference artifacts.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Artifact.Overview` | visible | List artifact tools and kind summary |
| `Artifact.Create` | hidden | Create a versioned artifact with initial revision |
| `Artifact.Get` | hidden | Fetch artifact with latest or specific revision |
| `Artifact.List` | hidden | List artifacts filtered by kind |
| `Artifact.AddRevision` | hidden | Append a new revision to an artifact |
| `Artifact.ListRevisions` | hidden | List revision summaries |
| `Artifact.GetBinary` | hidden | Fetch raw binary content as base64 |

---

### Artifact.Overview

Returns a list of all artifact tools with descriptions and a count of artifacts by kind.

**Parameters:** None

---

### Artifact.Create

Create a new artifact with its initial revision. The artifact kind determines how content is interpreted and rendered.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `kind` | str | yes | Artifact kind: `"code"`, `"document"`, `"image"`, `"wiki"`, `"config"`, `"binary"` |
| `title` | str | yes | Artifact title |
| `content` | str | yes | Initial content (text or base64 for binary) |
| `mime_type` | str | no | MIME type (e.g., `"text/markdown"`, `"image/png"`) |
| `metadata` | dict | no | Additional metadata |

**Returns:** Artifact object with `id`, `revision_id`, `kind`, `title`, `created_at`.

---

### Artifact.Get

Fetch an artifact with its content. Returns the latest revision by default, or a specific revision.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `artifact_id` | int | yes | Artifact ID |
| `revision_id` | int | no | Specific revision ID. If omitted, returns latest. |

---

### Artifact.List

List artifact heads (latest revision per artifact). Paginated and optionally filtered by kind.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `kind` | str | no | Filter by artifact kind |
| `search` | str | no | Search in title |
| `limit` | int | no | Max results (default 50) |
| `offset` | int | no | Pagination offset |

---

### Artifact.AddRevision

Append a new revision to an existing artifact. The previous revision is preserved.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `artifact_id` | int | yes | Artifact ID |
| `content` | str | yes | New content |
| `note` | str | no | Revision note describing changes |

**Returns:** New revision object with `revision_id`, `created_at`.

---

### Artifact.ListRevisions

List revision summaries for an artifact, ordered newest first.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `artifact_id` | int | yes | Artifact ID |
| `limit` | int | no | Max results (default 50) |

---

### Artifact.GetBinary

Fetch the raw binary content of an artifact revision encoded as base64.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `artifact_id` | int | yes | Artifact ID |
| `revision_id` | int | no | Specific revision ID. If omitted, returns latest. |

**Returns:** `{ "content_base64": "...", "mime_type": "...", "size_bytes": ... }`
