# Phase 0 — Shell: User Stories

> TUI browser shell — URL bar, tab management, request/response viewer, raw HTML display.

---

### US-001: Navigate to a URL

**As** P-001 Kai (tool-building developer), **I want** to type a URL into an input bar and press Enter to issue an HTTP/HTTPS request, **so that** I can fetch and view web content without leaving the terminal.

**Acceptance Criteria:**
- [ ] URL bar accepts text input and submits on Enter
- [ ] HTTP and HTTPS schemes are supported; bare domains default to `https://`
- [ ] The fetched response body is displayed in the content pane
- [ ] Invalid URLs produce a clear inline error (not a crash)

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-001, P-003

---

### US-002: Display Raw HTML

**As** P-002 Dr. Amara (researcher), **I want** the fetched HTML source displayed verbatim in the content pane, **so that** I can inspect page structure before any rendering engine exists.

**Acceptance Criteria:**
- [ ] Raw HTML is displayed with preserved whitespace and indentation
- [ ] Content pane is scrollable (vertical at minimum)
- [ ] Large documents (>1 MB) load without freezing the TUI
- [ ] UTF-8 content renders correctly; other charsets show a warning

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-002, P-001

---

### US-003: Open a New Tab

**As** P-003 Maya (keyboard power user), **I want** to open a new tab with a keybinding, **so that** I can have multiple pages loaded simultaneously without losing context.

**Acceptance Criteria:**
- [ ] A keybinding (default: `Ctrl+T`) opens a new empty tab with focus on the URL bar
- [ ] Tab bar updates immediately to show the new tab
- [ ] New tabs are appended to the right of the current tab
- [ ] Tab count is displayed somewhere visible (tab bar or status line)

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-003, P-001

---

### US-004: Close a Tab

**As** P-003 Maya (keyboard power user), **I want** to close the current tab with a keybinding, **so that** I can dismiss pages I no longer need without reaching for a mouse.

**Acceptance Criteria:**
- [ ] A keybinding (default: `Ctrl+W`) closes the active tab
- [ ] Focus moves to the next tab, or the previous tab if the closed tab was last
- [ ] Closing the last tab exits the browser (or opens a blank tab, configurable)
- [ ] No confirmation prompt for closing tabs in Phase 0

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-003, P-001

---

### US-005: Switch Between Tabs

**As** P-003 Maya (keyboard power user), **I want** to switch between tabs using keyboard shortcuts, **so that** I can move fluidly between multiple pages.

**Acceptance Criteria:**
- [ ] `Ctrl+Tab` / `Ctrl+Shift+Tab` cycle forward/backward through tabs
- [ ] `Alt+1` through `Alt+9` jump to tab by position (1-indexed)
- [ ] Active tab is visually highlighted in the tab bar
- [ ] Switching tabs restores scroll position of the destination tab

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-003, A-001

---

### US-006: List All Open Tabs

**As** A-001 Claude (browsing copilot agent), **I want** to retrieve a list of all open tabs with their URLs and titles, **so that** I can reason about what the user has open and suggest relevant actions.

**Acceptance Criteria:**
- [ ] A command or keybinding displays a tab list overlay (index, URL, title/status)
- [ ] The list is navigable and selecting an entry switches to that tab
- [ ] The same data is available programmatically via MCP `tabs/list` tool
- [ ] Tabs are ordered by position, not most-recently-used

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** A-001, P-003, P-001

---

### US-007: Inspect Response Headers and Status Code

**As** P-005 Suki (security analyst), **I want** to view the HTTP response status code, headers, and timing for the current page, **so that** I can audit server behavior, caching policy, and security headers.

**Acceptance Criteria:**
- [ ] A toggleable inspector pane shows: status code, reason phrase, all response headers
- [ ] Request timing is displayed (DNS, connect, TLS handshake, TTFB, total)
- [ ] Headers are displayed as `Name: Value` pairs, preserving original casing
- [ ] Inspector pane can be opened with a keybinding (default: `F12` or `Ctrl+I`)

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-005, P-001, A-003

