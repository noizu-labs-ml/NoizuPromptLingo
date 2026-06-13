# User Stories — Phases 2–4: Paint, Interact, Connect

> **Project:** therobotbrowses — AI/LLM-native web browser in Rust
> **Scope:** GPU rendering, user interaction, MCP server integration

---

## Phase 2 — Paint

### US-201: GPU Rendering Pipeline Initialization

**As** P-001 Kai (tool-building developer), **I want** the browser to initialize a wgpu-based GPU rendering pipeline on startup, **so that** all visual output is hardware-accelerated and I can build on a performant foundation.

**Acceptance Criteria:**
- [ ] wgpu adapter and device are acquired with graceful fallback to software rasterizer
- [ ] A render surface is created and bound to the native window
- [ ] Frame presentation uses double-buffering with vsync
- [ ] GPU initialization errors produce actionable diagnostics to stderr

**Phase:** 2 — Paint
**Priority:** P0
**Personas:** P-001, P-003

---

### US-202: Box Model Painting

**As** P-003 Maya (keyboard power user), **I want** the browser to paint CSS box model elements (backgrounds, borders, padding) correctly, **so that** pages render with proper visual structure.

**Acceptance Criteria:**
- [ ] Background colors and background-clip are painted per CSS spec
- [ ] Border widths, styles (solid, dashed, dotted, double), and colors render correctly
- [ ] Border-radius produces anti-aliased rounded corners
- [ ] Box-shadow (inset and outset) renders with correct blur and spread

**Phase:** 2 — Paint
**Priority:** P0
**Personas:** P-003, P-004

---

### US-203: Image Decoding and Display

**As** P-002 Dr. Amara (researcher), **I want** the browser to decode and display PNG, JPEG, GIF, and WebP images, **so that** I can view research papers, diagrams, and figures inline.

**Acceptance Criteria:**
- [ ] PNG images decode with alpha transparency support
- [ ] JPEG images decode with proper color space conversion (CMYK → sRGB)
- [ ] GIF images decode with first-frame display (animated GIF support is P2)
- [ ] WebP images decode (lossy and lossless)
- [ ] Broken or unsupported images display a placeholder with alt text
- [ ] Image decoding runs on a background thread to avoid blocking paint

**Phase:** 2 — Paint
**Priority:** P0
**Personas:** P-002, A-002

---

### US-204: Font Rendering with Hinting and Antialiasing

**As** P-004 Jordan (accessibility advocate), **I want** text to render with proper font hinting, subpixel antialiasing, and configurable sizing, **so that** text is legible at all sizes and display densities.

**Acceptance Criteria:**
- [ ] System fonts are discovered and loaded via fontdb or equivalent
- [ ] TrueType and OpenType font rendering with hinting (light, normal, full modes)
- [ ] Subpixel antialiasing for LCD displays, with grayscale fallback
- [ ] Font fallback chain resolves missing glyphs across installed fonts
- [ ] Emoji rendering via color font tables (COLR/CPAL or CBDT/CBLC)
- [ ] Minimum font size is configurable (accessibility setting)

**Phase:** 2 — Paint
**Priority:** P0
**Personas:** P-004, P-003

---

### US-205: CSS Gradient Rendering

**As** P-001 Kai (tool-building developer), **I want** the browser to render CSS linear, radial, and conic gradients, **so that** modern web pages display correctly without visual regressions.

**Acceptance Criteria:**
- [ ] Linear gradients render with correct angle, color stops, and interpolation
- [ ] Radial gradients render (circle and ellipse shapes, closest-side/farthest-corner sizing)
- [ ] Conic gradients render with correct from-angle and color stop distribution
- [ ] Repeating variants of all three gradient types work
- [ ] Gradient rendering is performed on the GPU via shader programs

**Phase:** 2 — Paint
**Priority:** P1
**Personas:** P-001, P-003

---

### US-206: Compositing and Z-Order

**As** A-001 Claude (browsing copilot agent), **I want** overlapping elements to composite correctly according to CSS stacking contexts and z-index, **so that** I can reliably identify which elements are visually on top when interpreting a page.

