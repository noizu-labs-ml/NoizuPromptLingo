# Review Domain

**Subdomain:** `review.tobor.locker`

Reviews are structured feedback sessions against artifact revisions. They support inline comments at specific locations, coordinate-based image overlay annotations, and compilation into annotated output documents.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Review.Overview` | visible | List review tools and workflow states |
| `Review.Create` | hidden | Start a review for an artifact revision |
| `Review.Get` | hidden | Fetch review with comments and overlays |
| `Review.Comment` | hidden | Add inline or general comment (cross-cutting) |
| `Review.Overlay` | hidden | Add coordinate-based image annotation |
| `Review.Complete` | hidden | Mark review as completed |
| `Review.Compile` | hidden | Generate annotated artifact with inline comments |
| `Review.Attach` | hidden | Attach supplementary artifact (cross-cutting) |

---

### Review.Overview

Returns a list of all review tools with descriptions and the available review workflow states.

**Parameters:** None

---

### Review.Create

Start a new review session for an artifact revision. A review collects inline comments, overlay annotations, and a final summary.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `artifact_id` | int | yes | ID of the artifact to review |
| `revision_id` | int | yes | ID of the specific revision to review |
| `reviewer_persona` | str | yes | Persona slug of the reviewer |
| `title` | str | no | Review title |

**Returns:** Review object with `id`, `artifact_id`, `revision_id`, `status`, `created_at`.

---

### Review.Get

Fetch a review with all its inline comments and overlay annotations.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `review_id` | int | yes | Review ID |

**Returns:** Review object including `comments[]` and `overlays[]` arrays.

---

### Review.Comment

Add a comment to a review. Can be a general comment on the whole document or an inline comment at a specific location. Uses the generic [Comment](12-cross-cutting.md#comment) pattern with `entity_type="review"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `review_id` | int | yes | Review ID |
| `content` | str | yes | Comment text (markdown) |
| `author` | str | yes | Persona slug of commenter |
| `location` | str | no | Location in artifact (line number, section name, CSS selector, etc.) |
| `reply_to_id` | int | no | Parent comment ID for threaded replies |

**Aliases:** `Review.AddComment`

---

### Review.Overlay

Add a coordinate-based overlay annotation on an image or visual artifact. Overlays are positioned by (x, y) coordinates and rendered as markers on the artifact.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `review_id` | int | yes | Review ID |
| `x` | int | yes | X coordinate of the annotation |
| `y` | int | yes | Y coordinate of the annotation |
| `comment` | str | yes | Annotation text |
| `persona` | str | yes | Persona slug of the annotator |
| `width` | int | no | Annotation region width |
| `height` | int | no | Annotation region height |

**Aliases:** `Review.AddOverlay`

---

### Review.Complete

Mark a review as completed. Optionally include a summary comment.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `review_id` | int | yes | Review ID |
| `summary` | str | no | Final summary comment |
| `verdict` | str | no | Review verdict: `"approved"`, `"changes_requested"`, `"rejected"` |

---

### Review.Compile

Generate an annotated version of the reviewed artifact with all inline comments and overlays rendered in-place. For text artifacts, comments are inserted as inline annotations. For images, overlays are composited.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `review_id` | int | yes | Review ID |
| `format` | str | no | Output format: `"markdown"` (default), `"html"`, `"pdf"` |

**Returns:** Annotated artifact content or artifact ID of the compiled output.

---

### Review.Attach

Attach a supplementary artifact to a review (e.g., a revised version, a screenshot, supporting documentation). Uses the generic [Attach](12-cross-cutting.md#attach) pattern with `entity_type="review"`.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `review_id` | int | yes | Review ID |
| `artifact_id` | int | no | Artifact ID to attach |
| `artifact_type` | str | no | Type: `"artifact"`, `"url"`, `"file"` (default `"artifact"`) |
| `url` | str | no | URL if artifact_type is `"url"` |
| `description` | str | no | Description of the attachment |