---

### US-008: Inspect Request Details

**As** P-005 Suki (security analyst), **I want** to view the outgoing HTTP request (method, URL, headers sent), **so that** I can verify what the browser transmitted and debug request issues.

**Acceptance Criteria:**
- [ ] The inspector pane includes a "Request" section showing method, URL, and all sent headers
- [ ] User-Agent and other auto-injected headers are visible
- [ ] Request and response sections are independently scrollable
- [ ] Copy-to-clipboard works for individual headers or the full request block

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** P-005, P-001

---

### US-009: Handle DNS Failures Gracefully

**As** P-004 Jordan (accessibility advocate), **I want** DNS resolution failures to produce a clear, readable error page in the content pane, **so that** I understand what went wrong without deciphering a stack trace.

**Acceptance Criteria:**
- [ ] DNS failures display an error page with: the failing domain, error type, and a suggestion
- [ ] The error page is navigable (URL bar remains editable for retry)
- [ ] Screen readers can parse the error content (plain text, no raw ANSI artifacts)
- [ ] The tab title updates to reflect the error state (e.g., "Error — example.invalid")

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-004, P-003

---

### US-010: Handle Connection Timeouts

**As** P-001 Kai (tool-building developer), **I want** connection and read timeouts to be configurable and to surface clearly, **so that** I can diagnose slow or unresponsive servers.

**Acceptance Criteria:**
- [ ] Default connect timeout: 10 seconds; default read timeout: 30 seconds
- [ ] Timeouts are configurable via config file
- [ ] Timeout errors display elapsed time and which phase timed out (connect vs. read)
- [ ] A loading indicator is visible while a request is in-flight

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** P-001, A-002

---

### US-011: Handle TLS Errors

**As** P-005 Suki (security analyst), **I want** TLS certificate errors to be clearly reported with details (expiry, CN mismatch, self-signed), **so that** I can assess the risk before deciding whether to proceed.

**Acceptance Criteria:**
- [ ] TLS errors display: error type, certificate subject, issuer, expiry date
- [ ] The user is not silently redirected or allowed to proceed without acknowledgment
- [ ] A `--insecure` flag or config option exists for development use (disabled by default)
- [ ] TLS error details are available in the inspector pane

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** P-005, A-003

---

### US-012: Follow Redirects

**As** A-002 Crawler (headless data harvester agent), **I want** HTTP redirects (301, 302, 307, 308) to be followed automatically up to a configurable limit, **so that** I reach final destinations without manual intervention.

**Acceptance Criteria:**
- [ ] Redirects are followed automatically (default limit: 10 hops)
- [ ] The URL bar updates to the final URL after redirects
- [ ] The inspector pane shows the full redirect chain (each hop with status and Location header)
- [ ] Redirect limit is configurable; exceeding it produces a clear error

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** A-002, P-001

---

### US-013: In-Session History

**As** P-003 Maya (keyboard power user), **I want** back/forward navigation within a tab's session history, **so that** I can retrace my steps without re-typing URLs.

**Acceptance Criteria:**
- [ ] `Alt+Left` / `Alt+Right` (or configurable) navigate back/forward in per-tab history
- [ ] History stack tracks URLs visited within a tab during the current session
- [ ] Back/forward buttons are visually indicated as enabled/disabled in the status line
- [ ] History is per-tab and not persisted across sessions in Phase 0

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** P-003, P-001

---

### US-014: Keyboard-Driven Focus Management

**As** P-004 Jordan (accessibility advocate), **I want** clear, predictable keyboard focus cycling between the URL bar, tab bar, content pane, and inspector, **so that** I can operate the browser entirely without a pointing device.