**Acceptance Criteria:**
- [ ] Stacking contexts are created per CSS spec (position, opacity, transform, etc.)
- [ ] z-index ordering is respected within each stacking context
- [ ] opacity < 1.0 composites correctly with elements underneath
- [ ] mix-blend-mode applies (at minimum: normal, multiply, screen, overlay)
- [ ] Overflow clipping (overflow: hidden/scroll/auto) clips child content correctly

**Phase:** 2 — Paint
**Priority:** P0
**Personas:** A-001, P-001

---

### US-207: Smooth Scrolling and Scroll Snap

**As** P-003 Maya (keyboard power user), **I want** pages to scroll smoothly via keyboard, trackpad, and mouse wheel, with CSS scroll-snap support, **so that** navigation feels responsive and precise.

**Acceptance Criteria:**
- [ ] Scroll events from mouse wheel, trackpad gesture, and keyboard (Page Up/Down, arrow keys, Space) produce smooth animation
- [ ] scroll-behavior: smooth animates scroll position over time
- [ ] CSS scroll-snap-type (x/y, mandatory/proximity) snaps to scroll-snap-align targets
- [ ] Scrollbar is rendered (native or custom) and is draggable
- [ ] Overflow: auto/scroll creates scrollable containers for overflowing content
- [ ] Scroll position is maintained on back/forward navigation

**Phase:** 2 — Paint
**Priority:** P1
**Personas:** P-003, P-004

---

### US-208: Text Selection and Highlighting

**As** P-002 Dr. Amara (researcher), **I want** to select text by clicking and dragging, and see it highlighted, **so that** I can copy content from web pages for my research.

**Acceptance Criteria:**
- [ ] Click-and-drag selects text across inline elements
- [ ] Double-click selects a word; triple-click selects a line/paragraph
- [ ] Selection is visually highlighted with the system selection color
- [ ] Ctrl/Cmd+A selects all text in the document
- [ ] Selected text is available to the clipboard on Ctrl/Cmd+C

**Phase:** 2 — Paint
**Priority:** P1
**Personas:** P-002, P-003, A-001

---

### US-209: HiDPI and Multi-Monitor Support

**As** P-001 Kai (tool-building developer), **I want** the browser to render correctly on HiDPI (Retina) displays and handle monitor scale factor changes, **so that** content is crisp regardless of display configuration.

**Acceptance Criteria:**
- [ ] Device pixel ratio is detected and applied to the render surface
- [ ] Moving the window between monitors with different scale factors triggers re-render at the correct DPI
- [ ] Images are rendered at native resolution when available (srcset support is Phase 3+)
- [ ] Text remains crisp at all scale factors

**Phase:** 2 — Paint
**Priority:** P1
**Personas:** P-001, P-003

---

### US-210: Accessibility Paint Modes

**As** P-004 Jordan (accessibility advocate), **I want** the browser to support forced-colors mode and high-contrast rendering, **so that** users with visual impairments can perceive all page content.

**Acceptance Criteria:**
- [ ] forced-colors: active media query is detectable and applies system color overrides
- [ ] prefers-contrast: more/less media query is reported to CSS
- [ ] A built-in high-contrast toggle overrides page colors with a user-selected palette
- [ ] Focus indicators are always visible (minimum 2px solid outline) regardless of page styles
- [ ] Text-over-image areas compute contrast and optionally add a background scrim

**Phase:** 2 — Paint
**Priority:** P1
**Personas:** P-004, P-003

---

### US-211: Paint Performance Profiling

**As** A-002 Crawler (headless data harvester agent), **I want** paint operations to complete within a frame budget (16ms at 60fps), **so that** headless rendering for screenshots and DOM snapshots is fast and predictable.

**Acceptance Criteria:**
- [ ] Frame timing is measured and exposed via an internal performance API
- [ ] Frames exceeding 16ms are logged with a breakdown of paint phases (layout, raster, composite)
- [ ] Headless mode skips window presentation but still executes the full paint pipeline
- [ ] A --no-paint flag skips GPU rendering entirely for DOM-only headless use cases

