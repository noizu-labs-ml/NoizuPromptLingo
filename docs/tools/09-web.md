# Web Domain

**Consolidated from:** Browser

Web tools provide headless browser automation, page capture, interactive sessions, visual regression testing, and HTTP utilities. Interactive sessions persist across calls for multi-step browser workflows.

## Methods

| Method | Visibility | Description |
|--------|-----------|-------------|
| `Web.Overview` | visible | List web/browser tools |
| `Web.ToMarkdown` | hidden | Convert a web page to clean markdown |
| `Web.Capture` | hidden | Full-page screenshot of a URL |
| `Web.Screenshot` | hidden | Screenshot current browser page or element |
| `Web.Navigate` | hidden | Navigate browser session to a URL |
| `Web.Click` | hidden | Click an element in browser session |
| `Web.Fill` | hidden | Fill a form field in browser session |
| `Web.GetState` | hidden | Get current page state |
| `Web.ListSessions` | hidden | List active browser sessions |
| `Web.CloseSession` | hidden | Close a browser session |
| `Web.Diff` | hidden | Compare two screenshots for regressions |
| `Web.Checkpoint` | hidden | Capture visual checkpoint across URLs/viewports |
| `Web.ListCheckpoints` | hidden | List visual checkpoints |
| `Web.CompareCheckpoints` | hidden | Compare checkpoints for regressions |
| `Web.Ping` | hidden | Check if a URL is reachable |
| `Web.Download` | hidden | Download a file from a URL |
| `Web.Rest` | hidden | Make a REST API call |

---

### Web.Overview

Returns a list of all web tools with descriptions.

**Parameters:** None

---

## Page Capture

### Web.ToMarkdown

Fetch a web page and convert it to clean markdown. Strips navigation, ads, and boilerplate; extracts the main content.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | str | yes | URL to convert |
| `selector` | str | no | CSS selector to extract specific element |
| `include_links` | bool | no | Preserve hyperlinks in output (default true) |
| `include_images` | bool | no | Include image alt text (default true) |

**Aliases:** `ToMarkdown`

---

### Web.Capture

Capture a full-page screenshot of a URL. Creates a new browser page, navigates, screenshots, and closes.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | str | yes | URL to capture |
| `viewport_width` | int | no | Viewport width in pixels (default 1280) |
| `viewport_height` | int | no | Viewport height in pixels (default 720) |
| `full_page` | bool | no | Capture full scrollable page (default true) |
| `format` | str | no | Image format: `"png"` (default), `"jpeg"` |

**Returns:** Screenshot as artifact with `artifact_id`.

**Aliases:** `Browser.Capture`

---

### Web.Screenshot

Screenshot the current page or a specific element in an active browser session.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | no | Browser session ID. If omitted, uses default session. |
| `selector` | str | no | CSS selector of element to screenshot. If omitted, captures full page. |
| `format` | str | no | Image format: `"png"` (default), `"jpeg"` |

**Aliases:** `Browser.Screenshot`

---

## Interactive Browser Sessions

### Web.Navigate

Navigate an interactive browser session to a URL.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | str | yes | URL to navigate to |
| `session_id` | str | no | Browser session ID. Creates new session if omitted. |
| `wait_for` | str | no | Wait condition: `"load"` (default), `"networkidle"`, CSS selector |

**Returns:** `{ "session_id": "...", "title": "...", "url": "..." }`

**Aliases:** `Browser.Interact.Navigate`

---

### Web.Click

Click an element in a browser session by CSS selector.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Browser session ID |
| `selector` | str | yes | CSS selector of element to click |

**Aliases:** `Browser.Interact.Click`

---

### Web.Fill

Fill a form field in a browser session.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Browser session ID |
| `selector` | str | yes | CSS selector of the input field |
| `value` | str | yes | Value to fill |

**Aliases:** `Browser.Interact.Fill`

---

### Web.GetState

Get the current state of a browser session: URL, title, scroll position, and page structure.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Browser session ID |

**Aliases:** `Browser.Interact.GetState`

---

### Web.ListSessions

List all active browser session IDs with their current URLs.

**Parameters:** None

**Aliases:** `Browser.ListSessions`

---

### Web.CloseSession

Close an interactive browser session and free resources.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `session_id` | str | yes | Browser session ID |

**Aliases:** `Browser.CloseSession`

---

## Visual Regression

### Web.Diff

Compare two screenshots pixel-by-pixel and highlight differences. Returns a diff image artifact.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `before_artifact_id` | int | yes | Artifact ID of the "before" screenshot |
| `after_artifact_id` | int | yes | Artifact ID of the "after" screenshot |
| `threshold` | float | no | Pixel difference threshold (0.0-1.0, default 0.1) |

**Aliases:** `Browser.Diff`

---

### Web.Checkpoint

Capture a visual checkpoint: screenshots across multiple URLs and/or viewports for later comparison.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | str | yes | Checkpoint name |
| `urls` | list | yes | List of URLs to capture |
| `viewports` | list | no | List of viewport sizes (default `[{"width": 1280, "height": 720}]`) |

**Aliases:** `Browser.Checkpoint`

---

### Web.ListCheckpoints

List all saved visual checkpoints.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `limit` | int | no | Max results (default 50) |

**Aliases:** `Browser.ListCheckpoints`

---

### Web.CompareCheckpoints

Compare two named checkpoints URL-by-URL, viewport-by-viewport and report regressions.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `baseline` | str | yes | Baseline checkpoint name |
| `current` | str | yes | Current checkpoint name |
| `threshold` | float | no | Pixel difference threshold (default 0.1) |

**Aliases:** `Browser.CompareCheckpoints`

---

## HTTP Utilities

### Web.Ping

Check if a URL is reachable. Returns status code and response time.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | str | yes | URL to check |
| `timeout` | int | no | Timeout in seconds (default 10) |

**Aliases:** `Ping`

---

### Web.Download

Download a file from a URL and store it as an artifact.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | str | yes | URL to download |
| `filename` | str | no | Override filename |

**Aliases:** `Download`

---

### Web.Rest

Make a REST API call. Supports all HTTP methods, headers, authentication, and body formats.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `url` | str | yes | API endpoint URL |
| `method` | str | no | HTTP method (default `"GET"`) |
| `headers` | dict | no | Request headers |
| `body` | str | no | Request body |
| `content_type` | str | no | Content-Type header (default `"application/json"`) |
| `secret_name` | str | no | Named secret to use for authentication |

**Aliases:** `Rest`