**Acceptance Criteria:**
- [ ] `Tab` / `Shift+Tab` cycle focus between major UI regions
- [ ] The focused region has a visible border or highlight indicator
- [ ] `Escape` returns focus to the content pane from any input field
- [ ] Focus order is logical: URL bar -> content pane -> inspector (if open)

**Phase:** 0 — Shell
**Priority:** P0
**Personas:** P-004, P-003

---

### US-015: Headless Mode (No TUI)

**As** A-002 Crawler (headless data harvester agent), **I want** to start the browser in headless mode with no TUI rendering, **so that** I can drive it purely through MCP tools or CLI flags for automated data collection.

**Acceptance Criteria:**
- [ ] `--headless` flag starts the browser without initializing the TUI
- [ ] In headless mode, navigation is driven via MCP tool calls or CLI subcommands
- [ ] stdout output is structured (JSON) for machine consumption
- [ ] Exit codes reflect success (0), navigation error (1), or argument error (2)

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** A-002, A-004, P-001

---

### US-016: Basic MCP Server Startup

**As** A-001 Claude (browsing copilot agent), **I want** the browser to start an MCP server exposing navigation and page-content tools, **so that** I can programmatically navigate to URLs and read page source.

**Acceptance Criteria:**
- [ ] `--mcp` flag starts an MCP server on stdio transport (default) or SSE (configurable)
- [ ] Minimum tool surface: `navigate`, `get_page_source`, `get_url`, `tabs/list`, `tabs/open`, `tabs/close`
- [ ] MCP server is available in both TUI and headless modes
- [ ] Tool responses use structured JSON with consistent error schemas

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** A-001, A-002, A-004

---

### US-017: Configurable Keybindings

**As** P-003 Maya (keyboard power user), **I want** to remap keybindings via a config file, **so that** I can match my muscle memory from other tools.

**Acceptance Criteria:**
- [ ] Keybindings are defined in a TOML or YAML config file (e.g., `~/.config/therobotbrowses/keys.toml`)
- [ ] All default bindings are overridable
- [ ] Invalid key definitions produce a startup warning, not a crash
- [ ] A `--dump-keybindings` flag prints the active keymap to stdout

**Phase:** 0 — Shell
**Priority:** P2
**Personas:** P-003, P-004

---

### US-018: Status Bar with Connection Info

**As** P-001 Kai (tool-building developer), **I want** a persistent status bar showing connection state, current URL, and request status, **so that** I have ambient awareness of what the browser is doing.

**Acceptance Criteria:**
- [ ] Status bar is always visible at the bottom of the TUI
- [ ] Displays: current URL (truncated if needed), HTTP status code, TLS lock indicator
- [ ] Shows a spinner or progress indicator during active requests
- [ ] Shows "Disconnected" / "Error" states distinctly from successful loads

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** P-001, P-003

---

### US-019: Reload Current Page

**As** P-002 Dr. Amara (researcher), **I want** to reload the current page with a keybinding, **so that** I can re-fetch content that may have changed without re-typing the URL.

**Acceptance Criteria:**
- [ ] `F5` or `Ctrl+R` re-fetches the current URL
- [ ] Scroll position resets to top on reload
- [ ] The inspector pane updates with the new request/response data
- [ ] Reload is a no-op on empty tabs or error pages with no URL

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** P-002, P-003

---

### US-020: Graceful Shutdown and Cleanup

**As** A-004 Weaver (workflow automator agent), **I want** the browser to shut down cleanly when receiving SIGINT/SIGTERM or when the last tab closes, **so that** I can orchestrate browser lifecycle in automated pipelines without orphaned processes.

**Acceptance Criteria:**
- [ ] `Ctrl+C` or SIGTERM triggers graceful shutdown (close connections, flush state)
- [ ] MCP server sends clean shutdown notification to connected clients before exit
- [ ] No zombie processes or leaked file descriptors after exit
- [ ] Exit within 3 seconds of signal; force-kill after 5 seconds

**Phase:** 0 — Shell
**Priority:** P1
**Personas:** A-004, A-002, P-001