**Phase:** 2 — Paint
**Priority:** P2
**Personas:** A-002, P-001

---

## Phase 3 — Interact

### US-301: DOM Event Dispatch (Click, Focus, Keyboard)

**As** P-003 Maya (keyboard power user), **I want** click, focus, blur, and keyboard events to dispatch through the DOM event model (capture → target → bubble), **so that** interactive pages respond to my input.

**Acceptance Criteria:**
- [ ] Mouse click events (mousedown, mouseup, click, dblclick) dispatch to the correct target element
- [ ] Focus and blur events fire on focusable elements with correct activeElement tracking
- [ ] Keyboard events (keydown, keyup, keypress) dispatch with correct key, code, and modifier properties
- [ ] Event propagation follows capture → target → bubble phases
- [ ] event.stopPropagation() and event.preventDefault() work correctly

**Phase:** 3 — Interact
**Priority:** P0
**Personas:** P-003, A-001, A-004

---

### US-302: Form Elements Rendering and Input

**As** P-002 Dr. Amara (researcher), **I want** HTML form elements (text input, textarea, select, checkbox, radio, button) to render and accept input, **so that** I can log into research portals and fill out search forms.

**Acceptance Criteria:**
- [ ] `<input type="text|password|email|search|url|number">` renders and accepts text input with cursor
- [ ] `<textarea>` renders with multi-line editing and scrolling
- [ ] `<select>` renders a dropdown and allows option selection
- [ ] `<input type="checkbox">` and `<input type="radio">` render and toggle state on click
- [ ] `<button>` and `<input type="submit">` render and are clickable
- [ ] Tab key moves focus between form elements in document order (respecting tabindex)

**Phase:** 3 — Interact
**Priority:** P0
**Personas:** P-002, P-003, A-004

---

### US-303: Form Submission (GET/POST)

**As** A-004 Weaver (workflow automator agent), **I want** form submission to send GET or POST requests with encoded form data, **so that** I can automate login flows and search queries.

**Acceptance Criteria:**
- [ ] Submit button or Enter key in a text field triggers form submission
- [ ] GET forms append URL-encoded data to the action URL as query parameters
- [ ] POST forms send URL-encoded data in the request body with correct Content-Type
- [ ] File inputs are excluded (file upload is out of scope for Phase 3)
- [ ] Form validation attributes (required, pattern, min/max) prevent submission and show error indicators
- [ ] Successful submission navigates to the response page

**Phase:** 3 — Interact
**Priority:** P0
**Personas:** A-004, P-002, A-001

---

### US-304: JavaScript Engine Integration

**As** P-001 Kai (tool-building developer), **I want** a JavaScript engine (boa or V8) embedded in the browser that executes `<script>` tags and inline scripts, **so that** dynamic web pages function.

**Acceptance Criteria:**
- [ ] Inline `<script>` blocks execute in document order during parsing
- [ ] External `<script src="...">` files are fetched and executed
- [ ] `defer` and `async` attributes are respected for execution timing
- [ ] Script errors are caught and reported to an internal console (not crash the browser)
- [ ] Each page gets an isolated JS execution context (no cross-page leakage)
- [ ] Global objects (window, document, navigator, location, console) are available

**Phase:** 3 — Interact
**Priority:** P0
**Personas:** P-001, A-001

---

### US-305: DOM API (Query, Create, Modify)

**As** A-001 Claude (browsing copilot agent), **I want** the standard DOM API to be available in JavaScript (querySelector, createElement, appendChild, setAttribute, textContent, innerHTML), **so that** pages that dynamically build their content work correctly.

**Acceptance Criteria:**
- [ ] document.querySelector / querySelectorAll return correct elements for CSS selectors
- [ ] document.getElementById, getElementsByClassName, getElementsByTagName work
- [ ] document.createElement creates new elements that can be appended to the DOM
- [ ] element.appendChild, removeChild, insertBefore, replaceChild modify the tree
- [ ] element.setAttribute, getAttribute, removeAttribute, classList work
- [ ] element.textContent and element.innerHTML read and write content
- [ ] DOM mutations trigger layout recalculation and repaint

