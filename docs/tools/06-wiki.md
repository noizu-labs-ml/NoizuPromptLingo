# Wiki Domain

**Subdomain:** `wiki.tobor.locker`
**Status:** New (not yet implemented)

Wiki provides persistent, versioned knowledge pages organized into spaces. Page content is stored as artifact revisions, giving automatic version history. Pages support hierarchical nesting, tagging, inline comments, attachments, and permissions.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Wiki.Overview` | visible | List wiki tools and space summary |
| `Wiki.CreateSpace` | hidden | Create a wiki namespace |
| `Wiki.CreatePage` | hidden | Create a page in a space |
| `Wiki.EditPage` | hidden | Update page content |
| `Wiki.GetPage` | hidden | Get page with current content |
| `Wiki.ListPages` | hidden | List pages with filters |
| `Wiki.Attach` | hidden | Attach file or artifact (cross-cutting) |
| `Wiki.Comment` | hidden | Add comment to a page (cross-cutting) |
| `Wiki.Permissions` | hidden | Set access control on pages or spaces |

---

### Wiki.Overview

Returns a list of all wiki tools with descriptions and a summary of spaces (count, total pages).

**Parameters:** None

---

### Wiki.CreateSpace

Create a wiki namespace. Spaces are top-level containers that group related pages.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `slug` | str | yes | Unique space identifier (URL-safe) |
| `name` | str | yes | Display name |
| `description` | str | no | Space description |

**Returns:** Space object with `id`, `slug`, `name`, `created_at`.

---

### Wiki.CreatePage

Create a new wiki page in a space. Content is stored as an artifact of kind `"wiki"`, so all revisions are automatically tracked.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `space_id` | int | yes | Space ID |
| `slug` | str | yes | Page slug (unique within space) |
| `title` | str | yes | Page title |
| `content` | str | yes | Page body (markdown) |
| `tags` | list | no | List of tag strings |
| `parent_page_id` | int | no | Parent page ID for nested hierarchy |

**Returns:** Page object with `id`, `slug`, `title`, `artifact_id`, `created_at`.

---

### Wiki.EditPage

Update a page's content. Creates a new artifact revision internally — the previous content is preserved in revision history.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `page_id` | int | yes | Page ID |
| `content` | str | yes | Updated page body (markdown) |
| `title` | str | no | Updated title |
| `tags` | list | no | Updated tags (replaces existing) |
| `edit_message` | str | no | Short description of what changed (stored as revision note) |

---

### Wiki.GetPage

Get a wiki page with its current content. Optionally fetch a specific revision.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `page_id` | int | yes | Page ID |
| `revision_id` | int | no | Specific revision ID. If omitted, returns latest. |

**Returns:** Page object with `id`, `title`, `content`, `tags`, `revision_id`, `updated_at`.

---

### Wiki.ListPages

List wiki pages with optional filtering by space, tag, or parent page.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `space_id` | int | no | Filter by space |
| `tag` | str | no | Filter by tag |
| `parent_page_id` | int | no | Filter by parent page (list children) |
| `search` | str | no | Full-text search in title and content |
| `limit` | int | no | Max results (default 50) |
| `offset` | int | no | Pagination offset |

---

### Wiki.Attach

Attach a file or artifact to a wiki page. Uses the generic [Attach](12-cross-cutting.md#attach) pattern with `entity_type="wiki_page"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `page_id` | int | yes | Page ID |
| `artifact_id` | int | no | Artifact ID to attach |
| `artifact_type` | str | no | Type: `"artifact"`, `"url"`, `"file"` (default `"artifact"`) |
| `url` | str | no | URL if artifact_type is `"url"` |
| `description` | str | no | Description of the attachment |

---

### Wiki.Comment

Add a comment to a wiki page. Supports page-level comments and inline comments at specific locations. Uses the generic [Comment](12-cross-cutting.md#comment) pattern with `entity_type="wiki_page"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `page_id` | int | yes | Page ID |
| `content` | str | yes | Comment body (markdown) |
| `author` | str | yes | Persona slug of commenter |
| `location` | str | no | Inline location (line number, heading, text selection). Omit for page-level comment. |
| `reply_to_id` | int | no | Parent comment ID for threaded replies |

---

### Wiki.Permissions

Set access control on a wiki page or space. Permissions are per-persona.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entity_type` | str | yes | `"space"` or `"page"` |
| `entity_id` | int | yes | Space or page ID |
| `persona` | str | yes | Persona slug to grant/revoke |
| `permission` | str | yes | Permission level: `"read"`, `"write"`, `"admin"` |
| `action` | str | no | `"grant"` (default) or `"revoke"` |