**Phase:** 3 — Interact
**Priority:** P0
**Personas:** A-001, P-001, A-004

---

### US-306: Timers (setTimeout, setInterval)

**As** P-001 Kai (tool-building developer), **I want** setTimeout and setInterval to schedule callbacks, **so that** pages with timed behavior (animations, polling, debounce) function correctly.

**Acceptance Criteria:**
- [ ] setTimeout(fn, ms) fires the callback after the specified delay
- [ ] setInterval(fn, ms) fires the callback repeatedly at the specified interval
- [ ] clearTimeout and clearInterval cancel pending timers
- [ ] Timers with delay 0 fire asynchronously (after current script completes)
- [ ] Timer IDs are unique and do not collide across contexts
- [ ] Timers are cancelled when the page navigates away

**Phase:** 3 — Interact
**Priority:** P1
**Personas:** P-001, A-004

---

### US-307: fetch() API

**As** A-002 Crawler (headless data harvester agent), **I want** the JavaScript fetch() API to make HTTP requests and return responses, **so that** pages that load data dynamically (XHR/fetch) render their full content.

**Acceptance Criteria:**
- [ ] fetch(url) performs a GET request and returns a Promise resolving to a Response
- [ ] Response.json(), Response.text(), and Response.blob() parse the body
- [ ] Custom method, headers, and body are supported in the RequestInit options
- [ ] CORS preflight (OPTIONS) is sent when required; CORS errors are surfaced in console
- [ ] Network errors reject the promise (not throw synchronously)
- [ ] AbortController / AbortSignal cancels in-flight requests

**Phase:** 3 — Interact
**Priority:** P1
**Personas:** A-002, P-001, A-004

---

### US-308: Cookie Management

**As** P-005 Suki (security analyst), **I want** the browser to store, send, and manage cookies per RFC 6265, with clear inspection and control, **so that** I can audit cookie-based authentication and tracking behavior.

**Acceptance Criteria:**
- [ ] Set-Cookie response headers create cookies in the jar
- [ ] Cookies are sent on subsequent requests matching domain, path, and secure constraints
- [ ] HttpOnly cookies are not accessible from JavaScript (document.cookie)
- [ ] Secure cookies are only sent over HTTPS
- [ ] SameSite (Strict, Lax, None) is enforced
- [ ] Cookie expiry (Expires, Max-Age) is respected; session cookies clear on browser close
- [ ] A cookie inspector UI or API lists all cookies with their attributes

**Phase:** 3 — Interact
**Priority:** P1
**Personas:** P-005, A-003, P-002

---

### US-309: Clipboard Integration

**As** P-003 Maya (keyboard power user), **I want** copy, cut, and paste to work with the system clipboard for text content, **so that** I can transfer data between the browser and other applications.

**Acceptance Criteria:**
- [ ] Ctrl/Cmd+C copies selected text to the system clipboard
- [ ] Ctrl/Cmd+X cuts selected text from editable fields
- [ ] Ctrl/Cmd+V pastes clipboard content into focused editable fields
- [ ] JavaScript clipboard API (navigator.clipboard.readText/writeText) is available with permission gating
- [ ] Paste events fire on the target element with clipboardData

**Phase:** 3 — Interact
**Priority:** P1
**Personas:** P-003, P-002

---

### US-310: Keyboard Navigation and Accessibility

**As** P-004 Jordan (accessibility advocate), **I want** full keyboard navigation (Tab, Shift+Tab, Enter, Escape, arrow keys in selects/radios), **so that** the browser is usable without a mouse.

**Acceptance Criteria:**
- [ ] Tab and Shift+Tab cycle focus through all interactive elements in DOM order
- [ ] tabindex attribute overrides natural focus order
- [ ] Enter activates the focused button or link
- [ ] Escape closes dropdowns, dialogs, and menus
- [ ] Arrow keys navigate within select dropdowns and radio button groups
- [ ] Focus is never trapped in a non-modal container (unless role="dialog" with aria-modal)
- [ ] Skip-to-content link is supported when present in the page

**Phase:** 3 — Interact
**Priority:** P0
**Personas:** P-004, P-003

---

### US-311: Basic Console API

**As** P-001 Kai (tool-building developer), **I want** console.log, console.warn, console.error, and console.info to capture output to an internal log buffer, **so that** I can debug page scripts.

**Acceptance Criteria:**
- [ ] console.log/warn/error/info capture messages with log level and timestamp
- [ ] Objects are serialized to a readable format (not [object Object])
- [ ] console.clear() empties the log buffer
- [ ] Log entries are accessible via an internal API (for MCP exposure in Phase 4)
- [ ] Uncaught exceptions and promise rejections are also logged

**Phase:** 3 — Interact
**Priority:** P1
**Personas:** P-001, A-001, A-003

---

### US-312: Content Security and Script Sandboxing

**As** P-005 Suki (security analyst), **I want** JavaScript execution to be sandboxed with resource limits, **so that** malicious scripts cannot crash the browser, access the filesystem, or consume unbounded resources.

**Acceptance Criteria:**
- [ ] Script execution has a configurable CPU time limit per frame (default: 100ms)
- [ ] Memory usage per script context is bounded (default: 256MB)
- [ ] Scripts cannot access the filesystem, spawn processes, or open raw sockets
- [ ] Infinite loops are detected and terminated with a console error
- [ ] Content-Security-Policy headers are parsed and enforced (script-src at minimum)
- [ ] A per-site toggle allows disabling JavaScript entirely

**Phase:** 3 — Interact
**Priority:** P0
**Personas:** P-005, A-003, P-001

---

## Phase 4 — Connect (MCP Server)

### US-401: MCP Server Core and Transport

**As** P-001 Kai (tool-building developer), **I want** the browser to expose an MCP server over stdio and streamable-HTTP transports, **so that** AI agents can connect and control the browser programmatically.

**Acceptance Criteria:**
- [ ] MCP server starts on browser launch (configurable: --mcp-stdio, --mcp-http=:PORT)
- [ ] Server implements the MCP protocol (initialize, tool listing, tool invocation, notifications)
- [ ] Multiple MCP clients can connect simultaneously over HTTP transport
- [ ] stdio transport supports single-client mode for direct agent piping
- [ ] Server shuts down cleanly when the browser exits

**Phase:** 4 — Connect
**Priority:** P0
**Personas:** P-001, A-001, A-004

---

### US-402: DOM Query Tools

**As** A-001 Claude (browsing copilot agent), **I want** MCP tools to query the DOM (querySelector, getTextContent, getAttributes, getAccessibilityTree), **so that** I can understand page content and answer user questions about what's on screen.

**Acceptance Criteria:**
- [ ] `dom.querySelector(selector)` returns a serialized element (tag, id, classes, attributes, text)
- [ ] `dom.querySelectorAll(selector)` returns an array of matching elements (paginated for large results)
- [ ] `dom.getTextContent(selector)` returns visible text content of the matched subtree
- [ ] `dom.getAttributes(selector)` returns all attributes of the matched element
- [ ] `dom.getOuterHTML(selector)` returns the HTML markup of the matched subtree
- [ ] Selectors that match nothing return an empty result (not an error)

**Phase:** 4 — Connect
**Priority:** P0
**Personas:** A-001, A-002, A-004

---

### US-403: Navigation and Interaction Tools

**As** A-004 Weaver (workflow automator agent), **I want** MCP tools to navigate pages, click elements, fill form fields, and submit forms, **so that** I can automate multi-step web workflows end-to-end.

**Acceptance Criteria:**
- [ ] `nav.goto(url)` navigates to a URL and waits for load
- [ ] `nav.back()` and `nav.forward()` traverse session history
- [ ] `nav.reload()` reloads the current page
- [ ] `interact.click(selector)` clicks the first matching element (scrolling into view if needed)
- [ ] `interact.fill(selector, value)` clears and types into an input/textarea
- [ ] `interact.select(selector, value)` selects an option in a `<select>` element
- [ ] `interact.check(selector)` / `interact.uncheck(selector)` toggles checkboxes
- [ ] `interact.submit(formSelector)` submits a form
- [ ] All interaction tools wait for resulting navigation or DOM update before returning

**Phase:** 4 — Connect
**Priority:** P0
**Personas:** A-004, A-001, A-002

---

### US-404: Network Inspection Tools

**As** P-005 Suki (security analyst), **I want** MCP tools to inspect network activity (request log, response headers, cookies, active connections), **so that** I can audit what data the browser sends and receives.

**Acceptance Criteria:**
- [ ] `network.getRequests(filter?)` returns a list of requests with URL, method, status, headers, timing
- [ ] `network.getResponse(requestId)` returns full response headers and body (text or base64)
- [ ] `network.getCookies(domain?)` lists cookies with all attributes
- [ ] `network.setCookie(cookie)` and `network.deleteCookie(name, domain)` manage the cookie jar
- [ ] `network.getActiveConnections()` lists open HTTP/WebSocket connections
- [ ] Request log is circular-buffered (configurable max entries, default 1000)

**Phase:** 4 — Connect
**Priority:** P1
**Personas:** P-005, A-003, A-002

---

### US-405: Layout and Style Inspection Tools

**As** A-001 Claude (browsing copilot agent), **I want** MCP tools to inspect element layout (bounding box, computed styles, box model), **so that** I can describe visual positioning to users and reason about what's visible on screen.

**Acceptance Criteria:**
- [ ] `layout.getBoundingRect(selector)` returns x, y, width, height relative to viewport
- [ ] `layout.getComputedStyle(selector, properties?)` returns computed CSS values
- [ ] `layout.getBoxModel(selector)` returns content, padding, border, and margin dimensions
- [ ] `layout.isVisible(selector)` reports whether an element is visible (not display:none, not clipped, not zero-size)
- [ ] `layout.getScrollPosition()` returns viewport and document scroll offsets

**Phase:** 4 — Connect
**Priority:** P1
**Personas:** A-001, P-001

---

### US-406: Accessibility Tree Tools

**As** P-004 Jordan (accessibility advocate), **I want** MCP tools to expose the browser's accessibility tree, **so that** agents and testing tools can verify that pages are accessible.

**Acceptance Criteria:**
- [ ] `a11y.getTree(root?)` returns the full or subtree accessibility tree (role, name, state, value per node)
- [ ] `a11y.getNodeBySelector(selector)` returns the accessibility properties of a specific element
- [ ] `a11y.findByRole(role)` returns all elements with a given ARIA role
- [ ] `a11y.findByName(name)` returns elements with a given accessible name
- [ ] `a11y.checkContrast(selector)` returns foreground/background color and WCAG contrast ratio
- [ ] Tree output is serializable and diffable for regression testing

**Phase:** 4 — Connect
**Priority:** P1
**Personas:** P-004, A-001, A-003

---

### US-407: Console and Log Tools

**As** A-003 Sentinel (security/privacy monitor agent), **I want** MCP tools to read console output and subscribe to log events in real-time, **so that** I can monitor for security warnings, CSP violations, and unexpected errors.

**Acceptance Criteria:**
- [ ] `console.getEntries(level?, limit?)` returns buffered console messages
- [ ] `console.subscribe()` streams new console entries as MCP notifications
- [ ] `console.clear()` clears the console buffer
- [ ] CSP violation reports are surfaced as console entries with type "security"
- [ ] Mixed-content warnings appear as console entries with type "security"
- [ ] Entries include source URL and line number when available

**Phase:** 4 — Connect
**Priority:** P1
**Personas:** A-003, P-005, P-001

---

### US-408: Tab Management Tools

**As** A-004 Weaver (workflow automator agent), **I want** MCP tools to create, list, switch, and close browser tabs, **so that** I can run multi-page workflows and compare content across tabs.

**Acceptance Criteria:**
- [ ] `tabs.create(url?)` opens a new tab (optionally navigating to a URL)
- [ ] `tabs.list()` returns all open tabs with id, title, URL, and active status
- [ ] `tabs.switch(tabId)` makes a tab the active/focused tab
- [ ] `tabs.close(tabId)` closes a tab
- [ ] `tabs.getActive()` returns the currently active tab
- [ ] Tab events (created, closed, navigated, titleChanged) are emitted as MCP notifications

**Phase:** 4 — Connect
**Priority:** P1
**Personas:** A-004, A-001, A-002

---

### US-409: Screenshot and Visual Capture Tools

**As** A-002 Crawler (headless data harvester agent), **I want** MCP tools to capture screenshots (full page, viewport, element), **so that** I can extract visual content and provide visual context to LLMs.

**Acceptance Criteria:**
- [ ] `capture.screenshot(format?)` captures the current viewport as PNG or JPEG
- [ ] `capture.fullPage(format?)` captures the entire scrollable page
- [ ] `capture.element(selector, format?)` captures a specific element's bounding box
- [ ] Output is returned as base64-encoded data or written to a specified file path
- [ ] Capture works in both headed and headless modes
- [ ] Configurable quality for JPEG output (default: 80)

**Phase:** 4 — Connect
**Priority:** P1
**Personas:** A-002, A-001, P-001

---

### US-410: Agent Permission Model

**As** P-005 Suki (security analyst), **I want** a granular permission model that controls which MCP tools each connected agent can invoke, **so that** agents operate under least-privilege and cannot perform unauthorized actions.

**Acceptance Criteria:**
- [ ] Agents authenticate with a token or identity on MCP connection
- [ ] A permission policy maps agent identities to allowed tool namespaces (e.g., read-only, interact, network)
- [ ] Denied tool invocations return a structured error (not silently fail)
- [ ] Default policy is read-only (dom.*, layout.*, a11y.*, console.read) — interaction requires explicit grant
- [ ] Permission changes take effect immediately without server restart
- [ ] Audit log records all tool invocations with agent identity, tool name, and timestamp

**Phase:** 4 — Connect
**Priority:** P0
**Personas:** P-005, A-003

---

### US-411: Multi-Agent Coordination

**As** A-001 Claude (browsing copilot agent), **I want** the MCP server to handle multiple connected agents with conflict resolution, **so that** a copilot agent and a monitoring agent can operate on the same browser without interference.

**Acceptance Criteria:**
- [ ] Multiple agents can connect simultaneously via HTTP transport
- [ ] Read-only tools (dom.*, layout.*, a11y.*, console.*) execute concurrently without locking
- [ ] Mutating tools (interact.*, nav.*) acquire an exclusive interaction lock
- [ ] Lock requests that cannot be immediately fulfilled return a "busy" status with the holding agent's ID
- [ ] Agents can subscribe to navigation and DOM-change notifications without invoking tools
- [ ] Server reports connected agent count and identities via `server.status()` tool

**Phase:** 4 — Connect
**Priority:** P1
**Personas:** A-001, A-003, A-004

---

### US-412: MCP Tool Discovery and Documentation

**As** P-001 Kai (tool-building developer), **I want** the MCP server to provide rich tool metadata (descriptions, parameter schemas, examples), **so that** agents and developers can discover and use tools without external documentation.

**Acceptance Criteria:**
- [ ] Every tool has a human-readable description and parameter JSON Schema
- [ ] Tool listing includes categorization by namespace (dom, nav, interact, network, layout, a11y, console, tabs, capture)
- [ ] Parameter schemas use descriptive field names and include default values
- [ ] Error responses include structured error codes and human-readable messages
- [ ] A `server.version()` tool returns the browser version and supported MCP protocol version

**Phase:** 4 — Connect
**Priority:** P2
**Personas:** P-001, A-001
